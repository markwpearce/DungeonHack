package;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.math.FlxPoint;
import flixel.FlxState;
import flixel.FlxG;

class PopText extends FlxText {

  static public var currentState: FlxState;

  static public function show(position: FlxPoint, text: String = "", color:FlxColor = FlxColor.WHITE, bold:Bool =false, italic:Bool=false) {
    if(PopText.currentState == null) {
      return;
    }
    var x = position.x;
    var y = position.y;
    var popText = new PopText(x, y-50, 0, text);
    popText.alignment = FlxTextAlign.CENTER;
    popText.addFormat(new FlxTextFormat(color, bold, italic));
    FlxTween.linearMotion(popText, x, y-50, x, y-80, 1, true, {onComplete: popText.completeTween, type: FlxTween.ONESHOT });
    PopText.currentState.add(popText);
  }

  static public function showCenter(text: String = "",color:FlxColor = FlxColor.WHITE, bold:Bool =false, italic:Bool=false,  size:Int=16) {
    if(PopText.currentState == null) {
      return;
    }
    var popText = new PopText(0, 0, 0, text, size);
    popText.screenCenter();
    popText.x+=64;
		popText.y+=32;
		
    popText.alignment = FlxTextAlign.CENTER;
    popText.addFormat(new FlxTextFormat(color, bold, italic));
    FlxTween.color(popText, 3, color, FlxColor.TRANSPARENT, {startDelay: .5, onComplete: popText.completeTween, type: FlxTween.ONESHOT });
    popText.scrollFactor.set(0, 0);
    PopText.currentState.add(popText);
  }

  public function completeTween(tween:FlxTween): Void {
    destroy();
  }
}