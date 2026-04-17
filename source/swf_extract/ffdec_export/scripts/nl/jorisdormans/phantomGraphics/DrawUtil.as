package nl.jorisdormans.phantomGraphics
{
   import flash.display.Graphics;
   import flash.display.GraphicsPathCommand;
   
   public class DrawUtil
   {
      
      public static const moveTo:int = 0;
      
      public static const lineTo:int = 1;
      
      public static const curveTo:int = 2;
      
      public static var strokeWidthAdjust:Number = 0.7;
      
      public function DrawUtil()
      {
         super();
      }
      
      public static function drawPolygon(param1:Graphics, param2:Number, param3:Number, param4:Array, param5:Number = 1, param6:Number = 1) : void
      {
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc7_:int = 0;
         while(_loc7_ < param4.length)
         {
            _loc8_ = param4[_loc7_] as int;
            switch(_loc8_)
            {
               default:
               case moveTo:
                  _loc9_ = (param4[_loc7_ + 1] as Number) * param5;
                  _loc11_ = (param4[_loc7_ + 2] as Number) * param6;
                  param1.moveTo(param2 + _loc9_,param3 + _loc11_);
                  _loc7_ += 3;
                  break;
               case lineTo:
                  _loc9_ = (param4[_loc7_ + 1] as Number) * param5;
                  _loc11_ = (param4[_loc7_ + 2] as Number) * param6;
                  param1.lineTo(param2 + _loc9_,param3 + _loc11_);
                  _loc7_ += 3;
                  break;
               case curveTo:
                  _loc9_ = (param4[_loc7_ + 1] as Number) * param5;
                  _loc11_ = (param4[_loc7_ + 2] as Number) * param6;
                  _loc10_ = (param4[_loc7_ + 3] as Number) * param5;
                  _loc12_ = (param4[_loc7_ + 4] as Number) * param6;
                  param1.curveTo(param2 + _loc10_,param3 + _loc12_,param2 + _loc9_,param3 + _loc11_);
                  _loc7_ += 5;
            }
         }
      }
      
      public static function drawPolygonAngled(param1:Graphics, param2:Number, param3:Number, param4:Array, param5:Number, param6:Number = 1, param7:Number = 1) : void
      {
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc8_:int = 0;
         param5 += Math.PI * 0.5;
         var _loc14_:Number = Math.cos(param5);
         var _loc15_:Number = Math.sin(param5);
         while(_loc8_ < param4.length)
         {
            _loc9_ = param4[_loc8_] as int;
            switch(_loc9_)
            {
               default:
               case moveTo:
                  _loc10_ = (param4[_loc8_ + 1] as Number) * param6;
                  _loc12_ = (param4[_loc8_ + 2] as Number) * param7;
                  param1.moveTo(param2 + _loc14_ * _loc10_ - _loc15_ * _loc12_,param3 + _loc14_ * _loc12_ + _loc15_ * _loc10_);
                  _loc8_ += 3;
                  break;
               case lineTo:
                  _loc10_ = (param4[_loc8_ + 1] as Number) * param6;
                  _loc12_ = (param4[_loc8_ + 2] as Number) * param7;
                  param1.lineTo(param2 + _loc14_ * _loc10_ - _loc15_ * _loc12_,param3 + _loc14_ * _loc12_ + _loc15_ * _loc10_);
                  _loc8_ += 3;
                  break;
               case curveTo:
                  _loc10_ = (param4[_loc8_ + 1] as Number) * param6;
                  _loc12_ = (param4[_loc8_ + 2] as Number) * param7;
                  _loc11_ = (param4[_loc8_ + 3] as Number) * param6;
                  _loc13_ = (param4[_loc8_ + 4] as Number) * param7;
                  param1.curveTo(param2 + _loc14_ * _loc11_ - _loc15_ * _loc13_,param3 + _loc14_ * _loc13_ + _loc15_ * _loc11_,param2 + _loc14_ * _loc10_ - _loc15_ * _loc12_,param3 + _loc14_ * _loc12_ + _loc15_ * _loc10_);
                  _loc8_ += 5;
            }
         }
      }
      
      public static function colorToIllumination(param1:uint) : Number
      {
         var _loc2_:uint = uint((param1 & 0xFF0000) >> 16);
         var _loc3_:uint = uint((param1 & 0xFF00) >> 8);
         var _loc4_:uint = uint(param1 & 0xFF);
         var _loc5_:uint = _loc2_ + (_loc3_ << 1) + _loc4_;
         return _loc5_ / 1024;
      }
      
      public static function lerpColor(param1:uint, param2:uint, param3:Number) : uint
      {
         var _loc4_:uint = uint((param1 & 0xFF0000) >> 16);
         var _loc5_:uint = uint((param1 & 0xFF00) >> 8);
         var _loc6_:uint = uint(param1 & 0xFF);
         var _loc7_:uint = uint((param2 & 0xFF0000) >> 16);
         var _loc8_:uint = uint((param2 & 0xFF00) >> 8);
         var _loc9_:uint = uint(param2 & 0xFF);
         _loc4_ += Math.round((_loc7_ - _loc4_) * param3);
         _loc5_ += Math.round((_loc8_ - _loc5_) * param3);
         _loc6_ += Math.round((_loc9_ - _loc6_) * param3);
         return _loc4_ << 16 | _loc5_ << 8 | _loc6_;
      }
      
      public static function drawCircleToSVG(param1:Number, param2:Number, param3:Number, param4:String, param5:String, param6:Number) : XML
      {
         var _loc7_:XML = <circle/>;
         _loc7_.@cx = param1.toFixed(2);
         _loc7_.@cy = param2.toFixed(2);
         _loc7_.@r = param3.toFixed(2);
         if(param5 != null)
         {
            _loc7_.@stroke = param5;
            _loc7_["stroke-width"] = (param6 * strokeWidthAdjust).toFixed(1);
         }
         if(param4 != null)
         {
            _loc7_.@fill = param4;
         }
         return _loc7_;
      }
      
      public static function drawRectToSVG(param1:Number, param2:Number, param3:Number, param4:Number, param5:String, param6:String, param7:Number) : XML
      {
         var _loc8_:XML = <rect/>;
         _loc8_.@x = param1.toFixed(2);
         _loc8_.@y = param2.toFixed(2);
         _loc8_.@width = param3.toFixed(2);
         _loc8_.@height = param4.toFixed(2);
         if(param6 != null)
         {
            _loc8_.@stroke = param6;
            _loc8_["stroke-width"] = (param7 * strokeWidthAdjust).toFixed(1);
         }
         if(param5 != null)
         {
            _loc8_.@fill = param5;
         }
         return _loc8_;
      }
      
      public static function drawRoundRectToSVG(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:String, param8:String, param9:Number) : XML
      {
         var _loc10_:XML = <rect/>;
         _loc10_.@x = param1.toFixed(2);
         _loc10_.@y = param2.toFixed(2);
         _loc10_.@width = param3.toFixed(2);
         _loc10_.@height = param4.toFixed(2);
         _loc10_.@rx = param5.toFixed(2);
         _loc10_.@ry = param6.toFixed(2);
         if(param8 != null)
         {
            _loc10_.@stroke = param8;
            _loc10_["stroke-width"] = (param9 * strokeWidthAdjust).toFixed(1);
         }
         if(param7 != null)
         {
            _loc10_.@fill = param7;
         }
         return _loc10_;
      }
      
      public static function drawPathToSVG(param1:Vector.<int>, param2:Vector.<Number>, param3:String, param4:String, param5:Number) : XML
      {
         var _loc7_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc6_:String = "";
         _loc7_ = 0;
         var _loc8_:int = 0;
         while(_loc8_ < param1.length)
         {
            switch(param1[_loc8_])
            {
               case GraphicsPathCommand.WIDE_MOVE_TO:
                  _loc6_ += " M " + param2[_loc7_ + 2].toFixed(2) + " " + param2[_loc7_ + 3].toFixed(2);
                  _loc7_ += 4;
                  break;
               case GraphicsPathCommand.MOVE_TO:
                  _loc6_ += " M " + param2[_loc7_].toFixed(2) + " " + param2[_loc7_ + 1].toFixed(2);
                  _loc7_ += 2;
                  break;
               case GraphicsPathCommand.WIDE_LINE_TO:
                  _loc6_ += " L " + param2[_loc7_ + 2].toFixed(2) + " " + param2[_loc7_ + 3].toFixed(2);
                  _loc7_ += 4;
                  break;
               case GraphicsPathCommand.LINE_TO:
                  _loc6_ += " L " + param2[_loc7_].toFixed(2) + " " + param2[_loc7_ + 1].toFixed(2);
                  _loc7_ += 2;
                  break;
               case GraphicsPathCommand.CURVE_TO:
                  _loc10_ = param2[_loc7_];
                  _loc11_ = param2[_loc7_ + 1];
                  if(_loc8_ > 0 && param1[_loc8_ - 1] == GraphicsPathCommand.CURVE_TO)
                  {
                     _loc10_ = param2[_loc7_ + 2] + (param2[_loc7_ + 0] - param2[_loc7_ + 2]) * 0.5;
                     _loc11_ = param2[_loc7_ + 3] + (param2[_loc7_ + 1] - param2[_loc7_ + 3]) * 0.5;
                  }
                  _loc6_ += " S " + _loc10_.toFixed(2) + " " + _loc11_.toFixed(2) + " " + param2[_loc7_ + 2].toFixed(2) + " " + param2[_loc7_ + 3].toFixed(2);
                  _loc7_ += 4;
            }
            _loc8_++;
         }
         if(_loc6_.charAt(0) == " ")
         {
            _loc6_ = _loc6_.substr(1);
         }
         var _loc9_:XML = <path/>;
         _loc9_.@d = _loc6_;
         if(param4 != null)
         {
            _loc9_.@stroke = param4;
            _loc9_["stroke-width"] = (param5 * strokeWidthAdjust).toFixed(1);
         }
         if(param3 != null)
         {
            _loc9_.@fill = param3;
         }
         return _loc9_;
      }
   }
}

