package dungeonhack.sound;

import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.system.FlxSoundGroup;
import flixel.FlxSprite;
import flixel.FlxBasic;
import openfl.Assets;



class SoundPlayer extends FlxBasic {

  private var emitter: FlxSprite;

  private var soundGroup: FlxSoundGroup;

  private var persistentSounds: Array<FlxSound> = new Array<FlxSound>();

  public function new(emitterSprite: FlxSprite, ?group: FlxSoundGroup) {
    emitter = emitterSprite;
    if(group != null) {
      soundGroup = group;
    }
    else {
      soundGroup = SoundGlobal.soundEffectsGroup;
    }
    super();
  }

  public function play(assetName:String, loop: Bool = false, useProximity: Bool = true): FlxSound {
    var sound = new FlxSound();
    sound.loadEmbedded(assetName, loop, true);
    sound.group = soundGroup;

    if(useProximity) {
      sound.proximity(emitter.x, emitter.y, SoundGlobal.soundListener, 400);
    }
    if(loop) {
      persistentSounds.push(sound);
    }

    return sound;
  }

  override public function update(elapsed: Float) {
    for(sound in persistentSounds) {
      sound.setPosition(emitter.x, emitter.y);
    }

    super.update(elapsed);
  }


  override public function destroy():Void {

    for(sound in persistentSounds) {
      sound.stop();
    }
  
    super.destroy();
  }

  

}