package dungeonhack.states;

import flixel.FlxG;

import dungeonhack.characters.*;
import dungeonhack.characters.Enemies;

class GameState extends PlayState
{


	public var gameLength: Float = 10;

	private var enemiesByLevel: Array< Array< String > >;

	override public function create():Void
	{
    super.create();

    addLevelMap(AssetPaths.Dungeon1__tmx);
		setPlayer(new Player());

		enemiesByLevel = new Array< Array< String> > ();
	
		FlxG.sound.playMusic(AssetPaths.Dark_Amb__ogg, 0.8, true);
 		//FlxG.sound.pause;
	}

	private function addLeveledEnemy() {

		var enemyLevelNum = player.level;
		var enemy;
		/*var enemyLevel = enemiesByLevel[enemyLevelNum];
		var enemyName = enemyLevel[random.int(0,enemyLevel.length-1)];
		
		var enemyT = Type.createInstance( Type.resolveClass(enemyName), []);
		var enemy: Enemy = cast enemyT;
		*/
		
		switch(enemyLevelNum) {
			case 1:{
				enemy = enemies.length % 1== 0 ?
					new OrcArcher() : new Orc();
			}

			case 2:{
				enemy = enemies.length % 2 == 0 ?
					new OrcHeavy() : new Orc();
			}

			case 3:{
				enemy = enemies.length % 2 == 0 ?
					new OrcHeavy() : new OrcElite();
			}

			case 4:{
				enemy = enemies.length % 2 == 0 ?
					new OrcElite() : new Skeleton();
			}

			default: {
				enemy =  	new Minotaur();
			}
		}
    addEnemy(enemy);
	}


	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		gameLength+= elapsed;

		if(gameLength > 8) {
			addLeveledEnemy();
			gameLength = 0;
		}
		
	}
}
