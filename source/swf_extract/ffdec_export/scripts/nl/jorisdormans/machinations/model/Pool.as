package nl.jorisdormans.machinations.model
{
   import nl.jorisdormans.graph.GraphEvent;
   
   public class Pool extends Source
   {
      
      public static const TOKEN_LIMIT:int = 25;
      
      private var _startingResources:int;
      
      public var capacity:int = -1;
      
      private var startingCapacity:int;
      
      public var resources:Vector.<Resource> = new Vector.<Resource>();
      
      public var overPulled:Boolean;
      
      public var pulls:int = 0;
      
      private var shortage:int;
      
      public var displayCapacity:int = 25;
      
      public function Pool()
      {
         this.startingResources = 0;
         super();
         activationMode = MODE_PASSIVE;
      }
      
      override public function generateXML() : XML
      {
         var _loc1_:XML = super.generateXML();
         _loc1_.@startingResources = this.startingResources;
         _loc1_.@capacity = this.capacity;
         if(this.displayCapacity != TOKEN_LIMIT)
         {
            _loc1_.@displayCapacity = this.displayCapacity;
         }
         return _loc1_;
      }
      
      override public function readXML(param1:XML) : void
      {
         super.readXML(param1);
         this.startingResources = param1.@startingResources;
         if(param1.@maxResources.length() > 0)
         {
            this.capacity = param1.@maxResources;
         }
         else
         {
            this.capacity = param1.@capacity;
         }
         if(param1.@tokenLimit.length() > 0)
         {
            this.displayCapacity = parseInt(param1.@tokenLimit);
         }
         if(param1.@displayCapacity.length() > 0)
         {
            this.displayCapacity = parseInt(param1.@displayCapacity);
         }
      }
      
      public function get startingResources() : int
      {
         return this._startingResources;
      }
      
      public function set startingResources(param1:int) : void
      {
         this._startingResources = param1;
         this.resources.splice(0,this.resources.length);
         var _loc2_:int = 0;
         while(_loc2_ < param1)
         {
            this.resources.push(new Resource(this.resourceColor,0));
            _loc2_++;
         }
      }
      
      override public function get resourceColor() : uint
      {
         return super.resourceColor;
      }
      
      override public function set resourceColor(param1:uint) : void
      {
         super.resourceColor = param1;
         this.resources.splice(0,this.resources.length);
         var _loc2_:int = 0;
         while(_loc2_ < this.startingResources)
         {
            this.resources.push(new Resource(param1,0));
            _loc2_++;
         }
      }
      
      override public function prepare(param1:Boolean) : void
      {
         super.prepare(param1);
         this.shortage = 0;
         this.overPulled = false;
         checkInhibition();
         if(resourceInputCount == 0)
         {
            if(pullMode == PULL_MODE_PULL_ANY)
            {
               pullMode = PULL_MODE_PUSH_ANY;
            }
            if(pullMode == PULL_MODE_PULL_ALL)
            {
               pullMode = PULL_MODE_PUSH_ALL;
            }
         }
         this.startingCapacity = this.capacity;
      }
      
      public function modify(param1:int) : void
      {
         var _loc2_:int = 0;
         if(param1 > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < param1)
            {
               this.receiveResource(this.resourceColor,null);
               _loc2_++;
            }
         }
         if(param1 < 0)
         {
            _loc2_ = 0;
            while(_loc2_ < -param1)
            {
               if(this.resourceCount <= 0)
               {
                  ++this.shortage;
                  this.changeState(16777216,-1);
               }
               else
               {
                  this.removeResource(16777216,0);
               }
               _loc2_++;
            }
         }
         if(doEvents)
         {
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
         }
      }
      
      override public function stop() : void
      {
         super.stop();
         this.capacity = this.startingCapacity;
         this.resources.splice(0,this.resources.length);
         var _loc1_:int = 0;
         while(_loc1_ < this.startingResources)
         {
            this.resources.push(new Resource(this.resourceColor,0));
            _loc1_++;
         }
         this.shortage = 0;
         if(doEvents)
         {
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
         }
      }
      
      override public function autoFire() : void
      {
         super.autoFire();
      }
      
      override public function update(param1:Number) : void
      {
         this.pulls = 0;
         var _loc2_:int = 0;
         var _loc3_:int = int(this.resources.length);
         var _loc4_:* = int(_loc3_ - 1);
         while(_loc4_ >= 0)
         {
            if(this.resources[_loc4_].position > 0)
            {
               this.resources[_loc4_].position -= param1;
               if(this.resources[_loc4_].position <= 0)
               {
                  this.resources.splice(_loc4_,1);
                  _loc2_++;
               }
            }
            _loc4_--;
         }
         if(firing > 0)
         {
            firing -= param1;
            if(firing <= 0)
            {
               firing = 0;
               if(doEvents)
               {
                  dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
               }
            }
         }
         if(_loc2_ > 0 && doEvents)
         {
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
         }
      }
      
      override public function fire() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Boolean = false;
         var _loc3_:* = 0;
         setFiring();
         switch(pullMode)
         {
            default:
               pull();
               break;
            case PULL_MODE_PUSH_ANY:
               _loc1_ = int(outputs.length);
               _loc3_ = int(_loc1_ - 1);
               while(_loc3_ >= 0)
               {
                  if(outputs[_loc3_] is ResourceConnection)
                  {
                     (outputs[_loc3_] as ResourceConnection).pull();
                  }
                  _loc3_--;
               }
               break;
            case PULL_MODE_PUSH_ALL:
               _loc1_ = int(outputs.length);
               _loc2_ = false;
               _loc3_ = int(_loc1_ - 1);
               while(_loc3_ >= 0)
               {
                  if(outputs[_loc3_] is ResourceConnection && !(outputs[_loc3_] as ResourceConnection).pull())
                  {
                     _loc2_ = true;
                  }
                  _loc3_--;
               }
               if(_loc2_)
               {
                  _loc3_ = int(_loc1_ - 1);
                  while(_loc3_ >= 0)
                  {
                     if(outputs[_loc3_] is ResourceConnection)
                     {
                        (outputs[_loc3_] as ResourceConnection).undoPull(false);
                     }
                     _loc3_--;
                  }
               }
         }
         if(resourceInputCount == 0)
         {
            this.satisfy();
         }
      }
      
      override public function satisfy() : void
      {
         var _loc1_:int = int(outputs.length);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            if(outputs[_loc2_] is StateConnection)
            {
               (outputs[_loc2_] as StateConnection).fire();
            }
            _loc2_++;
         }
      }
      
      override public function receiveResource(param1:uint, param2:ResourceConnection) : void
      {
         if(this.capacity >= 0 && this.resources.length >= this.capacity)
         {
            return;
         }
         if(this.shortage > 0)
         {
            --this.shortage;
         }
         else
         {
            this.resources.push(new Resource(param1,0));
         }
         if(doEvents)
         {
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this));
         }
         this.changeState(param1,1);
         if(checkInputs())
         {
            this.satisfy();
         }
      }
      
      public function returnResource(param1:uint) : void
      {
         if(checkInputs())
         {
            this.satisfy();
         }
         this.changeState(param1,1);
         var _loc2_:int = int(this.resources.length);
         var _loc3_:* = int(_loc2_ - 1);
         while(_loc3_ >= 0)
         {
            if((param1 == 16777216 || this.resources[_loc3_].color == param1) && this.resources[_loc3_].position >= 0.01)
            {
               this.resources[_loc3_].position = 0;
               return;
            }
            _loc3_--;
         }
         if(this.shortage > 0)
         {
            --this.shortage;
         }
         else
         {
            this.resources.push(new Resource(param1,0));
         }
      }
      
      public function removeResource(param1:uint, param2:Number) : uint
      {
         var _loc5_:uint = 0;
         var _loc3_:int = int(this.resources.length);
         var _loc4_:* = int(_loc3_ - 1);
         while(_loc4_ >= 0)
         {
            if((param1 == 16777216 || this.resources[_loc4_].color == param1) && this.resources[_loc4_].position == 0)
            {
               _loc5_ = this.resources[_loc4_].color;
               if(param2 > 0)
               {
                  this.resources[_loc4_].position = param2 + 0.01;
               }
               else
               {
                  this.resources[_loc4_].position = 0.01;
               }
               this.changeState(_loc5_,-1);
               return _loc5_;
            }
            _loc4_--;
         }
         return 16777216;
      }
      
      public function removeRandomResource(param1:Number) : uint
      {
         var _loc2_:int = int(this.resources.length);
         var _loc3_:int = 0;
         var _loc4_:* = int(_loc2_ - 1);
         while(_loc4_ >= 0)
         {
            if(this.resources[_loc4_].position == 0)
            {
               _loc3_++;
            }
            _loc4_--;
         }
         var _loc5_:int = Math.random() * _loc3_;
         _loc4_ = int(_loc2_ - 1);
         while(_loc4_ >= 0)
         {
            if(this.resources[_loc4_].position == 0)
            {
               if(--_loc5_ < 0)
               {
                  if(param1 > 0)
                  {
                     this.resources[_loc4_].position = param1 + 0.01;
                  }
                  else
                  {
                     this.resources[_loc4_].position = 0.01;
                  }
                  this.changeState(this.resources[_loc4_].color,-1);
                  return this.resources[_loc4_].color;
               }
            }
            _loc4_--;
         }
         return 16777216;
      }
      
      public function canRemoveResource(param1:uint, param2:int) : Boolean
      {
         var _loc3_:int = int(this.resources.length);
         var _loc4_:* = int(_loc3_ - 1);
         while(_loc4_ >= 0)
         {
            if((param1 == 16777216 || this.resources[_loc4_].color == param1) && this.resources[_loc4_].position == 0)
            {
               param2--;
               if(param2 <= 0)
               {
                  return true;
               }
            }
            _loc4_--;
         }
         return false;
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
      
      public function get resourceCount() : int
      {
         var _loc1_:int = int(this.resources.length);
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_)
         {
            if(this.resources[_loc3_].position == 0)
            {
               _loc2_++;
            }
            _loc3_++;
         }
         return _loc2_ - this.shortage;
      }
      
      public function resourceColorCount(param1:uint) : int
      {
         var _loc2_:int = int(this.resources.length);
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            if(this.resources[_loc4_].color == param1)
            {
               _loc3_++;
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function resolveOverPull() : void
      {
         var _loc1_:int = 0;
         if(this.overPulled)
         {
            this.overPulled = false;
            if(this.pulls > 1)
            {
               _loc1_ = 0;
               while(_loc1_ < this.resources.length)
               {
                  this.resources[_loc1_].position = 0;
                  _loc1_++;
               }
               _loc1_ = 0;
               while(_loc1_ < outputs.length)
               {
                  if(outputs[_loc1_] is ResourceConnection)
                  {
                     (outputs[_loc1_] as ResourceConnection).undoPull();
                  }
                  _loc1_++;
               }
            }
         }
      }
      
      public function modifyCapacity(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         this.capacity += param1;
         if(this.capacity < this.resources.length)
         {
            _loc2_ = Math.max(this.capacity,0);
            _loc3_ = this.resources.length - _loc2_;
            _loc4_ = _loc2_;
            while(_loc4_ < _loc2_ + _loc3_)
            {
               this.changeState(this.resources[_loc4_].color,-1);
               _loc4_++;
            }
            this.resources.splice(_loc2_,_loc3_);
            if(doEvents)
            {
               dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this));
            }
         }
      }
   }
}

