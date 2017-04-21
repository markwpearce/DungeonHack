package dungeonhack.debug;

import flixel.system.debug.FlxDebugger;

import dungeonhack.characters.Enemies;

class EnemyDebugWindow extends DebugWindow {

  private var addEnemyCallback:Null<Void -> Void>;

  public var selectedEnemy:String ="";

  public function new(addEnemyFunc:Null<Void -> Void>) {
    super("Enemy Debug");
    addEnemyCallback = addEnemyFunc;

    selectedEnemy = Enemies.ENEMY_TYPE_LIST[0];
    addLabeledSelect("Enemy type", Enemies.ENEMY_TYPE_LIST, selectEnemy);

    addLabeledButton("Add enemy", addEnemyCallback, new GraphicInteractive(0, 0));    
  }


  private function selectEnemy(enemyName: String) {
    trace('Select Enemy ${enemyName}');
    selectedEnemy = enemyName;

  }

}