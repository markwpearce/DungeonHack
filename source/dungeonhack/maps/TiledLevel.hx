package dungeonhack.maps;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledImageTile;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledTilePropertySet;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.tile.FlxTileSpecial;
import flixel.math.FlxPoint;
import nape.shape.Shape;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.geom.Vec2;
import nape.geom.Vec2List;

import haxe.io.Path;


class TiledMapWithOffset extends TiledMap {

  public var x:Int = 0;
  public var y:Int = 0;

  public function new(tiledLevel:Dynamic, topLeftX:Int = 0, topLeftY:Int = 0)
	{
    super(tiledLevel);
    x = topLeftX;
    y = topLeftY;
  }

}


/**
 * @author Samuel Batista
 */
class TiledLevel
{
	// For each "Tile Layer" in the map, you must define a "tileset" property which contains the name of a tile sheet image 
	// used to draw tiles in that layer (without file extension). The image file must be located in the directory specified bellow.
	private inline static var c_PATH_LEVEL_TILESHEETS = "assets/tiled/";
	
  public var tiledMaps: Array<TiledMapWithOffset>;


	// Array of tilemaps used for collision
	public var foregroundTiles:FlxGroup;
	public var objectsLayer: FlxTypedGroup<FlxSprite>;
	public var backgroundLayer:FlxGroup;
	public var collisionMeshes:Array<Shape>;
	public var playerSpawns:Array<Shape>;
	public var spawnMeshes:Array<Shape>;
	public var navigationMap:FlxTilemap;

	
	// Sprites of images layers
	public var imagesLayer:FlxGroup;
	
	public function new(tiledLevel:Dynamic)
	{
    tiledMaps = new Array<TiledMapWithOffset>();
    imagesLayer = new FlxGroup();
		foregroundTiles = new FlxGroup();
		objectsLayer = new FlxTypedGroup<FlxSprite>();
		backgroundLayer = new FlxGroup();
		collisionMeshes = new Array<Shape>();
		spawnMeshes = new Array<Shape>();
		playerSpawns = new Array<Shape>();
    addTiledMap(tiledLevel);
	}


  public function addTiledMap(mapPath: String, X:Int = 0, Y:Int = 0): Void {
    
    var map: TiledMapWithOffset = new TiledMapWithOffset(mapPath, X, Y);

   FlxG.camera.setScrollBoundsRect(-128, -128, map.fullWidth+128, map.fullHeight+128, true);


		loadImages(map);
		loadObjects(map);
		
		// Load Tile Maps
		for (layer in map.layers)
		{
			
			if (layer.type != TiledLayerType.TILE) continue;
			var tileLayer:TiledTileLayer = cast layer;
			
			var tileSet = getTileSetFromLayer(map, tileLayer);
			var processedPath = getImagePathFromTileSet(tileSet);
			
			// could be a regular FlxTilemap if there are no animated tiles
			var tilemap = new FlxTilemap();
		
			tilemap.offset.x = -tileLayer.offsetX;
			tilemap.offset.y = -tileLayer.offsetY;
      trace("Tile Layer: "+tileLayer.name+ " type: "+tileLayer.type+" Path: "+processedPath);
			tilemap.loadMapFromArray(tileLayer.tileArray, map.width, map.height, processedPath,
				tileSet.tileWidth, tileSet.tileHeight, OFF,
				 tileSet.firstGID, 1, 1);
			var count = tilemap.totalTiles;
			
			/* Animated tiles?
			if (tileLayer.properties.contains("animated"))
			{
				var tileset = tilesets["level"];
				var specialTiles:Map<Int, TiledTilePropertySet> = new Map();
				for (tileProp in tileset.tileProps)
				{
					if (tileProp != null && tileProp.animationFrames.length > 0)
					{
						specialTiles[tileProp.tileID + tileset.firstGID] = tileProp;
					}
				}
				var tileLayer:TiledTileLayer = cast layer;
				tilemap.setSpecialTiles([
					for (tile in tileLayer.tiles)
						if (tile != null && specialTiles.exists(tile.tileID))
							getAnimatedTile(specialTiles[tile.tileID], tileset)
						else null
				]);
			}
			*/
			
			if (tileLayer.properties.contains("nocollide")
				&& tileLayer.properties.get("nocollide") == "true")
			{
				backgroundLayer.add(tilemap);
			}
			else if(tileLayer.name == "Navigation")
			{
				trace("Found navigation layer");
				if(navigationMap == null) {
					navigationMap = tilemap;
				}
				else {
					throw "More than one navigation tile map found";
		
				}
			}
		}

		if(navigationMap == null) {
				throw "No navigation map found";
		}
  }

