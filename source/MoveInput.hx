package ;

import flixel.math.FlxPoint;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.FlxSprite;

class MoveInput
{
  public var up : Bool;
  public var down: Bool;
  public var left: Bool;
  public var right: Bool;
  public var target: FlxPoint;
  public var xAxis: Float;
  public var yAxis: Float;
  public var angle: Float;
  public var magnitude: Float;

  public function new(u:Bool=false, d:Bool=false, l:Bool=false, r:Bool=false, ?tar:FlxPoint, x:Float = 0, y:Float=0) {
    up = u;
    down = d;
    left = l;
    right = r;
    target = tar;
    xAxis = x;
    yAxis = y;
  }

  public static function newDirection(u:Bool=false, d:Bool=false, l:Bool=false, r:Bool=false) : MoveInput {
    return new MoveInput(u, d, l, r);
  }

  public static function newTarget(?tar:FlxPoint) : MoveInput {
    return new MoveInput(false, false, false, false, tar);
  }

  public static function newAxis(x:Float = 0, y:Float=0) : MoveInput {
    return new MoveInput(false, false, false, false, null, x, y);
  }

  public function toString():String {
    var str = "MoveInput {up:"+up+", down:"+down+", left:"+left+", right:"+right+", target:";

    str += target != null ? "("+target.x+", "+target.y+"), " : "null, ";
    str += "xAxis:"+xAxis+", yAxis:"+yAxis+", angle:"+angle+"}";

    return str;
  }

  public function isEmpty() : Bool {
    return !up && !down && !left && !right && target == null && xAxis == 0 && yAxis == 0; 
  }

  public function setDirectionAndAngle(?sprite: FlxSprite):Void
  {
    if(target != null && sprite != null) {
      angle = FlxAngle.angleBetweenPoint(sprite, target);
      setDirectionFromAngle();
    }
    else if(xAxis != 0 || yAxis != 0) {
      angle =  FlxAngle.wrapAngle(Math.atan2(yAxis, xAxis));
      setDirectionFromAngle();      
    }
    else {
      setAngleFromDirection();
    }
    setMagnitude();
  }

  private function setDirectionFromAngle(): Void 
  {
    up = false;
    down = false;
    left = false;
    right = false;
    
    var aD =  angle * (180/Math.PI);

    if(aD <= -150) {
      left = true;
    }
    else if(aD > -150 && aD <= -105) {
      up = true;
      left = true;
    }else if(aD > -105 && aD <= -60) {
      up = true;
    }
    else if(aD > -60 && aD <= -15) {
      up = true;
      right = true;
    }
    else if(aD > -15 && aD <= 30) {
      right = true;
    }
    else if(aD > 30 && aD<=75) {
      down = true;
      right = true;
    } 
    else if(aD > 75 && aD<=120) {
      down = true;
    }
    else if(aD > 120 && aD<=165) {
      down = true;
      left = true;
    }
    else if(aD > 165) {
      left = true;
    }
  }


  private function setAngleFromDirection(inRad:Bool = true): Float 
  {
    var mA:Float = 0;
    var angleChange = 60; //isometric. true topdown -> 45
    if (up)
    {
        mA = -90;
        if (left)
            mA -= angleChange;
        else if (right)
            mA += angleChange;
    }
    else if (down)
    {
        mA = 90;
        if (left)
            mA += angleChange;
        else if (right)
            mA -= angleChange;
    }
    else if (left)
        mA = 180;
    else if (right)
        mA = 0;
    
    if(inRad) {
      mA =  mA * (Math.PI/180);
    }
    angle = mA;
    return angle;
  }


  private function setMagnitude(): Float {
    if(xAxis == 0 && yAxis == 0) {
      magnitude = 1.0;
    }
    else {
      magnitude = Math.sqrt(xAxis*xAxis + yAxis*yAxis);
    }
   
    return magnitude;
  }

}