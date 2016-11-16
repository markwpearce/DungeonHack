package;

import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxPoint;
import Character;


class Player extends Character
{
  
  public function new(?X:Float=0, ?Y:Float=0)
  {
      super(200, X, Y, AssetPaths.orc_regular_0__png);
  }
  
  override public function update(elapsed:Float):Void
  {
     movement(elapsed);
     super.update(elapsed);
  }

  private function getInput():MoveInput 
  {
    var _up:Bool = false;
    var _down:Bool = false;
    var _left:Bool = false;
    var _right:Bool = false;
    _up = FlxG.keys.anyPressed([UP, W]);
    _down = FlxG.keys.anyPressed([DOWN, S]);
    _left = FlxG.keys.anyPressed([LEFT, A]);
    _right = FlxG.keys.anyPressed([RIGHT, D]);

    if(FlxG.gamepads.lastActive != null) {
      var gp = FlxG.gamepads.lastActive;
      var gpX = gp.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK);
      var gpY = gp.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK);
      var deadZone:Float = 0.1;
      
      _up = _up || gpY > deadZone;
      _down = _down || gpY < -deadZone;
      _left = _left || gpX > deadZone;
      _right = _right || gpX < deadZone;
    }
    if (_up && _down)
      _up = _down = false;
    if (_left && _right)
      _left = _right = false;

    return {
      up: _up,
      down: _down,
      left: _left,
      right: _right
    }
  }

  private function movement(elapsed: Float):Void
  {
    var input = getInput();
    characterMove(elapsed, input);
  }
}