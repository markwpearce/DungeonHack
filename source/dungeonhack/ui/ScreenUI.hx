package dungeonhack.ui;

import flixel.group.FlxGroup;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;

import dungeonhack.characters.Player;

class ScreenUI extends FlxTypedGroup<FlxSprite> {


  public var player: Player;
  private var healthBar: FlxBar;
  private var hpText: FlxText;
  private var expText: FlxText;
  private var lvlText: FlxText;
  private var setup: Bool = false;

  private var initialCamX: Float;
  private var initialCamY: Float;
  

  public function new(thePlayer: Player) {
    super();
    player = thePlayer;
    setupUI();


    
  }

  private function getScreenX():Float{
     var cam = FlxG.camera;
     return cam.scroll.x+(FlxG.camera.width)/6 + 64/1.5;
  }
  private function getScreenY():Float{
     var cam = FlxG.camera;
     return cam.scroll.y+ (FlxG.camera.height)/6 + 64/1.5;
  }

  private function setupUI() {
    if(setup) {
      return;
    }
   
    var screenX= getScreenX();
    var screenY= getScreenY();
     
    hpText = new FlxText(screenX+5, screenY+5, 100, "HP", 8);
    expText = new FlxText(screenX+5, screenY+5+10, 100, "EXP", 8);
    lvlText = new FlxText(screenX+5+69, screenY+5+10, 100, "LVL", 8);
    healthBar = new FlxBar(screenX+5+70, screenY+6, FlxBarFillDirection.LEFT_TO_RIGHT, 100, 10, null, "" , 0, 100, true);
    healthBar.fixedPosition = true;
    add(healthBar);
    add(lvlText);
    add(hpText);
    add(expText);
    

    forEach(function(spr:FlxSprite)
    {
      spr.scrollFactor.set(0, 0);
    });

    setup = true;
  }


  override public function update(elapsed: Float) {
    hpText.text = "HP "+player.health+" / "+player.maxHealth;
    expText.text = "EXP "+player.exp+" / "+player.nextLevel;
    lvlText.text = "LVL "+player.level;
    healthBar.percent = (player.health / player.maxHealth)*100;
    super.update(elapsed);
  }



}