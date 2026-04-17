package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   
   public class PhantomHorizontalScrollbar extends PhantomControl
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
      
      public function PhantomHorizontalScrollbar(param1:int, param2:int, param3:int, param4:DisplayObjectContainer, param5:Number, param6:Number, param7:Number, param8:Boolean = true, param9:Boolean = true)
      {
         if(param7 < BARSIZE * 3)
         {
            param7 = BARSIZE * 3;
         }
         _controlHeight = BARSIZE;
         _controlWidth = param7;
         this.setValues(param1,param2,param3);
         super(param4,param5,param6,param7,BARSIZE,param8,param9);
         new PhantomButton("",this.doDown,this,0,0,BARSIZE - 1,BARSIZE - 1,param8,param9).glyph = PhantomGlyph.ARROW_LEFT;
         new PhantomButton("",this.doUp,this,_controlWidth - BARSIZE,0,BARSIZE - 1,BARSIZE - 1,param8,param9).glyph = PhantomGlyph.ARROW_RIGHT;
         this._handle = new PhantomDragHandle(this,BARSIZE - 1,0,this.realHandleSize,BARSIZE - 1,BARSIZE - 1,_controlWidth - BARSIZE - this.realHandleSize - 1,0,0,this.doChange,param8,param9);
      }
      
      private function doDown(param1:PhantomButton) : void
      {
         this._handle.moveBy(-(this.handleSize - 1) * (this.realValueSize / (this.maxValue - this.handleSize)),0);
      }
      
      private function doUp(param1:PhantomButton) : void
      {
         this._handle.moveBy((this.handleSize - 1) * (this.realValueSize / (this.maxValue - this.handleSize)),0);
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
            this.realHandleSize = Math.floor(_controlWidth - 2 * BARSIZE);
         }
         else
         {
            this.realHandleSize = Math.floor((_controlWidth - 2 * BARSIZE) * (this.handleSize / this.maxValue));
         }
         if(this.realHandleSize > Math.floor(_controlWidth - 2 * BARSIZE))
         {
            this.realHandleSize = Math.floor(_controlWidth - 2 * BARSIZE);
         }
         if(this.realHandleSize < BARSIZE - 1)
         {
            this.realHandleSize = BARSIZE - 1;
         }
         this.realValueSize = _controlWidth - BARSIZE * 2 - this.realHandleSize;
         if(this._handle != null)
         {
            this._handle.setSize(this.realHandleSize,BARSIZE - 1);
            this._handle.setArea(BARSIZE - 1,_controlWidth - BARSIZE - this.realHandleSize - 1,0,0);
            this._handle.setPosition(BARSIZE - 1 + param1 * (this.realValueSize / (this.maxValue - this.handleSize)),0);
         }
         this.draw();
      }
      
      public function setLength(param1:Number) : void
      {
         if(param1 < BARSIZE * 3)
         {
            param1 = BARSIZE * 3;
         }
         _controlHeight = BARSIZE;
         _controlWidth = param1;
      }
      
      public function get currentValue() : int
      {
         this._currentValue = (this.maxValue - this.handleSize) * this._handle.positionX;
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
            _loc2_ = PhantomGUISettings.colorSchemes[colorScheme].colorWindowDisabled;
         }
         graphics.clear();
         graphics.beginFill(_loc3_);
         graphics.drawRect(0,0,_controlWidth,_controlHeight);
         graphics.endFill();
         graphics.beginFill(_loc1_);
         graphics.drawRect(BARSIZE - PhantomGUISettings.borderWidth,1,_controlWidth - BARSIZE * 2 + 2 * PhantomGUISettings.borderWidth,_controlHeight - 1);
         graphics.endFill();
         graphics.beginFill(_loc2_);
         graphics.drawRect(BARSIZE,PhantomGUISettings.borderWidth + 1,_controlWidth - BARSIZE * 2,_controlHeight - 1 - 2 * PhantomGUISettings.borderWidth);
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

