package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   
   public class PhantomVerticalScrollbar extends PhantomControl
   {
      
      public static const BARSIZE:int = 16;
      
      public var maxValue:int;
      
      private var _currentValue:int;
      
      public var increment:int = 1;
      
      public var handleSize:int = 1;
      
      private var realHandleSize:Number;
      
      private var realValueSize:Number;
      
      private var _handle:PhantomDragHandle;
      
      public var onChange:Function;
      
      private var _down:PhantomButton;
      
      private var _up:PhantomButton;
      
      public function PhantomVerticalScrollbar(param1:int, param2:int, param3:int, param4:DisplayObjectContainer, param5:Number, param6:Number, param7:Number, param8:Boolean = true, param9:Boolean = true)
      {
         if(param7 < BARSIZE * 3)
         {
            param7 = BARSIZE * 3;
         }
         _controlHeight = param7;
         _controlWidth = BARSIZE;
         this.setValues(param1,param2,param3);
         super(param4,param5,param6,BARSIZE,param7,param8,param9);
         this._down = new PhantomButton("",this.doDown,this,0,0,BARSIZE - 1,BARSIZE - 1,param8,param9);
         this._down.glyph = PhantomGlyph.ARROW_UP;
         this._up = new PhantomButton("",this.doUp,this,0,_controlHeight - BARSIZE,BARSIZE - 1,BARSIZE - 1,param8,param9);
         this._up.glyph = PhantomGlyph.ARROW_DOWN;
         this._handle = new PhantomDragHandle(this,0,BARSIZE - 1,BARSIZE - 1,this.realHandleSize,0,0,BARSIZE - 1,_controlHeight - BARSIZE - this.realHandleSize - 1,this.doChange,param8,param9);
      }
      
      private function doDown(param1:PhantomButton) : void
      {
         this._handle.moveBy(0,-(this.handleSize - 1) * (this.realValueSize / (this.maxValue - this.handleSize)));
      }
      
      private function doUp(param1:PhantomButton) : void
      {
         this._handle.moveBy(0,(this.handleSize - 1) * (this.realValueSize / (this.maxValue - this.handleSize)));
      }
      
      public function setValues(param1:int, param2:int = -1, param3:int = -1) : void
      {
         if(param3 > 0)
         {
            this.handleSize = param3;
         }
         if(param2 >= 0)
         {
            this.maxValue = param2;
         }
         this.currentValue = param1;
         if(this.maxValue == 0)
         {
            this.realHandleSize = Math.floor(_controlHeight - 2 * BARSIZE);
         }
         else
         {
            this.realHandleSize = Math.floor((_controlHeight - 2 * BARSIZE) * (this.handleSize / this.maxValue));
         }
         if(this.realHandleSize > Math.floor(_controlHeight - 2 * BARSIZE))
         {
            this.realHandleSize = Math.floor(_controlHeight - 2 * BARSIZE);
         }
         if(this.realHandleSize < BARSIZE - 1)
         {
            this.realHandleSize = BARSIZE - 1;
         }
         this.realValueSize = _controlHeight - BARSIZE * 2 - this.realHandleSize;
         if(this._handle != null)
         {
            this._handle.setSize(BARSIZE - 1,this.realHandleSize);
            this._handle.setArea(0,0,BARSIZE - 1,_controlHeight - BARSIZE - this.realHandleSize - 1);
            this._handle.setPosition(0,BARSIZE - 1 + param1 * (this.realValueSize / (this.maxValue - this.handleSize)));
            this._handle.enabled = this.realHandleSize == Math.floor(_controlHeight - 2 * BARSIZE) ? false : true;
            this._up.enabled = this.realHandleSize == Math.floor(_controlHeight - 2 * BARSIZE) ? false : true;
            this._down.enabled = this.realHandleSize == Math.floor(_controlHeight - 2 * BARSIZE) ? false : true;
         }
         this.draw();
      }
      
      public function setLength(param1:Number) : void
      {
         if(param1 < BARSIZE * 3)
         {
            param1 = BARSIZE * 3;
         }
         _controlHeight = param1;
         _controlWidth = BARSIZE;
      }
      
      public function get currentValue() : int
      {
         this._currentValue = (this.maxValue - this.handleSize) * this._handle.positionY;
         return this._currentValue;
      }
      
      public function set currentValue(param1:int) : void
      {
         this._currentValue = param1;
      }
      
      override public function draw() : void
      {
         var _loc1_:uint = PhantomGUISettings.colorSchemes[colorScheme].colorBorder;
         var _loc2_:uint = PhantomGUISettings.colorSchemes[colorScheme].colorFaceDisabled;
         var _loc3_:uint = PhantomGUISettings.colorSchemes[colorScheme].colorFace;
         if(!enabled)
         {
            _loc1_ = PhantomGUISettings.colorSchemes[colorScheme].colorBorderDisabled;
         }
         graphics.clear();
         graphics.beginFill(_loc3_);
         graphics.drawRect(0,0,_controlWidth,_controlHeight);
         graphics.endFill();
         graphics.beginFill(_loc1_);
         graphics.drawRect(1,BARSIZE - PhantomGUISettings.borderWidth,_controlWidth - 1,_controlHeight - BARSIZE * 2 + 2 * PhantomGUISettings.borderWidth);
         graphics.endFill();
         graphics.beginFill(_loc2_);
         graphics.drawRect(PhantomGUISettings.borderWidth + 1,BARSIZE,_controlWidth - 1 - 2 * PhantomGUISettings.borderWidth,_controlHeight - BARSIZE * 2);
         graphics.endFill();
      }
      
      private function doChange(param1:PhantomControl) : void
      {
         if(this.onChange != null)
         {
            this.onChange(this);
         }
      }
   }
}

