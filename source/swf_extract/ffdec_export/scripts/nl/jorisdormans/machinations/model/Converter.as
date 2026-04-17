package nl.jorisdormans.machinations.model
{
   public class Converter extends Source
   {
      
      public function Converter()
      {
         super();
         activationMode = MODE_PASSIVE;
      }
      
      override public function fire() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = int(inputs.length);
         while(_loc2_ < _loc1_)
         {
            if(inputs[_loc2_] is StateConnection && (inputs[_loc2_] as StateConnection).inhibited)
            {
               return;
            }
            _loc2_++;
         }
         setFiring();
         pull();
      }
      
      override public function satisfy() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(!_inhibited)
         {
            _loc1_ = int(outputs.length);
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               if(outputs[_loc2_] is StateConnection)
               {
                  (outputs[_loc2_] as StateConnection).fire();
               }
               _loc2_++;
            }
         }
         super.satisfy();
      }
      
      override public function get inhibited() : Boolean
      {
         return super.inhibited;
      }
      
      override public function set inhibited(param1:Boolean) : void
      {
         var _loc3_:int = 0;
         super.inhibited = param1;
         var _loc2_:int = int(inputs.length);
         while(_loc3_ < _loc2_)
         {
            if(inputs[_loc3_] is ResourceConnection)
            {
               (inputs[_loc3_] as ResourceConnection).checkInhibition(false);
            }
            _loc3_++;
         }
      }
      
      override public function checkInhibition() : void
      {
         var _loc1_:Boolean = false;
         var _loc3_:int = 0;
         _loc1_ = _inhibited;
         _inhibited = false;
         var _loc2_:int = int(inputs.length);
         while(_loc3_ < _loc2_)
         {
            if(inputs[_loc3_] is ResourceConnection)
            {
               (inputs[_loc3_] as ResourceConnection).checkInhibition(false);
            }
            _loc3_++;
         }
         _inhibited = _loc1_;
         super.checkInhibition();
      }
      
      public function canDrain() : Boolean
      {
         var _loc2_:int = 0;
         var _loc1_:int = int(inputs.length);
         while(_loc2_ < _loc1_)
         {
            if(inputs[_loc2_] is StateConnection)
            {
               if(!((inputs[_loc2_] as StateConnection).start is Delay) && !((inputs[_loc2_] as StateConnection).start is Gate) && (inputs[_loc2_] as StateConnection).label.type != Label.TYPE_TRIGGER && (inputs[_loc2_] as StateConnection).label.type != Label.TYPE_REVERSE_TRIGGER && !(inputs[_loc2_] as StateConnection).label.checkCondition((inputs[_loc2_] as StateConnection).state))
               {
                  return false;
               }
            }
            _loc2_++;
         }
         return true;
      }
   }
}

