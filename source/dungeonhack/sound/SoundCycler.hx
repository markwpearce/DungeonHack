package dungeonhack.sound;

import flixel.FlxSprite;
import haxe.Timer;


class SoundCycler {

  private var clips: Array<String>;
  private var player: SoundPlayer;

  public var debounceMs: Float = 0;
  
  private var lastPlayTime: Float;

  
  public function new(soundPlayer: SoundPlayer, ?soundClips:Array<String>, dbnceMs: Float = 0) {
    player = soundPlayer;
    clips = new Array<String>();
    if(soundClips != null) {
      for(clip in soundClips) {
        add(clip);
      }
    }

    debounceMs = dbnceMs;
    lastPlayTime = 0;
  }

  public function clear() {
    while(clips.length > 0) {
      clips.pop();
    }
  }

  public function add(clipName: String) {
    clips.push(clipName);
  }


  public function play() {
    
    if(clips.length == 0) {
      trace("can't play! no clips!");
      return;
    }

    var now = Timer.stamp();

    if(debounceMs > 0 && (now - lastPlayTime)*1000 < debounceMs) {
      return;
    } 


    var clipName = clips[0];
    clips.splice(0, 1);
    clips.push(clipName);
    player.play(clipName);
    lastPlayTime = now;

  }


}
