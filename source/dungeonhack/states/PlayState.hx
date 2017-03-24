package dungeonhack.states;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.FlxState;

class PlayState extends FlxState
{

  private function getQuit():Bool {
    var exit = FlxG.keys.anyJustPressed([ESCAPE]);
    if(!exit && FlxG.gamepads.lastActive != null) {
      var gp = FlxG.gamepads.lastActive;
      exit = gp.anyJustPressed([FlxGamepadInputID.BACK]);
    }

    return exit;
  }

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

     if(getQuit()) {
       FlxG.switchState(new TitleState());
     }
  }
}