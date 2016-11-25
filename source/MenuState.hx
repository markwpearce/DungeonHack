package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.input.gamepad.FlxGamepadInputID;

class MenuState extends FlxState
{
	private var _btnPlay:FlxButton;
	private var _btnQuit:FlxButton;
	private var bkgrnd: FlxSprite;

	override public function create():Void
	{
		bkgrnd = new FlxSprite(0, 0, AssetPaths.TitleScreen__png);
		bkgrnd.screenCenter();
		_btnPlay = new FlxButton(0, 0, "Play", clickPlay);
		_btnPlay.screenCenter();
 		_btnQuit = new FlxButton(0, 0, "Quit", clickQuit);
		_btnQuit.screenCenter();
		_btnQuit.y+=30;
 		add(bkgrnd);
		add(_btnPlay);
		add(_btnQuit);
		 	

 		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		var exit = FlxG.keys.anyJustPressed([ESCAPE]);
    if(!exit && FlxG.gamepads.lastActive != null) {
      var gp = FlxG.gamepads.lastActive;
      exit = gp.anyJustPressed([FlxGamepadInputID.BACK]);
    }
		if(exit) {
			clickQuit();

		}
		var play = FlxG.keys.anyJustPressed([SPACE, ENTER]);
    if(!play && FlxG.gamepads.lastActive != null) {
      var gp = FlxG.gamepads.lastActive;
      play = gp.anyJustPressed([FlxGamepadInputID.X, FlxGamepadInputID.START]);
    }
		if(play) {
			clickPlay();
		}
    super.update(elapsed);
	}

	private function clickPlay():Void
  { 
     FlxG.switchState(new PlayState());
  }

	private function clickQuit():Void
  { 
     openfl.Lib.close();
  }
}
