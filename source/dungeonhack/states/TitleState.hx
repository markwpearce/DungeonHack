package dungeonhack.states;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.input.gamepad.FlxGamepadInputID;
import flash.system.System;

class TitleState extends MenuState
{

  public static var VERSION:String = "0.2.2";


	private var byText: FlxText;
  private var verText: FlxText;
 
	override public function create():Void
	{		

 		super.create();
		addButton("Play", clickPlay);
		addButton("Credits", clickCredits);
    addButton("Debug Level", clickDebug);
    addButton("Quit", clickQuit);

    setActiveButtonIndex(0);
    addFinePrint();
    
    FlxG.sound.playMusic(AssetPaths.prologue__ogg, 0.8, true);
	}


  private function addFinePrint() {
    var height = 405;

    byText = new FlxText(0,0,0,"A game by Mark Pearce");
		byText.alignment = FlxTextAlign.CENTER;
		byText.screenCenter();
    byText.x+=horizontalOffset;
		byText.y=height-50;
		verText = new FlxText(0,0,0,"Version "+VERSION);
		verText.alignment = FlxTextAlign.CENTER;
		verText.screenCenter();
		verText.y=height-35;
    verText.x+=horizontalOffset;
		add(verText);
		add(byText);
  }

	override public function update(elapsed:Float):Void
	{
    if(checkInput([ESCAPE, Q], [FlxGamepadInputID.BACK])) {
			clickQuit();
		}
    else if(checkInput([SPACE, ENTER], [FlxGamepadInputID.X, FlxGamepadInputID.START])) {
			getActiveButtonIndex().onUp.fire();
		}
    else if(checkInput([DOWN], [FlxGamepadInputID.DPAD_DOWN])) {
			setActiveButtonIndex(activeButtonIndex+1);
		}
    else if(checkInput([UP], [FlxGamepadInputID.DPAD_UP])) {
			setActiveButtonIndex(activeButtonIndex-1);
		}
    else if(checkInput([D],[])) {
			clickDebug();
		}
    else if(checkInput([P],[])) {
			clickPlay();
		}

    super.update(elapsed);
	}

	private function clickPlay():Void
  { 
     FlxG.switchState(new GameState());
  }

  private function clickCredits():Void
  { 
     FlxG.switchState(new CreditsState());
  }

  private function clickDebug():Void
  { 
     FlxG.switchState(new DebugState());
  }

	private function clickQuit():Void
  { 
    System.exit(0);
  }
}
