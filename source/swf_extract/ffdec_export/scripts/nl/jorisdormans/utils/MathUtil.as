package nl.jorisdormans.utils
{
   import flash.geom.Vector3D;
   
   public class MathUtil
   {
      
      public static const TO_DEGREES:Number = 180 / Math.PI;
      
      public static const RO_RADIANS:Number = Math.PI / 180;
      
      public static const TWO_PI:Number = Math.PI * 2;
      
      private static var _sin:Number = 0;
      
      private static var _cos:Number = 1;
      
      private static var _angle:Number = 0;
      
      private static var _sinb:Number = 0;
      
      private static var _cosb:Number = 1;
      
      private static var _angleb:Number = 0;
      
      public function MathUtil()
      {
         super();
      }
      
      public static function normalizeAngle(param1:Number) : Number
      {
         param1 %= TWO_PI;
         if(param1 > Math.PI)
         {
            param1 -= TWO_PI;
         }
         if(param1 <= -Math.PI)
         {
            param1 += TWO_PI;
         }
         return param1;
      }
      
      public static function angleDifference(param1:Number, param2:Number) : Number
      {
         param1 -= param2;
         return normalizeAngle(param1);
      }
      
      public static function rotateVector3D(param1:Vector3D, param2:Number) : Vector3D
      {
         if(param2 != _angle)
         {
            _sin = Math.sin(param2);
            _cos = Math.cos(param2);
            _angle = param2;
         }
         return new Vector3D(_cos * param1.x - _sin * param1.y,_sin * param1.x + _cos * param1.y,param1.z);
      }
      
      public static function rotateVector3Db(param1:Vector3D, param2:Number) : Vector3D
      {
         if(param2 != _angleb)
         {
            _sinb = Math.sin(param2);
            _cosb = Math.cos(param2);
            _angleb = param2;
         }
         return new Vector3D(_cosb * param1.x - _sinb * param1.y,_sinb * param1.x + _cosb * param1.y,param1.z);
      }
      
      public static function getNormal2D(param1:Vector3D) : Vector3D
      {
         var _loc2_:Vector3D = param1.clone();
         _loc2_.normalize();
         var _loc3_:Number = _loc2_.y;
         _loc2_.y = -_loc2_.x;
         _loc2_.x = _loc3_;
         return _loc2_;
      }
      
      public static function intersection(param1:Vector3D, param2:Vector3D, param3:Number, param4:Vector3D, param5:Vector3D, param6:Number) : Number
      {
         var _loc7_:Number = param4.x - param1.x;
         var _loc8_:Number = param4.y - param1.y;
         var _loc9_:Number = _loc7_ * param5.y - _loc8_ * param5.x;
         var _loc10_:Number = param2.x * param5.y - param2.y * param5.x;
         if(_loc10_ == 0)
         {
            return -1;
         }
         var _loc11_:Number = _loc9_ / _loc10_;
         if(_loc11_ <= 0 || _loc11_ >= param3)
         {
            return -1;
         }
         var _loc12_:Number = param1.x + param2.x * _loc11_;
         var _loc13_:Number = param1.y + param2.y * _loc11_;
         var _loc14_:Number = _loc12_ - param4.x;
         var _loc15_:Number = _loc13_ - param4.y;
         var _loc16_:Number = _loc14_ * param5.x + _loc15_ * param5.y;
         if(_loc16_ > 0 && _loc16_ < param6)
         {
            return _loc16_;
         }
         return -1;
      }
      
      public static function closestPointOnLine(param1:Vector3D, param2:Vector3D, param3:Number, param4:Vector3D) : Number
      {
         var _loc5_:Number = param4.x - param1.x;
         var _loc6_:Number = param4.y - param1.y;
         var _loc7_:Number = _loc5_ * param2.x + _loc6_ * param2.y;
         if(_loc7_ < 0)
         {
            _loc7_ = 0;
         }
         if(_loc7_ > param3)
         {
            _loc7_ = param3;
         }
         return _loc7_;
      }
      
      public static function distanceToLine(param1:Vector3D, param2:Vector3D, param3:Number, param4:Vector3D) : Number
      {
         var _loc5_:Number = closestPointOnLine(param1,param2,param3,param4);
         var _loc6_:Vector3D = param1.clone();
         _loc6_.x += param2.x * _loc5_;
         _loc6_.y += param2.y * _loc5_;
         return Vector3D.distance(_loc6_,param4);
      }
      
      public static function pointOnRightSide(param1:Vector3D, param2:Vector3D, param3:Vector3D) : Boolean
      {
         var _loc4_:Vector3D = new Vector3D(param3.y,-param3.x,0);
         return _loc4_.dotProduct(param2.subtract(param1)) > 0;
      }
      
      public static function getSquareOutlinePoint(param1:Vector3D, param2:Number) : Vector3D
      {
         param1.normalize();
         if(Math.abs(param1.x) > Math.abs(param1.y))
         {
            if(param1.x < 0)
            {
               return new Vector3D(-param2,-param2 * param1.y / param1.x,0);
            }
            return new Vector3D(param2,param2 * param1.y / param1.x,0);
         }
         if(param1.y < 0)
         {
            return new Vector3D(-param2 * param1.x / param1.y,-param2,0);
         }
         return new Vector3D(param2 * param1.x / param1.y,param2,0);
      }
      
      public static function getRectangleOutlinePoint(param1:Vector3D, param2:Number, param3:Number) : Vector3D
      {
         var _loc4_:Number = param3 / param2;
         param1.x *= _loc4_;
         param1 = getSquareOutlinePoint(param1,param2);
         param1.y *= _loc4_;
         return param1;
      }
      
      public static function distanceSquared(param1:Vector3D, param2:Vector3D) : Number
      {
         var _loc3_:Number = param1.x - param2.x;
         var _loc4_:Number = param1.y - param2.y;
         return _loc3_ * _loc3_ + _loc4_ * _loc4_;
      }
   }
}

