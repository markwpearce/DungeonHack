package dungeonhack.ui;

import flixel.math.FlxMath;
import flixel.FlxBasic;
import flixel.ui.FlxBar;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.util.FlxColor;

import dungeonhack.characters.Character;

class HealthBar extends FlxBasic {

  private var character:Character;
  private var healthBar: FlxBar;

  private var healthBarWidth: Int;

  private static inline var MIN_WIDTH = 20;
  private static inline var MAX_WIDTH = 128;
  private static inline var HEALTH_FOR_MIN_WIDTH = 0;
  private static inline var HEALTH_FOR_MAX_WIDTH = 200;
  private static inline var VISIBLE_THRESHOLD = 200;
  private static inline var FULLY_VISIBLE_THRESHOLD = 80;

  private var previousDistance = 1000000;

  static public var target: Character;

  public var verticalOffset:Float = 40;
  
  public function new(char:Character) {
    super();
    character = char;
    healthBar = new FlxBar(20,5, FlxBarFillDirection.LEFT_TO_RIGHT, getHealthBarWidth(), 5, null, "" , 0, 100, true);
    healthBar.createFilledBar(FlxColor.BLACK, FlxColor.RED, true, FlxColor.WHITE);
    setHealthBarPosition();
  }

  private function getHealthBarWidth():Int {
    var barWidth = Math.floor(FlxMath.lerp(MIN_WIDTH, MAX_WIDTH,
      Math.min(HEALTH_FOR_MAX_WIDTH, character.maxHealth/HEALTH_FOR_MAX_WIDTH)));    
    return barWidth;
  }

  private function setHealthBarPosition() {
    healthBar.x =  character.x+ Math.floor(character.width/2-healthBar.barWidth/2);
    healthBar.y = character.y+verticalOffset;
  }

  private function getAlphaValue():Float {
    if(target == null || !character.alive || !target.alive) {
      return 0;
    }

    var distance = Math.max(0,character.distanceToNapeSprite(target)-FULLY_VISIBLE_THRESHOLD);
    distance = Math.min(distance, VISIBLE_THRESHOLD-FULLY_VISIBLE_THRESHOLD); 
    distance = distance/(VISIBLE_THRESHOLD-FULLY_VISIBLE_THRESHOLD);
    var barAlpha = FlxMath.lerp(1,0,distance);
    return barAlpha;
  }

  public override function update(elapsed:Float) {
    setHealthBarPosition();
    healthBar.percent = (character.health / character.maxHealth)*100;
    healthBar.alpha = getAlphaValue();
  }

  public function getSprite():FlxSprite {
    return healthBar;
  }

}