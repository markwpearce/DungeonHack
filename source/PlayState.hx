package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
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

import flixel.group.FlxGroup;

class PlayState extends FlxState
{
	private var _player:Player;

	private var enemies: Array<Enemy>;
	public var _level:TiledLevel;

	private var entities:FlxGroup;

	private var  levelCollisionSprite:FlxNapeSprite;

	public var deadObjectsLayer: FlxTypedGroup<FlxSprite>;

	override public function create():Void
	{
		entities = new FlxGroup();
		FlxG.camera.width = FlxG.width+128;
		FlxG.camera.height = FlxG.height+128;
		FlxG.camera.setPosition(-64, -64);
		FlxG.camera.zoom = 1.5;
	
	
		
		FlxNapeSpace.init();
		FlxNapeSpace.space.gravity = new Vec2(0, 0);
		levelCollisionSprite = new FlxNapeSprite(0, 0, null, false, true);
		
		deadObjectsLayer = new FlxTypedGroup<FlxSprite>();
		_level = new TiledLevel("assets/tiled/test_map3.tmx", this);
		addCollisionMeshesToSpace();
		_player = new Player(200,200);

		enemies = new Array<Enemy>();
		for (i in 0...10) {
			var asset = i%2==0 ? AssetPaths.orc_archer_0__png : AssetPaths.orc_regular_0__png;
			var enemy = new Enemy(Math.random()*800+100, Math.random()*300+100, asset);
			enemy.setNavigtaionTileMap(_level.navigationMap);
			enemy.target = _player;
			enemy.name = "Enemy "+i;
			_level.objectsLayer.add(enemy);
			enemies.push(enemy);
			
		}
	
		_level.objectsLayer.add(_player);

		// Add backgrounds
		add(_level.backgroundLayer);
		
		// Add static images
	//	add(_level.imagesLayer);
		add(deadObjectsLayer);
		add(_level.objectsLayer);
	// Add foreground tiles after adding level objects, so these tiles render on top of player

		FlxG.camera.follow(_player, FlxCameraFollowStyle.TOPDOWN_TIGHT);
	
		//FlxNapeSpace.drawDebug = true;
		
 		
			super.create();
		
	}


	private function addCollisionMeshesToSpace():Void {
		var levelCollisions = new Body(BodyType.STATIC);
		
		for(shape in _level.collisionMeshes) {
			shape.body = levelCollisions;
		}
		levelCollisions.setShapeMaterials(new Material(0.4, 0.2, 0.38, 0.7)); // these values from FlxNapeSpace createWalls
		levelCollisions.space = FlxNapeSpace.space;
		levelCollisionSprite.addPremadeBody(levelCollisions);
		
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
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
		
		_level.objectsLayer.sort(sortByY);

	}


	private function sortByY(Order:Int, Obj1:FlxSprite, Obj2:FlxSprite):Int 
	{
		return FlxSort.byValues(Order,Obj1.y+Obj1.origin.y, Obj2.y+Obj2.origin.y);
	}
}
