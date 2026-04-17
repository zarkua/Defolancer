package nl.jorisdormans.machinations.model
{
   public class MachinationsRegisterExpression
   {
      
      private static var postFix:Array;
      
      private static var stack:Array;
      
      private static const operands:String = "0123456789.";
      
      private static const variables:String = "abcdefghijklmnopqrstuvw";
      
      private static const operators:String = "()-+*/%D";
      
      public function MachinationsRegisterExpression()
      {
         super();
      }
      
      private static function isOperand(param1:String) : Boolean
      {
         return operands.indexOf(param1) >= 0;
      }
      
      public static function isVariable(param1:String) : Boolean
      {
         return variables.indexOf(param1) >= 0;
      }
      
      private static function isOperator(param1:String) : Boolean
      {
         return operators.indexOf(param1) >= 0;
      }
      
      public static function toPostFix(param1:String) : Array
      {
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc2_:Array = new Array();
         postFix = new Array();
         stack = new Array();
         while(param1.length > 0)
         {
            _loc4_ = 0;
            _loc6_ = "";
            while(_loc4_ < param1.length)
            {
               _loc5_ = param1.charAt(_loc4_);
               if(!isOperand(_loc5_))
               {
                  break;
               }
               _loc6_ += _loc5_;
               _loc4_++;
            }
            if(_loc6_.length == 0)
            {
               if(isOperator(_loc5_))
               {
                  _loc2_.push(_loc5_);
               }
               if(isVariable(_loc5_))
               {
                  if(_loc2_.length > 0)
                  {
                     if(!isOperator(_loc2_[_loc2_.length - 1]))
                     {
                        _loc2_.push("*");
                     }
                  }
                  _loc2_.push(_loc5_);
               }
               param1 = param1.substr(1);
            }
            else
            {
               _loc2_.push(parseFloat(_loc6_));
               param1 = param1.substr(_loc6_.length);
            }
         }
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            if(_loc2_[_loc3_] == "-")
            {
               if(_loc3_ == 0 || isOperator(_loc2_[_loc3_ - 1] as String))
               {
                  if(_loc2_[_loc3_ + 1] is Number)
                  {
                     _loc2_[_loc3_ + 1] = (_loc2_[_loc3_ + 1] as Number) * -1;
                  }
                  _loc2_.splice(_loc3_,1);
                  continue;
               }
            }
            if(_loc2_[_loc3_] == "D")
            {
               if(_loc3_ == 0 || isOperator(_loc2_[_loc3_ - 1] as String))
               {
                  _loc2_.splice(_loc3_,0,1);
                  _loc3_ += 2;
                  continue;
               }
            }
            _loc3_++;
         }
         while(_loc2_.length > 0)
         {
            _loc5_ = _loc2_[0] as String;
            switch(_loc5_)
            {
               case "-":
               case "+":
                  gotOperator(_loc5_,1);
                  break;
               case "/":
               case "*":
               case "%":
                  gotOperator(_loc5_,2);
                  break;
               case "D":
                  gotOperator(_loc5_,3);
                  break;
               case "(":
                  stack.push(_loc5_);
                  break;
               case ")":
                  gotParenthesis();
                  break;
               default:
                  postFix.push(_loc2_[0]);
            }
            _loc2_.splice(0,1);
         }
         while(stack.length > 0)
         {
            postFix.push(stack.pop());
         }
         return postFix;
      }
      
      private static function gotOperator(param1:String, param2:int) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         while(stack.length > 0)
         {
            _loc3_ = stack.pop();
            if(_loc3_ == "(")
            {
               stack.push(_loc3_);
               break;
            }
            switch(_loc3_)
            {
               case "-":
               case "+":
                  _loc4_ = 1;
                  break;
               default:
               case "*":
               case "/":
               case "%":
                  _loc4_ = 2;
                  break;
               case "D":
                  _loc4_ = 3;
            }
            if(_loc4_ < param2)
            {
               stack.push(_loc3_);
               break;
            }
            postFix.push(_loc3_);
         }
         stack.push(param1);
      }
      
      private static function gotParenthesis() : void
      {
         var _loc1_:String = null;
         while(stack.length > 0)
         {
            _loc1_ = stack.pop();
            if(_loc1_ == "(")
            {
               break;
            }
            postFix.push(_loc1_);
         }
      }
      
      public static function evaluate(param1:Array, param2:Array) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         if(!param1 || !param2)
         {
            return 0;
         }
         stack = new Array();
         var _loc7_:int = int(param1.length);
         var _loc8_:int = 0;
         while(_loc8_ < _loc7_)
         {
            if(!(param1[_loc8_] is String))
            {
               stack.push(param1[_loc8_]);
            }
            else if(isVariable(param1[_loc8_] as String))
            {
               _loc6_ = param1[_loc8_].charCodeAt(0) - 97;
               if(_loc6_ >= 0 && _loc6_ < param2.length)
               {
                  stack.push(param2[_loc6_]);
               }
               else
               {
                  stack.push(0);
               }
            }
            else
            {
               _loc4_ = stack.pop() as Number;
               _loc3_ = stack.pop() as Number;
               switch(param1[_loc8_])
               {
                  case "+":
                     _loc5_ = _loc3_ + _loc4_;
                     break;
                  case "-":
                     _loc5_ = _loc3_ - _loc4_;
                     break;
                  case "%":
                     _loc5_ = _loc3_ % _loc4_;
                     break;
                  case "*":
                     _loc5_ = _loc3_ * _loc4_;
                     break;
                  case "/":
                     _loc5_ = _loc3_ / _loc4_;
                     break;
                  case "D":
                     _loc5_ = 0;
                     _loc6_ = 0;
                     while(_loc6_ < _loc3_)
                     {
                        _loc5_ += 1 + Math.floor(Math.random() * _loc4_);
                        _loc6_++;
                     }
                     break;
                  default:
                     _loc5_ = 0;
               }
               stack.push(_loc5_);
            }
            _loc8_++;
         }
         return stack.pop() as Number;
      }
   }
}

