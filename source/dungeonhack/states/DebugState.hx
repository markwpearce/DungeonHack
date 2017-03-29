package dungeonhack.states;

import flixel.FlxG;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.util.FlxColor;
import flixel.FlxG;

import dungeonhack.characters.*;
import dungeonhack.characters.Enemies;

class DebugState extends PlayState
{
	override public function create():Void
	{
    super.create();
    bgColor = FlxColor.GRAY;
    FlxNapeSpace.drawDebug = true;
    setLevelMap(AssetPaths.DebugLevel__tmx);
		setPlayer(new Player());
    FlxG.sound.music.stop();
	}


	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

}
