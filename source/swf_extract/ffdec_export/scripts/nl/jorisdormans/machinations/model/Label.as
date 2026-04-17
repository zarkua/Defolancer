package nl.jorisdormans.machinations.model
{
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import nl.jorisdormans.graph.GraphEvent;
   import nl.jorisdormans.phantomGraphics.PhantomFont;
   import nl.jorisdormans.utils.StringUtil;
   
   public class Label
   {
      
      public static const TYPE_CALCULATED_VALUE:String = "calculated";
      
      public static const TYPE_FIXED_VALUE:String = "fixed";
      
      public static const TYPE_NONE:String = "none";
      
      public static const TYPE_CHANGE_VALUE:String = "change_value";
      
      public static const TYPE_CHANGE_INTERVAL:String = "change_interval";
      
      public static const TYPE_CHANGE_PROBABILITY:String = "change_probability";
      
      public static const TYPE_CHANGE_MULTIPLIER:String = "change_multiplier";
      
      public static const TYPE_CHANGE_CAPACITY:String = "change_capacity";
      
      public static const TYPE_PROBABILITY:String = "probability";
      
      public static const TYPE_PROBABILITY_DYNAMIC:String = "probability_dynamic";
      
      public static const TYPE_EQUAL_TO:String = "equal_to";
      
      public static const TYPE_NOT_EQUAL_TO:String = "not_equal_to";
      
      public static const TYPE_LESS:String = "less";
      
      public static const TYPE_GREATER:String = "greater";
      
      public static const TYPE_LESS_OR_EQUAL:String = "less_or_equal";
      
      public static const TYPE_GREATER_OR_EQUAL:String = "greater_or_equal";
      
      public static const TYPE_RANGE:String = "range";
      
      public static const TYPE_DICE:String = "dice";
      
      public static const TYPE_SKILL:String = "random";
      
      public static const TYPE_MULTIPLAYER:String = "multiplayer";
      
      public static const TYPE_STRATEGY:String = "strategy";
      
      public static const TYPE_TRIGGER:String = "trigger";
      
      public static const TYPE_REVERSE_TRIGGER:String = "reverse_trigger";
      
      public static const TYPE_ELSE:String = "else";
      
      public static const TYPE_ALL:String = "all";
      
      public static const LIMIT:Number = 9999;
      
      private static const MAX_DIGIT:int = 3;
      
      private static const MAX_PROBABILITY_DIGIT:int = 1;
      
      private static const MAX_MULTIPLIER_DIGIT:int = 0;
      
      public var position:Number;
      
      public var connection:MachinationsConnection;
      
      public var calculatedPosition:Vector3D;
      
      public var calculatedNormal:Vector3D;
      
      private var _text:String;
      
      public var align:String;
      
      public var size:Point;
      
      public var side:int = 1;
      
      private var intervalText:String;
      
      private var preIntervalText:String;
      
      private var postFix:Array;
      
      private var postFixInterval:Array;
      
      private var _value:Number;
      
      public var type:String;
      
      public var intervalType:String;
      
      private var probability:Number;
      
      private var inputStateValue:Number;
      
      private var inputStateInterval:Number;
      
      private var _interval:int;
      
      private var rangeTop:Number;
      
      private var rest:Number;
      
      public var drawRandom:Boolean = false;
      
      private var multiplier:int;
      
      private var originalMultiplier:int;
      
      public var generatedValues:Vector.<Number>;
      
      public var min:Number = -LIMIT;
      
      public var max:Number = 9999;
      
      public function Label(param1:MachinationsConnection, param2:Number, param3:String)
      {
         super();
         this.generatedValues = new Vector.<Number>();
         this.connection = param1;
         this.position = param2;
         this.text = param3;
         this.align = PhantomFont.ALIGN_LEFT;
         this.size = new Point();
         this.inputStateInterval = 0;
         this.inputStateValue = 0;
         this.preIntervalText = "";
         this.intervalText = "";
         this.rest = 0;
         this.drawRandom = false;
         this.multiplier = -1;
         this.originalMultiplier = this.multiplier;
      }
      
      public function pointInModifier(param1:Number, param2:Number) : Boolean
      {
         switch(this.align)
         {
            default:
            case PhantomFont.ALIGN_LEFT:
               return param1 > this.calculatedPosition.x - 5 && param1 < this.calculatedPosition.x + this.size.x + 5 && param2 > this.calculatedPosition.y - 10 && param2 < this.calculatedPosition.y + this.size.y;
            case PhantomFont.ALIGN_RIGHT:
               return param1 > this.calculatedPosition.x - this.size.x - 5 && param1 < this.calculatedPosition.x + 5 && param2 > this.calculatedPosition.y - 10 && param2 < this.calculatedPosition.y + this.size.y;
            case PhantomFont.ALIGN_CENTER:
               return param1 > this.calculatedPosition.x - this.size.x * 0.5 - 5 && param1 < this.calculatedPosition.x + this.size.x * 0.5 + 5 && param2 > this.calculatedPosition.y - 10 && param2 < this.calculatedPosition.y + this.size.y;
         }
      }
      
      public function generateNewValue() : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(Boolean(this.postFix) && this.postFix.length > 0)
         {
         }
         this.generatedValues.splice(0,this.generatedValues.length);
         switch(this.type)
         {
            case TYPE_EQUAL_TO:
            case TYPE_GREATER:
            case TYPE_GREATER_OR_EQUAL:
            case TYPE_CHANGE_INTERVAL:
            case TYPE_CHANGE_VALUE:
            case TYPE_CHANGE_PROBABILITY:
            case TYPE_CHANGE_MULTIPLIER:
            case TYPE_CHANGE_CAPACITY:
            case TYPE_ALL:
            case TYPE_LESS:
            case TYPE_LESS_OR_EQUAL:
            case TYPE_NOT_EQUAL_TO:
            case TYPE_RANGE:
            case TYPE_TRIGGER:
            case TYPE_REVERSE_TRIGGER:
            case TYPE_PROBABILITY_DYNAMIC:
               this.generatedValues.push(this._value);
               return;
            case TYPE_NONE:
               this._value = 1;
               this.generatedValues.push(this._value);
               return;
            case TYPE_ELSE:
               this._value = 1;
               this.generatedValues.push(this._value);
               return;
            case TYPE_DICE:
               if(this.connection.graph)
               {
                  this._value = (this.connection.graph as MachinationsGraph).getDiceValue() + this.inputStateValue;
               }
               this.generatedValues.push(this._value);
               return;
            case TYPE_SKILL:
               if(this.connection.graph)
               {
                  this._value = (this.connection.graph as MachinationsGraph).getSkillValue() + this.inputStateValue;
               }
               this.generatedValues.push(this._value);
               return;
            case TYPE_MULTIPLAYER:
               if(this.connection.graph)
               {
                  this._value = (this.connection.graph as MachinationsGraph).getMultiplayerValue() + this.inputStateValue;
               }
               this.generatedValues.push(this._value);
               return;
            case TYPE_STRATEGY:
               if(this.connection.graph)
               {
                  this._value = (this.connection.graph as MachinationsGraph).getStrategyValue() + this.inputStateValue;
               }
               this.generatedValues.push(this._value);
               return;
            default:
               this._value = 0;
               var _loc1_:int = this.multiplier;
               if(this.originalMultiplier < 0)
               {
                  _loc1_ = 1;
               }
               var _loc2_:int = 0;
               while(_loc2_ < _loc1_)
               {
                  switch(this.type)
                  {
                     case TYPE_FIXED_VALUE:
                        _loc3_ = this.postFix[0] as Number;
                        _loc3_ += this.inputStateValue;
                        if(this.connection is ResourceConnection)
                        {
                           _loc3_ += this.rest;
                           this._value += Math.floor(_loc3_);
                           this.generatedValues.push(Math.floor(_loc3_));
                           this.rest = _loc3_ % 1;
                        }
                        else
                        {
                           this._value += _loc3_;
                           this.generatedValues.push(_loc3_);
                        }
                        break;
                     case TYPE_CALCULATED_VALUE:
                        _loc3_ = MachinationsExpression.evaluatePostFix(this.postFix);
                        _loc3_ += this.inputStateValue;
                        if(this.connection is ResourceConnection)
                        {
                           _loc3_ += this.rest;
                           this._value += Math.floor(_loc3_);
                           this.generatedValues.push(Math.floor(_loc3_));
                           this.rest = _loc3_ % 1;
                        }
                        else
                        {
                           this._value += _loc3_;
                           this.generatedValues.push(_loc3_);
                        }
                        break;
                     case TYPE_PROBABILITY:
                        _loc4_ = this.probability + this.inputStateValue;
                        _loc3_ = 0;
                        while(_loc4_ > 100)
                        {
                           _loc3_ += 1;
                           _loc4_ -= 100;
                        }
                        if(Math.random() * 100 < _loc4_)
                        {
                           _loc3_++;
                        }
                        this._value += _loc3_;
                        this.generatedValues.push(_loc3_);
                  }
                  _loc2_++;
               }
               return;
         }
      }
      
      public function get value() : Number
      {
         var _loc1_:Number = NaN;
         if(this.connection is ResourceConnection && this.intervalType != TYPE_NONE)
         {
            if(this._interval > 1)
            {
               --this._interval;
               return 0;
            }
            this.setNewInterval();
         }
         switch(this.type)
         {
            case TYPE_PROBABILITY_DYNAMIC:
            case TYPE_PROBABILITY:
               if(this.connection.start is Gate)
               {
                  var _temp_4:* = Math;
                  var _temp_3:* = this.min;
                  Math.min;
                  this.max;
                  return _temp_4.max(_temp_3,this.probability + this.inputStateValue);
               }
               return Math.max(this.min,Math.min(this.max,this._value));
               break;
            case TYPE_ALL:
               if(this.connection.start is Pool)
               {
                  if((this.connection.start as Pool).color != this.connection.color)
                  {
                     this._value = Math.max(0,Math.max(this.min,Math.min(this.max,(this.connection.start as Pool).resourceColorCount(this.connection.color))));
                  }
                  else
                  {
                     this._value = Math.max(0,Math.max(this.min,Math.min(this.max,(this.connection.start as Pool).resourceCount)));
                  }
                  this.generatedValues.push(this._value);
                  return this._value;
               }
               return 0;
               break;
            case TYPE_CHANGE_VALUE:
            case TYPE_CHANGE_INTERVAL:
            case TYPE_CHANGE_PROBABILITY:
               _loc1_ = this._value + this.inputStateValue;
               return Math.max(this.min,Math.min(this.max,_loc1_));
            default:
               return Math.max(this.min,Math.min(this.max,this._value));
         }
      }
      
      private function setNewInterval() : void
      {
         switch(this.intervalType)
         {
            default:
            case TYPE_NONE:
               this._interval = 1;
               break;
            case TYPE_FIXED_VALUE:
               this._interval = Math.floor(this.postFixInterval[0]) + this.inputStateInterval;
               break;
            case TYPE_CALCULATED_VALUE:
               this._interval = Math.floor(MachinationsExpression.evaluatePostFix(this.postFixInterval)) + this.inputStateInterval;
         }
      }
      
      public function get text() : String
      {
         var _loc1_:Number = NaN;
         if(this._text == "")
         {
            return "";
         }
         var _loc2_:String = this._text;
         switch(this.type)
         {
            case TYPE_NONE:
               return "";
            case TYPE_DICE:
            case TYPE_SKILL:
            case TYPE_MULTIPLAYER:
            case TYPE_STRATEGY:
               return "   " + this.getIntervalText();
            default:
               _loc2_ = this.preIntervalText;
               if(this.inputStateValue != 0)
               {
                  switch(this.type)
                  {
                     case TYPE_FIXED_VALUE:
                        _loc1_ = this.postFix[0] as Number;
                        _loc1_ += this.inputStateValue;
                        _loc1_ = Math.round(_loc1_ * 100) / 100;
                        _loc1_ = Math.max(this.min,Math.min(this.max,_loc1_));
                        _loc2_ = StringUtil.floatToStringMaxPrecision(_loc1_,MAX_DIGIT);
                        break;
                     case TYPE_CALCULATED_VALUE:
                        _loc1_ = Math.round(this.inputStateValue);
                        _loc1_ = Math.max(this.min,Math.min(this.max,_loc1_));
                        if(_loc1_ < 0)
                        {
                           _loc2_ = this.preIntervalText + StringUtil.floatToStringMaxPrecision(_loc1_,MAX_DIGIT);
                        }
                        else if(_loc1_ > 0)
                        {
                           _loc2_ = this.preIntervalText + "+" + StringUtil.floatToStringMaxPrecision(_loc1_,MAX_DIGIT);
                        }
                        break;
                     case TYPE_PROBABILITY:
                        _loc1_ = this.probability + Math.round(this.inputStateValue);
                        _loc1_ = Math.max(this.min,Math.min(this.max,_loc1_));
                        _loc2_ = StringUtil.floatToStringMaxPrecision(_loc1_,MAX_PROBABILITY_DIGIT) + "%";
                        break;
                     case TYPE_PROBABILITY_DYNAMIC:
                        _loc1_ = this.probability;
                        _loc1_ = Math.max(this.min,Math.min(this.max,_loc1_));
                        if(_loc1_ < 0)
                        {
                           _loc2_ = "%";
                        }
                        else
                        {
                           _loc2_ = StringUtil.floatToStringMaxPrecision(_loc1_,MAX_PROBABILITY_DIGIT) + "%";
                        }
                        break;
                     case TYPE_CHANGE_VALUE:
                        _loc1_ = this._value + this.inputStateValue;
                        _loc1_ = Math.max(this.min,Math.min(this.max,_loc1_));
                        if(_loc1_ < 0)
                        {
                           _loc2_ = StringUtil.floatToStringMaxPrecision(_loc1_,MAX_DIGIT);
                        }
                        else
                        {
                           _loc2_ = "+" + StringUtil.floatToStringMaxPrecision(_loc1_,MAX_DIGIT);
                        }
                        break;
                     case TYPE_CHANGE_INTERVAL:
                        _loc1_ = Math.round(this._value + this.inputStateValue);
                        _loc1_ = Math.max(this.min,Math.min(this.max,_loc1_));
                        if(_loc1_ < 0)
                        {
                           _loc2_ = StringUtil.floatToStringMaxPrecision(_loc1_,MAX_MULTIPLIER_DIGIT) + "i";
                        }
                        else
                        {
                           _loc2_ = "+" + StringUtil.floatToStringMaxPrecision(_loc1_,MAX_MULTIPLIER_DIGIT) + "i";
                        }
                        break;
                     case TYPE_CHANGE_PROBABILITY:
                        _loc1_ = this._value + this.inputStateValue;
                        _loc1_ = Math.max(this.min,Math.min(this.max,_loc1_));
                        if(_loc1_ < 0)
                        {
                           _loc2_ = StringUtil.floatToStringMaxPrecision(_loc1_,MAX_PROBABILITY_DIGIT) + "%";
                        }
                        else
                        {
                           _loc2_ = "+" + StringUtil.floatToStringMaxPrecision(_loc1_,MAX_PROBABILITY_DIGIT) + "%";
                        }
                        break;
                     case TYPE_CHANGE_MULTIPLIER:
                        _loc1_ = this._value + this.inputStateValue;
                        _loc1_ = Math.max(this.min,Math.min(this.max,_loc1_));
                        if(_loc1_ < 0)
                        {
                           _loc2_ = StringUtil.floatToStringMaxPrecision(_loc1_,MAX_MULTIPLIER_DIGIT) + "m";
                        }
                        else
                        {
                           _loc2_ = "+" + StringUtil.floatToStringMaxPrecision(_loc1_,MAX_MULTIPLIER_DIGIT) + "m";
                        }
                        break;
                     case TYPE_CHANGE_CAPACITY:
                        _loc1_ = this._value + this.inputStateValue;
                        _loc1_ = Math.max(this.min,Math.min(this.max,_loc1_));
                        if(_loc1_ < 0)
                        {
                           _loc2_ = StringUtil.floatToStringMaxPrecision(_loc1_,MAX_MULTIPLIER_DIGIT) + "c";
                        }
                        else
                        {
                           _loc2_ = "+" + StringUtil.floatToStringMaxPrecision(_loc1_,MAX_MULTIPLIER_DIGIT) + "c";
                        }
                        break;
                     case TYPE_EQUAL_TO:
                        _loc1_ = this._value + this.inputStateValue;
                        _loc1_ = Math.max(this.min,Math.min(this.max,_loc1_));
                        _loc2_ = "==" + StringUtil.floatToStringMaxPrecision(_loc1_,0);
                        break;
                     case TYPE_NOT_EQUAL_TO:
                        _loc1_ = this._value + this.inputStateValue;
                        _loc1_ = Math.max(this.min,Math.min(this.max,_loc1_));
                        _loc2_ = "!=" + StringUtil.floatToStringMaxPrecision(_loc1_,0);
                        break;
                     case TYPE_LESS_OR_EQUAL:
                        _loc1_ = this._value + this.inputStateValue;
                        _loc1_ = Math.max(this.min,Math.min(this.max,_loc1_));
                        _loc2_ = "<=" + StringUtil.floatToStringMaxPrecision(_loc1_,0);
                        break;
                     case TYPE_LESS:
                        _loc1_ = this._value + this.inputStateValue;
                        _loc1_ = Math.max(this.min,Math.min(this.max,_loc1_));
                        _loc2_ = "<" + StringUtil.floatToStringMaxPrecision(_loc1_,0);
                        break;
                     case TYPE_GREATER_OR_EQUAL:
                        _loc1_ = this._value + this.inputStateValue;
                        _loc1_ = Math.max(this.min,Math.min(this.max,_loc1_));
                        _loc2_ = ">=" + StringUtil.floatToStringMaxPrecision(_loc1_,0);
                        break;
                     case TYPE_GREATER:
                        _loc1_ = this._value + this.inputStateValue;
                        _loc1_ = Math.max(this.min,Math.min(this.max,_loc1_));
                        _loc2_ = ">" + StringUtil.floatToStringMaxPrecision(_loc1_,0);
                        break;
                     case TYPE_TRIGGER:
                        _loc2_ = "!";
                        break;
                     case TYPE_TRIGGER:
                        _loc2_ = "*";
                        break;
                     case TYPE_ALL:
                        _loc2_ = "all";
                  }
               }
               _loc2_ += this.getIntervalText();
               if(this.drawRandom && _loc2_.substr(0,4) != "draw")
               {
                  _loc2_ = "draw" + _loc2_;
               }
               if(this.originalMultiplier >= 0)
               {
                  _loc2_ = this.multiplier.toString() + "*" + _loc2_;
               }
               return _loc2_;
         }
      }
      
      private function getIntervalText() : String
      {
         var _loc1_:String = null;
         var _loc2_:int = 0;
         if(this.intervalText == null || this.intervalText == "")
         {
            _loc1_ = "";
         }
         else
         {
            _loc1_ = "/" + this.intervalText;
         }
         if(this.inputStateInterval != 0)
         {
            switch(this.intervalType)
            {
               case TYPE_FIXED_VALUE:
                  _loc2_ = this.postFixInterval[0] + Math.round(this.inputStateInterval);
                  _loc1_ = "/" + _loc2_.toString();
                  break;
               case TYPE_CALCULATED_VALUE:
                  _loc2_ = Math.round(this.inputStateInterval);
                  if(_loc2_ < 0)
                  {
                     _loc1_ = this.intervalText + _loc2_.toString();
                  }
                  else if(_loc2_ > 0)
                  {
                     _loc1_ = "/" + (this.intervalText + "+" + _loc2_.toString());
                  }
            }
         }
         return _loc1_;
      }
      
      public function set text(param1:String) : void
      {
         this._text = param1;
         this.determineType();
         this.generateNewValue();
         this.setNewInterval();
      }
      
      public function getRealText() : String
      {
         return this._text;
      }
      
      public function get interval() : int
      {
         return this._interval;
      }
      
      public function prepare() : void
      {
         this.determineType();
         this.inputStateValue = 0;
         this.inputStateInterval = 0;
         this.rest = 0;
         this.generateNewValue();
         this.setNewInterval();
      }
      
      public function reset() : void
      {
         this.inputStateValue = 0;
      }
      
      public function determineType() : void
      {
         var _loc2_:int = 0;
         var _loc1_:String = this._text;
         this.drawRandom = false;
         this.intervalType = TYPE_NONE;
         if(_loc1_ == "")
         {
            if(this.connection is ResourceConnection)
            {
               this.type = TYPE_NONE;
               this.generateNewValue();
            }
            else
            {
               this.type = TYPE_CHANGE_VALUE;
               this._value = 1;
            }
            return;
         }
         _loc2_ = _loc1_.indexOf("*");
         if(_loc2_ > 0)
         {
            this.multiplier = parseInt(_loc1_.substr(0,_loc2_));
            _loc1_ = _loc1_.substr(_loc2_ + 1);
         }
         else
         {
            this.multiplier = -1;
         }
         this.originalMultiplier = this.multiplier;
         _loc2_ = _loc1_.indexOf("/");
         if(_loc2_ >= 0)
         {
            this.preIntervalText = _loc1_.substr(0,_loc2_);
            this.intervalText = _loc1_.substr(_loc2_ + 1);
            _loc1_ = this.preIntervalText;
            this.postFixInterval = MachinationsExpression.toPostFix(this.intervalText);
            if(this.postFixInterval.length == 1)
            {
               this.intervalType = TYPE_FIXED_VALUE;
            }
            else
            {
               this.intervalType = TYPE_CALCULATED_VALUE;
            }
         }
         else
         {
            this.preIntervalText = _loc1_;
            this.intervalText = "";
         }
         if(_loc1_.substr(0,4) == "draw")
         {
            this.drawRandom = true;
            _loc1_ = _loc1_.substr(4);
         }
         if(_loc1_ == "*")
         {
            this.type = TYPE_TRIGGER;
            this._value = 0;
         }
         else if(_loc1_ == "!")
         {
            this.type = TYPE_REVERSE_TRIGGER;
            this._value = 0;
         }
         else if(_loc1_ == "%")
         {
            this.type = TYPE_PROBABILITY_DYNAMIC;
            this.probability = -1;
            this._value = 0;
         }
         else if(_loc1_.toLowerCase() == "else")
         {
            this.type = TYPE_ELSE;
            this.probability = 0;
            this._value = 0;
         }
         else if(_loc1_.toLowerCase() == "all")
         {
            this.type = TYPE_ALL;
            this.probability = 0;
            this._value = 0;
         }
         else if(_loc1_ == "D")
         {
            this.type = TYPE_DICE;
         }
         else if(_loc1_ == "S")
         {
            this.type = TYPE_SKILL;
         }
         else if(_loc1_ == "ST")
         {
            this.type = TYPE_STRATEGY;
         }
         else if(_loc1_ == "M")
         {
            this.type = TYPE_MULTIPLAYER;
         }
         else if(_loc1_.substr(0,2) == "==")
         {
            this.type = TYPE_EQUAL_TO;
            this._value = parseFloat(_loc1_.substr(2));
         }
         else if(_loc1_.substr(0,2) == "!=")
         {
            this.type = TYPE_NOT_EQUAL_TO;
            this._value = parseFloat(_loc1_.substr(2));
         }
         else if(_loc1_.substr(0,2) == "<=")
         {
            this.type = TYPE_LESS_OR_EQUAL;
            this._value = parseFloat(_loc1_.substr(2));
         }
         else if(_loc1_.substr(0,2) == ">=")
         {
            this.type = TYPE_GREATER_OR_EQUAL;
            this._value = parseFloat(_loc1_.substr(2));
         }
         else if(_loc1_.substr(0,1) == "<")
         {
            this.type = TYPE_LESS;
            this._value = parseFloat(_loc1_.substr(1));
         }
         else if(_loc1_.substr(0,1) == ">")
         {
            this.type = TYPE_GREATER;
            this._value = parseFloat(_loc1_.substr(1));
         }
         else if((this.connection.start is Gate || this.connection is StateConnection) && _loc1_.indexOf("-") > 0)
         {
            this.type = TYPE_RANGE;
            _loc2_ = _loc1_.indexOf("-");
            this._value = parseFloat(_loc1_.substr(0,_loc2_));
            this.rangeTop = parseFloat(_loc1_.substr(_loc2_ + 1));
         }
         else if(_loc1_.charAt(0) == "+" || _loc1_.charAt(0) == "-" && this.connection is StateConnection)
         {
            this.type = TYPE_CHANGE_VALUE;
            _loc2_ = _loc1_.indexOf("m");
            if(_loc2_ >= 0)
            {
               this.type = TYPE_CHANGE_MULTIPLIER;
               _loc1_ = _loc1_.substr(0,_loc2_);
            }
            _loc2_ = _loc1_.indexOf("c");
            if(_loc2_ >= 0)
            {
               this.type = TYPE_CHANGE_CAPACITY;
               _loc1_ = _loc1_.substr(0,_loc2_);
            }
            _loc2_ = _loc1_.indexOf("i");
            if(_loc2_ >= 0)
            {
               this.type = TYPE_CHANGE_INTERVAL;
               _loc1_ = _loc1_.substr(0,_loc2_);
            }
            _loc2_ = _loc1_.indexOf("%");
            if(_loc2_ >= 0)
            {
               this.type = TYPE_CHANGE_PROBABILITY;
               _loc1_ = _loc1_.substr(0,_loc2_);
            }
            this._value = parseFloat(_loc1_.substr(1));
            if(_loc1_.charAt(0) == "-")
            {
               this._value *= -1;
            }
         }
         else if(_loc1_.indexOf("%") > 0)
         {
            this.type = TYPE_PROBABILITY;
            this.probability = parseFloat(_loc1_.substr(0,_loc1_.indexOf("%")));
            if(isNaN(this.probability))
            {
               this.probability = 0;
            }
         }
         else
         {
            this.postFix = MachinationsExpression.toPostFix(_loc1_);
            if(this.postFix.length == 1)
            {
               this.type = TYPE_FIXED_VALUE;
            }
            else
            {
               this.type = TYPE_CALCULATED_VALUE;
            }
         }
      }
      
      public function stop() : void
      {
         this.inputStateValue = 0;
         this.inputStateInterval = 0;
         this.multiplier = this.originalMultiplier;
      }
      
      public function modify(param1:Number) : void
      {
         this.inputStateValue += param1;
         this.generateNewValue();
         if(this.connection.doEvents)
         {
            this.connection.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this.connection));
         }
         if(this.connection.start is Gate && this.type == TYPE_PROBABILITY)
         {
            (this.connection.start as Gate).checkDynamicProbabilities();
         }
         if(this.isCondition() && this.connection is StateConnection)
         {
            (this.connection as StateConnection).inhibited = !this.checkCondition((this.connection as StateConnection).state);
         }
      }
      
      public function modifyInterval(param1:int) : void
      {
         this.inputStateInterval += param1;
         this.generateNewValue();
         if(this.connection.doEvents)
         {
            this.connection.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this.connection));
         }
      }
      
      public function modifyMultiplier(param1:int) : void
      {
         this.multiplier += param1;
         this.generateNewValue();
         if(this.connection.doEvents)
         {
            this.connection.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this.connection));
         }
      }
      
      public function isCondition() : Boolean
      {
         switch(this.type)
         {
            case Label.TYPE_GREATER:
            case Label.TYPE_GREATER_OR_EQUAL:
            case Label.TYPE_EQUAL_TO:
            case Label.TYPE_LESS:
            case Label.TYPE_LESS_OR_EQUAL:
            case Label.TYPE_NOT_EQUAL_TO:
            case Label.TYPE_RANGE:
            case Label.TYPE_ELSE:
               return true;
            default:
               return false;
         }
      }
      
      public function checkCondition(param1:Number) : Boolean
      {
         if(!this.connection.graph || !(this.connection.graph as MachinationsGraph).running)
         {
            return true;
         }
         switch(this.type)
         {
            case Label.TYPE_GREATER:
               return param1 > this._value + this.inputStateValue;
            case Label.TYPE_GREATER_OR_EQUAL:
               return param1 >= this._value + this.inputStateValue;
            case Label.TYPE_EQUAL_TO:
               return param1 == this._value + this.inputStateValue;
            case Label.TYPE_LESS:
               return param1 < this._value + this.inputStateValue;
            case Label.TYPE_LESS_OR_EQUAL:
               return param1 <= this._value + this.inputStateValue;
            case Label.TYPE_NOT_EQUAL_TO:
               return param1 != this._value + this.inputStateValue;
            case Label.TYPE_RANGE:
               return param1 >= this._value && param1 <= this.rangeTop;
            case Label.TYPE_FIXED_VALUE:
               return param1 == this._value + this.inputStateValue;
            case Label.TYPE_ELSE:
               return false;
            default:
               return false;
         }
      }
      
      public function setDynamicProbability(param1:Number) : void
      {
         if(param1 != this.probability)
         {
            this.probability = param1;
            this.inputStateValue = 1;
            if(this.connection.doEvents)
            {
               this.connection.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this.connection));
            }
         }
      }
   }
}

