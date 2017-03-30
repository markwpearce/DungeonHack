package dungeonhack.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

import dungeonhack.util.*;

typedef Credit = {
  name:String,
  note:String,
  web:String,
  licence:String
};

enum LineType {
  HEAD;
  SUBHEAD;
  DETAIL;
}

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
    createLine("DungeonHack", HEAD, 0);
    createLine("A Game By Mark Pearce", SUBHEAD, 0);
    createEmptySpace();
    createSeparator();
    createEmptySpace();

    var creditTypes = ["Art", "Music", "Sound"];

    for(creditType in creditTypes) {
      createLine(creditType, HEAD, 1);
      var creditsList:Array<Credit> = Reflect.field(credits, creditType);
      for(credit in creditsList) {
        createLine(credit.name, SUBHEAD, 2);
        if(credit.web != null) {
          createLine(credit.web, DETAIL, 3);
        }
        if(credit.note != null) {
          createLine(credit.note, DETAIL, 3);
        }
        if(credit.licence != null) {
          createLine("Licence: "+credit.licence, DETAIL, 3);
        }
        createEmptySpace();
      }
      createSeparator();    
    }
  }

  private function createSeparator(): Void {
    createLine("------------", HEAD, 1); 
  }

  private function createEmptySpace(): Void {
    createLine("", SUBHEAD, 2);
  }



  private function createLine(text:String, lineType:LineType, level:Int):Void {
    var font = AssetPaths.TheWildBreathofZelda__otf;
    switch(lineType) {
      case HEAD:
        font = AssetPaths.TheWildBreathofZelda__otf;
      case SUBHEAD:
        level += 2;
        font = AssetPaths.PixelMusketeer__otf;
      case DETAIL:
        font = null;
        level += 4;
    }
    var fontSize = 32-level*3;
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
		if(CheckInput.check([ESCAPE, SPACE, ENTER], [FlxGamepadInputID.BACK, FlxGamepadInputID.X, FlxGamepadInputID.START])) {
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
