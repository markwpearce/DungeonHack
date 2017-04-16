package dungeonhack.states;

import flixel.FlxG;
import flixel.addons.nape.FlxNapeSpace;
import flixel.util.FlxColor;
import flixel.system.scaleModes.*;
import flixel.FlxSprite;
import flixel.system.debug.watch.Tracker;

import flixel.addons.ui.*;

import dungeonhack.characters.*;
import dungeonhack.debug.*;
import dungeonhack.ui.*;
import dungeonhack.maps.RoomPlacer;
import dungeonhack.util.*;
import dungeonhack.characters.Enemies;

class DebugState extends PlayState
{

  private var lastEnemyType:String = "Orc";

  private var mapDebugWindow: MapDebugWindow;
  
	override public function create():Void
	{
    super.create();
    bgColor = FlxColor.GRAY;
    FlxNapeSpace.drawDebug = true;
    FlxG.sound.music.stop();
    FlxG.debugger.visible = true;
    FlxG.debugger.drawDebug = true;
    FlxG.log.redirectTraces = true;

    FlxG.scaleMode = new FixedScaleMode();
    FlxG.camera.zoom = 0.5;

    roomPlacer = new RoomPlacer();//(20*64),(32*-6));
    //addLevelMap(AssetPaths.DebugLevel__tmx);
		setPlayer(new Player());
    FlxG.debugger.addTrackerProfile(new TrackerProfile(Player, [
        "health",
        "maxHealth",
        "exp",
        "level",
        "nextLevel"
    ], [FlxSprite]));
    FlxG.debugger.track(player);
    mapDebugWindow = new MapDebugWindow(addMapRoom);
    FlxG.game.debugger.addWindow(mapDebugWindow);

    addDebugUi();
	}


  private function addDebugUi():Void {
   
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

  private function addMapRoom() {
    addMap(mapDebugWindow.mapX, mapDebugWindow.mapY);
    mapDebugWindow.incXY();
  }

  private function addMap(?roomX: Int=0, ?roomY:Int = 0, mapPath:String = AssetPaths.all_1__tmx):Void {
    addLevelMap(mapPath,
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
      addMapRoom();
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

  override public function destroy():Void {
    mapDebugWindow.close();
    super.destroy();
  }

}
