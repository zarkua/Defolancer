package nl.jorisdormans.machinations.model
{
   import nl.jorisdormans.graph.GraphEvent;
   
   public class Delay extends MachinationsNode
   {
      
      public static var TYPE_QUEUE:String = "queue";
      
      public static var TYPE_NORMAL:String = "normal";
      
      private var resources:Vector.<Resource>;
      
      private var output:ResourceConnection;
      
      public var delayType:String;
      
      public var inputStateValue:Number;
      
      public function Delay()
      {
         super();
         size = 12;
         this.resources = new Vector.<Resource>();
         this.delayType = TYPE_NORMAL;
      }
      
      override public function generateXML() : XML
      {
         var _loc1_:XML = super.generateXML();
         _loc1_.@delayType = this.delayType;
         return _loc1_;
      }
      
      override public function autoFire() : void
      {
         super.autoFire();
         if((graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_TURN_BASED)
         {
            this.advanceTime(1);
         }
      }
      
      override public function readXML(param1:XML) : void
      {
         super.readXML(param1);
         this.delayType = param1.@delayType;
      }
      
      override public function prepare(param1:Boolean) : void
      {
         super.prepare(param1);
         this.resources.splice(0,this.resources.length);
         this.output = null;
         var _loc2_:int = 0;
         while(_loc2_ < outputs.length)
         {
            if(outputs[_loc2_] is ResourceConnection)
            {
               this.output = outputs[_loc2_] as ResourceConnection;
            }
            _loc2_++;
         }
         this.inputStateValue = 0;
      }
      
      override public function stop() : void
      {
         super.stop();
         this.resources.splice(0,this.resources.length);
         if(doEvents)
         {
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this));
         }
      }
      
      override public function fire() : void
      {
         super.fire();
         pull();
      }
      
      override public function receiveResource(param1:uint, param2:ResourceConnection) : void
      {
         var _loc3_:Resource = null;
         var _loc4_:int = 0;
         var _loc5_:ResourceConnection = null;
         var _loc6_:Number = NaN;
         super.receiveResource(param1,param2);
         if((graph as MachinationsGraph).colorCoding == 1)
         {
            _loc4_ = 0;
            while(_loc4_ < outputs.length)
            {
               _loc5_ = outputs[_loc4_] as ResourceConnection;
               if((Boolean(_loc5_)) && _loc5_.color == param1)
               {
                  _loc5_.label.generateNewValue();
                  _loc6_ = _loc5_.label.value + this.inputStateValue;
                  _loc3_ = new Resource(param1,_loc6_);
                  _loc3_.connection = _loc5_;
                  break;
               }
               _loc4_++;
            }
            if(!_loc3_)
            {
               _loc4_ = 0;
               while(_loc4_ < outputs.length)
               {
                  _loc5_ = outputs[_loc4_] as ResourceConnection;
                  if((Boolean(_loc5_)) && _loc5_.color == this.color)
                  {
                     _loc5_.label.generateNewValue();
                     _loc6_ = _loc5_.label.value + this.inputStateValue;
                     _loc3_ = new Resource(param1,_loc6_);
                     _loc3_.connection = _loc5_;
                     break;
                  }
                  _loc4_++;
               }
            }
         }
         else if(this.output)
         {
            this.output.label.generateNewValue();
            _loc6_ = this.output.label.value + this.inputStateValue;
            _loc3_ = new Resource(param1,_loc6_);
            _loc3_.connection = this.output;
         }
         if(_loc3_)
         {
            this.resources.push(_loc3_);
            this.changeState(_loc3_.color,1);
         }
         if(doEvents)
         {
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this));
         }
      }
      
      override public function update(param1:Number) : void
      {
         super.update(param1);
         if((graph as MachinationsGraph).timeMode != MachinationsGraph.TIME_MODE_TURN_BASED)
         {
            this.advanceTime(param1);
         }
      }
      
      private function advanceTime(param1:Number) : void
      {
         var _loc2_:int = int(this.resources.length);
         if(this.delayType == TYPE_QUEUE)
         {
            _loc2_ = Math.min(_loc2_,1);
         }
         var _loc3_:* = int(_loc2_ - 1);
         while(_loc3_ >= 0)
         {
            this.resources[_loc3_].position -= param1;
            if(this.resources[_loc3_].position <= 0)
            {
               if(this.output)
               {
                  this.changeState(this.resources[_loc3_].color,-1);
                  this.resources[_loc3_].position = 0;
                  this.resources[_loc3_].connection.resources.push(this.resources[_loc3_]);
                  this.resources[_loc3_].connection.requestQueue.push(1);
                  this.resources.splice(_loc3_,1);
                  this.trigger();
                  if(doEvents)
                  {
                     dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this));
                  }
               }
            }
            _loc3_--;
         }
      }
      
      private function trigger() : void
      {
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
      
      public function get delayed() : Boolean
      {
         return this.resources.length > 0;
      }
      
      public function modify(param1:Number) : void
      {
         this.inputStateValue += param1;
      }
      
      public function changeState(param1:uint, param2:int) : void
      {
         var _loc3_:int = int(outputs.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(outputs[_loc4_] is StateConnection)
            {
               if((outputs[_loc4_] as StateConnection).color == this.color || param1 == 16777216 || (outputs[_loc4_] as StateConnection).color == param1 || (graph as MachinationsGraph).colorCoding == 0)
               {
                  (outputs[_loc4_] as StateConnection).changeState(param2);
               }
            }
            if(outputs[_loc4_] is ResourceConnection)
            {
               (outputs[_loc4_] as ResourceConnection).checkInhibition(true);
            }
            _loc4_++;
         }
         if(param2 != 0)
         {
            checkInhibition();
         }
      }
   }
}

