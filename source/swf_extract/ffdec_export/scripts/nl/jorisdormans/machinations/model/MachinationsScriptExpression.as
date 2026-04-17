package nl.jorisdormans.machinations.model
{
   import nl.jorisdormans.utils.StringUtil;
   
   public class MachinationsScriptExpression
   {
      
      private static var postFix:Array;
      
      private static var stack:Array;
      
      private static const operands:String = "0123456789.";
      
      private static const operators:String = "()-+*/%&|^=!><";
      
      public function MachinationsScriptExpression()
      {
         super();
      }
      
      private static function isOperand(param1:String) : Boolean
      {
         return operands.indexOf(param1) >= 0;
      }
      
      private static function isOperator(param1:String) : Boolean
      {
         if(param1.length > 0)
         {
            return operators.indexOf(param1.substring(0,1)) >= 0;
         }
         return operators.indexOf(param1) >= 0;
      }
      
      public static function toPostFix(param1:String) : Array
      {
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:Number = NaN;
         var _loc2_:Array = new Array();
         postFix = new Array();
         stack = new Array();
         while(param1.indexOf(" ") >= 0)
         {
            param1 = param1.replace(" ","");
         }
         while(param1.length > 0)
         {
            _loc4_ = 0;
            _loc6_ = "";
            _loc7_ = 0;
            while(_loc4_ < param1.length)
            {
               _loc5_ = param1.charAt(_loc4_);
               if(_loc7_ == 0)
               {
                  if(isOperator(_loc5_))
                  {
                     _loc7_ = 1;
                  }
                  else
                  {
                     _loc7_ = -1;
                  }
               }
               if(_loc7_ == 1)
               {
                  if((_loc5_ == "-" || _loc5_ == "(" || _loc5_ == ")") && _loc4_ > 0)
                  {
                     break;
                  }
                  if(!isOperator(_loc5_))
                  {
                     break;
                  }
               }
               if(_loc7_ == -1)
               {
                  if(isOperator(_loc5_))
                  {
                     break;
                  }
               }
               _loc6_ += _loc5_;
               _loc4_++;
               if(_loc5_ == ")" || _loc5_ == "(")
               {
                  break;
               }
            }
            if(_loc7_ == 1)
            {
               _loc2_.push(_loc6_);
            }
            if(_loc7_ == -1)
            {
               _loc8_ = parseFloat(_loc6_);
               if(isNaN(_loc8_))
               {
                  _loc2_.push(_loc6_);
               }
               else
               {
                  _loc2_.push(_loc8_);
               }
            }
            param1 = param1.substr(_loc6_.length);
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
                  else
                  {
                     _loc2_.splice(_loc3_ + 1,0,-1,"*");
                  }
                  _loc2_.splice(_loc3_,1);
                  continue;
               }
            }
            _loc3_++;
         }
         while(_loc2_.length > 0)
         {
            _loc5_ = _loc2_[0] as String;
            if(_loc5_ != null)
            {
               _loc5_ = StringUtil.trim(_loc5_);
            }
            switch(_loc5_)
            {
               case "||":
                  gotOperator(_loc5_,1);
                  break;
               case "&&":
                  gotOperator(_loc5_,2);
                  break;
               case "|":
                  gotOperator(_loc5_,3);
                  break;
               case "^":
                  gotOperator(_loc5_,4);
                  break;
               case "&":
                  gotOperator(_loc5_,5);
                  break;
               case "==":
               case "!=":
                  gotOperator(_loc5_,6);
                  break;
               case "<":
               case ">":
               case "<=":
               case ">=":
                  gotOperator(_loc5_,7);
                  break;
               case "-":
               case "+":
                  gotOperator(_loc5_,8);
                  break;
               case "%":
               case "/":
               case "*":
                  gotOperator(_loc5_,9);
                  break;
               case "(":
                  stack.push(_loc5_);
                  break;
               case ")":
                  gotParenthesis();
                  break;
               default:
                  if(_loc5_)
                  {
                     postFix.push(_loc5_);
                  }
                  else
                  {
                     postFix.push(_loc2_[0]);
                  }
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
               case "||":
                  _loc4_ = 1;
                  break;
               case "&&":
                  _loc4_ = 2;
                  break;
               case "|":
                  _loc4_ = 3;
                  break;
               case "^":
                  _loc4_ = 4;
                  break;
               case "&":
                  _loc4_ = 5;
                  break;
               case "==":
               case "!=":
                  _loc4_ = 6;
                  break;
               case "<":
               case ">":
               case "<=":
               case ">=":
                  _loc4_ = 7;
                  break;
               case "-":
               case "+":
                  _loc4_ = 8;
                  break;
               case "%":
               case "/":
               case "*":
                  _loc4_ = 9;
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
      
      public static function evaluate(param1:Array, param2:APInstruction) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc8_:int = 0;
         stack = new Array();
         var _loc6_:int = int(param1.length);
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            if(!(param1[_loc7_] is String))
            {
               stack.push(param1[_loc7_]);
            }
            else
            {
               _loc8_ = int(stack.length);
               _loc4_ = stack.pop() as Number;
               _loc3_ = stack.pop() as Number;
               switch(param1[_loc7_])
               {
                  case "||":
                     _loc5_ = _loc3_ > 0 || _loc4_ > 0 ? 1 : 0;
                     break;
                  case "&&":
                     _loc5_ = _loc3_ > 0 && _loc4_ > 0 ? 1 : 0;
                     break;
                  case "|":
                     _loc5_ = _loc3_ | _loc4_;
                     break;
                  case "^":
                     _loc5_ = _loc3_ ^ _loc4_;
                     break;
                  case "&":
                     _loc5_ = _loc3_ & _loc4_;
                     break;
                  case "==":
                     _loc5_ = _loc3_ == _loc4_ ? 1 : 0;
                     break;
                  case "!=":
                     _loc5_ = _loc3_ != _loc4_ ? 1 : 0;
                     break;
                  case "<":
                     _loc5_ = _loc3_ < _loc4_ ? 1 : 0;
                     break;
                  case ">":
                     _loc5_ = _loc3_ > _loc4_ ? 1 : 0;
                     break;
                  case "<=":
                     _loc5_ = _loc3_ <= _loc4_ ? 1 : 0;
                     break;
                  case ">=":
                     _loc5_ = _loc3_ >= _loc4_ ? 1 : 0;
                     break;
                  case "+":
                     _loc5_ = _loc3_ + _loc4_;
                     break;
                  case "-":
                     _loc5_ = _loc3_ - _loc4_;
                     break;
                  case "*":
                     _loc5_ = _loc3_ * _loc4_;
                     break;
                  case "/":
                     _loc5_ = _loc3_ / _loc4_;
                     break;
                  case "%":
                     _loc5_ = _loc3_ % _loc4_;
                     break;
                  default:
                     _loc5_ = param2.getVariable(param1[_loc7_]);
                     if(_loc8_ > 1)
                     {
                        stack.push(_loc3_);
                     }
                     if(_loc8_ > 0)
                     {
                        stack.push(_loc4_);
                     }
               }
               stack.push(_loc5_);
            }
            _loc7_++;
         }
         return stack.pop() as Number;
      }
   }
}

