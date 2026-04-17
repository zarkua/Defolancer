package nl.jorisdormans.machinations.model
{
   import nl.jorisdormans.graph.GraphEvent;
   
   public class StateConnection extends MachinationsConnection
   {
      
      private var _state:int;
      
      private var _alreadyTriggered:Boolean;
      
      public function StateConnection()
      {
         super();
      }
      
      public function fire() : void
      {
         if((label.type == Label.TYPE_TRIGGER || start is Gate) && !this._alreadyTriggered)
         {
            this._alreadyTriggered = true;
            if(end is MachinationsNode && (!(end as MachinationsNode).inhibited || end is EndCondition))
            {
               (end as MachinationsNode).fire();
            }
            if(end is ResourceConnection)
            {
               (end as ResourceConnection).fire();
            }
            firing = Math.min((graph as MachinationsGraph).fireInterval * 0.75,0.5);
            if(doEvents)
            {
               dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
            }
         }
      }
      
      public function reverseFire() : void
      {
         if(label.type == Label.TYPE_REVERSE_TRIGGER && !this._alreadyTriggered)
         {
            this._alreadyTriggered = true;
            if(end is MachinationsNode && (!(end as MachinationsNode).inhibited || end is EndCondition))
            {
               (end as MachinationsNode).fire();
            }
            if(end is ResourceConnection)
            {
               (end as ResourceConnection).fire();
            }
            firing = Math.min((graph as MachinationsGraph).fireInterval * 0.75,0.5);
            if(doEvents)
            {
               dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
            }
         }
      }
      
      override public function update(param1:Number) : void
      {
         this._alreadyTriggered = false;
         super.update(param1);
      }
      
      override public function prepare(param1:Boolean) : void
      {
         super.prepare(param1);
         this._state = 0;
         if(start is Pool)
         {
            this._state = (start as Pool).resourceCount;
            if((graph as MachinationsGraph).colorCoding > 0)
            {
               if(this.color != (start as Pool).color)
               {
                  this._state = (start as Pool).resourceColorCount(this.color);
               }
            }
         }
         if(start is Register)
         {
            this._state = (start as Register).value;
         }
         this.changeState(0);
      }
      
      public function get state() : Number
      {
         return this._state;
      }
      
      public function set state(param1:Number) : void
      {
         if(end is Register)
         {
            if(start is Pool)
            {
               param1 = (start as Pool).resourceCount;
            }
            else if(start is Register)
            {
               param1 = (start as Register).value;
            }
            else
            {
               param1 = 0;
            }
         }
         var _loc2_:int = this._state;
         var _loc3_:int = 1;
         if(label.intervalType == Label.TYPE_FIXED_VALUE)
         {
            _loc3_ = label.interval;
         }
         switch(label.type)
         {
            default:
               this._state = param1;
            case Label.TYPE_CHANGE_MULTIPLIER:
               this._state = param1;
               if(end is MachinationsConnection)
               {
                  (end as MachinationsConnection).label.modifyMultiplier((this._state / _loc3_ - _loc2_ / _loc3_) * label.value);
               }
               break;
            case Label.TYPE_CHANGE_CAPACITY:
               this._state = param1;
               if(end is Pool)
               {
                  (end as Pool).modifyCapacity((this._state / _loc3_ - _loc2_ / _loc3_) * label.value);
               }
               break;
            case Label.TYPE_CHANGE_INTERVAL:
               this._state = param1;
               if(end is MachinationsConnection)
               {
                  (end as MachinationsConnection).label.modifyInterval((this._state / _loc3_ - _loc2_ / _loc3_) * label.value);
               }
               break;
            case Label.TYPE_FIXED_VALUE:
            case Label.TYPE_CALCULATED_VALUE:
            case Label.TYPE_CHANGE_PROBABILITY:
            case Label.TYPE_CHANGE_VALUE:
               this._state = param1;
               if(end is MachinationsConnection && _loc3_ != 1)
               {
                  (end as MachinationsConnection).label.modify((Math.floor(this._state / _loc3_) - Math.floor(_loc2_ / _loc3_)) * label.value);
               }
               else if(end is MachinationsConnection)
               {
                  (end as MachinationsConnection).label.modify((this._state - _loc2_) * label.value);
               }
               else if(end is Register)
               {
                  (end as Register).calculateValue();
               }
               else if(end is Pool)
               {
                  (end as Pool).modify((Math.floor(this._state / _loc3_) - Math.floor(_loc2_ / _loc3_)) * label.value);
               }
               else if(end is Gate)
               {
                  (end as Gate).modify((this._state / _loc3_ - _loc2_ / _loc3_) * label.value);
               }
               else if(end is Delay)
               {
                  (end as Delay).modify((this._state / _loc3_ - _loc2_ / _loc3_) * label.value);
               }
               break;
            case Label.TYPE_GREATER:
            case Label.TYPE_GREATER_OR_EQUAL:
            case Label.TYPE_EQUAL_TO:
            case Label.TYPE_LESS:
            case Label.TYPE_LESS_OR_EQUAL:
            case Label.TYPE_NOT_EQUAL_TO:
            case Label.TYPE_RANGE:
               this._state = param1;
               inhibited = !label.checkCondition(param1);
         }
      }
      
      public function changeState(param1:int) : void
      {
         this.state = this._state + param1;
         this.checkInhibition();
      }
      
      public function changeModifier(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         if(start is Pool)
         {
            _loc2_ = (start as Pool).resourceCount * param1;
            this._state += _loc2_;
            _loc3_ = 1;
            if(label.intervalType == Label.TYPE_FIXED_VALUE)
            {
               _loc3_ = label.interval;
            }
            if(end is MachinationsConnection && _loc3_ != 1)
            {
               (end as MachinationsConnection).label.modify(_loc2_);
            }
            else if(end is MachinationsConnection)
            {
               (end as MachinationsConnection).label.modify(_loc2_);
            }
            else if(end is Pool)
            {
               (end as Pool).modify(_loc2_);
            }
            else if(end is Gate)
            {
               (end as Gate).modify(_loc2_);
            }
            else if(end is Register)
            {
               this.state = this._state;
               (end as Register).calculateValue();
            }
         }
      }
      
      public function resetState() : void
      {
         if(start is Pool)
         {
            this.state = (start as Pool).resources.length;
         }
         else if(start is Register)
         {
            this._state = 0;
            if(end is MachinationsConnection)
            {
               (end as MachinationsConnection).label.reset();
            }
            this.state = (start as Register).value;
         }
      }
      
      public function isSetter() : Boolean
      {
         switch(label.type)
         {
            case Label.TYPE_FIXED_VALUE:
            case Label.TYPE_CALCULATED_VALUE:
            case Label.TYPE_CHANGE_INTERVAL:
            case Label.TYPE_CHANGE_PROBABILITY:
            case Label.TYPE_CHANGE_VALUE:
               return true;
            default:
               return false;
         }
      }
      
      public function isActivator() : Boolean
      {
         return label.isCondition();
      }
      
      public function checkInhibition() : void
      {
         if(start is MachinationsNode && (label.type == Label.TYPE_TRIGGER || start is Gate))
         {
            inhibited = (start as MachinationsNode).inhibited;
         }
      }
   }
}

