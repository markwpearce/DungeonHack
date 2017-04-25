package dungeonhack.characters;

import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap;
import nape.geom.Ray;
import nape.geom.RayResult;
import nape.geom.Vec2;
import nape.shape.ShapeList;
import flixel.util.FlxColor;

import dungeonhack.ui.PopText;
import dungeonhack.sound.*;

typedef WeaponStats = {
  cooldown: Float, //seconds
  maxDamage: Float, //maxDamage
  distance: Float, //pixels
  critChance: Float, //chance of double damage
  missChance: Float, //chance of no damage
};

enum CharacterType {
  ENEMY;
  PLAYER;
  NPC;
}

enum LineOfSiteResult {
  NO_LOS;
  SEES;
  CLOSE;
}

typedef RollResult = {
  damage: Int,
  miss: Bool,
  critical: Bool
}


class Character extends FlxNapeSprite
{
  public var maxSpeed:Float = 200;
  
  public var pointing:MoveInput;

  private var navigationTileMap: FlxTilemap =null;
  static private var distanceToTargetThreshold: Float = 50;


  private var cooldowns: Map<String, Float>;

  private var animFPS:Int = 10;
  private var waitForAnimationToFinish:Bool = false;

  private var meleeStats: WeaponStats;

  public var name:String;
  
  public var type: CharacterType;

  public var maxHealth:Int = 20;

  private var wasAliveLastFrame:Bool = true;
  public var level= 1;

  public var spriteTileSize = 128;

  public var soundPlayer: SoundPlayer;
  public var quietSoundPlayer: SoundPlayer;
  public var walkSounds: SoundCycler;
  public var meleeSounds: SoundCycler;
  public var hurtSounds: SoundCycler;

  public var spriteRowCount:Int;
  

  public function new(cType:CharacterType, maxHealthVal:Int=20, maxSpeedVal:Float=200, X:Float=0, Y:Float=0,
    ?characterSpriteSheet:FlxGraphicAsset, spriteWidth:Int=128, spriteHeight:Int=128, spriteRowCount:Int=32)
  {
    super(X, Y, null, false, true);
    type = cType;
    pointing = new MoveInput();
    this.spriteRowCount = spriteRowCount;
    loadGraphic(characterSpriteSheet, true, spriteWidth, spriteHeight);
    origin.set(spriteWidth/2,spriteHeight*0.75);
    soundPlayer = new SoundPlayer(this);
    quietSoundPlayer = new SoundPlayer(this, dungeonhack.sound.SoundGlobal.quietSoundEffectsGroup);
    meleeSounds = new SoundCycler(soundPlayer);
    walkSounds = new SoundCycler(quietSoundPlayer, [], 500);
    hurtSounds = new SoundCycler(soundPlayer);
    
  
    setUpPhysics();

    maxHealth = maxHealthVal;
    health = maxHealth;

    
    for(shape in body.shapes) {
      shape.userData.transparent = true; // characters can see through other charcters
      shape.userData.character = this;
    }

    cooldowns = ["melee" => 0];
    setMelee();
    maxSpeed = maxSpeedVal;

    setUpAnimations();
    setUpSounds();
    setUpWalkSounds();
  }

  public function setUpPhysics() {
    createCircularBody(10);
    setBodyMaterial(0,1, 0.8, 1, 0.01);
    body.space = FlxNapeSpace.space;
    body.allowMovement = true;
    body.allowRotation = false;
  } 

  public function setUpAnimations() {
    addAnimation("idle", 0, 4, true);
    addAnimation("move", 4, 8);
    addAnimation("melee", 12, 4);
    addAnimation("hit", 18, 2);
    addAnimation("die", 18, 6);
  }

  public function setUpWalkSounds() {
     walkSounds.add(AssetPaths.slime2__wav);
     walkSounds.add(AssetPaths.slime3__wav);
     walkSounds.add(AssetPaths.slime4__wav);
     walkSounds.add(AssetPaths.slime5__wav);
     walkSounds.add(AssetPaths.slime6__wav);
  }

  public function setUpSounds() {
     //nothing
  }

  public function onKilledSomething(entity: Character) {
    //nothing
  }

  public function onDied() {
    playAnimation("die");
    physicsEnabled  =false;
  }

  override public function hurt(damage: Float) {
    health -= damage;
    health = Math.round(health);
    health = Math.max(0, health);
    hurtSounds.play();
    if(health == 0) {
      alive = false;
    }
    waitForAnimationToFinish= true;
    playAnimation("hit");
  }

