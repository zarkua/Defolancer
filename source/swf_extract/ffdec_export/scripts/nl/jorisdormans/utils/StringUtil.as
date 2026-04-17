package nl.jorisdormans.utils
{
   public class StringUtil
   {
      
      public function StringUtil()
      {
         super();
      }
      
      public static function toColor(param1:String) : uint
      {
         switch(param1.toLowerCase())
         {
            case "black":
               return 0;
            case "white":
               return 16777215;
            case "red":
               return 13500416;
            case "darkred":
               return 9109504;
            case "orange":
               return 16753920;
            case "orangered":
               return 16729344;
            case "yellow":
               return 16776960;
            case "gold":
               return 16766720;
            case "green":
               return 32768;
            case "lime":
               return 65280;
            case "blue":
               return 255;
            case "lightblue":
               return 32977;
            case "darkblue":
               return 139;
            case "purple":
               return 8388736;
            case "violet":
               return 15631086;
            case "teal":
               return 32896;
            case "gray":
               return 11119017;
            case "darkgray":
               return 8421504;
            case "brown":
               return 9127187;
            default:
               return parseInt(param1);
         }
      }
      
      public static function toColorString(param1:uint) : String
      {
         var _loc2_:String = null;
         switch(param1)
         {
            case 0:
               return "Black";
            case 16777215:
               return "White";
            case 13500416:
               return "Red";
            case 9109504:
               return "DarkRed";
            case 16753920:
               return "Orange";
            case 16729344:
               return "OrangeRed";
            case 16776960:
               return "Yellow";
            case 16766720:
               return "Gold";
            case 32768:
               return "Green";
            case 65280:
               return "Lime";
            case 255:
               return "Blue";
            case 139:
               return "DarkBlue";
            case 32977:
               return "LightBlue";
            case 8388736:
               return "Purple";
            case 15631086:
               return "Violet";
            case 32896:
               return "Teal";
            case 11119017:
               return "Gray";
            case 8421504:
               return "DarkGray";
            case 9127187:
               return "Brown";
            default:
               _loc2_ = param1.toString(16);
               while(_loc2_.length < 6)
               {
                  _loc2_ = "0" + _loc2_;
               }
               return "0x" + _loc2_;
         }
      }
      
      public static function toColorStringSVG(param1:uint) : String
      {
         var _loc2_:String = param1.toString(16);
         while(_loc2_.length < 6)
         {
            _loc2_ = "0" + _loc2_;
         }
         return "#" + _loc2_;
      }
      
      public static function parseCommand(param1:String) : Array
      {
         var _loc2_:Array = new Array();
         var _loc3_:int = param1.indexOf("(");
         if(_loc3_ >= 0)
         {
            _loc2_.push(param1.substr(0,_loc3_));
            param1 = trim(param1.substr(_loc3_ + 1));
            _loc3_ = param1.indexOf(")");
            if(_loc3_ >= 0)
            {
               param1 = trim(param1.substr(0,_loc3_));
               _loc3_ = param1.indexOf(",");
               while(_loc3_ > 0)
               {
                  _loc2_.push(param1.substr(0,_loc3_));
                  param1 = trim(param1.substr(_loc3_ + 1));
                  _loc3_ = param1.indexOf(",");
               }
               if(param1 != "")
               {
                  _loc2_.push(param1);
               }
            }
            return _loc2_;
         }
         _loc3_ = param1.indexOf(";");
         if(_loc3_ >= 0)
         {
            param1 = trim(param1.substr(0,_loc3_ - 1));
         }
         _loc2_.push(param1);
         return _loc2_;
      }
      
      public static function trim(param1:String) : String
      {
         while(param1.charAt(0) == " ")
         {
            param1 = param1.substr(1);
         }
         while(param1.charAt(param1.length - 1) == " ")
         {
            param1 = param1.substr(0,param1.length - 1);
         }
         return param1;
      }
      
      private static function doEvaluateValue(param1:String, param2:int, param3:String) : int
      {
         var _loc7_:int = 0;
         var _loc12_:* = 0;
         var _loc13_:int = 0;
         var _loc4_:int = param1.indexOf("+");
         var _loc5_:int = param1.indexOf("-");
         var _loc6_:String = "";
         if(_loc4_ >= 0 && (_loc4_ < _loc5_ || _loc5_ < 0))
         {
            _loc7_ = _loc4_ - 1;
            _loc6_ = "+";
         }
         else if(_loc5_ >= 0)
         {
            _loc7_ = _loc5_ - 1;
            _loc6_ = "-";
         }
         else
         {
            _loc7_ = param1.length;
         }
         var _loc8_:String = param1.substr(0,_loc7_ + 1);
         var _loc9_:String = param1.substr(_loc7_ + 2);
         var _loc10_:int = 0;
         var _loc11_:int = param1.indexOf("D");
         if(_loc11_ < 0)
         {
            _loc10_ = parseInt(_loc8_);
         }
         else
         {
            _loc12_ = 1;
            if(_loc11_ > 0)
            {
               _loc12_ = int(parseInt(_loc8_.substr(0,_loc11_)));
            }
            _loc13_ = 0;
            _loc13_ = parseInt(_loc8_.substr(_loc11_ + 1));
            while(_loc12_ > 0)
            {
               _loc10_ += Math.floor(Math.random() * _loc13_) + 1;
               _loc12_--;
            }
         }
         if(param3 == "-")
         {
            param2 -= _loc10_;
         }
         else
         {
            param2 += _loc10_;
         }
         if(_loc9_.length > 0)
         {
            return doEvaluateValue(_loc9_,param2,_loc6_);
         }
         return param2;
      }
      
      public static function evaluateValue(param1:String) : int
      {
         return doEvaluateValue(param1,0,"+");
      }
      
      public static function setFileExtention(param1:String, param2:String) : String
      {
         var _loc3_:int = param1.lastIndexOf(".");
         if(_loc3_ < 0)
         {
            return param1 + "." + param2;
         }
         return param1.substr(0,_loc3_ + 1) + param2;
      }
      
      public static function splitString(param1:String, param2:String, param3:Boolean = false) : Vector.<String>
      {
         var _loc6_:String = null;
         var _loc4_:Vector.<String> = new Vector.<String>();
         if(param1 == null)
         {
            return _loc4_;
         }
         var _loc5_:int = param1.indexOf(param2);
         while(_loc5_ >= 0)
         {
            if(param3)
            {
               _loc6_ = trim(param1.substr(0,_loc5_));
            }
            else
            {
               _loc6_ = param1.substr(0,_loc5_);
            }
            _loc4_.push(_loc6_);
            param1 = param1.substr(_loc5_ + param2.length);
            _loc5_ = param1.indexOf(param2);
         }
         if(param3)
         {
            param1 = trim(param1);
         }
         if(param1.length > 0)
         {
            _loc4_.push(param1);
         }
         return _loc4_;
      }
      
      public static function getCommand(param1:String) : String
      {
         var _loc2_:String = null;
         var _loc3_:int = param1.indexOf("(");
         if(_loc3_ >= 0)
         {
            _loc2_ = param1.substr(0,_loc3_);
            param1 = param1.substr(0);
         }
         else
         {
            _loc2_ = param1;
            param1 = "";
         }
         return _loc2_;
      }
      
      public static function getCondition(param1:String) : String
      {
         var _loc5_:String = null;
         var _loc2_:int = 0;
         var _loc3_:* = 0;
         var _loc4_:String = "";
         while(_loc2_ < param1.length)
         {
            _loc5_ = param1.charAt(_loc2_);
            switch(_loc5_)
            {
               case "(":
                  _loc3_++;
                  break;
               case ")":
                  _loc3_--;
                  if(_loc3_ <= 0)
                  {
                     return _loc4_ + _loc5_;
                  }
            }
            _loc2_++;
            _loc4_ += _loc5_;
         }
         return _loc4_;
      }
      
      public static function getParameters(param1:String) : Vector.<String>
      {
         var _loc6_:String = null;
         var _loc2_:int = 0;
         var _loc3_:* = 0;
         var _loc4_:Vector.<String> = new Vector.<String>();
         var _loc5_:String = "";
         while(_loc2_ < param1.length)
         {
            _loc6_ = param1.charAt(_loc2_);
            switch(_loc6_)
            {
               case "(":
                  if(++_loc3_ == 1)
                  {
                     _loc6_ = "";
                  }
                  break;
               case ",":
                  if(_loc3_ == 1)
                  {
                     _loc4_.push(_loc5_);
                     _loc5_ = "";
                     _loc6_ = "";
                  }
                  break;
               case ")":
                  _loc3_--;
                  if(_loc3_ <= 0)
                  {
                     _loc4_.push(_loc5_);
                     return _loc4_;
                  }
            }
            _loc2_++;
            _loc5_ += _loc6_;
         }
         param1 = "";
         return _loc4_;
      }
      
      public static function floatToStringMaxPrecision(param1:Number, param2:int) : String
      {
         var _loc3_:Number = Math.pow(10,param2);
         var _loc4_:Number = Math.floor(param1 * _loc3_) / _loc3_;
         var _loc5_:String = _loc4_.toString();
         var _loc6_:int = _loc5_.indexOf(".");
         if(_loc6_ >= 0 && _loc6_ < _loc5_.length - param2 - 1)
         {
            _loc5_ = _loc5_.substr(0,_loc6_ + param2 + 1);
         }
         return _loc5_;
      }
   }
}

