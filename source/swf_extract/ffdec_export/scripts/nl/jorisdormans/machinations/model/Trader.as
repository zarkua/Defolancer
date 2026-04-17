package nl.jorisdormans.machinations.model
{
   public class Trader extends Source
   {
      
      private var actAsConverter:Boolean;
      
      public function Trader()
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
      
      override public function prepare(param1:Boolean) : void
      {
         super.prepare(param1);
         var _loc2_:int = int(outputs.length);
         var _loc3_:uint = this.color;
         if(resourceOutputCount < 2 || resourceInputCount < 2)
         {
            this.actAsConverter = true;
         }
         else
         {
            this.actAsConverter = false;
         }
      }
      
      override public function receiveResource(param1:uint, param2:ResourceConnection) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:ResourceConnection = null;
         if(this.actAsConverter)
         {
            super.receiveResource(param1,param2);
         }
         else
         {
            _loc3_ = int(outputs.length);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc5_ = outputs[_loc4_] as ResourceConnection;
               if((Boolean(_loc5_)) && _loc5_.color == param2.color)
               {
                  _loc5_.resources.push(new Resource(param1,0));
                  break;
               }
               _loc4_++;
            }
            if(checkInputs())
            {
               this.satisfy();
            }
         }
      }
      
      override public function satisfy() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this.actAsConverter)
         {
            super.satisfy();
         }
         else
         {
            checkInhibition();
         }
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
      }
   }
}

