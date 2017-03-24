package dungeonhack.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;


class CreditsState extends MenuState
{ 
  private var bkgrndDimmer: FlxSprite;

  private var credits:Dynamic;
  

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
    createLine("A Game By Mark Pearce", false, 1);
  }

  private function createLine(text:String, heading:Bool, level:Int):Void {
    if(!heading) {
      level += 2;
    }
    var fontSize = 28-level*4;
    var font = heading ?  AssetPaths.TheWildBreathofZelda__otf : AssetPaths.PixelMusketeer__otf;
    var color = FlxColor.WHITE;
    var text = new FlxText(0,0, 500, text, fontSize);
    text.setFormat(font, fontSize, color, FlxTextAlign.CENTER, FlxTextBorderStyle.SHADOW);
    text.screenCenter();
    text.y = nextLineY;
    nextLineY += fontSize+20;
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
