package;

import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxPoint;

typedef MoveInput = {
  var up : Bool;
  var down: Bool;
  var left: Bool;
  var right: Bool;
}

class Character extends FlxNapeSprite
{
  static var NoMovement:MoveInput = {up: false, down: false, left: true, right: false};
  
  
  public var maxSpeed:Float = 200;
  public var pointing:MoveInput = {up: false, down: false, left: true, right: false};

  public function new(maxSpeedVal:Float=200, X:Float=0, Y:Float=0, ?characterSpriteSheet:FlxGraphicAsset, spriteWidth:Int=128, spriteHeight:Int=128)
  {
      super(X, Y, null, false, true);
      loadGraphic(characterSpriteSheet, true, spriteWidth, spriteHeight);
      origin.set(spriteWidth/2,spriteHeight*0.75);
      createCircularBody(10);
      setBodyMaterial(0,1, 0.8, 1, 0.01);
      body.space = FlxNapeSpace.space;
      body.allowMovement = true;
      body.allowRotation = false;
      
      maxSpeed = maxSpeedVal;
      addAnimation("idle", 0, 4, true);
      addAnimation("move", 4, 8);
  }
  
  override public function update(elapsed:Float):Void
  {
     super.update(elapsed);
  }

  public function addAnimation(name:String, start:Int, numberOfFrames:Int, pingPong: Bool = false)
  {
    var directions = ["l", "ul", "u", "ur", "r", "dr", "d", "dl"];
    for(i in 0...8) {
      var animName = name+"_"+directions[i];
      var animStart:Int = start+i*32;
      var animEnd:Int = start+numberOfFrames+i*32;

      var frames = [for (j in animStart...animEnd) j];

      if(pingPong) {
        frames = frames.concat([for (j in 0...(animEnd-animStart)) animEnd-1-j]);
      }
      animation.add(animName, frames, 10, false);
    }
  }

  public function playAnimation(name:String)
  {
    var direction = "";
    if(pointing.up) direction += "u";
    else if(pointing.down) direction += "d";
    if(pointing.left) direction += "l";
    else if(pointing.right) direction += "r";

    var animationName = "";
    if(direction.length  == 0)
    {
      animationName = "idle_l";
    }
    else {
      animationName = name+"_"+direction;
    }

    if(animation.getByName(animationName) != null) {
      animation.play(animationName);
    }
    
      
  }
  
  public function getMovementAngle(input:MoveInput, inRad:Bool = true): Float 
  {
    var mA:Float = 0;
    var angleChange = 60; //isometric. true topdown -> 45
    if (input.up)
    {
        mA = -90;
        if (input.left)
            mA -= angleChange;
        else if (input.right)
            mA += angleChange;
    }
    else if (input.down)
    {
        mA = 90;
        if (input.left)
            mA += angleChange;
        else if (input.right)
            mA -= angleChange;
    }
    else if (input.left)
        mA = 180;
    else if (input.right)
        mA = 0;
    
    if(inRad) {
      mA =  mA * (Math.PI/180);
    }

    return mA;
  }

  public function getNormalizedSpeed(elapsed: Float, speedPercentage:Float=1.0): Float {
    return maxSpeed*60*elapsed*speedPercentage;
  }

  public function characterMove(elapsed: Float, ?direction:MoveInput, speedPercentage: Float = 1.0) {
    if(direction != null && (direction.up || direction.down || direction.right || direction.left))
    {
      pointing = direction;
      
      var angleRad = getMovementAngle(direction);
     
      body.velocity.set(new nape.geom.Vec2(getNormalizedSpeed(elapsed, speedPercentage), 0));
      body.velocity.rotate(angleRad);
      playAnimation("move");
    } 
    else {
      body.velocity.set(new nape.geom.Vec2(0, 0));
      
      playAnimation("idle");
    }
  
  }

}