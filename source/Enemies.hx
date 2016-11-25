package ;


class OrcArcher extends Enemy {

  public function new(?X:Float=0, ?Y:Float=0) {
    super(X, Y, AssetPaths.orc_archer_0__png, 10, 110);
    //setMelee(_cooldown: Float= 0.5, _maxDamage: Float = 10, _distance:Float = 50, _critChance:Float = 0.05, _missChance:Float =0.1)
    setMelee(.8, 8, 50, 0.1, 0.1);
  }
}

class Orc extends Enemy {

  public function new(?X:Float=0, ?Y:Float=0) {
    super(X, Y, AssetPaths.orc_regular_0__png, 14);
    //setMelee(_cooldown: Float= 0.5, _maxDamage: Float = 10, _distance:Float = 50, _critChance:Float = 0.05, _missChance:Float =0.1)
    setMelee(0.6, 5, 50, 0.05, 0.2);
  }
}

class OrcHeavy extends Enemy {

  public function new(?X:Float=0, ?Y:Float=0) {
    super(X, Y, AssetPaths.orc_heavy_1__png, 18, 80);
    //setMelee(_cooldown: Float= 0.5, _maxDamage: Float = 10, _distance:Float = 50, _critChance:Float = 0.05, _missChance:Float =0.1)
    setMelee(1, 12, 50, 0.08, 0.2);
  }
}

class OrcElite extends Enemy {

  public function new(?X:Float=0, ?Y:Float=0) {
    super(X, Y, AssetPaths.orc_elite_0__png, 25, 100);
    //setMelee(_cooldown: Float= 0.5, _maxDamage: Float = 10, _distance:Float = 50, _critChance:Float = 0.05, _missChance:Float =0.1)
    setMelee(0.5, 12, 50, 0.08, 0.1);
  }
}



class Skeleton extends Enemy {

  public function new(?X:Float=0, ?Y:Float=0) {
    super(X, Y, AssetPaths.skeleton_0__png, 40, 120);
    //setMelee(_cooldown: Float= 0.5, _maxDamage: Float = 10, _distance:Float = 50, _critChance:Float = 0.05, _missChance:Float =0.1)
    setMelee(0.6, 10, 50, 0.05, 0.1);
  }
}

class Minotaur extends Enemy {

  public function new(?X:Float=0, ?Y:Float=0) {
    super(X, Y, AssetPaths.skeleton_0__png, 80, 100);
    //setMelee(_cooldown: Float= 0.5, _maxDamage: Float = 10, _distance:Float = 50, _critChance:Float = 0.05, _missChance:Float =0.1)
    setMelee(0.6, 15, 60, 0.05, 0.1);
  }
}