package dungeonhack.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.util.FlxColor;

class MenuState extends FlxState
{

  public var bkgrnd: FlxSprite;
	private var selectText: FlxText;
  public var buttons: Array<FlxButton> = new Array<FlxButton>();
  public var buttonHeight:Int = 30;
  public var horizontalOffset = 170;
  public var activeButtonIndex:Int = -1;

  private var selectTextAdded = false;

  override public function create():Void
	{
    bkgrnd = new FlxSprite(0, 0, AssetPaths.TitleScreen__png);
		bkgrnd.screenCenter();
    add(bkgrnd);
    selectText = new FlxText(0,0,0,"->                                  	<-");
		selectText.alignment = FlxTextAlign.CENTER;
		selectText.screenCenter();
    selectText.x+=horizontalOffset;
    selectText.bold = true;
    
  }

  public function setButtonPosition(butHeight:Int = 30, hOffset:Int=170) {
    buttonHeight = butHeight;
    horizontalOffset = hOffset;
  }

  public function addButton(name:String, ?OnClick:Null<Void -> Void> ):Void {
    var button:FlxButton = new FlxButton(0, 0, name, OnClick);
    button.makeGraphic(100, buttonHeight, FlxColor.TRANSPARENT);
    button.label.setFormat(AssetPaths.PixelMusketeer__otf, 16, FlxColor.WHITE,
      FlxTextAlign.CENTER,FlxTextBorderStyle.SHADOW);
    button.screenCenter();
    button.y += (buttons.length * buttonHeight);
    button.x +=horizontalOffset;
    buttons.push(button);
    add(button);
  }

  public function setActiveButtonIndex(buttonNum:Int):Void {
    buttonNum = buttonNum < 0 ?  0 : buttonNum;
    buttonNum = buttonNum > buttons.length-1 ? buttons.length-1 : buttonNum;
    activeButtonIndex = buttonNum;
    selectText.y = buttons[activeButtonIndex].y+8;
    if(!selectTextAdded) {
      add(selectText);
      selectTextAdded = true;
    }
  }
  
  public function getActiveButtonIndex(): FlxButton {
    return buttons[activeButtonIndex];
  }
}
