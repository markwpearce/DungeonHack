package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledImageTile;
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

/**
 * @author Samuel Batista
 */
class TiledLevel extends TiledMap
{
	// For each "Tile Layer" in the map, you must define a "tileset" property which contains the name of a tile sheet image 
	// used to draw tiles in that layer (without file extension). The image file must be located in the directory specified bellow.
	private inline static var c_PATH_LEVEL_TILESHEETS = "assets/tiled/";
	
	// Array of tilemaps used for collision
	public var foregroundTiles:FlxGroup;
	public var objectsLayer: FlxTypedGroup<FlxSprite>;
	public var backgroundLayer:FlxGroup;
	public var collisionMeshes:Array<Shape>;
	public var navigationMap:FlxTilemap;

	
	// Sprites of images layers
	public var imagesLayer:FlxGroup;
	
	public function new(tiledLevel:Dynamic, state:PlayState)
	{
		super(tiledLevel);
		
		imagesLayer = new FlxGroup();
		foregroundTiles = new FlxGroup();
		objectsLayer = new FlxTypedGroup<FlxSprite>();
		backgroundLayer = new FlxGroup();
		collisionMeshes = new Array<Shape>();

		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);


		loadImages();
		loadObjects(state);
		
		// Load Tile Maps
		for (layer in layers)
		{
			//if(layer.name == "Navigation") continue;
			
			if (layer.type != TiledLayerType.TILE) continue;
			var tileLayer:TiledTileLayer = cast layer;
			
			var tileSheetName:String = tileLayer.properties.get("tileset");
			
			if (tileSheetName == null)
				throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";
				
			var tileSet:TiledTileSet = null;
			for (ts in tilesets)
			{
				if (ts.name == tileSheetName)
				{
					tileSet = ts;
					break;
				}
			}
			
			if (tileSet == null)
				throw "Tileset '" + tileSheetName + " not found. Did you misspell the 'tilesheet' property in " + tileLayer.name + "' layer?";
				
			var imagePath 		= new Path(tileSet.imageSource);
			var processedPath 	= c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;
			
			// could be a regular FlxTilemap if there are no animated tiles
			var tilemap = new FlxTilemap();
		
			tilemap.offset.x = -tileLayer.offsetX;
			tilemap.offset.y = -tileLayer.offsetY;
			tilemap.loadMapFromArray(tileLayer.tileArray, width, height, processedPath,
				tileSet.tileWidth, tileSet.tileHeight, OFF,
				 tileSet.firstGID, 1, 1);
			var count = tilemap.totalTiles;
			
			/*
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
	
	public function loadObjects(state:PlayState)
	{
		var layer:TiledObjectLayer;
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.OBJECT)
				continue;
			var objectLayer:TiledObjectLayer = cast layer;

			//collection of images layer
			/*if (layer.name == "images")
			{
				for (o in objectLayer.objects)
				{
					loadImageObject(o);
				}
			}*/
			
			//objects layer
			if (layer.type  == TiledLayerType.OBJECT)
			{
				for (o in objectLayer.objects)
				{
					if(o.properties.contains("collide") && 
						(o.objectType == TiledObject.RECTANGLE || o.objectType == TiledObject.POLYGON || o.objectType == TiledObject.ELLIPSE) ) {
						//deal with collision mesh
						createCollisionShape(o);
					}
					else if(o.objectType == TiledObject.TILE) {
					  //load it as a tile based scenery
						loadObject(state, o, objectLayer, objectsLayer);	
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

	private function createCollisionShape(object:TiledObject) {
		
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
				collisionMeshes.push(napeShape);
			
			case TiledObject.RECTANGLE:
				
				var x = Math.max(object.x, 0);
				var y = Math.max(object.y, 0);
				trace("Rect: "+x+" "+y+" "+object.width+" "+object.height);

				var napeShape = new Polygon(Polygon.rect(x, y, object.width, object.height, false));
				collisionMeshes.push(napeShape);
	
			case TiledObject.ELLIPSE:
				var napeShape = new Circle((object.height+object.width)/4, new Vec2(object.x+(object.width)/2, object.y+object.height/2));
				collisionMeshes.push(napeShape);
		}
		trace(collisionMeshes.length);
	}

	
	private function loadImageObject(object:TiledObject)
	{
		
		var tilesImageCollection:TiledTileSet = this.getTileSet("imageCollection");
			var imagePath 		= new Path(tilesImageCollection.imageSource);
			var processedPath 	= c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;
		
		//var tileImagesSource:TiledImageTile = processedPath;//tilesImageCollection.getImageSourceByGid(object.gid);
		
		//decorative sprites
		var levelsDir:String = "assets/tiled/";
		
		var decoSprite:FlxSprite = new FlxSprite(0, 0, processedPath);//levelsDir + tileImagesSource.source);
		if (decoSprite.width != object.width ||
			decoSprite.height != object.height)
		{
			decoSprite.antialiasing = true;
			decoSprite.setGraphicSize(object.width, object.height);
		}
		decoSprite.setPosition(object.x, object.y - decoSprite.height);
		decoSprite.origin.set(0, decoSprite.height);
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
	
	private function loadObject(state:PlayState, object:TiledObject, g:TiledObjectLayer, group:FlxTypedGroup<FlxSprite>)
	{
		/*var x:Int = o.x;
		var y:Int = o.y;
		
		// objects in tiled are aligned bottom-left (top-left in flixel)
		if (o.gid != -1)
			y -= g.map.getGidOwner(o.gid).tileHeight;
		
		var tileset = g.map.getGidOwner(o.gid);
		var obj = new FlxSprite(x, y, c_PATH_LEVEL_TILESHEETS + tileset.imageSource);
		group.add(obj);
		*/
		//var tilesImageCollection:TiledTileSet = this.getTileSet("grassland_tiles2");

		//tilesImageCollection.
		
		
		var tileset:TiledTileSet = 	g.map.getTileSet("grassland_tiles2");
		var tileIndex = object.gid-tileset.firstGID;
		
		//trace(tileIndex+" of "+tileset.tileWidth+" x "+tileset.tileHeight);
	
		
		//decorative sprites
		var levelsDir:String = "assets/tiled/";
				var imagePath 		= new Path(tileset.imageSource);
			var processedPath 	= c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;
	

		var decoSprite:FlxSprite = new FlxSprite(0, 0);//, processedPath);//levelsDir + tileImagesSource.source);
		decoSprite.loadGraphic(processedPath, true, tileset.tileWidth, tileset.tileHeight);
    decoSprite.animation.frameIndex = tileIndex;
	
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

	public function loadImages()
	{
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.IMAGE)
				continue;

			var image:TiledImageLayer = cast layer;
			var sprite = new FlxSprite(image.x, image.y, c_PATH_LEVEL_TILESHEETS + image.imagePath);
			imagesLayer.add(sprite);
		}
	}
	
}