	private function getTileSetFromLayer(map: TiledMap, tileLayer: TiledLayer): TiledTileSet
	{
		var tileSheetName:String = tileLayer.properties.get("tileset");
			
		if (tileSheetName == null)
				throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";
				
		var tileSet:TiledTileSet = null;
		for (ts in map.tilesets)
		{
			if (ts.name == tileSheetName)
			{
				tileSet = ts;
				break;
			}
		}
		
		if (tileSet == null)
			throw "Tileset '" + tileSheetName + " not found. Did you misspell the 'tilesheet' property in " + tileLayer.name + "' layer?";
			
		return tileSet;
	}

	private function getImagePathFromTileSet(tileSet:TiledTileSet): String
	{
		var imagePath 		= new Path(tileSet.imageSource);
		var processedPath 	= c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;
		return processedPath;
	}

	private function getAnimatedTile(props:TiledTilePropertySet, tileset:TiledTileSet):FlxTileSpecial
	{
		var special = new FlxTileSpecial(1, false, false, 0);
		var n:Int = props.animationFrames.length;
		var offset = Std.random(n);
		special.addAnimation(
			[for (i in 0 ... n) props.animationFrames[(i + offset) % n].tileID + tileset.firstGID],
			(1000 / props.animationFrames[0].duration)
		);
		return special;
	}
	
	public function loadObjects(map: TiledMap)
	{
		var layer:TiledObjectLayer;
		for (layer in map.layers)
		{
			trace("Layer: "+layer.name+ " type: "+layer.type);

			if (layer.type != TiledLayerType.OBJECT)
				continue;
			var objectLayer:TiledObjectLayer = cast layer;

			//objects layer
			if (layer.type  == TiledLayerType.OBJECT)
			{
				for (o in objectLayer.objects)
				{
					if(o.objectType == TiledObject.RECTANGLE || o.objectType == TiledObject.POLYGON || o.objectType == TiledObject.ELLIPSE)  {
						//deal with collision mesh
						if(o.properties.contains("collide")|| o.type.toLowerCase() == "collider") createCollisionShape(o, collisionMeshes);
						else if((o.properties.contains("spawn") && o.properties.get("spawn") != "player") || o.type.toLowerCase() == "enemyspawn") createCollisionShape(o, spawnMeshes);
						else if((o.properties.contains("spawn") && o.properties.get("spawn") == "player") || o.type.toLowerCase() == "playerspawn") createCollisionShape(o, playerSpawns);
					}
					else if(o.objectType == TiledObject.TILE) {
					  //load it as a tile based scenery
						loadObject(map, o, objectLayer, objectsLayer);	
					}
				}
			}
		
		}
	}

	private function objectPointsToVec2List(object: TiledObject):Vec2List {
		var list = new Vec2List();
		for(point in object.points) {
			list.push(new Vec2(object.x+point.x, object.y+point.y));
		}
		return list;
	}

