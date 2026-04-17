package nl.jorisdormans.machinations.model
{
   import nl.jorisdormans.graph.GraphEvent;
   
   public class Gate extends MachinationsNode
   {
      
      public static const GATE_DETERMINISTIC:String = "deterministic";
      
      public static const GATE_DICE:String = "dice";
      
      public static const GATE_SKILL:String = "skill";
      
      public static const GATE_STRATEGY:String = "strategy";
      
      public static const GATE_MULTIPLAYER:String = "multiplayer";
      
      private static const OUTPUT_PROBABLE:String = "probable";
      
      private static const OUTPUT_PROBABLE_PERCENTAGE:String = "probable_percentage";
      
      private static const OUTPUT_CONDITIONAL:String = "conditional";
      
      private static const OUTPUT_COLOR_CODED:String = "color_coded";
      
      public var gateType:String;
      
      private var outputType:String;
      
      public var value:int;
      
      public var displayValue:Number = 0;
      
      public var counting:Number = 0;
      
      public var inputStateValue:Number;
      
      public function Gate()
      {
         super();
         size = 16;
         this.gateType = GATE_DETERMINISTIC;
      }
      
      override public function generateXML() : XML
      {
         var _loc1_:XML = super.generateXML();
         _loc1_.@gateType = this.gateType;
         return _loc1_;
      }
      
      override public function readXML(param1:XML) : void
      {
         super.readXML(param1);
         this.gateType = param1.@gateType;
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
         super.fire();
         if(resourceInputCount == 0)
         {
            this.satisfy();
            this.receiveResource(16777215,null);
         }
         else
         {
            pull();
         }
      }
      
      override public function satisfy() : void
      {
         super.satisfy();
         var _loc1_:int = int(outputs.length);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            if(outputs[_loc2_] is StateConnection && (outputs[_loc2_] as StateConnection).label.type == Label.TYPE_TRIGGER)
            {
               (outputs[_loc2_] as StateConnection).fire();
            }
            _loc2_++;
         }
      }
      
      override public function prepare(param1:Boolean) : void
      {
         var _loc5_:MachinationsConnection = null;
         super.prepare(param1);
         this.outputType = OUTPUT_PROBABLE;
         resourceOutputCount = 0;
         var _loc2_:int = int(outputs.length);
         var _loc3_:uint = this.color;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            _loc5_ = outputs[_loc4_] as MachinationsConnection;
            if(_loc5_)
            {
               ++resourceOutputCount;
               if(_loc5_.label.type == Label.TYPE_PROBABILITY)
               {
                  this.outputType = OUTPUT_PROBABLE_PERCENTAGE;
               }
               if(_loc5_.label.isCondition())
               {
                  this.outputType = OUTPUT_CONDITIONAL;
               }
               if(resourceOutputCount == 1)
               {
                  _loc3_ = _loc5_.color;
               }
               else if(_loc3_ != _loc5_.color && this.outputType == OUTPUT_PROBABLE)
               {
                  this.outputType = OUTPUT_COLOR_CODED;
               }
            }
            _loc4_++;
         }
         if(this.outputType == OUTPUT_CONDITIONAL && this.gateType == GATE_DETERMINISTIC)
         {
            this.value = 0;
         }
         else
         {
            this.value = -1;
         }
         this.counting = 0;
         this.inputStateValue = 0;
         if(this.outputType == OUTPUT_PROBABLE_PERCENTAGE)
         {
            this.checkDynamicProbabilities();
         }
      }
      
      override public function stop() : void
      {
         this.displayValue = 0;
         if(doEvents)
         {
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this));
         }
         super.stop();
      }
      
      override public function receiveResource(param1:uint, param2:ResourceConnection) : void
      {
         super.receiveResource(param1,param2);
         switch(this.outputType)
         {
            case OUTPUT_CONDITIONAL:
               this.distributeConditional(param1);
               break;
            case OUTPUT_PROBABLE:
               this.distributeProbable(param1);
               break;
            case OUTPUT_PROBABLE_PERCENTAGE:
               this.distributeProbablePercentage(param1);
               break;
            case OUTPUT_COLOR_CODED:
               this.distributeColorCoded(param1);
         }
         if(doEvents && this.outputType == OUTPUT_CONDITIONAL)
         {
            this.displayValue = Math.min((graph as MachinationsGraph).fireInterval * 0.75,0.5);
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this));
         }
      }
      
      override public function autoFire() : void
      {
         if((graph as MachinationsGraph).actionsPerTurn > 0 && this.outputType == OUTPUT_CONDITIONAL && this.gateType == GATE_DETERMINISTIC)
         {
            this.value = 0;
         }
         super.autoFire();
      }
      
      override public function update(param1:Number) : void
      {
         super.update(param1);
         if(this.counting > 0)
         {
            this.counting -= param1;
            if(this.counting <= 0)
            {
               this.counting = 0;
               this.value = this.inputStateValue;
            }
         }
         if(this.displayValue > 0)
         {
            this.displayValue -= param1;
            if(this.displayValue <= 0)
            {
               this.displayValue = 0;
               dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this));
            }
         }
      }
      
      private function produce(param1:uint, param2:MachinationsConnection) : void
      {
         var _loc3_:ResourceConnection = param2 as ResourceConnection;
         if(_loc3_)
         {
            _loc3_.resources.push(new Resource(param1,0));
            _loc3_.requestQueue.push(1);
         }
         var _loc4_:StateConnection = param2 as StateConnection;
         if(_loc4_)
         {
            _loc4_.fire();
         }
      }
      
      private function distributeColorCoded(param1:uint) : void
      {
         var _loc4_:MachinationsConnection = null;
         var _loc2_:int = int(outputs.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = outputs[_loc3_] as MachinationsConnection;
            if((Boolean(_loc4_)) && _loc4_.color == param1)
            {
               this.produce(param1,_loc4_);
               return;
            }
            _loc3_++;
         }
         if((graph as MachinationsGraph).colorCoding > 0)
         {
            this.distributeProbable(16777216);
         }
      }
      
      private function distributeProbablePercentage(param1:uint) : void
      {
         var _loc5_:MachinationsConnection = null;
         if(this.gateType == GATE_DETERMINISTIC)
         {
            this.value += 11;
            this.value %= 100;
         }
         else
         {
            this.value = Math.random() * 100;
         }
         var _loc2_:Number = this.value;
         var _loc3_:int = int(outputs.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = outputs[_loc4_] as MachinationsConnection;
            if(_loc5_)
            {
               if(_loc2_ < _loc5_.label.value)
               {
                  this.produce(param1,_loc5_);
                  return;
               }
               _loc2_ -= _loc5_.label.value;
            }
            _loc4_++;
         }
      }
      
      private function distributeProbable(param1:uint) : void
      {
         var _loc6_:MachinationsConnection = null;
         var _loc2_:Number = 0;
         var _loc3_:int = int(outputs.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc6_ = outputs[_loc4_] as MachinationsConnection;
            if(_loc6_)
            {
               _loc2_ += _loc6_.label.value;
            }
            _loc4_++;
         }
         if(this.gateType == GATE_DETERMINISTIC)
         {
            ++this.value;
            this.value %= _loc2_;
         }
         else
         {
            this.value = Math.random() * _loc2_;
         }
         var _loc5_:Number = this.value;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc6_ = outputs[_loc4_] as MachinationsConnection;
            if(_loc6_)
            {
               if(_loc5_ < _loc6_.label.value)
               {
                  if(param1 == 16777216)
                  {
                     param1 = _loc6_.color;
                  }
                  this.produce(param1,_loc6_);
                  return;
               }
               _loc5_ -= _loc6_.label.value;
            }
            _loc4_++;
         }
      }
      
      private function distributeConditional(param1:uint) : void
      {
         var _loc5_:MachinationsConnection = null;
         switch(this.gateType)
         {
            case GATE_DETERMINISTIC:
               ++this.value;
               if(this.counting == 0 && (graph as MachinationsGraph).actionsPerTurn == 0)
               {
                  this.counting = (graph as MachinationsGraph).fireInterval - 0.001;
               }
               break;
            default:
            case GATE_DICE:
               this.value = (graph as MachinationsGraph).getDiceValue() + this.inputStateValue;
               break;
            case GATE_SKILL:
               this.value = (graph as MachinationsGraph).getSkillValue() + this.inputStateValue;
               break;
            case GATE_STRATEGY:
               this.value = (graph as MachinationsGraph).getStrategyValue() + this.inputStateValue;
               break;
            case GATE_MULTIPLAYER:
               this.value = (graph as MachinationsGraph).getMultiplayerValue() + this.inputStateValue;
         }
         var _loc2_:Boolean = false;
         var _loc3_:int = int(outputs.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = outputs[_loc4_] as MachinationsConnection;
            if(_loc5_)
            {
               if(_loc5_.label.checkCondition(this.value))
               {
                  _loc2_ = true;
                  this.produce(param1,_loc5_);
               }
            }
            _loc4_++;
         }
         if(!_loc2_)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc5_ = outputs[_loc4_] as MachinationsConnection;
               if((Boolean(_loc5_)) && _loc5_.label.type == Label.TYPE_ELSE)
               {
                  this.produce(param1,_loc5_);
               }
               _loc4_++;
            }
         }
      }
      
      public function modify(param1:Number) : void
      {
         this.inputStateValue += param1;
      }
      
      public function checkDynamicProbabilities() : void
      {
         var _loc5_:MachinationsConnection = null;
         var _loc1_:Number = 0;
         var _loc2_:int = 0;
         var _loc3_:int = int(outputs.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = outputs[_loc4_] as MachinationsConnection;
            if(_loc5_.label.type == Label.TYPE_PROBABILITY_DYNAMIC)
            {
               _loc2_++;
            }
            if(_loc5_.label.type == Label.TYPE_PROBABILITY)
            {
               _loc1_ += _loc5_.label.value;
            }
            _loc4_++;
         }
         if(_loc2_ > 0)
         {
            _loc1_ = Math.max(0,(100 - _loc1_) / _loc2_);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc5_ = outputs[_loc4_] as MachinationsConnection;
               if(_loc5_.label.type == Label.TYPE_PROBABILITY_DYNAMIC)
               {
                  _loc5_.label.setDynamicProbability(_loc1_);
               }
               _loc4_++;
            }
         }
      }
   }
}

