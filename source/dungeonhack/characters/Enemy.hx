package dungeonhack.characters;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.addons.nape.FlxNapeSprite;
import flixel.math.FlxPoint;


import dungeonhack.characters.Character;

class Enemy extends Character
{
  public  var target: FlxNapeSprite;
  private var lastKnownTargetPosition: FlxPoint;
  private var secondsSinceLastSawTarget: Float;
  private var ai:FSM;
  private var activeStateName:String;
 
 
  public function new(?X:Float=0, ?Y:Float=0,?characterSpriteSheet:FlxGraphicAsset, mHealth: Int =20, eSpeed: Int = 100, spriteRowSize: Int = 32)
  {
      super(CharacterType.ENEMY, mHealth, eSpeed, X, Y, characterSpriteSheet,128,128, spriteRowSize);
      
      secondsSinceLastSawTarget = 1000;
      
      ai = new FSM(idleState);

      for(shape in body.shapes) {
        shape.userData.enemy = true;
      }
  }

  private function setState(stateFunc:Float->Void, stateName:String):Void {
    ai.setState(stateFunc);
    activeStateName = stateName;  
  }


  private function idleState(elapsed:Float): Void {
    if(target.alive) {
      var losResult = seesTargetSprite(target, meleeStats.distance/2);
      if(losResult != LineOfSiteResult.NO_LOS) {
        setState(chaseState, "chaseState");
        secondsSinceLastSawTarget = 0;
      }
    }
    characterMove(elapsed);
  }


  private function chaseState(elapsed:Float):Void {
    if(!target.alive) {
      setState(idleState, "idleState");  
      characterMove(elapsed);
      return;
    }
    var losResult = seesTargetSprite(target, meleeStats.distance/2);
    
    switch(losResult) {
      case LineOfSiteResult.CLOSE: {
        setState(meleeState, "meleeState");
        secondsSinceLastSawTarget = 0;
      }
      case LineOfSiteResult.SEES :{
        secondsSinceLastSawTarget = 0;
      }
      case LineOfSiteResult.NO_LOS: {
        if(secondsSinceLastSawTarget > 3) {
          setState(idleState, "idleState"); 
        }
      }
    }

    characterMove(elapsed, goToTarget());
  }

  private function meleeState(elapsed:Float):Void {
    var losResult = seesTargetSprite(target, meleeStats.distance/2);
    if(losResult == LineOfSiteResult.CLOSE) {
      this.characterMelee();
    }
    else {
      setState(chaseState,"chaseState");  
    }
    secondsSinceLastSawTarget = 0;
    characterMove(elapsed, goToTarget());
  }


  private function deadState(elapsed:Float):Void {
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
        getBodyPosition().distanceTo(lastKnownTargetPosition) >= Character.distanceToTargetThreshold) {
        return MoveInput.newTarget(lastKnownTargetPosition);
      }
      return null;
      
    }
    lastKnownTargetPosition = currentTargetPostion;
    
    return MoveInput.newTarget(points[0]);
  }


  override public function update(elapsed:Float):Void
  {
     ai.update(elapsed);
     super.update(elapsed);
     secondsSinceLastSawTarget+= elapsed;
  }

  override public function onDied() {
    super.onDied();
    setState(deadState,"deadState");
  }
}