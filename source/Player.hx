package;

import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxPoint;
import Character;


class Player extends Character
{

  public var exp: Int = 0;
  public var nextLevel: Int = 20;
  private var secondsSinceLastMove: Float = 0;
 
  
  public function new(?X:Float=0, ?Y:Float=0)
  {
      super(CharacterType.PLAYER, 50, 200, X, Y, AssetPaths.female_hero_knight__png);
      for(shape in body.shapes) {
        shape.userData.player = true;
      }
      name = "Player";
  }
  
  override public function update(elapsed:Float):Void
  {
     if(getQuit()) {
       FlxG.switchState(new MenuState());
     }
     
     if(getMelee()) {
       characterMelee();
       secondsSinceLastMove = -1;
     }
     else {
       movement(elapsed);
     }
     super.update(elapsed);
  }

  private function getInput():MoveInput 
  {
    var _up:Bool = false;
    var _down:Bool = false;
    var _left:Bool = false;
    var _right:Bool = false;
    var gpX:Float = 0;
    var gpY:Float = 0;
    
    _up = FlxG.keys.anyPressed([UP, W]);
    _down = FlxG.keys.anyPressed([DOWN, S]);
    _left = FlxG.keys.anyPressed([LEFT, A]);
    _right = FlxG.keys.anyPressed([RIGHT, D]);

    if(FlxG.gamepads.lastActive != null) {
      var gp = FlxG.gamepads.lastActive;
      gpX = gp.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK);
      gpY = gp.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK);
      var deadZone:Float = 0.1;
      
      _up = _up || gpY < -deadZone;
      _down = _down || gpY > deadZone;
      _left = _left || gpX < -deadZone;
      _right = _right || gpX > deadZone;
      
      if(gpX!= 0 || gpY!=0) {
        return MoveInput.newAxis(gpX, gpY);
      }
    }
    if (_up && _down)
      _up = _down = false;
    if (_left && _right)
      _left = _right = false;

    return MoveInput.newDirection(_up, _down, _left, _right);
  }

  private function getMelee():Bool {
    
    var attack = FlxG.keys.anyJustPressed([SPACE]);
    if(!attack && FlxG.gamepads.lastActive != null) {
      var gp = FlxG.gamepads.lastActive;
      attack = gp.anyJustPressed([FlxGamepadInputID.X]);
    }

    return attack;
  }

  private function getQuit():Bool {
    var exit = FlxG.keys.anyJustPressed([ESCAPE]);
    if(!exit && FlxG.gamepads.lastActive != null) {
      var gp = FlxG.gamepads.lastActive;
      exit = gp.anyJustPressed([FlxGamepadInputID.BACK]);
    }

    return exit;
  }

  private function movement(elapsed: Float):Void
  {
    var input = getInput();
    if(input.isEmpty()) {
      secondsSinceLastMove += elapsed;
      if(secondsSinceLastMove > 1 && alive) {
        health = Math.round(Math.min(health+2, maxHealth));
        secondsSinceLastMove = 0;
      }
    }
    else {
       secondsSinceLastMove = 0;
    }
    
    characterMove(elapsed, input);
  }


  override public function onKilledSomething(entity: Character) {
    var moreExp = Math.round(entity.maxHealth/5);
    exp += moreExp;
    PopText.show(getBodyPosition(), "+"+moreExp, flixel.util.FlxColor.WHITE);
   
    if(exp >= nextLevel) {
      exp = exp % nextLevel;
      nextLevel = Math.round(nextLevel*1.2);
      maxHealth = Math.round(maxHealth*1.5);
      health = maxHealth;
      level++;
      PopText.showCenter("LEVEL UP!", flixel.util.FlxColor.WHITE, true, true);
    }
  }

  override public function onDied() {
    PopText.showCenter("GAME OVER!", flixel.util.FlxColor.RED, true, true);
    super.onDied();
  }
}