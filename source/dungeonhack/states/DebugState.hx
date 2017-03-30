package dungeonhack.states;

import flixel.FlxG;
import flixel.addons.nape.FlxNapeSpace;
import flixel.util.FlxColor;
import flixel.system.scaleModes.*;

import flixel.addons.ui.*;

import dungeonhack.characters.*;
import dungeonhack.ui.*;
import dungeonhack.util.*;
import dungeonhack.characters.Enemies;

class DebugState extends PlayState
{

  private var enemySelector: FlxUIDropDownMenu;
  private var lastEnemyType:String = "Orc";

	override public function create():Void
	{
    super.create();
    bgColor = FlxColor.GRAY;
    FlxNapeSpace.drawDebug = true;
    setLevelMap(AssetPaths.DebugLevel__tmx);
		setPlayer(new Player());
    FlxG.sound.music.stop();
    FlxG.debugger.visible = true;
    FlxG.debugger.drawDebug = true;
    FlxG.scaleMode = new FixedScaleMode();
    FlxG.camera.zoom = 1;

    addDebugUi();
	}


  private function addDebugUi():Void {
    var enemyLabels = new Array<StrNameLabel>();
    for(enemyType in Enemies.ENEMY_TYPE_LIST) {
      enemyLabels.push(new StrNameLabel(enemyType, enemyType));
    }
    enemySelector = new FlxUIDropDownMenu(5, 25, enemyLabels, addEnemyType);
    screenUi.addFixedSprite(enemySelector);
  } 

  private function addEnemyType(enemyType: String):Void {
    addEnemy(Enemies.createEnemyByType(enemyType));
    lastEnemyType = enemyType;
  } 


	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
    if(CheckInput.check([E])) {
      addEnemyType(lastEnemyType);
    }
    
	}

  override private function doQuit(): Void {
    FlxNapeSpace.drawDebug = false;
    FlxG.debugger.visible = false;
    FlxG.debugger.drawDebug = false;
    FlxG.scaleMode = new RatioScaleMode();
    bgColor = FlxColor.BLACK;
    
    super.doQuit();
  }

}
