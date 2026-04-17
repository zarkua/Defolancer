package nl.jorisdormans.machinations.model
{
   import flash.geom.Vector3D;
   import nl.jorisdormans.graph.GraphEvent;
   import nl.jorisdormans.utils.MathUtil;
   
   public class Register extends MachinationsNode
   {
      
      public static const LIMIT:int = 9999;
      
      private var _value:int;
      
      private var calculated:Boolean;
      
      public var minValue:int;
      
      public var maxValue:int;
      
      private var _startValue:int;
      
      public var valueStep:int;
      
      public var interaction:int = 0;
      
      public var hasTriggers:Boolean = false;
      
      public var isTriggered:Boolean = false;
      
      private var postFix:Array;
      
      private var values:Array;
      
      private var expression:Boolean;
      
      public function Register()
      {
         super();
         size = 32;
         this._value = 0;
         this.calculated = true;
         this.minValue = -LIMIT;
         this.maxValue = LIMIT;
         this.valueStep = 1;
         this._startValue = 0;
         this.values = new Array();
         this.actions = 0;
         var _loc1_:int = 0;
         while(_loc1_ < 26)
         {
            this.values.push(0);
            _loc1_++;
         }
      }
      
      public function reset() : void
      {
         this.calculated = false;
      }
      
      override public function fire() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this.hasTriggers && this.isTriggered && this.interaction == 0)
         {
            _loc1_ = Math.random() * 100;
            _loc4_ = 0;
            while(_loc4_ < this.outputs.length)
            {
               if(this.outputs[_loc4_] is StateConnection && (this.outputs[_loc4_] as StateConnection).label.type == Label.TYPE_TRIGGER)
               {
                  if(_loc1_ < this._value)
                  {
                     (this.outputs[_loc4_] as StateConnection).fire();
                  }
               }
               if(this.outputs[_loc4_] is StateConnection && (this.outputs[_loc4_] as StateConnection).label.type == Label.TYPE_REVERSE_TRIGGER)
               {
                  if(_loc1_ >= this._value)
                  {
                     (this.outputs[_loc4_] as StateConnection).reverseFire();
                  }
               }
               _loc4_++;
            }
         }
         if(this.interaction != 0)
         {
            if(doEvents)
            {
               dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
            }
            _loc2_ = this._value;
            this._value += this.interaction;
            this.interaction = 0;
            this._value = Math.min(Math.max(this._value,this.minValue),this.maxValue);
            this.calculateValue();
            _loc3_ = int(outputs.length);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(outputs[_loc4_] is StateConnection)
               {
                  (outputs[_loc4_] as StateConnection).changeState(this._value - _loc2_);
               }
               _loc4_++;
            }
         }
         super.fire();
      }
      
      override public function autoFire() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:int = 0;
         super.autoFire();
         if(this.hasTriggers && !this.isTriggered)
         {
            _loc1_ = Math.random() * 100;
            _loc2_ = 0;
            while(_loc2_ < this.outputs.length)
            {
               if(this.outputs[_loc2_] is StateConnection && (this.outputs[_loc2_] as StateConnection).label.type == Label.TYPE_TRIGGER)
               {
                  if(_loc1_ < this._value)
                  {
                     (this.outputs[_loc2_] as StateConnection).fire();
                  }
               }
               if(this.outputs[_loc2_] is StateConnection && (this.outputs[_loc2_] as StateConnection).label.type == Label.TYPE_REVERSE_TRIGGER)
               {
                  if(_loc1_ >= this._value)
                  {
                     (this.outputs[_loc2_] as StateConnection).reverseFire();
                  }
               }
               _loc2_++;
            }
         }
      }
      
      public function get value() : int
      {
         if(!this.calculated)
         {
            this.calculateValue();
         }
         return this._value;
      }
      
      public function get startValue() : int
      {
         return this._startValue;
      }
      
      public function set startValue(param1:int) : void
      {
         this._startValue = param1;
         if(activationMode == MODE_INTERACTIVE)
         {
            this._value = this._startValue;
         }
      }
      
      override public function getConnection(param1:Vector3D) : Vector3D
      {
         var _loc2_:Vector3D = position.clone();
         var _loc3_:Vector3D = param1.subtract(position);
         _loc3_.normalize();
         var _loc4_:Vector3D = MathUtil.getSquareOutlinePoint(_loc3_,0.5 * size + thickness + 1);
         _loc2_.incrementBy(_loc4_);
         return _loc2_;
      }
      
      public function calculateValue() : void
      {
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(activationMode == MODE_INTERACTIVE)
         {
            this.calculated = true;
            return;
         }
         var _loc1_:int = int(inputs.length);
         var _loc3_:int = 0;
         if(this.expression)
         {
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               if(inputs[_loc2_] is StateConnection)
               {
                  _loc4_ = (inputs[_loc2_] as StateConnection).label.text.charCodeAt(0) - 97;
                  if(_loc4_ >= 0 && _loc4_ < this.values.length)
                  {
                     this.values[_loc4_] = (inputs[_loc2_] as StateConnection).state;
                  }
               }
               _loc2_++;
            }
            _loc3_ = MachinationsRegisterExpression.evaluate(this.postFix,this.values);
         }
         else if(caption.toLowerCase() == "max")
         {
            _loc3_ = int.MIN_VALUE;
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               if(inputs[_loc2_] is StateConnection)
               {
                  if(_loc3_ < (inputs[_loc2_] as StateConnection).state)
                  {
                     _loc3_ = (inputs[_loc2_] as StateConnection).state;
                  }
               }
               _loc2_++;
            }
         }
         else if(caption.toLowerCase() == "min")
         {
            _loc3_ = int.MAX_VALUE;
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               if(inputs[_loc2_] is StateConnection)
               {
                  if(_loc3_ > (inputs[_loc2_] as StateConnection).state)
                  {
                     _loc3_ = (inputs[_loc2_] as StateConnection).state;
                  }
               }
               _loc2_++;
            }
         }
         else
         {
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               if(inputs[_loc2_] is StateConnection)
               {
                  _loc3_ += (inputs[_loc2_] as StateConnection).state * (inputs[_loc2_] as StateConnection).label.value;
               }
               _loc2_++;
            }
            if(caption.toLowerCase() == "actions" && (graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_TURN_BASED)
            {
               (graph as MachinationsGraph).actionsPerTurn = _loc3_;
            }
         }
         _loc3_ = Math.min(Math.max(_loc3_,this.minValue),this.maxValue);
         if(_loc3_ != this._value)
         {
            _loc5_ = _loc3_ - this._value;
            this._value = _loc3_;
            if(doEvents)
            {
               dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
            }
            _loc1_ = int(outputs.length);
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               if(outputs[_loc2_] is StateConnection)
               {
                  (outputs[_loc2_] as StateConnection).changeState(_loc5_);
               }
               _loc2_++;
            }
         }
         this.calculated = true;
      }
      
      override public function prepare(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         super.prepare(param1);
         this.expression = false;
         if(this.activationMode != MODE_INTERACTIVE && caption != "" && caption != "max" && caption != "min")
         {
            if(!MachinationsRegisterExpression.isVariable(caption) && caption.indexOf("+") < 0 && caption.indexOf("-") < 0 && caption.indexOf("%") < 0 && caption.indexOf("*") < 0 && caption.indexOf("/") < 0 && caption.indexOf("D") < 0 && caption.indexOf("(") < 0 && caption.indexOf(")") < 0)
            {
               this.expression = false;
            }
            else
            {
               this.postFix = MachinationsRegisterExpression.toPostFix(caption);
               this.expression = true;
               _loc2_ = 0;
               while(_loc2_ < this.values.length)
               {
                  this.values[_loc2_] = 0;
                  _loc2_++;
               }
               this.calculateValue();
            }
         }
         if(this.activationMode == MODE_INTERACTIVE)
         {
            this.calculated = true;
            this._value = this.startValue;
            if(param1)
            {
               dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
            }
         }
         else if(!this.calculated)
         {
            this._value = 0;
         }
         this.hasTriggers = false;
         _loc2_ = 0;
         while(_loc2_ < this.outputs.length)
         {
            if(this.outputs[_loc2_] is StateConnection && ((this.outputs[_loc2_] as StateConnection).label.type == Label.TYPE_TRIGGER || (this.outputs[_loc2_] as StateConnection).label.type == Label.TYPE_REVERSE_TRIGGER))
            {
               this.hasTriggers = true;
               break;
            }
            _loc2_++;
         }
         this.isTriggered = false;
         _loc2_ = 0;
         while(_loc2_ < this.inputs.length)
         {
            if(this.inputs[_loc2_] is StateConnection && ((this.inputs[_loc2_] as StateConnection).label.type == Label.TYPE_TRIGGER || (this.inputs[_loc2_] as StateConnection).label.type == Label.TYPE_REVERSE_TRIGGER))
            {
               this.isTriggered = true;
               break;
            }
            _loc2_++;
         }
      }
      
      public function prepareCalculated() : void
      {
         if(this.activationMode == MODE_INTERACTIVE)
         {
            return;
         }
         if(!this.calculated)
         {
            this._value = 0;
         }
         var _loc1_:int = int(outputs.length);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            if(outputs[_loc2_] is StateConnection)
            {
               (outputs[_loc2_] as StateConnection).resetState();
            }
            _loc2_++;
         }
         this.calculateValue();
      }
      
      override public function stop() : void
      {
         super.stop();
         if(activationMode == MODE_INTERACTIVE)
         {
            this._value = this.startValue;
         }
         else
         {
            this._value = 0;
         }
         if(doEvents)
         {
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
         }
      }
      
      override public function generateXML() : XML
      {
         var _loc1_:XML = super.generateXML();
         _loc1_.@min = this.minValue;
         _loc1_.@max = this.maxValue;
         _loc1_.@start = this.startValue;
         _loc1_.@step = this.valueStep;
         return _loc1_;
      }
      
      override public function readXML(param1:XML) : void
      {
         super.readXML(param1);
         this.minValue = param1.@min;
         this.maxValue = param1.@max;
         this.startValue = param1.@start;
         this.valueStep = param1.@step;
         this.actions = 0;
      }
   }
}

