package dungeonhack.states;

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
	private var byText: FlxText;
	private var verText: FlxText;

	override public function create():Void
	{
		bkgrnd = new FlxSprite(0, 0, AssetPaths.TitleScreen__png);
		bkgrnd.screenCenter();
		_btnPlay = new FlxButton(0, 0, "Play", clickPlay);
		_btnPlay.screenCenter();
 		_btnQuit = new FlxButton(0, 0, "Quit", clickQuit);
		_btnQuit.screenCenter();
		_btnQuit.y+=30;
		byText = new FlxText(0,0,0,"A game by Mark Pearce");
		byText.alignment = FlxTextAlign.CENTER;
		byText.screenCenter();
		byText.y+=120;
		
		verText = new FlxText(0,0,0,"Version 0.2.0");
		verText.alignment = FlxTextAlign.CENTER;
		verText.screenCenter();
		verText.y+=150;
		add(bkgrnd);
		add(_btnPlay);
		add(_btnQuit);
		add(verText);
		add(byText);
 		FlxG.sound.playMusic(AssetPaths.prologue__ogg, 0.8, true);
 		
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
