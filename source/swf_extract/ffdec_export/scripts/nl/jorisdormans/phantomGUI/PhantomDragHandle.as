package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   import flash.events.MouseEvent;
   
   public class PhantomDragHandle extends PhantomButton
   {
      
      private var _minX:Number;
      
      private var _maxX:Number;
      
      private var _minY:Number;
      
      private var _maxY:Number;
      
      private var _positionX:Number;
      
      private var _positionY:Number;
      
      private var _mouseDownX:Number;
      
      private var _mouseDownY:Number;
      
      public var onMove:Function;
      
      public function PhantomDragHandle(param1:DisplayObjectContainer, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number, param9:Number, param10:Function, param11:Boolean = true, param12:Boolean = true)
      {
         super("",null,param1,param2,param3,param4,param5,param11,param12);
         this._minX = param6;
         this._maxX = param7;
         this._minY = param8;
         this._maxY = param9;
         this._positionX = (param2 - this._minX) / (this._maxX - this._minX);
         this._positionY = (param3 - this._minY) / (this._maxY - this._minY);
         this.onMove = param10;
      }
      
      public function setArea(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         this._minX = param1;
         this._maxX = param2;
         this._minY = param3;
         this._maxY = param4;
         x = Math.max(this._minX,Math.min(this._maxX,x));
         y = Math.max(this._minY,Math.min(this._maxY,y));
         _controlX = x;
         _controlY = y;
      }
      
      public function moveTo(param1:Number, param2:Number) : void
      {
         param1 = Math.max(this._minX,Math.min(this._maxX,param1));
         param2 = Math.max(this._minY,Math.min(this._maxY,param2));
         this.x = _controlX = param1;
         this.y = _controlY = param2;
         var _loc3_:Number = (param1 - this._minX) / (this._maxX - this._minX);
         var _loc4_:Number = (param2 - this._minY) / (this._maxY - this._minY);
         if(this._minX == this._maxX)
         {
            _loc3_ = param1;
         }
         if(this._minY == this._maxY)
         {
            _loc4_ = param2;
         }
         if(_loc3_ != this._positionX || _loc4_ != this._positionY)
         {
            this._positionX = _loc3_;
            this._positionY = _loc4_;
            if(this.onMove != null)
            {
               this.onMove(this);
            }
         }
      }
      
      public function moveBy(param1:Number, param2:Number) : void
      {
         x += param1;
         y += param2;
         x = Math.max(this._minX,Math.min(this._maxX,x));
         y = Math.max(this._minY,Math.min(this._maxY,y));
         _controlX = x;
         _controlY = y;
         var _loc3_:Number = (x - this._minX) / (this._maxX - this._minX);
         var _loc4_:Number = (y - this._minY) / (this._maxY - this._minY);
         if(this._minX == this._maxX)
         {
            _loc3_ = x;
         }
         if(this._minY == this._maxY)
         {
            _loc4_ = y;
         }
         if(_loc3_ != this._positionX || _loc4_ != this._positionY)
         {
            this._positionX = _loc3_;
            this._positionY = _loc4_;
            if(this.onMove != null)
            {
               this.onMove(this);
            }
         }
      }
      
      protected function moveHandle(param1:MouseEvent) : void
      {
         if(!_pressed)
         {
            return;
         }
         x = _controlX + param1.stageX - this._mouseDownX;
         y = _controlY + param1.stageY - this._mouseDownY;
         x = Math.max(this._minX,Math.min(this._maxX,x)) + 1;
         y = Math.max(this._minY,Math.min(this._maxY,y)) + 1;
         var _loc2_:Number = (x - this._minX - 1) / (this._maxX - this._minX);
         var _loc3_:Number = (y - this._minY - 1) / (this._maxY - this._minY);
         if(this._minX == this._maxX)
         {
            _loc2_ = x;
         }
         if(this._minY == this._maxY)
         {
            _loc3_ = y;
         }
         if(_loc2_ != this._positionX || _loc3_ != this._positionY)
         {
            this._positionX = _loc2_;
            this._positionY = _loc3_;
            if(this.onMove != null)
            {
               this.onMove(this);
            }
         }
      }
      
      override protected function mouseDown(param1:MouseEvent) : void
      {
         super.mouseDown(param1);
         this._mouseDownX = param1.stageX;
         this._mouseDownY = param1.stageY;
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.moveHandle);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.endMoveHandler);
      }
      
      override protected function mouseUp(param1:MouseEvent) : void
      {
      }
      
      protected function endMoveHandler(param1:MouseEvent) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.moveHandle);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.endMoveHandler);
         _controlX = x;
         _controlY = y;
         pressed = false;
         hover = false;
      }
      
      override protected function mouseOut(param1:MouseEvent) : void
      {
         if(!pressed)
         {
            hover = false;
         }
      }
      
      public function get minX() : Number
      {
         return this._minX;
      }
      
      public function get maxX() : Number
      {
         return this._maxX;
      }
      
      public function get minY() : Number
      {
         return this._minY;
      }
      
      public function get maxY() : Number
      {
         return this._maxY;
      }
      
      public function get positionX() : Number
      {
         return this._positionX;
      }
      
      public function set positionX(param1:Number) : void
      {
         this._positionX = param1;
      }
      
      public function get positionY() : Number
      {
         return this._positionY;
      }
      
      public function set positionY(param1:Number) : void
      {
         this._positionY = param1;
      }
   }
}

