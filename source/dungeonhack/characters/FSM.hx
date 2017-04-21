package dungeonhack.characters;


class FSM
 {
     public var activeState:Float->Void;
     public var activeStateName:String;
     

     public function new(?InitState:Float->Void):Void
     {
         activeState = InitState;
     }

     public function update(elapsed:Float):Void
     {
         if (activeState != null)
             activeState(elapsed);
     }

     public function setState(nextState:Float->Void):Void {
       activeState = nextState;
       activeStateName = '${nextState}';
     }


 }