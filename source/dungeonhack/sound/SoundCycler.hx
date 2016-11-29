package dungeonhack.sound;

import flixel.FlxSprite;


class SoundCycler {

  private var clips: Array<String>;
  private var player: SoundPlayer;



  public function new(soundPlayer: SoundPlayer, ?soundClips:Array<String>) {
    player = soundPlayer;
    clips = new Array<String>();
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
      return;
    }
    var clipName = clips[0];
    clips.splice(0, 1);
    clips.push(clipName);
    player.play(clipName);

  }


}
