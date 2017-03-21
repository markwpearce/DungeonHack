package dungeonhack.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flash.system.System;

class MenuState extends FlxState
{

  public static var VERSION:String = "0.2.0";


	private var bkgrnd: FlxSprite;
	private var byText: FlxText;
  private var verText: FlxText;
  private var selectText: FlxText;
  private var buttons: Array<FlxButton> = new Array<FlxButton>();
  private var buttonHeight:Int = 30;
  private var activeButtonIndex:Int = -1;

	override public function create():Void
	{
		bkgrnd = new FlxSprite(0, 0, AssetPaths.TitleScreen__png);
		bkgrnd.screenCenter();
    add(bkgrnd);
		
		addButton("Play", clickPlay);
		addButton("Quit", clickQuit);
    addButton("Credits");
    addButton("Debug Level");

    selectText = new FlxText(0,0,0,"->                            	<-");
		selectText.alignment = FlxTextAlign.CENTER;
		selectText.screenCenter();
    selectText.bold = true;
    add(selectText);
    setActiveButtonIndex(0);
    
	
    addFinePrint();
    FlxG.sound.playMusic(AssetPaths.prologue__ogg, 0.8, true);
 		
 		super.create();
	}

  private function addButton(name:String, ?OnClick:Null<Void -> Void> ):Void {
    var button:FlxButton = new FlxButton(0, 0, name, OnClick);
    button.screenCenter();
    button.y += (buttons.length * buttonHeight);
    buttons.push(button);
    add(button);
  }

  private function setActiveButtonIndex(buttonNum:Int):Void {
    buttonNum = buttonNum < 0 ?  0 : buttonNum;
    buttonNum = buttonNum > buttons.length-1 ? buttons.length-1 : buttonNum;
    activeButtonIndex = buttonNum;
    selectText.y = buttons[activeButtonIndex].y+4;
  }

  private function addFinePrint() {
    var height = 405;

    byText = new FlxText(0,0,0,"A game by Mark Pearce");
		byText.alignment = FlxTextAlign.CENTER;
		byText.screenCenter();
		byText.y=height-50;
		verText = new FlxText(0,0,0,"Version "+VERSION);
		verText.alignment = FlxTextAlign.CENTER;
		verText.screenCenter();
		verText.y=height-35;
		add(verText);
		add(byText);
  }

  private function getActiveButtonIndex(): FlxButton {
    return buttons[activeButtonIndex];
  }

  private function checkInput(KeyArray:Array<flixel.input.keyboard.FlxKey>,
      GPArray:Array<flixel.input.gamepad.FlxGamepadInputID>):Bool {
    var pressed = FlxG.keys.anyJustPressed(KeyArray);
    if(!pressed && FlxG.gamepads.lastActive != null) {
      var gp = FlxG.gamepads.lastActive;
      pressed = gp.anyJustPressed(GPArray);
    }
		return pressed;
  }

	override public function update(elapsed:Float):Void
	{
		if(checkInput([ESCAPE], [FlxGamepadInputID.BACK])) {
			clickQuit();
		}
    else if(checkInput([SPACE, ENTER], [FlxGamepadInputID.X, FlxGamepadInputID.START])) {
			getActiveButtonIndex().onUp.fire();
		}
    else if(checkInput([DOWN], [FlxGamepadInputID.X, FlxGamepadInputID.DPAD_DOWN])) {
			setActiveButtonIndex(activeButtonIndex+1);
		}
    else if(checkInput([UP], [FlxGamepadInputID.X, FlxGamepadInputID.DPAD_UP])) {
			setActiveButtonIndex(activeButtonIndex-1);
		}

    super.update(elapsed);
	}

	private function clickPlay():Void
  { 
     FlxG.switchState(new PlayState());
  }

	private function clickQuit():Void
  { 
    System.exit(0);
  }
}
