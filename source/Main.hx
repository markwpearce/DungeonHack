package;

import flixel.FlxGame;
import openfl.display.Sprite;
import dungeonhack.states.TitleState
;


class Main extends Sprite
{
	public function new()
	{
		super();
		

		addChild(new FlxGame(0, 0, TitleState));
	}
}
