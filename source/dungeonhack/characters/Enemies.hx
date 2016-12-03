package dungeonhack.characters;

import dungeonhack.characters.Enemy;

class OrcArcher extends Enemy {

  public function new(?X:Float=0, ?Y:Float=0) {
    super(X, Y, AssetPaths.orc_archer_0__png, 10, 110);
    //setMelee(_cooldown: Float= 0.5, _maxDamage: Float = 10, _distance:Float = 50, _critChance:Float = 0.05, _missChance:Float =0.1)
    setMelee(0.8, 8, 50, 0.1, 0.1);
  }

  override public function setUpSounds() {
    meleeSounds.add(AssetPaths.ogre1__wav);
    meleeSounds.add(AssetPaths.ogre2__wav);
    hurtSounds.add(AssetPaths.ogre3__wav);
    hurtSounds.add(AssetPaths.ogre4__wav);
    hurtSounds.add(AssetPaths.ogre5__wav);
  }
}

class Orc extends Enemy {

  public function new(?X:Float=0, ?Y:Float=0) {
    super(X, Y, AssetPaths.orc_regular_0__png, 14);
    //setMelee(_cooldown: Float= 0.5, _maxDamage: Float = 10, _distance:Float = 50, _critChance:Float = 0.05, _missChance:Float =0.1)
    setMelee(0.6, 5, 50, 0.05, 0.2);
  }
  
  override public function setUpSounds() {
    meleeSounds.add(AssetPaths.ogre1__wav);
    meleeSounds.add(AssetPaths.ogre2__wav);
    hurtSounds.add(AssetPaths.ogre3__wav);
    hurtSounds.add(AssetPaths.ogre4__wav);
    hurtSounds.add(AssetPaths.ogre5__wav);
  }
}

class OrcHeavy extends Enemy {

  public function new(?X:Float=0, ?Y:Float=0) {
    super(X, Y, AssetPaths.orc_heavy_1__png, 18, 80);
    //setMelee(_cooldown: Float= 0.5, _maxDamage: Float = 10, _distance:Float = 50, _critChance:Float = 0.05, _missChance:Float =0.1)
    setMelee(1, 12, 50, 0.08, 0.2);
  }

  override public function setUpSounds() {
    meleeSounds.add(AssetPaths.ogre1__wav);
    meleeSounds.add(AssetPaths.ogre2__wav);
    hurtSounds.add(AssetPaths.ogre3__wav);
    hurtSounds.add(AssetPaths.ogre4__wav);
    hurtSounds.add(AssetPaths.ogre5__wav);
  }
}

class OrcElite extends Enemy {

  public function new(?X:Float=0, ?Y:Float=0) {
    super(X, Y, AssetPaths.orc_elite_0__png, 25, 100);
    //setMelee(_cooldown: Float= 0.5, _maxDamage: Float = 10, _distance:Float = 50, _critChance:Float = 0.05, _missChance:Float =0.1)
    setMelee(0.5, 12, 50, 0.08, 0.1);
  }
  
  override public function setUpSounds() {
    meleeSounds.add(AssetPaths.ogre1__wav);
    meleeSounds.add(AssetPaths.ogre2__wav);
    hurtSounds.add(AssetPaths.ogre3__wav);
    hurtSounds.add(AssetPaths.ogre4__wav);
    hurtSounds.add(AssetPaths.ogre5__wav);
  }
}



class Skeleton extends Enemy {

  public function new(?X:Float=0, ?Y:Float=0) {
    super(X, Y, AssetPaths.skeleton_0__png, 40, 120);
    //setMelee(_cooldown: Float= 0.5, _maxDamage: Float = 10, _distance:Float = 50, _critChance:Float = 0.05, _missChance:Float =0.1)
    setMelee(0.6, 10, 50, 0.05, 0.1);
  }

  override public function setUpAnimations() {
    addAnimation("idle", 0, 4, true);
    addAnimation("move", 4, 8);
    addAnimation("melee", 12, 4);
    addAnimation("hit", 20, 2);
    addAnimation("die",18, 8);
  }

  override public function setUpSounds() {
    meleeSounds.add(AssetPaths.mnstr1__wav);
    meleeSounds.add(AssetPaths.mnstr2__wav);
    meleeSounds.add(AssetPaths.mnstr3__wav);
    meleeSounds.add(AssetPaths.mnstr4__wav);
    hurtSounds.add(AssetPaths.mnstr10__wav);
    hurtSounds.add(AssetPaths.mnstr11__wav);
  }
}

class Minotaur extends Enemy {

  public function new(?X:Float=0, ?Y:Float=0) {
    super(X, Y, AssetPaths.minotaur_alpha__png, 80, 100);
    //setMelee(_cooldown: Float= 0.5, _maxDamage: Float = 10, _distance:Float = 50, _critChance:Float = 0.05, _missChance:Float =0.1)
    setMelee(0.6, 15, 60, 0.2, 0.1);
  }

  override public function setUpSounds() {
    meleeSounds.add(AssetPaths.shade5__wav);
    meleeSounds.add(AssetPaths.shade2__wav);
    meleeSounds.add(AssetPaths.shade3__wav);
    meleeSounds.add(AssetPaths.shade4__wav);
    hurtSounds.add(AssetPaths.giant1__wav);
    hurtSounds.add(AssetPaths.giant4__wav);
  }
}