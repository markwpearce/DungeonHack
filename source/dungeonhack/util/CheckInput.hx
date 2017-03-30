package dungeonhack.util;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

class CheckInput {

   static public function check(KeyArray:Array<FlxKey>,
      ?GPArray:Array<flixel.input.gamepad.FlxGamepadInputID> = null):Bool {
    var pressed = FlxG.keys.anyJustPressed(KeyArray);
    if(GPArray == null) {
      GPArray = [];
    }
    if(!pressed && FlxG.gamepads.lastActive != null) {
      var gp = FlxG.gamepads.lastActive;
      pressed = gp.anyJustPressed(GPArray);
    }
		return pressed;
  }


}