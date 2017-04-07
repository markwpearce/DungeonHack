package dungeonhack.maps;


class RoomPlacer {

  private var roomWidthInTiles: Int;
  private var roomHeightInTiles: Int;
  private var tileWidth: Int;
  private var tileHeight: Int;

  private var startOffsetX: Int;
  private var startOffsetY: Int;

  public function new(?offSetX:Int = 0, ?offsetY:Int = 0,
    ?roomWidth:Int = 16,
    ?roomHeight:Int = 16,
    ?tileW:Int = 64,
    ?tileH:Int = 32)
  {
    startOffsetX = offSetX;
    startOffsetY = offsetY;
    roomWidthInTiles = roomWidth;
    roomHeightInTiles = roomHeight;
    tileWidth = tileW;
    tileHeight = tileH;
  }

  public function roomXYToPixelX(roomX:Int, roomY:Int):Int {
   var roomWidthInPixels = (roomWidthInTiles+1)*tileWidth;
   return Math.floor(startOffsetX + 
     (roomX + roomY) * roomWidthInPixels/2);
  }

  public function roomXYToPixelY(roomX:Int, roomY:Int):Int {
    var roomHeightInPixels = (roomHeightInTiles+1)*tileHeight;
    return Math.floor(startOffsetY - 
      (roomY - roomX) *roomHeightInPixels/2);
  }

}