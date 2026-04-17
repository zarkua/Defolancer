package nl.jorisdormans.machinations.model
{
   import flash.display.Graphics;
   import flash.display.GraphicsPathCommand;
   import flash.geom.Vector3D;
   import nl.jorisdormans.graph.GraphEvent;
   import nl.jorisdormans.phantomGraphics.DrawUtil;
   import nl.jorisdormans.phantomGraphics.PhantomFont;
   import nl.jorisdormans.utils.FileIO;
   import nl.jorisdormans.utils.StringUtil;
   
   public class Chart extends GroupBox
   {
      
      private var _defaultScaleX:int = 0;
      
      private var _defaultScaleY:int = 0;
      
      private var _scaleX:Number = 20;
      
      private var _scaleY:Number = 12;
      
      private var _negScaleY:Number = 0;
      
      private var _data:Vector.<ChartData> = new Vector.<ChartData>();
      
      private var _time:Number;
      
      private var _tick:int;
      
      private var _stopped:Boolean;
      
      private var _highLighted:int = 0;
      
      private var _runs:int;
      
      private var fileIO:FileIO = new FileIO();
      
      public function Chart()
      {
         super();
         captionPosition = 5;
         activationMode = MODE_AUTOMATIC;
      }
      
      override public function generateXML() : XML
      {
         var _loc1_:XML = super.generateXML();
         _loc1_.@scaleX = this.defaultScaleX;
         _loc1_.@scaleY = this.defaultScaleY;
         return _loc1_;
      }
      
      override public function readXML(param1:XML) : void
      {
         this.defaultScaleX = param1.@scaleX;
         this.defaultScaleY = param1.@scaleY;
         super.readXML(param1);
      }
      
      public function draw(param1:Graphics, param2:Number, param3:Number) : void
      {
         var _loc14_:Number = NaN;
         var _loc15_:int = 0;
         var _loc4_:Vector3D = new Vector3D(param2,param3);
         if(this.defaultScaleX > 0)
         {
            this._scaleX = this.defaultScaleX;
         }
         if(this.defaultScaleY > 0)
         {
            this._scaleY = this.defaultScaleY;
         }
         if(this.defaultScaleY < 0)
         {
            this._scaleY = -this.defaultScaleY;
            this._negScaleY = this.defaultScaleY;
         }
         param1.lineStyle(thickness,color);
         param1.beginFill(16777215);
         param1.drawRect(_loc4_.x,_loc4_.y,width,height);
         param1.endFill();
         param1.lineStyle();
         var _loc5_:Vector.<int> = new Vector.<int>();
         var _loc6_:Vector.<Number> = new Vector.<Number>();
         var _loc7_:Number = this._scaleY / (this._scaleY - this._negScaleY);
         var _loc8_:Number = _loc7_ * 0.25;
         while(_loc8_ < 1)
         {
            _loc5_.push(GraphicsPathCommand.MOVE_TO,GraphicsPathCommand.LINE_TO);
            _loc6_.push(_loc4_.x + 2,_loc4_.y + height * _loc8_);
            _loc6_.push(_loc4_.x + width - 3,_loc4_.y + height * _loc8_);
            _loc8_ += _loc7_ * 0.25;
         }
         var _loc9_:int = 10;
         while(_loc9_ * (width / this._scaleX) < 10)
         {
            _loc9_ *= 10;
         }
         param2 = _loc9_;
         while(param2 < this._scaleX)
         {
            _loc14_ = param2 * (width / this._scaleX);
            _loc5_.push(GraphicsPathCommand.MOVE_TO,GraphicsPathCommand.LINE_TO);
            _loc6_.push(_loc4_.x + _loc14_,_loc4_.y + 2);
            _loc6_.push(_loc4_.x + _loc14_,_loc4_.y + height - 3);
            param2 += _loc9_;
         }
         param1.lineStyle(1,13421772);
         param1.drawPath(_loc5_,_loc6_);
         param1.lineStyle();
         var _loc10_:Number = 1;
         var _loc11_:int = 0;
         if(this._defaultScaleX > 0)
         {
            _loc11_ = this._defaultScaleX;
         }
         else
         {
            _loc11_ = width;
         }
         var _loc12_:int = 0;
         while(_loc12_ < this._data.length)
         {
            if(this._data[_loc12_].data.length > 0 && this._data[_loc12_].run > this._runs - (graph as MachinationsGraph).visibleRuns && this._data[_loc12_].run != this._highLighted)
            {
               _loc5_ = new Vector.<int>();
               _loc6_ = new Vector.<Number>();
               _loc5_.push(GraphicsPathCommand.MOVE_TO);
               _loc6_.push(_loc4_.x,_loc4_.y + _loc7_ * (height - this._data[_loc12_].data[0] * (height / this._scaleY)));
               _loc15_ = 1;
               while(_loc15_ < Math.min(this._data[_loc12_].data.length,_loc11_))
               {
                  _loc5_.push(GraphicsPathCommand.LINE_TO);
                  _loc6_.push(_loc4_.x + _loc15_ * (width / this._scaleX) * _loc10_,_loc4_.y + _loc7_ * (height - this._data[_loc12_].data[_loc15_] * (height / this._scaleY)));
                  _loc15_++;
               }
               param1.lineStyle(this._data[_loc12_].thickness,this._data[_loc12_].color2);
               param1.drawPath(_loc5_,_loc6_);
               param1.lineStyle();
            }
            _loc12_++;
         }
         _loc12_ = 0;
         while(_loc12_ < this._data.length)
         {
            if(this._data[_loc12_].data.length > 0 && this._data[_loc12_].run == this._highLighted)
            {
               _loc5_ = new Vector.<int>();
               _loc6_ = new Vector.<Number>();
               _loc5_.push(GraphicsPathCommand.MOVE_TO);
               _loc6_.push(_loc4_.x,_loc4_.y + _loc7_ * (height - this._data[_loc12_].data[0] * (height / this._scaleY)));
               _loc15_ = 1;
               while(_loc15_ < Math.min(this._data[_loc12_].data.length,_loc11_))
               {
                  _loc5_.push(GraphicsPathCommand.LINE_TO);
                  _loc6_.push(_loc4_.x + _loc15_ * (width / this._scaleX) * _loc10_,_loc4_.y + _loc7_ * (height - this._data[_loc12_].data[_loc15_] * (height / this._scaleY)));
                  _loc15_++;
               }
               param1.lineStyle(this._data[_loc12_].thickness,this._data[_loc12_].color);
               param1.drawPath(_loc5_,_loc6_);
               param1.lineStyle();
            }
            _loc12_++;
         }
         param1.lineStyle(1,11184810);
         PhantomFont.drawText((this._scaleY * 0.25).toString(),param1,_loc4_.x + 5,_loc4_.y + height * 0.75 * _loc7_ + MachinationsGrammar.fontSize * 1.4,MachinationsGrammar.fontSize,PhantomFont.ALIGN_LEFT);
         PhantomFont.drawText((this._scaleY * 0.5).toString(),param1,_loc4_.x + 5,_loc4_.y + height * 0.5 * _loc7_ + MachinationsGrammar.fontSize * 1.4,MachinationsGrammar.fontSize,PhantomFont.ALIGN_LEFT);
         PhantomFont.drawText((this._scaleY * 0.75).toString(),param1,_loc4_.x + 5,_loc4_.y + height * 0.25 * _loc7_ + MachinationsGrammar.fontSize * 1.4,MachinationsGrammar.fontSize,PhantomFont.ALIGN_LEFT);
         if(this._negScaleY < 0)
         {
            PhantomFont.drawText("0",param1,_loc4_.x + 5,_loc4_.y + height * _loc7_ + MachinationsGrammar.fontSize * 1.4,MachinationsGrammar.fontSize,PhantomFont.ALIGN_LEFT);
         }
         param1.lineStyle();
         param1.lineStyle(1,11184810);
         PhantomFont.drawText((this._scaleY * 1).toString() + "",param1,_loc4_.x + 5,_loc4_.y + height * 0 + MachinationsGrammar.fontSize * 1.4,MachinationsGrammar.fontSize,PhantomFont.ALIGN_LEFT);
         param1.lineStyle();
         var _loc13_:String = this._scaleX.toString();
         if(Boolean(graph) && (graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_TURN_BASED)
         {
            _loc13_ += " turns";
         }
         else
         {
            _loc13_ += " s";
         }
         param1.lineStyle(1,11184810);
         PhantomFont.drawText(_loc13_,param1,_loc4_.x + this._scaleX * (width / this._scaleX) - 4,_loc4_.y + height - 4,MachinationsGrammar.fontSize,PhantomFont.ALIGN_RIGHT);
         param1.lineStyle();
         if(Boolean(graph) || !(graph as MachinationsGraph).running)
         {
            param1.lineStyle(2,color);
            if(this._runs >= 1)
            {
               PhantomFont.drawText("clear",param1,_loc4_.x + width - 5,_loc4_.y + MachinationsGrammar.fontSize + 5,MachinationsGrammar.fontSize,PhantomFont.ALIGN_RIGHT);
               PhantomFont.drawText("export",param1,_loc4_.x + width - 5,_loc4_.y + height + MachinationsGrammar.fontSize + 5,MachinationsGrammar.fontSize,PhantomFont.ALIGN_RIGHT);
            }
            if(this._runs >= 2)
            {
               PhantomFont.drawText("<<",param1,_loc4_.x + 10,_loc4_.y + height + MachinationsGrammar.fontSize + 5,MachinationsGrammar.fontSize,PhantomFont.ALIGN_CENTER);
               PhantomFont.drawText((this._highLighted + 1).toString(),param1,_loc4_.x + 35,_loc4_.y + height + MachinationsGrammar.fontSize + 5,MachinationsGrammar.fontSize,PhantomFont.ALIGN_CENTER);
               PhantomFont.drawText(">>",param1,_loc4_.x + 60,_loc4_.y + height + MachinationsGrammar.fontSize + 5,MachinationsGrammar.fontSize,PhantomFont.ALIGN_CENTER);
            }
            param1.lineStyle();
         }
      }
      
      public function toSVG(param1:XML) : void
      {
         var _loc16_:Number = NaN;
         var _loc17_:int = 0;
         var _loc2_:Vector3D = position.clone();
         var _loc3_:Number = size * 0.5;
         var _loc4_:XML = DrawUtil.drawRectToSVG(_loc2_.x,_loc2_.y,width,height,"none",StringUtil.toColorStringSVG(color),1);
         param1.appendChild(_loc4_);
         var _loc5_:Vector.<int> = new Vector.<int>();
         var _loc6_:Vector.<Number> = new Vector.<Number>();
         var _loc7_:Number = this._scaleY / (this._scaleY - this._negScaleY);
         var _loc8_:Number = _loc7_ * 0.25;
         while(_loc8_ < 1)
         {
            _loc5_.push(GraphicsPathCommand.MOVE_TO,GraphicsPathCommand.LINE_TO);
            _loc6_.push(_loc2_.x + 2,_loc2_.y + height * _loc8_);
            _loc6_.push(_loc2_.x + width - 3,_loc2_.y + height * _loc8_);
            _loc8_ += _loc7_ * 0.25;
         }
         var _loc9_:int = 10;
         while(_loc9_ * (width / this._scaleX) < 10)
         {
            _loc9_ *= 10;
         }
         var _loc10_:Number = _loc9_;
         while(_loc10_ < this._scaleX)
         {
            _loc16_ = _loc10_ * (width / this._scaleX);
            _loc5_.push(GraphicsPathCommand.MOVE_TO,GraphicsPathCommand.LINE_TO);
            _loc6_.push(_loc2_.x + _loc16_,_loc2_.y + 2);
            _loc6_.push(_loc2_.x + _loc16_,_loc2_.y + height - 3);
            _loc10_ += _loc9_;
         }
         var _loc11_:XML = DrawUtil.drawPathToSVG(_loc5_,_loc6_,"none",StringUtil.toColorStringSVG(0),1);
         _loc11_["stroke-dasharray"] = "1,2";
         param1.appendChild(_loc11_);
         var _loc12_:Number = 1;
         var _loc13_:int = 0;
         if(this._defaultScaleX > 0)
         {
            _loc13_ = this._defaultScaleX;
         }
         else
         {
            _loc13_ = width;
         }
         _loc2_ = position.clone();
         var _loc14_:int = 0;
         while(_loc14_ < this._data.length)
         {
            if(this._data[_loc14_].data.length > 0 && this._data[_loc14_].run > this._runs - (graph as MachinationsGraph).visibleRuns && this._data[_loc14_].run != this._highLighted)
            {
               _loc5_ = new Vector.<int>();
               _loc6_ = new Vector.<Number>();
               _loc5_.push(GraphicsPathCommand.MOVE_TO);
               _loc6_.push(_loc2_.x,_loc2_.y + _loc7_ * (height - this._data[_loc14_].data[0] * (height / this._scaleY)));
               _loc17_ = 1;
               while(_loc17_ < Math.min(this._data[_loc14_].data.length,_loc13_))
               {
                  _loc5_.push(GraphicsPathCommand.LINE_TO);
                  _loc6_.push(_loc2_.x + _loc17_ * (width / this._scaleX) * _loc12_,_loc2_.y + _loc7_ * (height - this._data[_loc14_].data[_loc17_] * (height / this._scaleY)));
                  _loc17_++;
               }
               param1.appendChild(DrawUtil.drawPathToSVG(_loc5_,_loc6_,"none",StringUtil.toColorStringSVG(this._data[_loc14_].color2),this._data[_loc14_].thickness));
            }
            _loc14_++;
         }
         _loc14_ = 0;
         while(_loc14_ < this._data.length)
         {
            if(this._data[_loc14_].data.length > 0 && this._data[_loc14_].run == this._highLighted)
            {
               _loc5_ = new Vector.<int>();
               _loc6_ = new Vector.<Number>();
               _loc5_.push(GraphicsPathCommand.MOVE_TO);
               _loc6_.push(_loc2_.x,_loc2_.y + _loc7_ * (height - this._data[_loc14_].data[0] * (height / this._scaleY)));
               _loc17_ = 1;
               while(_loc17_ < Math.min(this._data[_loc14_].data.length,_loc13_))
               {
                  _loc5_.push(GraphicsPathCommand.LINE_TO);
                  _loc6_.push(_loc2_.x + _loc17_ * (width / this._scaleX) * _loc12_,_loc2_.y + _loc7_ * (height - this._data[_loc14_].data[_loc17_] * (height / this._scaleY)));
                  _loc17_++;
               }
               param1.appendChild(DrawUtil.drawPathToSVG(_loc5_,_loc6_,"none",StringUtil.toColorStringSVG(this._data[_loc14_].color),this._data[_loc14_].thickness));
            }
            _loc14_++;
         }
         PhantomFont.drawTextToSVG((this._scaleY * 0.25).toString(),param1,_loc2_.x + 5,_loc2_.y + height * 0.75 * _loc7_ + MachinationsGrammar.fontSize * 1.4,MachinationsGrammar.fontSize,PhantomFont.ALIGN_LEFT,"none",StringUtil.toColorStringSVG(0),1);
         PhantomFont.drawTextToSVG((this._scaleY * 0.5).toString(),param1,_loc2_.x + 5,_loc2_.y + height * 0.5 * _loc7_ + MachinationsGrammar.fontSize * 1.4,MachinationsGrammar.fontSize,PhantomFont.ALIGN_LEFT,"none",StringUtil.toColorStringSVG(0),1);
         PhantomFont.drawTextToSVG((this._scaleY * 0.75).toString(),param1,_loc2_.x + 5,_loc2_.y + height * 0.25 * _loc7_ + MachinationsGrammar.fontSize * 1.4,MachinationsGrammar.fontSize,PhantomFont.ALIGN_LEFT,"none",StringUtil.toColorStringSVG(0),1);
         if(this._negScaleY < 0)
         {
            PhantomFont.drawTextToSVG("0",param1,_loc2_.x + 5,_loc2_.y + height * _loc7_ + MachinationsGrammar.fontSize * 1.4,MachinationsGrammar.fontSize,PhantomFont.ALIGN_LEFT,"none",StringUtil.toColorStringSVG(0),1);
         }
         PhantomFont.drawTextToSVG((this._scaleY * 1).toString() + "",param1,_loc2_.x + 5,_loc2_.y + height * 0 + MachinationsGrammar.fontSize * 1.4,MachinationsGrammar.fontSize,PhantomFont.ALIGN_LEFT,"none",StringUtil.toColorStringSVG(0),1);
         var _loc15_:String = this._scaleX.toString();
         if(Boolean(graph) && (graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_TURN_BASED)
         {
            _loc15_ += " turns";
         }
         else
         {
            _loc15_ += " s";
         }
         PhantomFont.drawTextToSVG(_loc15_,param1,_loc2_.x + this._scaleX * (width / this._scaleX) - 4,_loc2_.y + height - 4,MachinationsGrammar.fontSize,PhantomFont.ALIGN_RIGHT,"none",StringUtil.toColorStringSVG(0),1);
      }
      
      override public function prepare(param1:Boolean) : void
      {
         super.prepare(param1);
         this._time = 0;
         this._tick = 0;
         this._stopped = false;
         ++this._runs;
         this._highLighted = this._runs - 1;
         var _loc2_:int = int(inputs.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(inputs[_loc3_] is StateConnection)
            {
               this._data.push(new ChartData(inputs[_loc3_] as StateConnection,this._highLighted));
            }
            _loc3_++;
         }
      }
      
      public function clickClear(param1:Number, param2:Number) : Boolean
      {
         if(this._runs < 1)
         {
            return false;
         }
         if(param1 > position.x + width - 35 && param1 < position.x + width && param2 > position.y + 5 && param2 < position.y + 5 + MachinationsGrammar.fontSize * 1.2)
         {
            return true;
         }
         return false;
      }
      
      public function clickExport(param1:Number, param2:Number) : Boolean
      {
         if(this._runs < 1)
         {
            return false;
         }
         if(param1 > position.x + width - 45 && param1 < position.x + width && param2 > position.y + height && param2 < position.y + height + 5 + MachinationsGrammar.fontSize * 1.2)
         {
            return true;
         }
         return false;
      }
      
      public function clickPrevious(param1:Number, param2:Number) : Boolean
      {
         if(this._runs < 2)
         {
            return false;
         }
         if(param1 > position.x + 0 && param1 < position.x + 20 && param2 > position.y + height && param2 < position.y + height + 5 + MachinationsGrammar.fontSize * 1.2)
         {
            return true;
         }
         return false;
      }
      
      public function clickNext(param1:Number, param2:Number) : Boolean
      {
         if(this._runs < 2)
         {
            return false;
         }
         if(param1 > position.x + 50 && param1 < position.x + 70 && param2 > position.y + height && param2 < position.y + height + 5 + MachinationsGrammar.fontSize * 1.2)
         {
            return true;
         }
         return false;
      }
      
      public function doPrevious() : void
      {
         if(this._highLighted > 0)
         {
            --this._highLighted;
         }
      }
      
      public function doNext() : void
      {
         if(this._highLighted < this._runs - 1)
         {
            ++this._highLighted;
         }
      }
      
      public function clear() : void
      {
         this._data = new Vector.<ChartData>();
         this._scaleX = 20;
         this._runs = 0;
         this._highLighted = 0;
      }
      
      public function export() : void
      {
         this.fileIO.textData = "";
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._data.length)
         {
            if(this._data[_loc2_].data.length > _loc1_)
            {
               _loc1_ = int(this._data[_loc2_].data.length);
            }
            _loc2_++;
         }
         var _loc3_:String = "";
         var _loc4_:Boolean = false;
         _loc2_ = 0;
         while(_loc2_ < this._data.length)
         {
            if(this._data[_loc2_].name != "")
            {
               _loc4_ = true;
            }
            if(_loc2_ > 0)
            {
               _loc3_ += ",";
            }
            _loc3_ += this._data[_loc2_].name;
            _loc2_++;
         }
         if(_loc4_)
         {
            this.fileIO.textData += _loc3_ + "\r";
         }
         _loc3_ = "";
         _loc2_ = 0;
         while(_loc2_ < this._data.length)
         {
            if(_loc2_ > 0)
            {
               _loc3_ += ",";
            }
            _loc3_ += StringUtil.floatToStringMaxPrecision(this._data[_loc2_].thickness,1);
            _loc2_++;
         }
         this.fileIO.textData += _loc3_ + "\r";
         _loc3_ = "";
         _loc2_ = 0;
         while(_loc2_ < this._data.length)
         {
            if(_loc2_ > 0)
            {
               _loc3_ += ",";
            }
            _loc3_ += StringUtil.toColorString(this._data[_loc2_].color);
            _loc2_++;
         }
         this.fileIO.textData += _loc3_ + "\r";
         var _loc5_:int = 0;
         while(_loc5_ < _loc1_)
         {
            _loc3_ = "";
            _loc2_ = 0;
            while(_loc2_ < this._data.length)
            {
               if(_loc5_ < this._data[_loc2_].data.length)
               {
                  if(_loc2_ > 0)
                  {
                     _loc3_ += ",";
                  }
                  _loc3_ += StringUtil.floatToStringMaxPrecision(this._data[_loc2_].data[_loc5_],3);
               }
               _loc2_++;
            }
            this.fileIO.textData += _loc3_ + "\r";
            _loc5_++;
         }
         if(this.fileIO.fileName == "")
         {
            this.fileIO.saveFile("data.csv");
         }
         else
         {
            this.fileIO.saveFile(this.fileIO.fileName);
         }
      }
      
      override public function fire() : void
      {
         ++this._tick;
         var _loc1_:int = int(inputs.length);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            if(inputs[_loc2_] is StateConnection)
            {
               this.addData(inputs[_loc2_] as StateConnection);
            }
            _loc2_++;
         }
      }
      
      public function addData(param1:StateConnection) : void
      {
         if(Boolean(this._tick > 0) && Boolean(graph) && !(graph as MachinationsGraph).running)
         {
            return;
         }
         if(this.defaultScaleX > 0 && this._tick * (graph as MachinationsGraph).fireInterval > this.defaultScaleX)
         {
            return;
         }
         var _loc2_:Number = param1.state * param1.label.value;
         if(isNaN(_loc2_))
         {
            _loc2_ = 0;
         }
         if(this.defaultScaleY > 0 && _loc2_ > this.defaultScaleY)
         {
            return;
         }
         var _loc3_:* = int(this._data.length - 1);
         while(_loc3_ >= 0)
         {
            if(this._data[_loc3_].run == this._highLighted && this._data[_loc3_].connection == param1)
            {
               this._data[_loc3_].data.push(_loc2_);
               break;
            }
            _loc3_--;
         }
         while(this.defaultScaleY == 0 && this._scaleY < _loc2_ * 1.2)
         {
            if(this._scaleY == 12)
            {
               this._scaleY = 20;
            }
            else if(this._scaleY == 20)
            {
               this._scaleY = 40;
            }
            else if(this._scaleY == 40)
            {
               this._scaleY = 100;
            }
            else if(this._scaleY == 100)
            {
               this._scaleY = 200;
            }
            else if(this._scaleY == 200)
            {
               this._scaleY = 500;
            }
            else if(this._scaleY == 500)
            {
               this._scaleY = 1000;
            }
            else if(this._scaleY == 1000)
            {
               this._scaleY = 2000;
            }
            else
            {
               if(this._scaleY != 2000)
               {
                  break;
               }
               this._scaleY = 5000;
            }
         }
         while(this.defaultScaleY >= 0 && this._negScaleY > _loc2_ * 1.2)
         {
            if(this._negScaleY == 0)
            {
               this._negScaleY = -12;
            }
            else if(this._negScaleY == -12)
            {
               this._negScaleY = -20;
            }
            else if(this._negScaleY == -20)
            {
               this._negScaleY = -40;
            }
            else if(this._negScaleY == -40)
            {
               this._negScaleY = -100;
            }
            else if(this._negScaleY == -100)
            {
               this._negScaleY = -200;
            }
            else if(this._negScaleY == -200)
            {
               this._negScaleY = -500;
            }
            else if(this._negScaleY == -500)
            {
               this._negScaleY = -1000;
            }
            else if(this._negScaleY == -1000)
            {
               this._negScaleY = -2000;
            }
            else
            {
               if(this._negScaleY != -2000)
               {
                  break;
               }
               this._negScaleY = -5000;
            }
         }
         if(this.defaultScaleX <= 0 && this._scaleX < this._tick && this._scaleX <= width - 10)
         {
            this._scaleX += 10;
         }
         if(doEvents)
         {
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this));
         }
      }
      
      public function hasData() : Boolean
      {
         return this._data.length > 0;
      }
      
      override public function stop() : void
      {
         super.stop();
         if(doEvents)
         {
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this));
         }
      }
      
      public function get defaultScaleX() : int
      {
         return this._defaultScaleX;
      }
      
      public function set defaultScaleX(param1:int) : void
      {
         this._defaultScaleX = param1;
         this._scaleX = Math.max(param1,10);
      }
      
      public function get defaultScaleY() : int
      {
         return this._defaultScaleY;
      }
      
      public function set defaultScaleY(param1:int) : void
      {
         this._defaultScaleY = param1;
         this._scaleY = Math.max(param1,12);
      }
   }
}

