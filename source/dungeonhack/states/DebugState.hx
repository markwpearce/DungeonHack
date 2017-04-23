package dungeonhack.states;

import flixel.FlxG;
import flixel.addons.nape.FlxNapeSpace;
import flixel.util.FlxColor;
import flixel.system.scaleModes.*;
import flixel.FlxBasic;
import flixel.math.FlxPoint;
import flixel.system.debug.watch.Tracker;

import dungeonhack.characters.*;
import dungeonhack.debug.*;
import dungeonhack.ui.*;
import dungeonhack.maps.RoomPlacer;
import dungeonhack.util.*;
import dungeonhack.characters.Enemies;

class DebugState extends PlayState
{

  private var lastEnemyType:String = "Orc";
  private var playerTrackerWindow: flixel.system.debug.Window;
  private var lastEnemyTrackerWindow: flixel.system.debug.Window;

  private var mapDebugWindow: MapDebugWindow;
  private var enemyDebugWindow: EnemyDebugWindow;

  private var mapToAddPath:String = AssetPaths.all_1__tmx;

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
    FlxG.camera.zoom = 1;

    roomPlacer = new RoomPlacer((20*64),(32*-6));
    addLevelMap(AssetPaths.DebugLevel__tmx);
		setPlayer(new Player());
    FlxG.debugger.addTrackerProfile(new TrackerProfile(Character, [
        "name",
        "type",
        "health",
        "maxHealth",
        "level",
        "meleeStats"
    ], [FlxPoint, FlxBasic]));

    FlxG.debugger.addTrackerProfile(new TrackerProfile(Enemy, [
        "activeStateName"
    ], [Character]));
    FlxG.debugger.addTrackerProfile(new TrackerProfile(Player, [
        "exp",
        "nextLevel"
    ], [Character]));
    
    addDebugUi();
	}


  private function addDebugUi():Void {
    playerTrackerWindow = FlxG.debugger.track(player);
    mapDebugWindow = new MapDebugWindow(addMapRoom, setMapRoom);
    //FlxG.game.debugger.addWindow(mapDebugWindow);
    enemyDebugWindow = new EnemyDebugWindow(addLastEnemy);
    //FlxG.game.debugger.addWindow(enemyDebugWindow);
  } 

  private function addLastEnemy():Void {
    addEnemyType(enemyDebugWindow.selectedEnemy);
  } 

  private function addEnemyType(enemyType: String):Void {
    var enemy = Enemies.createEnemyByType(enemyType);
    addEnemy(enemy);
    lastEnemyType = enemyType;
    if(lastEnemyTrackerWindow != null) {
      lastEnemyTrackerWindow.close();
    }
    lastEnemyTrackerWindow = FlxG.debugger.track(enemy);
    lastEnemyTrackerWindow.reposition(FlxG.game.width-200, 300);
  } 

  private function addMapRoom() {
    addMap(mapDebugWindow.mapX, mapDebugWindow.mapY, mapToAddPath);
    mapDebugWindow.incXY();
  }

  private function setMapRoom(mapRoomPath:String) {
    trace('Setting map ${mapRoomPath}');
    
    mapToAddPath = mapRoomPath;
  }

  private function addMap(?roomX: Int=0, ?roomY:Int = 0, mapPath:String):Void {
    trace('Adding map ${mapPath}');
    
    addLevelMap(mapPath,
      roomPlacer.roomXYToPixelX(roomX, roomY),
      roomPlacer.roomXYToPixelY(roomX, roomY)
      );
  }

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
    if(CheckInput.check([E])) {
      addLastEnemy();
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
    playerTrackerWindow.close();
    if(lastEnemyTrackerWindow != null) {
      lastEnemyTrackerWindow.close();
    }
    enemyDebugWindow.close();
    super.destroy();
  }

}
