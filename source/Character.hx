package;

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


class Character extends FlxNapeSprite
{
  public var maxSpeed:Float = 200;
  public var pointing:MoveInput;

  private var navigationTileMap: FlxTilemap =null;
  private var distanceToTargetThreshold: Float = 50;


  public function new(maxSpeedVal:Float=200, X:Float=0, Y:Float=0, ?characterSpriteSheet:FlxGraphicAsset, spriteWidth:Int=128, spriteHeight:Int=128)
  {
      super(X, Y, null, false, true);
      pointing = new MoveInput();
      loadGraphic(characterSpriteSheet, true, spriteWidth, spriteHeight);
      origin.set(spriteWidth/2,spriteHeight*0.75);
      createCircularBody(10);
      setBodyMaterial(0,1, 0.8, 1, 0.01);
      body.space = FlxNapeSpace.space;
      body.allowMovement = true;
      body.allowRotation = false;
      
      maxSpeed = maxSpeedVal;
      addAnimation("idle", 0, 4, true);
      addAnimation("move", 4, 8);
  }
  
  override public function update(elapsed:Float):Void
  {
     super.update(elapsed);
  }

  public function addAnimation(name:String, start:Int, numberOfFrames:Int, pingPong: Bool = false)
  {
    var directions = ["l", "ul", "u", "ur", "r", "dr", "d", "dl"];
    for(i in 0...8) {
      var animName = name+"_"+directions[i];
      var animStart:Int = start+i*32;
      var animEnd:Int = start+numberOfFrames+i*32;

      var frames = [for (j in animStart...animEnd) j];

      if(pingPong) {
        frames = frames.concat([for (j in 0...(animEnd-animStart)) animEnd-1-j]);
      }
      animation.add(animName, frames, 10, false);
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

  public function findPathTo(destination:FlxPoint): Array<FlxPoint>
  {
    if(navigationTileMap == null) {
      trace("no nav map!");
      return null;
    }
    var position = body.position;
    
    var vecToTarget:Vec2  = new Vec2(destination.x, destination.y).sub(position); 
    var rayToTarget = new Ray(position, vecToTarget);

    // perform a ray cast using our nape's space instance
    // to determine line of site
    var rayResult:RayResult = FlxNapeSpace.space.rayCast(rayToTarget);

    if (rayResult != null)
    {
      var distanceDelta = Math.abs(rayResult.distance - vecToTarget.length);

      if(rayResult.distance < distanceToTargetThreshold){
      //  trace("too close!");
        return null;
      }
      else if(distanceDelta< 20 ) {
        var points = new Array<FlxPoint>();
        points.push(destination);
        return points;
      }
    }
    //trace("No line of site to Target");
    return null;//navigationTileMap.findPath(new FlxPoint(position.x, position.y), destination, false, false, FlxTilemapDiagonalPolicy.NORMAL);
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
    if(direction != null && (!direction.isEmpty()))
    {
      pointing = direction;
      direction.setDirectionAndAngle(this);
      var angleRad = direction.angle;
     
      body.velocity.set(new nape.geom.Vec2(getNormalizedSpeed(elapsed, speedPercentage), 0));
      body.velocity.rotate(angleRad);
      playAnimation("move");
    } 
    else {
      body.velocity.set(new nape.geom.Vec2(0, 0));
      
      playAnimation("idle");
    }
  
  }

}