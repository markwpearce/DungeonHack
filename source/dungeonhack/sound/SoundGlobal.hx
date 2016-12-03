package dungeonhack.sound;

import flixel.system.FlxSoundGroup;
import flixel.FlxObject;

class SoundGlobal {

  static public var soundEffectsGroup: FlxSoundGroup = new FlxSoundGroup(0.8);
  static public var quietSoundEffectsGroup: FlxSoundGroup = new FlxSoundGroup(0.4);
  static public var soundListener: FlxObject;
}