  public function heal(bonus: Float):Void {
    if(!alive) return;
    health += bonus;
    health = Math.round(health);
    health = Math.min(maxHealth, health);
  }
  


  


  private function applyCooldown(elapsed:Float): Void 
  {
    for (key in cooldowns.keys()) {
      if(cooldowns[key] > 0) {
        cooldowns[key] = Math.max(0, cooldowns[key]-elapsed);
      } 
    }
  }


  public function setMelee(_cooldown: Float= 0.5, _maxDamage: Float = 10, _distance:Float = 50, _critChance:Float = 0.05, _missChance:Float =0.1) {
    meleeStats = {
      cooldown: _cooldown,
      maxDamage: _maxDamage,
      distance: _distance,
      critChance: _critChance,
      missChance:_missChance
    };
  }

  /*  Damage is 0 if miss
      is between 0.25*maxDamage and maxDamage
      double if crit
  */
  public function rollForDamage(stats: WeaponStats):RollResult {
    if(Math.random() < stats.missChance) {
      return {damage: 0, critical: false, miss: true};
    }
    var crit = (Math.random() < stats.critChance);
    var damage = Math.random()*(stats.maxDamage);
    damage = Math.max(damage, stats.maxDamage/4)+level*1.5;
    if(crit) {
      damage = Math.max(damage, stats.maxDamage/2);
      damage *= 2;
    }
    return {damage: Math.round(damage), critical: crit, miss: false};
  }
  
  override public function update(elapsed:Float):Void
  {
     if(!alive) {
       body.velocity.set(new nape.geom.Vec2(0, 0));
     }
     
     if(wasAliveLastFrame && !alive) {
       onDied();
     }
     
     applyCooldown(elapsed);
     super.update(elapsed);
     wasAliveLastFrame = alive;
  }

  public function addAnimation(name:String, start:Int, numberOfFrames:Int, pingPong: Bool = false)
  {
    var directions = ["l", "ul", "u", "ur", "r", "dr", "d", "dl"];
    for(i in 0...8) {
      var animName = name+"_"+directions[i];
      var animStart:Int = start+i*spriteRowCount;
      var animEnd:Int = start+numberOfFrames+i*spriteRowCount;

      var frames = [for (j in animStart...animEnd) j];

      if(pingPong) {
        frames = frames.concat([for (j in 0...(animEnd-animStart)) animEnd-1-j]);
      }
      animation.add(animName, frames, animFPS, false);
    }
  }

  public function getBodyPosition(?vec:Vec2): FlxPoint 
  {
    if(vec != null) {
      return  new FlxPoint(vec.x, vec.y);
    }
    return new FlxPoint(body.position.x, body.position.y);
  }

  public function setNavigtaionTileMap(map: FlxTilemap) {
    navigationTileMap = map;
  }

  public function seesTargetSprite(target: FlxNapeSprite, thresholdDistance: Float = -1): LineOfSiteResult {
    return seesTarget(getBodyPosition(target.body.position), thresholdDistance);
  }
   

  public function seesTarget(currentTargetPostion: FlxPoint, thresholdDistance: Float = -1): LineOfSiteResult {
    if(thresholdDistance < 0) {
      thresholdDistance = distanceToTargetThreshold;
    }
    var position = body.position;
    
    var vecToTarget:Vec2  = new Vec2(currentTargetPostion.x, currentTargetPostion.y).sub(position); 
    var rayToTarget = new Ray(position, vecToTarget);

    var rayResult:RayResult = FlxNapeSpace.space.rayCast(rayToTarget);

    if (rayResult != null)
    {
      var distanceDelta = Math.abs(rayResult.distance - vecToTarget.length);
      if(rayResult.distance <= thresholdDistance+5 &&
        rayResult.shape.body.position.x == currentTargetPostion.x &&
        rayResult.shape.body.position.y == currentTargetPostion.y) {
        //  we're already close enough
        return LineOfSiteResult.CLOSE;
      }
      else if(distanceDelta< thresholdDistance ) {
        return LineOfSiteResult.SEES;
      }
    }
    return LineOfSiteResult.NO_LOS;

  }

  public function findPathToSprite(target:FlxNapeSprite, thresholdDistance: Float = -1): Array<FlxPoint> {
    return findPathTo(getBodyPosition(target.body.position), thresholdDistance);
  }
  

