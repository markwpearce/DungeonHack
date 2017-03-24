package dungeonhack.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;


typedef Credit = {
  name:String,
  note:String,
  web:String,
  licence:String
};

class CreditsState extends MenuState
{ 
  private var bkgrndDimmer: FlxSprite;

  private var credits:{
    Art:Array<Credit>,
    Music:Array<Credit>,
    Sound:Array<Credit>
  };
  
  private var textLines = new Array<FlxText>();

  private var nextLineY: Int;
  private var scrollLines = false;
  
	override public function create():Void
	{
    super.create();
		bkgrnd.loadGraphic(AssetPaths.TitleScreenNoText__png);
    
    bkgrndDimmer = new FlxSprite(360, 200);
    bkgrndDimmer.x = 0;
    bkgrndDimmer.y = 0;
    bkgrndDimmer.setGraphicSize(FlxG.width, FlxG.height);
    bkgrndDimmer.color = FlxColor.BLACK;
    bkgrndDimmer.alpha = 1;
    add(bkgrndDimmer);
    FlxTween.tween(bkgrndDimmer, { alpha: 0.5}, 1.0, {onComplete: startCredits, type: FlxTween.ONESHOT}); 
    nextLineY = FlxG.height;

    credits = haxe.Json.parse(sys.io.File.getContent(AssetPaths.credits__json));		
    createLines();
  }


  private function createLines() {
    createLine("DungeonHack", true, 0);
    createLine("A Game By Mark Pearce", false, 0);
    createLine("", false, 1);
    createLine("------------", true, 0);
    createLine("", false, 1);

    var creditTypes = ["Art", "Music", "Sound"];

    for(creditType in creditTypes) {
      createLine(creditType, true, 2);
      var creditsList:Array<Credit> = Reflect.field(credits, creditType);
      for(credit in creditsList) {
        createLine(credit.name, false, 2);
        if(credit.web != null) {
          createLine(credit.web, false, 3);
        }
        if(credit.note != null) {
          createLine(credit.note, false, 3);
        }
        if(credit.licence != null) {
          createLine("Licence: "+credit.licence, false, 3);
        }
        createLine("", false, 2);
      }
      createLine("------------", true, 1);    
    }
  }



  private function createLine(text:String, heading:Bool, level:Int):Void {
    if(!heading) {
      level += 2;
    }
    var fontSize = 32-level*3;
    var font = heading ?  AssetPaths.TheWildBreathofZelda__otf : AssetPaths.PixelMusketeer__otf;
    var color = FlxColor.WHITE;
    var text = new FlxText(0,0, 600, text, fontSize);
    text.setFormat(font, fontSize, color, FlxTextAlign.CENTER, FlxTextBorderStyle.SHADOW);
    text.screenCenter();
    text.y = nextLineY;
    nextLineY += Math.ceil(fontSize*1.5);
    add(text);
    textLines.push(text);
  }


  override public function update(elapsed:Float):Void
	{
		if(checkInput([ESCAPE, SPACE, ENTER], [FlxGamepadInputID.BACK, FlxGamepadInputID.X, FlxGamepadInputID.START])) {
			goToTitle();
		}
    if(scrollLines) {
      for(line in textLines) {
        line.y-=0.5;
      }
      if(textLines[textLines.length-1].y < -100) {
        goToTitle();
      }
    }
    super.update(elapsed);
	}

  private function goToTitle():Void {
     FlxG.switchState(new TitleState());
  }

  public function startCredits(tween:FlxTween): Void {
    scrollLines = true;
  }



}
