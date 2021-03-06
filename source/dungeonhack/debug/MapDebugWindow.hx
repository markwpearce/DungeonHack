package dungeonhack.debug;

import flixel.system.debug.FlxDebugger;
import openfl.text.TextField;

import dungeonhack.maps.RoomDiscovery;

class MapDebugWindow extends DebugWindow {

  public var mapX:Int = 0;
  public var mapY:Int = 0;

  private var mapPlacementDescription: TextField;
  private var setRoomCallback: Null<String -> Void>;

  public function new(addMapFunc:Null<Void -> Void>, setRoomFunc:Null<String -> Void>) {
    super("Map Debug");
    addMapCoordWatch("X");
    addMapCoordWatch("Y");
    setRoomCallback = setRoomFunc;
    addLabeledSelect("Map Room file", RoomDiscovery.getAllRoomNames(), setRoomWrapper);
    mapPlacementDescription = addLabeledButton("Add map", addMapFunc, new GraphicInteractive(0, 0)).label;    
  }


  private function addMapCoordWatch(coordName:String):Void {
    addWatch(this, "Map Room "+coordName, "map"+coordName);
    resize(200, 100);
  }

  override public function update():Void {
    if(mapPlacementDescription != null) {
      mapPlacementDescription.text = 'Add map room at (${mapX},${mapY})';   
    }
  }

  public function incXY() {
    if(mapX >= mapY) {
      mapX=0;
      mapY++;
    }
    else {
      mapX++;
    }
  }

  public function setRoomWrapper(roomName: String):Void {
    setRoomCallback(RoomDiscovery.roomNameToPath(roomName));
  }
}
