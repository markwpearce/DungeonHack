package;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.addons.nape.FlxNapeSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import Character;


class Enemy extends Character
{
  public  var target: FlxNapeSprite;
  private var lastKnownTargetPosition: FlxPoint;
 
  public function new(?X:Float=0, ?Y:Float=0,?characterSpriteSheet:FlxGraphicAsset)
  {
      super(100, X, Y, characterSpriteSheet);
  }
  

  private function goToTarget():MoveInput {
    if(target == null) {
      return null;
    }
    var currentTargetPostion = getBodyPosition(target.body.position);
  
    var points = findPathTo(currentTargetPostion);
    if(points == null || points.length < 1)
    {
      if(lastKnownTargetPosition != null &&
        getBodyPosition().distanceTo(lastKnownTargetPosition) >= distanceToTargetThreshold) {
        return MoveInput.newTarget(lastKnownTargetPosition);
      }
      return null;
      
    }
    lastKnownTargetPosition = currentTargetPostion;
    
    return MoveInput.newTarget(points[0]);
  }


  override public function update(elapsed:Float):Void
  {
     characterMove(elapsed, goToTarget());
     super.update(elapsed);
  }
}