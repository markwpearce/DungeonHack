class FSM
 {
     public var activeState:Float->Void;

     public function new(?InitState:Float->Void):Void
     {
         activeState = InitState;
     }

     public function update(elapsed:Float):Void
     {
         if (activeState != null)
             activeState(elapsed);
     }
 }