package dungeonhack.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxRandom;
import flixel.math.FlxPoint;
import flixel.util.FlxSort;

import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;

import flixel.addons.ui.FlxUIState;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.geom.AABB;

import dungeonhack.characters.*;
import dungeonhack.ui.*;
import dungeonhack.sound.*;
import dungeonhack.util.*;
import dungeonhack.maps.*;

class PlayState extends FlxUIState
{

  private var player:Player;
	private var screenUi: ScreenUI;
  public var level:TiledLevel;

	private var enemies: Array<Enemy>;
	private var entities: FlxGroup;


	private var levelCollisionSprite:FlxNapeSprite;
  private var levelCollisions:Body;// = new Body(BodyType.STATIC);
  private var levelSpawns:Body; //= new Body(BodyType.STATIC);
  private var levelCollisionMaterial:Material;

	public var deadObjectsLayer: FlxTypedGroup<FlxSprite>;

	public var playerSpawn: FlxPoint;
	public var enemySpawn: Array<FlxPoint>;

  private var random: FlxRandom;

  private var roomPlacer: RoomPlacer;

  override public function create():Void
	{
		random = new FlxRandom();
    enemies = new Array<Enemy>();
    entities = new FlxGroup();
		FlxG.camera.zoom = 1.5;
    PopText.currentState = this;

    FlxNapeSpace.init();
		FlxNapeSpace.space.gravity = new Vec2(0, 0);
   
		levelCollisionSprite = new FlxNapeSprite(0, 0, null, false, true);
    levelSpawns = new Body(BodyType.STATIC);
    levelCollisions = new Body(BodyType.STATIC);
    levelCollisionMaterial = new Material(0.4, 0.2, 0.38, 0.7);

    deadObjectsLayer = new FlxTypedGroup<FlxSprite>();

    level = new TiledLevel();

     // Add backgrounds
		add(level.backgroundLayer);
		
		// Add static images
    //	add(level.imagesLayer);
		add(deadObjectsLayer);
		add(level.objectsLayer);
    roomPlacer = new RoomPlacer();
  }

  private function addLevelMap(mapPath: String, ?X:Int = 0, ?Y:Int=0): Void {
    trace('Adding ${mapPath} at $X,$Y');
    
    level.addTiledMap(mapPath, X, Y);
		setCollisionMeshesToSpace();
		playerSpawn = getPlayerStartingLocation();
   
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

	private function setCollisionMeshesToSpace():Void {
    trace("Setting collisions - Total collsion meshes: "+level.collisionMeshes.length);
    
    levelCollisions.space = null;
    levelSpawns.space = null;
		
		
		for(shape in level.collisionMeshes) {
			if(shape.body == null) {
        shape.body = levelCollisions;
        shape.material = levelCollisionMaterial;
      }
		}
		for(shape in level.playerSpawns) {
			if(shape.body == null) {
        shape.body = levelSpawns;
        shape.material = levelCollisionMaterial;
      }
		}
		for(shape in level.spawnMeshes) {
			if(shape.body == null) {
        shape.body = levelSpawns;
      }
		}

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


  private function doQuit():Void {
    FlxG.switchState(new TitleState());
  }

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

    if(CheckInput.check([ESCAPE], [FlxGamepadInputID.BACK])) {
      doQuit();
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