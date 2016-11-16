package;

import flixel.system.FlxAssets.FlxGraphicAsset;
import Character;


class Enemy extends Character
{
  
  public function new(?X:Float=0, ?Y:Float=0,?characterSpriteSheet:FlxGraphicAsset)
  {
      super(200, X, Y, characterSpriteSheet);
  }
  
  override public function update(elapsed:Float):Void
  {
     characterMove(elapsed);
     super.update(elapsed);
  }
}