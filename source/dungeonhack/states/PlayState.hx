package dungeonhack.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.math.FlxPoint;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.util.FlxSort;
import flixel.FlxBasic;
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

import flixel.group.FlxGroup;

class PlayState extends FlxState
{
	private var _player:Player;
	private var screenUi: ScreenUI;

	private var enemies: Array<Enemy>;
	public var _level:TiledLevel;

	private var entities:FlxGroup;

	private var random: FlxRandom;

	private var  levelCollisionSprite:FlxNapeSprite;

	public var deadObjectsLayer: FlxTypedGroup<FlxSprite>;

	public var playerSpawn: FlxPoint;
	public var enemySpawn: Array<FlxPoint>;

	public var gameLength: Float = 10;


	private var enemiesByLevel: Array< Array< String > >;


	override public function create():Void
	{
		entities = new FlxGroup();
		FlxG.camera.width = FlxG.width+128;
		FlxG.camera.height = FlxG.height+128;
		FlxG.camera.setPosition(-64, -64);
		FlxG.camera.zoom = 1.5;
		PopText.currentState = this;
	
		random = new FlxRandom();
		FlxNapeSpace.init();
		FlxNapeSpace.space.gravity = new Vec2(0, 0);
		levelCollisionSprite = new FlxNapeSprite(0, 0, null, false, true);
		
		deadObjectsLayer = new FlxTypedGroup<FlxSprite>();
		_level = new TiledLevel("assets/tiled/Dungeon1.tmx");
		addCollisionMeshesToSpace();
		var playerStart= getPlayerStartingLocation();
		_player = new Player(playerStart.x,playerStart.y);
		SoundGlobal.soundListener = _player;

		enemiesByLevel = new Array< Array< String> > ();
		enemies = new Array<Enemy>();
		
	
		_level.objectsLayer.add(_player);

		// Add backgrounds
		add(_level.backgroundLayer);
		
		// Add static images
	//	add(_level.imagesLayer);
		add(deadObjectsLayer);
		add(_level.objectsLayer);
		
	// Add foreground tiles after adding level objects, so these tiles render on top of player
		FlxG.camera.follow(_player, FlxCameraFollowStyle.TOPDOWN_TIGHT);
		screenUi = new ScreenUI(_player);
		add(screenUi);
		//FlxNapeSpace.drawDebug = true;
		
		FlxG.sound.playMusic(AssetPaths.Dark_Amb__ogg, 1, true);
 		
		super.create();
		
	}

	private function addEnemy() {
		var start= getEnemyStartingLocation();
		
		var enemyLevelNum =_player.level;
		var enemy;
		/*var enemyLevel = enemiesByLevel[enemyLevelNum];
		var enemyName = enemyLevel[random.int(0,enemyLevel.length-1)];
		
		var enemyT = Type.createInstance( Type.resolveClass(enemyName), []);
		var enemy: Enemy = cast enemyT;
		*/
		
		switch(enemyLevelNum) {
			case 1:{
				enemy = enemies.length % 1== 0 ?
					new OrcArcher(start.x, start.y) : new Orc(start.x, start.y);
			}

			case 2:{
				enemy = enemies.length % 2 == 0 ?
					new OrcHeavy(start.x, start.y) : new Orc(start.x, start.y);
			}

			case 3:{
				enemy = enemies.length % 2 == 0 ?
					new OrcHeavy(start.x, start.y) : new OrcElite(start.x, start.y);
			}

			case 4:{
				enemy = enemies.length % 2 == 0 ?
					new OrcElite(start.x, start.y) : new Skeleton(start.x, start.y);
			}

			default: {
				enemy =  	new Minotaur(start.x, start.y);
			}
		}
		
		enemy.setNavigtaionTileMap(_level.navigationMap);
		enemy.target = _player;
		enemy.name = "Enemy"+" "+enemies.length;
		_level.objectsLayer.add(enemy);
		enemies.push(enemy);
		
	}

	private function getPlayerStartingLocation():FlxPoint {
		var start = new FlxPoint(500, 500);

		if(_level.playerSpawns.length > 0) {
			start = randomPointInBounds(_level.playerSpawns[random.int(0,_level.playerSpawns.length-1)].bounds);
		}
		return start;
	}

	private function getEnemyStartingLocation():FlxPoint {
		var start = new FlxPoint(500, 500);

		if(_level.spawnMeshes.length > 0) {
			start = randomPointInBounds(_level.spawnMeshes[random.int(0,_level.spawnMeshes.length-1)].bounds);
		}
		return start;
	}

	private function randomPointInBounds(bounds: AABB): FlxPoint {
		var point = new FlxPoint(bounds.x, bounds.y);
		point.x += random.float(0, bounds.width);
		point.y += random.float(0, bounds.height);
		return point;
		
	}

	private function addCollisionMeshesToSpace():Void {
		var levelCollisions = new Body(BodyType.STATIC);
		var levelSpawns = new Body(BodyType.STATIC);
		
		for(shape in _level.collisionMeshes) {
			shape.body = levelCollisions;
		}
		for(shape in _level.playerSpawns) {
			shape.body = levelSpawns;
		}
		for(shape in _level.spawnMeshes) {
			shape.body = levelSpawns;
	
		}
		levelCollisions.setShapeMaterials(new Material(0.4, 0.2, 0.38, 0.7)); // these values from FlxNapeSpace createWalls
		levelCollisions.space = FlxNapeSpace.space;
		levelCollisionSprite.addPremadeBody(levelCollisions);
		
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		gameLength+= elapsed;
		var deadSprites = new Array<FlxSprite>();

		for(sprite in _level.objectsLayer) {
			if(!sprite.alive) {
				deadObjectsLayer.add(sprite);
				deadSprites.push(sprite);
			}
		}

		//Then I'm removing scheduled objects from FlxGroup
		if (deadSprites.length > 0) {
			for (sprite in deadSprites) {
				_level.objectsLayer.remove(sprite, true);
			}
		}
		if(gameLength > 8) {
			addEnemy();
			gameLength = 0;
		}
		
		_level.objectsLayer.sort(sortByY);

	}


	private function sortByY(Order:Int, Obj1:FlxSprite, Obj2:FlxSprite):Int 
	{
		return FlxSort.byValues(Order,Obj1.y+Obj1.origin.y, Obj2.y+Obj2.origin.y);
	}





}
