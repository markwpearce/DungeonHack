package dungeonhack.states;

import flixel.FlxG;
import flixel.addons.nape.FlxNapeSpace;
import flixel.util.FlxColor;
import flixel.system.scaleModes.*;

import flixel.addons.ui.*;

import dungeonhack.characters.*;
import dungeonhack.ui.*;
import dungeonhack.maps.RoomPlacer;
import dungeonhack.util.*;
import dungeonhack.characters.Enemies;

class DebugState extends PlayState
{

  private var lastEnemyType:String = "Orc";

  private var mapPlacementX: FlxUINumericStepper;
  private var mapPlacementY: FlxUINumericStepper;
  
	override public function create():Void
	{
    super.create();
    bgColor = FlxColor.GRAY;
    FlxNapeSpace.drawDebug = true;

    roomPlacer = new RoomPlacer((20*64),(32*-6));
    addLevelMap(AssetPaths.DebugLevel__tmx);
		setPlayer(new Player());
    FlxG.sound.music.stop();
    FlxG.debugger.visible = true;
    FlxG.debugger.drawDebug = true;
    FlxG.scaleMode = new FixedScaleMode();
    FlxG.camera.zoom = 1;

    addDebugUi();
	}


  private function addDebugUi():Void {
    mapPlacementX = new FlxUINumericStepper(5, 60, 1, 0, 0, 10);
    mapPlacementY= new FlxUINumericStepper(5, 80, 1, 0, 0, 10);
    screenUi.addFixedSprite(mapPlacementX);
    screenUi.addFixedSprite(mapPlacementY);
    screenUi.addFixedSprite(new FlxUIButton(5, 100, "Add Map Tile", addMapTile));
    var enemyLabels = new Array<StrNameLabel>();
    for(enemyType in Enemies.ENEMY_TYPE_LIST) {
      enemyLabels.push(new StrNameLabel(enemyType, enemyType));
    }
    var enemySelector = new FlxUIDropDownMenu(5, 30, enemyLabels, addEnemyType);
    screenUi.addFixedSprite(enemySelector);

  } 

  private function addEnemyType(enemyType: String):Void {
    addEnemy(Enemies.createEnemyByType(enemyType));
    lastEnemyType = enemyType;
  } 

  private function addMapTile():Void {
    addMap(Math.round(mapPlacementX.value), Math.round(mapPlacementY.value));
  } 

  private function addMap(?roomX: Int=0, ?roomY:Int = 0):Void {
    addLevelMap(AssetPaths.all_1__tmx,
      roomPlacer.roomXYToPixelX(roomX, roomY),
      roomPlacer.roomXYToPixelY(roomX, roomY)
      );
  }

  

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
    if(CheckInput.check([E])) {
      addEnemyType(lastEnemyType);
    }
    if(CheckInput.check([M])) {
      addMapTile();
    }
    
	}

  override private function doQuit(): Void {
    FlxNapeSpace.drawDebug = false;
    FlxG.debugger.visible = false;
    FlxG.debugger.drawDebug = false;
    FlxG.scaleMode = new RatioScaleMode();
    bgColor = FlxColor.BLACK;
    
    super.doQuit();
  }

}
