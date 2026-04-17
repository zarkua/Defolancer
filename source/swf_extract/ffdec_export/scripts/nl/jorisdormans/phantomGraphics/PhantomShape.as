package nl.jorisdormans.phantomGraphics
{
   import flash.display.Graphics;
   import flash.display.GraphicsPathCommand;
   import flash.display.GraphicsPathWinding;
   import flash.geom.Vector3D;
   import nl.jorisdormans.utils.StringUtil;
   
   public class PhantomShape
   {
      
      private var _data:Vector.<Number>;
      
      private var _commands:Vector.<int>;
      
      private var _processedData:Vector.<Number>;
      
      private var _translation:Vector3D;
      
      private var _scale:Vector3D;
      
      private var _rotation:Number;
      
      public var winding:String = "evenOdd";
      
      public function PhantomShape(param1:Array, param2:Array, param3:int)
      {
         super();
         this._commands = new Vector.<int>();
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            this._commands.push(param1[_loc4_]);
            _loc4_++;
         }
         this._data = new Vector.<Number>();
         this._processedData = new Vector.<Number>();
         _loc4_ = 0;
         while(_loc4_ < param2.length)
         {
            this._data.push(param2[_loc4_]);
            this._processedData.push(param2[_loc4_]);
            _loc4_++;
         }
         this._translation = new Vector3D();
         this._scale = new Vector3D(1,1);
         this._rotation = 0;
         switch(param3)
         {
            case 0:
               this.winding = GraphicsPathWinding.EVEN_ODD;
               break;
            case 1:
               this.winding = GraphicsPathWinding.NON_ZERO;
         }
      }
      
      public static function emptyShape() : PhantomShape
      {
         return new PhantomShape(new Array(GraphicsPathCommand.WIDE_MOVE_TO,GraphicsPathCommand.WIDE_LINE_TO),new Array(0,0,0,0,0,0,10,-10),0);
      }
      
      public static function createFromString(param1:String) : PhantomShape
      {
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc2_:int = param1.indexOf("new PhantomShape(");
         if(_loc2_ != 0)
         {
            return emptyShape();
         }
         param1 = param1.substr(17);
         _loc2_ = param1.indexOf("),");
         if(_loc2_ < 0)
         {
            return emptyShape();
         }
         var _loc3_:String = param1.substr(0,_loc2_ + 1);
         var _loc4_:String = param1.substr(_loc2_ + 2);
         _loc2_ = _loc4_.indexOf("),");
         if(_loc2_ < 0)
         {
            return emptyShape();
         }
         var _loc5_:String = _loc4_.substr(_loc2_ + 2);
         _loc4_ = _loc4_.substr(0,_loc2_ + 1);
         _loc2_ = _loc5_.indexOf(");");
         if(_loc2_ < 0)
         {
            return emptyShape();
         }
         _loc5_ = _loc5_.substr(0,_loc2_);
         _loc3_ = StringUtil.trim(_loc3_);
         _loc4_ = StringUtil.trim(_loc4_);
         _loc5_ = StringUtil.trim(_loc5_);
         var _loc6_:Array = StringUtil.parseCommand(_loc3_);
         var _loc7_:Array = StringUtil.parseCommand(_loc4_);
         var _loc8_:Array = new Array();
         var _loc9_:Array = new Array();
         if(_loc6_[0] == "new Array" && _loc7_[0] == "new Array")
         {
            _loc10_ = 1;
            _loc11_ = 1;
            while(_loc10_ < _loc6_.length)
            {
               _loc12_ = int(_loc6_[_loc10_]);
               switch(_loc12_)
               {
                  case GraphicsPathCommand.MOVE_TO:
                     _loc8_.push(GraphicsPathCommand.WIDE_MOVE_TO);
                     _loc9_.push(0,0,_loc7_[_loc11_],_loc7_[_loc11_ + 1]);
                     _loc11_ += 2;
                     break;
                  case GraphicsPathCommand.WIDE_MOVE_TO:
                     _loc8_.push(GraphicsPathCommand.WIDE_MOVE_TO);
                     _loc9_.push(_loc7_[_loc11_],_loc7_[_loc11_ + 1],_loc7_[_loc11_ + 2],_loc7_[_loc11_ + 3]);
                     _loc11_ += 4;
                     break;
                  case GraphicsPathCommand.LINE_TO:
                     _loc8_.push(GraphicsPathCommand.WIDE_LINE_TO);
                     _loc9_.push(0,0,_loc7_[_loc11_],_loc7_[_loc11_ + 1]);
                     _loc11_ += 2;
                     break;
                  case GraphicsPathCommand.WIDE_LINE_TO:
                     _loc8_.push(GraphicsPathCommand.WIDE_LINE_TO);
                     _loc9_.push(_loc7_[_loc11_],_loc7_[_loc11_ + 1],_loc7_[_loc11_ + 2],_loc7_[_loc11_ + 3]);
                     _loc11_ += 4;
                     break;
                  case GraphicsPathCommand.CURVE_TO:
                     _loc8_.push(GraphicsPathCommand.CURVE_TO);
                     _loc9_.push(_loc7_[_loc11_],_loc7_[_loc11_ + 1],_loc7_[_loc11_ + 2],_loc7_[_loc11_ + 3]);
                     _loc11_ += 4;
               }
               _loc10_++;
            }
         }
         return new PhantomShape(_loc8_,_loc9_,parseInt(_loc5_));
      }
      
      public function copy() : PhantomShape
      {
         var _loc1_:PhantomShape = new PhantomShape(new Array(),new Array(),0);
         var _loc2_:int = 0;
         while(_loc2_ < this._commands.length)
         {
            _loc1_._commands.push(this._commands[_loc2_]);
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this._data.length)
         {
            _loc1_._data.push(this._data[_loc2_]);
            _loc1_._processedData.push(this._data[_loc2_]);
            _loc2_++;
         }
         _loc1_.winding = this.winding;
         return _loc1_;
      }
      
      public function draw(param1:Graphics, param2:Number, param3:Number) : void
      {
         var _loc4_:int = 0;
         if(this._translation.x != param2 || this._translation.y != param3 || this._scale.x != 1 || this._scale.y != 1 || this._rotation != 0)
         {
            _loc4_ = 0;
            while(_loc4_ < this._data.length)
            {
               this._processedData[_loc4_] = this._data[_loc4_] + param2;
               this._processedData[_loc4_ + 1] = this._data[_loc4_ + 1] + param3;
               this._translation.x = param2;
               this._translation.y = param3;
               this._scale.x = 1;
               this._scale.y = 1;
               this._rotation = 0;
               _loc4_ += 2;
            }
         }
         param1.drawPath(this._commands,this._processedData,this.winding);
      }
      
      public function drawScaled(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         var _loc6_:int = 0;
         if(this._translation.x != param2 || this._translation.y != param3 || this._scale.x != param4 || this._scale.y != param5 || this._rotation != 0)
         {
            _loc6_ = 0;
            while(_loc6_ < this._data.length)
            {
               this._processedData[_loc6_] = this._data[_loc6_] * param4 + param2;
               this._processedData[_loc6_ + 1] = this._data[_loc6_ + 1] * param5 + param3;
               this._translation.x = param2;
               this._translation.y = param3;
               this._scale.x = param4;
               this._scale.y = param5;
               this._rotation = 0;
               _loc6_ += 2;
            }
         }
         param1.drawPath(this._commands,this._processedData,this.winding);
      }
      
      public function drawScaledRotated(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : void
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         if(this._translation.x != param2 || this._translation.y != param3 || this._scale.x != param4 || this._scale.y != param5 || this._rotation != param6)
         {
            _loc7_ = Math.cos(param6);
            _loc8_ = Math.sin(param6);
            _loc9_ = 0;
            while(_loc9_ < this._data.length)
            {
               param2 = this._data[_loc9_] * param4;
               param3 = this._data[_loc9_ + 1] * param5;
               this._processedData[_loc9_] = _loc7_ * param2 - _loc8_ * param3 + param2;
               this._processedData[_loc9_ + 1] = _loc7_ * param3 + _loc8_ * param2 + param3;
               this._translation.x = param2;
               this._translation.y = param3;
               this._scale.x = param4;
               this._scale.y = param5;
               this._rotation = param6;
               _loc9_ += 2;
            }
         }
         param1.drawPath(this._commands,this._processedData,this.winding);
      }
      
      public function drawRotated(param1:Graphics, param2:Number, param3:Number, param4:Number) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         if(this._translation.x != param2 || this._translation.y != param3 || this._scale.x != 1 || this._scale.y != 1 || this._rotation != param4)
         {
            _loc5_ = Math.cos(param4);
            _loc6_ = Math.sin(param4);
            _loc7_ = 0;
            while(_loc7_ < this._data.length)
            {
               this._processedData[_loc7_] = _loc5_ * this._data[_loc7_] - _loc6_ * this._data[_loc7_ + 1] + param2;
               this._processedData[_loc7_ + 1] = _loc5_ * this._data[_loc7_ + 1] + _loc6_ * this._data[_loc7_] + param3;
               this._translation.x = param2;
               this._translation.y = param3;
               this._scale.x = 1;
               this._scale.y = 1;
               this._rotation = param4;
               _loc7_ += 2;
            }
         }
         param1.drawPath(this._commands,this._processedData);
      }
      
      public function getPointType(param1:int) : int
      {
         if(param1 < this._commands.length)
         {
            return this._commands[param1];
         }
         return 0;
      }
      
      public function getPoint(param1:int) : Vector3D
      {
         if(param1 * 4 < this._data.length)
         {
            return new Vector3D(this._data[param1 * 4 + 2],this._data[param1 * 4 + 3]);
         }
         return null;
      }
      
      public function setPoint(param1:int, param2:Vector3D) : void
      {
         if(param1 * 4 < this._data.length)
         {
            this._data[param1 * 4 + 2] = param2.x;
            this._data[param1 * 4 + 3] = param2.y;
            this._translation.x += 1;
         }
      }
      
      public function getControlPoint(param1:int) : Vector3D
      {
         if(param1 * 4 < this._data.length)
         {
            return new Vector3D(this._data[param1 * 4 + 0],this._data[param1 * 4 + 1]);
         }
         return null;
      }
      
      public function setControlPoint(param1:int, param2:Vector3D) : void
      {
         if(param1 * 4 < this._data.length)
         {
            this._data[param1 * 4 + 0] = param2.x;
            this._data[param1 * 4 + 1] = param2.y;
            this._translation.x += 1;
         }
      }
      
      public function get pointCount() : int
      {
         return this._data.length * 0.25;
      }
      
      public function addPoint(param1:int, param2:int) : void
      {
         var _loc3_:Vector3D = new Vector3D();
         if(param1 == this.pointCount - 1)
         {
            if(param1 == 0)
            {
               _loc3_.x = 20;
               _loc3_.y = 20;
            }
            else
            {
               _loc3_.x = this._data[param1 * 4 + 2] - this._data[param1 * 4 - 2];
               _loc3_.y = this._data[param1 * 4 + 3] - this._data[param1 * 4 - 1];
            }
            this._data.push(0);
            this._data.push(0);
            this._data.push(this._data[param1 * 4 + 2] + _loc3_.x);
            this._data.push(this._data[param1 * 4 + 3] + _loc3_.y);
            this._processedData.push(0);
            this._processedData.push(0);
            this._processedData.push(0);
            this._processedData.push(0);
            this._translation.x += 1;
            this._commands.push(param2);
         }
         else
         {
            _loc3_.x = 0.5 * (this._data[param1 * 4 + 2] - this._data[param1 * 4 + 6]);
            _loc3_.y = 0.5 * (this._data[param1 * 4 + 3] - this._data[param1 * 4 + 7]);
            this._data.splice(param1 * 4 + 4,0,0,0,this._data[param1 * 4 + 2] - _loc3_.x,this._data[param1 * 4 + 3] - _loc3_.y);
            this._commands.splice(param1 + 1,0,param2);
            this._translation.x += 1;
         }
      }
      
      public function addPointToEnd(param1:Vector3D, param2:int) : void
      {
         this._data.push(0);
         this._data.push(0);
         this._data.push(param1.x);
         this._data.push(param1.y);
         this._processedData.push(0);
         this._processedData.push(0);
         this._processedData.push(param1.x);
         this._processedData.push(param1.y);
         this._translation.x += 1;
         this._commands.push(param2);
      }
      
      public function removePoint(param1:int) : void
      {
         if(param1 == 0)
         {
            return;
         }
         this._data.splice(param1 * 4,4);
         this._processedData.splice(param1 * 4,4);
         this._commands.splice(param1,1);
         this._translation.x += 1;
      }
      
      public function changePoint(param1:int) : void
      {
         if(param1 == 0)
         {
            return;
         }
         var _loc2_:int = this._commands[param1];
         switch(_loc2_)
         {
            case GraphicsPathCommand.WIDE_LINE_TO:
               _loc2_ = GraphicsPathCommand.CURVE_TO;
               break;
            case GraphicsPathCommand.CURVE_TO:
               _loc2_ = GraphicsPathCommand.WIDE_MOVE_TO;
               break;
            case GraphicsPathCommand.WIDE_MOVE_TO:
               _loc2_ = GraphicsPathCommand.WIDE_LINE_TO;
         }
         var _loc3_:Number = (this._data[param1 * 4 + 2] + this._data[param1 * 4 - 2]) * 0.5;
         var _loc4_:Number = (this._data[param1 * 4 + 3] + this._data[param1 * 4 - 1]) * 0.5;
         this._data[param1 * 4 + 0] = _loc3_;
         this._data[param1 * 4 + 1] = _loc4_;
         this._commands[param1] = _loc2_;
         this._translation.x += 1;
      }
      
      public function smoothPoint(param1:int) : void
      {
         var _loc4_:int = 0;
         if(param1 == 0)
         {
            return;
         }
         var _loc2_:Vector3D = new Vector3D();
         var _loc3_:Vector3D = new Vector3D();
         if(param1 > 0)
         {
            _loc4_ = this._commands[param1];
            switch(_loc4_)
            {
               case GraphicsPathCommand.WIDE_LINE_TO:
                  _loc2_.x = this._data[param1 * 4 - 2];
                  _loc2_.y = this._data[param1 * 4 - 1];
                  break;
               case GraphicsPathCommand.CURVE_TO:
                  _loc2_.x = this._data[param1 * 4 + 0];
                  _loc2_.y = this._data[param1 * 4 + 1];
            }
            if(param1 < this._commands.length - 1)
            {
               _loc4_ = this._commands[param1 + 1];
               switch(_loc4_)
               {
                  case GraphicsPathCommand.WIDE_LINE_TO:
                     _loc3_.x = this._data[param1 * 4 + 6];
                     _loc3_.y = this._data[param1 * 4 + 7];
                     break;
                  case GraphicsPathCommand.CURVE_TO:
                     _loc3_.x = this._data[param1 * 4 + 4];
                     _loc3_.y = this._data[param1 * 4 + 5];
               }
            }
            else
            {
               _loc3_.x = this._data[2];
               _loc3_.y = this._data[3];
            }
            this._data[param1 * 4 + 2] = 0.5 * (_loc2_.x + _loc3_.x);
            this._data[param1 * 4 + 3] = 0.5 * (_loc2_.y + _loc3_.y);
         }
         this._commands[param1] = _loc4_;
         this._translation.x += 1;
      }
      
      public function translate(param1:Number, param2:Number) : void
      {
         var _loc3_:int = 0;
         while(_loc3_ < this._data.length)
         {
            this._data[_loc3_] += param1;
            this._data[_loc3_ + 1] += param2;
            _loc3_ += 2;
         }
         this._translation.x += 1;
      }
      
      public function scaleBy(param1:Number, param2:Number) : void
      {
         var _loc3_:int = 0;
         while(_loc3_ < this._data.length)
         {
            this._data[_loc3_] *= param1;
            this._data[_loc3_ + 1] *= param2;
            _loc3_ += 2;
         }
         this._translation.x += 1;
      }
      
      public function createString() : String
      {
         var _loc1_:Boolean = true;
         var _loc2_:String = "";
         var _loc3_:String = "";
         var _loc4_:int = 0;
         while(_loc4_ < this._commands.length)
         {
            if(_loc1_)
            {
               _loc1_ = false;
            }
            else
            {
               _loc2_ += ", ";
               _loc3_ += ", ";
            }
            switch(this._commands[_loc4_])
            {
               case GraphicsPathCommand.WIDE_MOVE_TO:
               case GraphicsPathCommand.MOVE_TO:
                  _loc2_ += GraphicsPathCommand.MOVE_TO.toString();
                  _loc3_ += this._data[_loc4_ * 4 + 2].toFixed(2) + ", " + this._data[_loc4_ * 4 + 3].toFixed(2);
                  break;
               case GraphicsPathCommand.WIDE_LINE_TO:
               case GraphicsPathCommand.LINE_TO:
                  _loc2_ += GraphicsPathCommand.LINE_TO.toString();
                  _loc3_ += this._data[_loc4_ * 4 + 2].toFixed(2) + ", " + this._data[_loc4_ * 4 + 3].toFixed(2);
                  break;
               case GraphicsPathCommand.CURVE_TO:
                  _loc2_ += GraphicsPathCommand.CURVE_TO.toString();
                  _loc3_ += this._data[_loc4_ * 4].toFixed(2) + ", " + this._data[_loc4_ * 4 + 1].toFixed(2) + ", " + this._data[_loc4_ * 4 + 2].toFixed(2) + ", " + this._data[_loc4_ * 4 + 3].toFixed(2);
            }
            _loc4_++;
         }
         var _loc5_:String = "";
         switch(this.winding)
         {
            case GraphicsPathWinding.EVEN_ODD:
               _loc5_ = "0";
               break;
            case GraphicsPathWinding.NON_ZERO:
               _loc5_ = "1";
         }
         return "new PhantomShape(new Array(" + _loc2_ + "), new Array(" + _loc3_ + "), " + _loc5_ + ");";
      }
      
      public function toSVG(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:String, param7:String, param8:Number) : XML
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:int = 0;
         if(this._translation.x != param1 || this._translation.y != param2 || this._scale.x != param3 || this._scale.y != param4 || this._rotation != param5)
         {
            _loc9_ = Math.cos(param5);
            _loc10_ = Math.sin(param5);
            _loc13_ = 0;
            while(_loc13_ < this._data.length)
            {
               _loc11_ = this._data[_loc13_] * param3;
               _loc12_ = this._data[_loc13_ + 1] * param4;
               this._processedData[_loc13_] = _loc9_ * _loc11_ - _loc10_ * _loc12_ + param1;
               this._processedData[_loc13_ + 1] = _loc9_ * _loc12_ + _loc10_ * _loc11_ + param2;
               this._translation.x = param1;
               this._translation.y = param2;
               this._scale.x = param3;
               this._scale.y = param4;
               this._rotation = param5;
               _loc13_ += 2;
            }
         }
         return DrawUtil.drawPathToSVG(this._commands,this._processedData,param6,param7,param8);
      }
   }
}

