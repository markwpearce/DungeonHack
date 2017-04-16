package dungeonhack.debug;

import flixel.system.debug.FlxDebugger;
import openfl.text.TextField;


class MapDebugWindow extends DebugWindow {

  public var mapX:Int = 0;
  public var mapY:Int = 0;

  private var mapPlacementDescription: TextField;

  private var addMapCallback:Null<Void -> Void>;
    
  private var initd:Bool = false;

  public function new(addMapFunc:Null<Void -> Void>) {
    super("Map Debug");
    addMapCoordWatch("X");
    addMapCoordWatch("Y");
      
    addMapCallback = addMapFunc;
    mapPlacementDescription = addLabeledButton("Add map", addMapCallback, new GraphicInteractive(0, 0)).label;    
  }


  private function addMapCoordWatch(coordName:String):Void {
    addWatch(this, "Map Room "+coordName, "map"+coordName);
    resize(200, 100);
  }

  override public function update():Void {
    mapPlacementDescription.text = 'Add map room at (${mapX},${mapY})';   
  }

  public function incXY() {
    if(mapX >= mapY) {
      mapY++;
    }
    else {
      mapX++;
    }
  }
}