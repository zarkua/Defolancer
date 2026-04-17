package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class PhantomDrawPanel extends PhantomControl
   {
      
      public var background:uint = 4491519;
      
      public var foreground:uint = 17612;
      
      public var gridX:Number = 40;
      
      public var gridY:Number = 40;
      
      public var snapDistance:Number = 7;
      
      private var _maskShape:Sprite;
      
      public function PhantomDrawPanel(param1:DisplayObjectContainer, param2:Number, param3:Number, param4:Number, param5:Number, param6:Boolean = true, param7:Boolean = true)
      {
         super(param1,param2,param3,param4,param5,param6,param7);
         this.setSize(param4,param5);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
      }
      
      protected function onMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:PhantomDrawControl = null;
         if(param1.target == this)
         {
            _loc2_ = 0;
            while(_loc2_ < numChildren)
            {
               _loc3_ = getChildAt(_loc2_) as PhantomDrawControl;
               if(_loc3_ != null && _loc3_.selected)
               {
                  _loc3_.selected = false;
               }
               _loc2_++;
            }
         }
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         super.setSize(param1,param2);
         if(this._maskShape != null && this._maskShape.parent != null)
         {
            this._maskShape.parent.removeChild(this._maskShape);
         }
         this._maskShape = new Sprite();
         addChild(this._maskShape);
         this._maskShape.graphics.clear();
         this._maskShape.graphics.beginFill(16711680);
         this._maskShape.graphics.drawRect(0,0,_controlWidth,_controlHeight);
         this._maskShape.graphics.endFill();
         mask = this._maskShape;
         this.draw();
      }
      
      override public function draw() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         graphics.clear();
         graphics.beginFill(this.background);
         graphics.drawRect(0,0,_controlWidth,_controlHeight);
         graphics.endFill();
         if(this.gridX > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < _controlWidth)
            {
               graphics.beginFill(this.foreground);
               graphics.drawRect(_loc1_,0,1,_controlHeight);
               _loc1_ += this.gridX;
               graphics.endFill();
            }
         }
         if(this.gridY > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < _controlHeight)
            {
               graphics.beginFill(this.foreground);
               graphics.drawRect(0,_loc2_,_controlWidth,1);
               _loc2_ += this.gridY;
               graphics.endFill();
            }
         }
      }
      
      public function trySnap(param1:Number, param2:Number) : Point
      {
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         if(this.gridX > 0)
         {
            _loc3_ = param1 % this.gridX;
            if(_loc3_ > this.gridX * 0.5)
            {
               _loc3_ -= this.gridX;
            }
            _loc3_ *= -1;
            if(Math.abs(_loc3_) > this.snapDistance)
            {
               _loc3_ = 0;
            }
         }
         if(this.gridY > 0)
         {
            _loc4_ = param2 % this.gridY;
            if(_loc4_ > this.gridY * 0.5)
            {
               _loc4_ -= this.gridY;
            }
            _loc4_ *= -1;
            if(Math.abs(_loc4_) > this.snapDistance)
            {
               _loc4_ = 0;
            }
         }
         return new Point(_loc3_,_loc4_);
      }
   }
}

