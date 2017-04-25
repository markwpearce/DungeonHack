package dungeonhack.states;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.input.gamepad.FlxGamepadInputID;
import flash.system.System;

import dungeonhack.util.*;

class TitleState extends MenuState
{

  public static var VERSION:String = "0.2.9";


	private var byText: FlxText;
  private var verText: FlxText;
 
	override public function create():Void
	{		

 		super.create();
		addButton("Play", clickPlay);
		addButton("Credits", clickCredits);
    #if debug
    addButton("Debug Level", clickDebug);
    #end 
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
    if(CheckInput.check([ESCAPE, Q], [FlxGamepadInputID.BACK])) {
			clickQuit();
		}
    else if(CheckInput.check([SPACE, ENTER], [FlxGamepadInputID.X, FlxGamepadInputID.START])) {
			getActiveButtonIndex().onUp.fire();
		}
    else if(CheckInput.check([DOWN], [FlxGamepadInputID.DPAD_DOWN])) {
			setActiveButtonIndex(activeButtonIndex+1);
		}
    else if(CheckInput.check([UP], [FlxGamepadInputID.DPAD_UP])) {
			setActiveButtonIndex(activeButtonIndex-1);
		}
    #if debug
    else if(CheckInput.check([D])) {
			clickDebug();
		}
    #end
    else if(CheckInput.check([P])) {
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
