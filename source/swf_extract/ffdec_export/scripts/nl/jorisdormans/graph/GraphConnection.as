package nl.jorisdormans.graph
{
   import flash.geom.Vector3D;
   import nl.jorisdormans.utils.MathUtil;
   
   public class GraphConnection extends GraphElement
   {
      
      private var _start:GraphElement;
      
      private var _end:GraphElement;
      
      public var type:GraphConnectionType;
      
      public var points:Vector.<Vector3D>;
      
      private var _startPoint:Vector3D;
      
      private var _endPoint:Vector3D;
      
      public var totalLength:Number = 0;
      
      public var startId:int;
      
      public var endId:int;
      
      public function GraphConnection()
      {
         super();
         this.points = new Vector.<Vector3D>();
         this.points.push(new Vector3D(0,0),new Vector3D(0,0));
         this._startPoint = new Vector3D();
         this._endPoint = new Vector3D();
      }
      
      override public function dispose() : void
      {
         this.start = null;
         this.end = null;
         this.points.splice(0,this.points.length);
         super.dispose();
      }
      
      public function get start() : GraphElement
      {
         return this._start;
      }
      
      public function set start(param1:GraphElement) : void
      {
         if(this._start)
         {
            this._start.removeOutput(this);
         }
         this._start = param1;
         if(this._start)
         {
            this._start.outputs.push(this);
            this._startPoint = this._start.getPosition();
            this.calculateStartPosition();
         }
         else
         {
            this._startPoint = this.points[0].clone();
         }
      }
      
      public function get end() : GraphElement
      {
         return this._end;
      }
      
      public function set end(param1:GraphElement) : void
      {
         if(this._end)
         {
            this._end.removeInput(this);
         }
         this._end = param1;
         if(this._end)
         {
            this._end.inputs.push(this);
            this._endPoint = this._end.getPosition();
            this.calculateEndPosition();
         }
         else
         {
            this._endPoint = this.points[this.points.length - 1].clone();
         }
      }
      
      public function calculateStartPosition(param1:Vector3D = null) : void
      {
         if(param1)
         {
            this._startPoint = param1.clone();
         }
         if(this._start)
         {
            this._startPoint = this._start.getPosition();
            if(this.points.length == 2)
            {
               this.points[0] = this._start.getConnection(this._endPoint);
               if(this._end)
               {
                  this.points[1] = this._end.getConnection(this._startPoint);
               }
            }
            else
            {
               this.points[0] = this._start.getConnection(this.points[1]);
            }
         }
         else
         {
            if(this.points.length == 2 && Boolean(this._end))
            {
               this.points[1] = this._end.getConnection(this._startPoint);
            }
            this.points[0] = this._startPoint.clone();
         }
         this.calculateTotalLength();
         dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
      }
      
      public function calculateEndPosition(param1:Vector3D = null) : void
      {
         if(param1)
         {
            this._endPoint = param1.clone();
         }
         if(this._end)
         {
            this._endPoint = this._end.getPosition();
            if(this.points.length == 2)
            {
               this.points[1] = this._end.getConnection(this._startPoint);
               if(this._start)
               {
                  this.points[0] = this._start.getConnection(this._endPoint);
               }
            }
            else
            {
               this.points[this.points.length - 1] = this._end.getConnection(this.points[this.points.length - 2]);
            }
         }
         else
         {
            if(this.points.length == 2 && Boolean(this._start))
            {
               this.points[0] = this._start.getConnection(this._endPoint);
            }
            this.points[this.points.length - 1] = this._endPoint.clone();
         }
         this.calculateTotalLength();
         dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
      }
      
      public function recalculatePoint(param1:int) : void
      {
         if(param1 == 1 && Boolean(this._start))
         {
            this.points[0] = this._start.getConnection(this.points[param1]);
         }
         if(param1 == this.points.length - 2 && Boolean(this._end))
         {
            this.points[param1 + 1] = this._end.getConnection(this.points[param1]);
         }
         this.calculateTotalLength();
      }
      
      protected function calculateTotalLength() : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         this.totalLength = 0;
         var _loc1_:int = int(this.points.length);
         var _loc2_:int = 1;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = this.points[_loc2_].x - this.points[_loc2_ - 1].x;
            _loc4_ = this.points[_loc2_].y - this.points[_loc2_ - 1].y;
            this.totalLength += Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
            _loc2_++;
         }
      }
      
      public function getPositionOnLine(param1:Number) : Vector3D
      {
         var _loc5_:Vector3D = null;
         var _loc6_:Number = NaN;
         var _loc2_:Number = param1 * this.totalLength;
         var _loc3_:int = 1;
         var _loc4_:Vector3D = this.points[0].clone();
         while(_loc3_ < this.points.length)
         {
            _loc5_ = this.points[_loc3_].subtract(this.points[_loc3_ - 1]);
            _loc6_ = _loc5_.normalize();
            if(_loc6_ >= _loc2_)
            {
               _loc4_ = this.points[_loc3_ - 1].clone();
               _loc4_.x += _loc5_.x * _loc2_;
               _loc4_.y += _loc5_.y * _loc2_;
               break;
            }
            _loc2_ -= _loc6_;
            _loc3_++;
         }
         return _loc4_;
      }
      
      public function getPositionSegment(param1:Number) : int
      {
         var _loc5_:Vector3D = null;
         var _loc6_:Number = NaN;
         var _loc2_:Number = param1 * this.totalLength;
         var _loc3_:int = 1;
         var _loc4_:Vector3D = this.points[0].clone();
         while(_loc3_ < this.points.length)
         {
            _loc5_ = this.points[_loc3_].subtract(this.points[_loc3_ - 1]);
            _loc6_ = _loc5_.normalize();
            if(_loc6_ >= _loc2_)
            {
               return _loc3_ - 1;
            }
            _loc2_ -= _loc6_;
            _loc3_++;
         }
         return 0;
      }
      
      public function findClosestPointTo(param1:Number, param2:Number) : Number
      {
         var _loc9_:Vector3D = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Vector3D = null;
         var _loc13_:Number = NaN;
         var _loc3_:Vector3D = new Vector3D(param1,param2);
         var _loc4_:Number = 100000;
         var _loc5_:int = -1;
         var _loc6_:Number = 0;
         var _loc7_:Number = 0;
         var _loc8_:int = 1;
         while(_loc8_ < this.points.length)
         {
            _loc9_ = this.points[_loc8_].subtract(this.points[_loc8_ - 1]);
            _loc10_ = _loc9_.normalize();
            _loc11_ = MathUtil.closestPointOnLine(this.points[_loc8_ - 1],_loc9_,_loc10_,_loc3_);
            _loc12_ = this.points[_loc8_ - 1].clone();
            _loc12_.x += _loc11_ * _loc9_.x - param1;
            _loc12_.y += _loc11_ * _loc9_.y - param2;
            _loc13_ = _loc12_.length;
            if(_loc13_ < _loc4_)
            {
               _loc4_ = _loc13_;
               _loc6_ = _loc7_ + _loc11_;
            }
            _loc8_++;
            _loc7_ += _loc10_;
         }
         return _loc6_ / _loc7_;
      }
      
      public function addPoint(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = this.findClosestPointTo(param1,param2);
         var _loc4_:int = this.getPositionSegment(_loc3_);
         var _loc5_:Vector3D = this.getPositionOnLine(_loc3_);
         this.points.splice(_loc4_ + 1,0,_loc5_);
         this.calculateTotalLength();
         dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
      }
      
      override public function generateXML() : XML
      {
         var _loc5_:XML = null;
         var _loc1_:XML = super.generateXML();
         var _loc2_:int = 0;
         var _loc3_:* = int(this.points.length);
         _loc1_.setName("connection");
         _loc1_.@type = this.type.name;
         if(Boolean(this._start) && this._start.id >= 0)
         {
            _loc1_.@start = this._start.id;
            _loc2_++;
         }
         else
         {
            _loc1_.@start = "-1";
         }
         if(Boolean(this._end) && this._end.id >= 0)
         {
            _loc1_.@end = this._end.id;
            _loc3_--;
         }
         else
         {
            _loc1_.@end = "-1";
         }
         var _loc4_:int = _loc2_;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = <point/>;
            _loc5_.@x = Math.round(this.points[_loc4_].x);
            _loc5_.@y = Math.round(this.points[_loc4_].y);
            _loc1_.appendChild(_loc5_);
            _loc4_++;
         }
         return _loc1_;
      }
      
      override public function readXML(param1:XML) : void
      {
         var _loc5_:Vector3D = null;
         super.readXML(param1);
         this.startId = param1.@start;
         this.endId = param1.@end;
         var _loc2_:int = 0;
         var _loc3_:* = param1.point.length();
         this._startPoint = new Vector3D(0,0);
         this._endPoint = new Vector3D(0,0);
         this.startId = param1.@start;
         this.endId = param1.@end;
         if(this.startId == -1)
         {
            this._startPoint.x = param1.point[0].@x;
            this._startPoint.y = param1.point[0].@y;
            _loc2_++;
         }
         if(this.endId == -1)
         {
            this._endPoint.x = param1.point[_loc3_ - 1].@x;
            this._endPoint.y = param1.point[_loc3_ - 1].@y;
            _loc3_--;
         }
         this.points[0] = this._startPoint.clone();
         this.points[1] = this._endPoint.clone();
         this.calculateStartPosition();
         this.calculateEndPosition();
         var _loc4_:int = _loc2_;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = new Vector3D(param1.point[_loc4_].@x,param1.point[_loc4_].@y);
            this.points.splice(this.points.length - 1,0,_loc5_);
            _loc4_++;
         }
         this.recalculatePoint(this.points.length - 2);
         this.recalculatePoint(1);
      }
   }
}

