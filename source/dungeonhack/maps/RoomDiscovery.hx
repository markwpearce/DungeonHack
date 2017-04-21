package dungeonhack.maps;

import sys.FileSystem;

class RoomDiscovery {

  private static inline var BASE_DIR = "assets/tiled/16x16/";

  private static var types:Array<String> = [];
  private static var allRoomPaths:Array<String> = [];
  private static var roomPathsBytype: Map< String , Array<String> > = new Map<String, Array<String>>();

  private static var inititialized: Bool = false;


  private static function init() {
    if(inititialized) return;

    for(n in 0...2) {
      for(e in 0...2) {
        for(s in 0...2) {
          for(w in 0...2) {
            types.push('${n}${e}${s}${w}');
          }
        }
      }
    }
  
    for(type in types) {
      trace(BASE_DIR+type);
      try {
        roomPathsBytype[type] = FileSystem.readDirectory(BASE_DIR+type).filter(function(path:String):Bool {
        trace(path);
        return path.indexOf(".tmx") != -1;
      });
      allRoomPaths = allRoomPaths.concat(roomPathsBytype[type]);
      }
      catch(except:Dynamic) {
        //trace(except);
      }
      
    }

    inititialized = true;
  }


  public static function getAllRooms():Array<String> {
    init();
    return allRoomPaths.copy();
  }

  public static function entrancesToType(north:Bool, east:Bool, south:Bool, west:Bool): String {
    return '${north?1:0}${east?1:0}${south?1:0}${west?1:0}';
  }

  public static function getAllRoomsWithEntrances(north:Bool, east:Bool, south:Bool, west:Bool):Array<String> {
    return getAllRoomsWithType(entrancesToType(north,east,south,west));
  }

  public static function getAllRoomsWithType(roomType:String):Array<String> {
    init();
    return roomPathsBytype[roomType].copy();
  }

  
}