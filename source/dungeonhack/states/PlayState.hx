package dungeonhack.states;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxSort;

import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;

import nape.constraint.PivotJoint;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyList;
import nape.phys.BodyType;
import nape.shape.Shape;
import nape.phys.Material;
import nape.geom.AABB;

import dungeonhack.characters.*;
import dungeonhack.characters.Enemies;
import dungeonhack.ui.*;
import dungeonhack.sound.*;
import dungeonhack.maps.TiledLevel;

class PlayState extends FlxState
{

  private var player:Player;
	private var screenUi: ScreenUI;
  public var level:TiledLevel;

	private var enemies: Array<Enemy>;
	private var entities: FlxGroup;


	private var  levelCollisionSprite:FlxNapeSprite;

	public var deadObjectsLayer: FlxTypedGroup<FlxSprite>;

	public var playerSpawn: FlxPoint;
	public var enemySpawn: Array<FlxPoint>;

  private var random: FlxRandom;

  override public function create():Void
	{
		random = new FlxRandom();
    enemies = new Array<Enemy>();
    entities = new FlxGroup();
		FlxG.camera.width = FlxG.width+128;
		FlxG.camera.height = FlxG.height+128;
		FlxG.camera.setPosition(-64, -64);
		FlxG.camera.zoom = 1.5;
		PopText.currentState = this;

    FlxNapeSpace.init();
		FlxNapeSpace.space.gravity = new Vec2(0, 0);
    //FlxNapeSpace.drawDebug = true;
    		
		levelCollisionSprite = new FlxNapeSprite(0, 0, null, false, true);
		deadObjectsLayer = new FlxTypedGroup<FlxSprite>();
  }


  private function setLevelMap(mapPath: String): Void {
    level = new TiledLevel("assets/tiled/Dungeon1.tmx");
		addCollisionMeshesToSpace();
		playerSpawn = getPlayerStartingLocation();
    // Add backgrounds
		add(level.backgroundLayer);
		
		// Add static images
    //	add(level.imagesLayer);
		add(deadObjectsLayer);
		add(level.objectsLayer);
  }
  

	private function getPlayerStartingLocation():FlxPoint {
		var start = new FlxPoint(500, 500);

		if(level.playerSpawns.length > 0) {
			start = randomPointInBounds(level.playerSpawns[random.int(0,level.playerSpawns.length-1)].bounds);
		}
		return start;
	}

	private function getEnemyStartingLocation():FlxPoint {
		var start = new FlxPoint(500, 500);

		if(level.spawnMeshes.length > 0) {
			start = randomPointInBounds(level.spawnMeshes[random.int(0, level.spawnMeshes.length-1)].bounds);
		}
		return start;
	}

	private function randomPointInBounds(bounds: AABB): FlxPoint {
		var point = new FlxPoint(bounds.x, bounds.y);
		point.x += random.float(0, bounds.width);
		point.y += random.float(0, bounds.height);
		return point;
	}


  private function setPlayer(thePlayer: Player): Void {
    if(level == null) {
      throw "Must load level before setting player";
    }
    player = thePlayer;
		player.setPosition(playerSpawn.x,playerSpawn.y);
		level.objectsLayer.add(player);
    SoundGlobal.soundListener = player;
    	// Add foreground tiles after adding level objects, so these tiles render on top of player
		FlxG.camera.follow(player, FlxCameraFollowStyle.TOPDOWN_TIGHT);
		screenUi = new ScreenUI(player);
		add(screenUi);
  }

	private function addCollisionMeshesToSpace():Void {
		var levelCollisions = new Body(BodyType.STATIC);
		var levelSpawns = new Body(BodyType.STATIC);
		
		for(shape in level.collisionMeshes) {
			shape.body = levelCollisions;
		}
		for(shape in level.playerSpawns) {
			shape.body = levelSpawns;
		}
		for(shape in level.spawnMeshes) {
			shape.body = levelSpawns;
	
		}
		levelCollisions.setShapeMaterials(new Material(0.4, 0.2, 0.38, 0.7)); // these values from FlxNapeSpace createWalls
		levelCollisions.space = FlxNapeSpace.space;
		levelCollisionSprite.addPremadeBody(levelCollisions);
	}

  private function addEnemy(enemy:Enemy, ?enemyStartLocation:FlxPoint) {
    enemyStartLocation = (enemyStartLocation != null) ? enemyStartLocation : getEnemyStartingLocation();
    enemy.setPosition(enemyStartLocation.x,enemyStartLocation.y);
		enemy.setNavigtaionTileMap(level.navigationMap);
		enemy.target = player;
		enemy.name = Type.getClassName(Type.getClass(enemy))+" "+enemies.length;
		level.objectsLayer.add(enemy);
		enemies.push(enemy);
  }


  private function getQuit():Bool {
    var exit = FlxG.keys.anyJustPressed([ESCAPE]);
    if(!exit && FlxG.gamepads.lastActive != null) {
      var gp = FlxG.gamepads.lastActive;
      exit = gp.anyJustPressed([FlxGamepadInputID.BACK]);
    }

    return exit;
  }

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

    if(getQuit()) {
      FlxG.switchState(new TitleState());
    }
    
    if(level == null) {
      return;
    }

    var deadSprites = new Array<FlxSprite>();

		for(sprite in level.objectsLayer) {
			if(!sprite.alive) {
				deadObjectsLayer.add(sprite);
				deadSprites.push(sprite);
			}
		}

		//Then I'm removing scheduled objects from FlxGroup
		if (deadSprites.length > 0) {
			for (sprite in deadSprites) {
				level.objectsLayer.remove(sprite, true);
			}
		}

		level.objectsLayer.sort(sortByY);
  }


	private function sortByY(Order:Int, Obj1:FlxSprite, Obj2:FlxSprite):Int 
	{
		return FlxSort.byValues(Order,Obj1.y+Obj1.origin.y, Obj2.y+Obj2.origin.y);
	}

}