	private function createCollisionShape(object:TiledObject, meshes:Array<Shape> ) {
		
		switch( object.objectType){
		
			case TiledObject.POLYGON: 
			
				if(object.points == null) {
					trace("Empty polygon!");
					return;
				}
				var pointsStr = "";
				for(point in object.points) {
					pointsStr+="("+point.x+","+point.y+") ";
				}

				trace("Polygon: "+pointsStr);
				var napeShape = new Polygon(objectPointsToVec2List(object));
				meshes.push(napeShape);
			
			case TiledObject.RECTANGLE:
				
				var x = Math.max(object.x, 0);
				var y = Math.max(object.y, 0);
				trace("Rect: "+x+" "+y+" "+object.width+" "+object.height);

				var napeShape = new Polygon(Polygon.rect(x, y, object.width, object.height, false));
				meshes.push(napeShape);
	
			case TiledObject.ELLIPSE:
				var napeShape = new Circle((object.height+object.width)/4, new Vec2(object.x+(object.width)/2, object.y+object.height/2));
				meshes.push(napeShape);
		}
		trace(meshes.length);
	}

	
	private function loadImageObject(map: TiledMap, object:TiledObject)
	{
		
		var tilesImageCollection:TiledTileSet = map.getTileSet("imageCollection");
	  var imagePath 		= new Path(tilesImageCollection.imageSource);
		var processedPath 	= c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;
		
		
		//decorative sprites
		var levelsDir:String = "assets/tiled/";
		
		var decoSprite:FlxSprite = new FlxSprite(0, 0, processedPath);
		if (decoSprite.width != object.width ||
			decoSprite.height != object.height)
		{
			decoSprite.antialiasing = true;
			decoSprite.setGraphicSize(object.width, object.height);
		}
		decoSprite.setPosition(object.x, object.y - decoSprite.height);
		decoSprite.origin.set(decoSprite.width/2, decoSprite.height);
		if (object.angle != 0)
		{
			decoSprite.angle = object.angle;
			decoSprite.antialiasing = true;
		}
		
		//Custom Properties
		if (object.properties.contains("depth"))
		{
			var depth = Std.parseFloat( object.properties.get("depth"));
			decoSprite.scrollFactor.set(depth,depth);
		}

		backgroundLayer.add(decoSprite);
	}
	
	private function loadObject(map: TiledMap, object:TiledObject, g:TiledObjectLayer, group:FlxTypedGroup<FlxSprite>)
	{
		var tileset:TiledTileSet = getTileSetFromLayer(map, g);
		var tileIndex = object.gid-tileset.firstGID;

		var processedPath 	= getImagePathFromTileSet(tileset);
	

		var decoSprite:FlxSprite = new FlxSprite(0, 0);
		decoSprite.loadGraphic(processedPath, true, tileset.tileWidth, tileset.tileHeight);
    decoSprite.animation.frameIndex = tileIndex;
	
		if (decoSprite.width != object.width ||
			decoSprite.height != object.height)
		{
			decoSprite.antialiasing = true;
			decoSprite.setGraphicSize(object.width, object.height);
		}
		decoSprite.setPosition(object.x, object.y - decoSprite.height);
		//decoSprite.origin.set(decoSprite.width/2, decoSprite.height);
		if (object.angle != 0)
		{
			decoSprite.angle = object.angle;
			decoSprite.antialiasing = true;
		}
		
		//Custom Properties
		if (object.properties.contains("depth"))
		{
			var depth = Std.parseFloat( object.properties.get("depth"));
			decoSprite.scrollFactor.set(depth,depth);
		}

		group.add(decoSprite);

/*

		switch (o.type.toLowerCase())
		{
			case "player_start":
				var player = new FlxSprite(x, y);
				player.makeGraphic(32, 32, 0xffaa1111);
				player.maxVelocity.x = 160;
				player.maxVelocity.y = 400;
				player.acceleration.y = 400;
				player.drag.x = player.maxVelocity.x * 4;
				FlxG.camera.follow(player);
				state.player = player;
				group.add(player);
				
			case "floor":
				var floor = new FlxObject(x, y, o.width, o.height);
				state.floor = floor;
				
			case "coin":
				var tileset = g.map.getGidOwner(o.gid);
				var coin = new FlxSprite(x, y, c_PATH_LEVEL_TILESHEETS + tileset.imageSource);
				state.coins.add(coin);
				
			case "exit":
				// Create the level exit
				var exit = new FlxSprite(x, y);
				exit.makeGraphic(32, 32, 0xff3f3f3f);
				exit.exists = false;
				state.exit = exit;
				group.add(exit);
			default:
				var tileset = g.map.getGidOwner(o.gid);
				var obj = new FlxSprite(x, y, c_PATH_LEVEL_TILESHEETS + tileset.imageSource);
				group.add(obj);
		}*/
	}

	public function loadImages(map:TiledMap)
	{
		for (layer in map.layers)
		{
			if (layer.type != TiledLayerType.IMAGE)
				continue;

			var image:TiledImageLayer = cast layer;
			var sprite = new FlxSprite(image.x, image.y, c_PATH_LEVEL_TILESHEETS + image.imagePath);
			imagesLayer.add(sprite);
		}
	}
	
}