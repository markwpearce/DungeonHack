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
   return Math.floor(startOffsetX + 
    (roomX + roomY) * roomWidthInTiles*tileWidth/2);
  }

  public function roomXYToPixelY(roomX:Int, roomY:Int):Int {
    return Math.floor(startOffsetY - 
      (roomY - roomX) *roomHeightInTiles*tileHeight/2);
  }

}