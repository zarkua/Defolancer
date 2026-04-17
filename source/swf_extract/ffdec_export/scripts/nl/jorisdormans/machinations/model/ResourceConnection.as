package nl.jorisdormans.machinations.model
{
   import nl.jorisdormans.graph.GraphElement;
   import nl.jorisdormans.graph.GraphEvent;
   
   public class ResourceConnection extends MachinationsConnection
   {
      
      public var justPulled:int;
      
      public var resources:Vector.<Resource>;
      
      public var speed:Number;
      
      public var delivered:int;
      
      public var requestQueue:Vector.<int>;
      
      public var instantaneous:Boolean;
      
      public function ResourceConnection()
      {
         super();
         this.resources = new Vector.<Resource>();
      }
      
      public function produce(param1:Source) : void
      {
         var _loc4_:uint = 0;
         var _loc2_:int = label.value;
         label.generateNewValue();
         this.requestQueue.push(Math.max(_loc2_,0));
         if(_loc2_ <= 0)
         {
            return;
         }
         var _loc3_:Number = (graph as MachinationsGraph).fireInterval;
         _loc3_ = _loc3_ / _loc2_ * -this.speed;
         if(color == param1.color)
         {
            _loc4_ = param1.resourceColor;
         }
         else
         {
            _loc4_ = color;
         }
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_)
         {
            this.resources.push(new Resource(_loc4_,_loc5_ * _loc3_));
            _loc5_++;
         }
      }
      
      override public function prepare(param1:Boolean) : void
      {
         super.prepare(param1);
         var _loc2_:Number = (graph as MachinationsGraph).resourceSpeed;
         if(_loc2_ > 0)
         {
            this.speed = (graph as MachinationsGraph).resourceSpeed / totalLength;
         }
         else
         {
            this.speed = 1;
         }
         this.delivered = 0;
         this.justPulled = 0;
         this.requestQueue = new Vector.<int>();
         this.instantaneous = (graph as MachinationsGraph).distributionMode == MachinationsGraph.DISTRIBUTION_MODE_INSTANTANEOUS;
         this.checkInhibition();
      }
      
      override public function stop() : void
      {
         this.resources.splice(0,this.resources.length);
         super.stop();
      }
      
      override public function update(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc3_:* = 0;
         super.update(param1);
         if(this.instantaneous)
         {
            _loc2_ = int(this.resources.length);
            _loc3_ = int(_loc2_ - 1);
            while(_loc3_ >= 0)
            {
               if(this.resources[_loc3_].position <= 0)
               {
                  this.resources[_loc3_].position += 1;
               }
               else
               {
                  ++this.delivered;
                  if(this.end is MachinationsNode)
                  {
                     (this.end as MachinationsNode).receiveResource(this.resources[_loc3_].color,this);
                  }
                  this.resources.splice(_loc3_,1);
                  this.checkInhibition();
               }
               _loc3_--;
            }
         }
         else
         {
            _loc2_ = int(this.resources.length);
            _loc3_ = int(_loc2_ - 1);
            while(_loc3_ >= 0)
            {
               this.resources[_loc3_].position += param1 * this.speed;
               if(this.resources[_loc3_].position >= 1)
               {
                  ++this.delivered;
                  if(this.end is MachinationsNode)
                  {
                     (this.end as MachinationsNode).receiveResource(this.resources[_loc3_].color,this);
                  }
                  this.resources.splice(_loc3_,1);
                  this.checkInhibition();
               }
               _loc3_--;
            }
            if(_loc2_ > 0 && doEvents)
            {
               dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
            }
         }
      }
      
      public function pull(param1:int = 0) : Boolean
      {
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:Number = NaN;
         if(param1 < 0)
         {
            param1 = 0;
         }
         var _loc2_:Pool = start as Pool;
         if(!_loc2_ && start is Source && (start as Source).activationMode == MachinationsNode.MODE_PASSIVE)
         {
            this.produce(start as Source);
            return true;
         }
         if(!_loc2_)
         {
            return false;
         }
         var _loc3_:int = label.value;
         var _loc4_:int = 0;
         while(_loc4_ < label.generatedValues.length)
         {
            this.requestQueue.push(Math.max(label.generatedValues[_loc4_],0));
            _loc4_++;
         }
         label.generateNewValue();
         if(_loc3_ <= 0)
         {
            return true;
         }
         ++_loc2_.pulls;
         var _loc5_:Number = (graph as MachinationsGraph).fireInterval;
         _loc5_ = _loc5_ / _loc3_;
         var _loc6_:Number = _loc5_ * -this.speed;
         if(color == _loc2_.color || (graph as MachinationsGraph).colorCoding == 0)
         {
            _loc7_ = 16777216;
         }
         else
         {
            _loc7_ = color;
         }
         this.justPulled = 0;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc9_ = 0;
            if(!this.instantaneous)
            {
               _loc9_ = _loc4_ * _loc5_;
            }
            if(label.drawRandom)
            {
               _loc8_ = _loc2_.removeRandomResource(_loc9_);
            }
            else
            {
               _loc8_ = _loc2_.removeResource(_loc7_,_loc9_);
            }
            if(_loc8_ < 16777216)
            {
               this.resources.push(new Resource(_loc8_,_loc4_ * _loc6_));
               ++this.justPulled;
            }
            if(_loc8_ == 16777216)
            {
               if(_loc4_ == 0 && this.end is MachinationsNode && (this.end as MachinationsNode).activationMode != MachinationsNode.MODE_AUTOMATIC)
               {
                  blocked = Math.min((graph as MachinationsGraph).fireInterval * 0.75,0.5);
                  if(doEvents)
                  {
                     dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
                  }
               }
               if((graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_SYNCHRONOUS)
               {
                  if(_loc4_ == 0)
                  {
                     blocked = Math.min((graph as MachinationsGraph).fireInterval * 0.75,0.5);
                  }
                  _loc2_.overPulled = true;
               }
               if(this.justPulled == 0)
               {
                  this.requestQueue.splice(this.requestQueue.length - 1,1);
               }
               return false;
            }
            _loc2_.checkInhibition();
            _loc4_++;
         }
         return true;
      }
      
      public function canPull(param1:int = 0) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:uint = 0;
         var _loc2_:Pool = start as Pool;
         if(_loc2_)
         {
            _loc3_ = label.value;
            _loc3_ -= param1;
            if(_loc3_ <= 0)
            {
               return true;
            }
            if(color == _loc2_.color)
            {
               _loc4_ = 16777216;
            }
            else
            {
               _loc4_ = color;
            }
            if(_loc2_.canRemoveResource(_loc4_,_loc3_))
            {
               return true;
            }
            if((graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_SYNCHRONOUS)
            {
               _loc2_.overPulled = true;
               blocked = Math.min((graph as MachinationsGraph).fireInterval * 0.75,0.5);
            }
         }
         if(this.end is MachinationsNode && (this.end as MachinationsNode).activationMode != MachinationsNode.MODE_AUTOMATIC)
         {
            blocked = Math.min((graph as MachinationsGraph).fireInterval * 0.75,0.5);
            if(doEvents)
            {
               dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
            }
         }
         return false;
      }
      
      public function checkInhibition(param1:Boolean = true) : void
      {
         communicateInhibition = param1;
         var _loc2_:Boolean = false;
         var _loc3_:int = int(inputs.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(inputs[_loc4_] is StateConnection && (inputs[_loc4_] as StateConnection).isActivator() && (inputs[_loc4_] as StateConnection).inhibited)
            {
               _loc2_ = true;
               break;
            }
            _loc4_++;
         }
         if(start is Pool && (start as Pool).caption == "keys")
         {
         }
         if(!_loc2_)
         {
            if(start is MachinationsNode && (start as MachinationsNode).inhibited)
            {
               _loc2_ = true;
            }
            if(this.resources.length > 0)
            {
               _loc2_ = false;
            }
         }
         inhibited = _loc2_;
      }
      
      public function fire() : void
      {
         firing = Math.min((graph as MachinationsGraph).fireInterval * 0.75,0.5);
         if(start is Pool)
         {
            this.pull(0);
         }
         else if(start is Source && !start is Converter)
         {
            this.produce(start as Source);
         }
      }
      
      public function undoPull(param1:Boolean = true) : void
      {
         var _loc2_:int = 0;
         var _loc3_:* = int(this.resources.length);
         while(_loc3_ > 0 && _loc2_ < this.justPulled)
         {
            _loc3_--;
            if(this.resources[_loc3_].position <= 0)
            {
               if(!param1)
               {
                  if(start is Pool)
                  {
                     (start as Pool).returnResource(this.resources[_loc3_].color);
                  }
               }
               _loc2_++;
               this.resources.splice(_loc3_,1);
            }
         }
         if(_loc2_ > 0)
         {
            blocked = Math.min((graph as MachinationsGraph).fireInterval * 0.75,0.5);
            this.requestQueue.splice(this.requestQueue.length - 1,1);
            if(param1 && (this.end as MachinationsNode).pullMode == MachinationsNode.PULL_MODE_PULL_ALL)
            {
               (this.end as MachinationsNode).undoPull();
            }
         }
         this.justPulled = 0;
      }
      
      override public function get end() : GraphElement
      {
         return super.end;
      }
      
      override public function set end(param1:GraphElement) : void
      {
         super.end = param1;
         if(this.end is MachinationsNode)
         {
            ++(this.end as MachinationsNode).resourceInputCount;
            if(doEvents)
            {
               this.end.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
            }
         }
      }
   }
}