  public function findPathTo(destination:FlxPoint,thresholdDistance: Float = -1): Array<FlxPoint>
  {
    if(navigationTileMap == null) {
      trace("no nav map!");
      return null;
    }
   
    var losResult = seesTarget(destination,thresholdDistance);
   
    switch(losResult) {
      case LineOfSiteResult.SEES: {
        //this gets me within the threshold
        var points = new Array<FlxPoint>();
        points.push(destination);
        return points;
      }
      case LineOfSiteResult.CLOSE: {
        //already within the threshold
        return null;
      }
      default: {
      }
    }
    var position = getBodyPosition();
    var path =  navigationTileMap.findPath(new FlxPoint(position.x, position.y), destination, false, false, FlxTilemapDiagonalPolicy.NORMAL);
    return path;
    
  }

  public function playAnimation(name:String)
  {
    var direction = "";
    if(pointing.up) direction += "u";
    else if(pointing.down) direction += "d";
    if(pointing.left) direction += "l";
    else if(pointing.right) direction += "r";

    var animationName = "";
    if(direction.length  == 0)
    {
      animationName = "idle_l";
    }
    else {
      animationName = name+"_"+direction;
    }

    if(animation.getByName(animationName) != null) {
      animation.play(animationName);
    }
  }

  public function getNormalizedSpeed(elapsed: Float, speedPercentage:Float=1.0): Float {
    return maxSpeed*60*elapsed*speedPercentage;
  }

  public function characterMove(elapsed: Float, ?direction:MoveInput, speedPercentage: Float = 1.0) {
    if(!alive) {
      return;
    }
    
    if(waitForAnimationToFinish) {
      if(animation.finished) {
        waitForAnimationToFinish = false;
      }
      else {
        return;
      }
    }
    if(direction != null && (!direction.isEmpty()))
    {
      pointing = direction;
      direction.setDirectionAndAngle(this);
      var angleRad = direction.angle;
      speedPercentage = Math.max(0, Math.min(direction.magnitude, speedPercentage));
      body.velocity.set(new nape.geom.Vec2(getNormalizedSpeed(elapsed, speedPercentage), 0));
      body.velocity.rotate(angleRad);
      pointing.angle = angleRad;
      walkSounds.play();
      playAnimation("move");
    } 
    else {
      body.velocity.set(new nape.geom.Vec2(0, 0));
      playAnimation("idle");
    }
  
  }

  public function checkIfCool(key: String, coolDownTime:Float = 0.5, animate:Bool=false): Bool
  {
    if(cooldowns[key] <= 0) {
      if(animate) {
        playAnimation(key);
        cooldowns[key] = coolDownTime;
        body.velocity.set(new nape.geom.Vec2(0, 0));
        waitForAnimationToFinish = true;
      }
      return true;
    }
    return false;
  }


  public function characterMelee():Bool {
    if(!alive || waitForAnimationToFinish) {
      return false;
    }   
    
    var meleed = checkIfCool("melee", meleeStats.cooldown, true);
    
    if(!meleed) {
      return false;
    }

    //check forward direction for enemies
    var forwardVector = new Vec2(1, 0);

    var middleOfHitZone = body.position.add(forwardVector.rotate(pointing.angle).mul(meleeStats.distance/2));
    var shapes:ShapeList = FlxNapeSpace.space.shapesInCircle(middleOfHitZone, meleeStats.distance/2);
    
    meleeSounds.play();
    var hitCharacters = new Array<Character>();
    for(shape in shapes) {
      var entity:Character  = shape.userData.character;
      if(entity != null && type == CharacterType.PLAYER && shape.userData.enemy) {
        if(hitCharacters.indexOf(entity) == -1) {
          hitCharacters.push(entity);
        }
      }
      else if(entity != null && type == CharacterType.ENEMY && shape.userData.player) {
        if(hitCharacters.indexOf(entity) == -1) {
          hitCharacters.push(entity);
        }
      }
    }
    
    //trace("Hits: "+hitCharacters.length);
    for(entity in hitCharacters) {
        //roll for damage on each
        var damageRoll = rollForDamage(meleeStats);
        if(damageRoll.miss) {
          //trace(name + " missed  "+entity.name);
        }
        else {
          PopText.show(entity.getBodyPosition(), ""+damageRoll.damage, FlxColor.RED);
          //trace(name + (damageRoll.critical ? " *HIT* ": " hit ")+entity.name+" for "+damageRoll.damage);
          entity.hurt(damageRoll.damage);
          if(!entity.alive) {
            onKilledSomething(entity);
          }
        }
              
    }
    return meleed;

  }


}