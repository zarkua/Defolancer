package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   import flash.events.MouseEvent;
   
   public class PhantomButton extends PhantomControl
   {
      
      protected var _action:Function;
      
      protected var _edge:Number = PhantomGUISettings.press;
      
      protected var _hover:Boolean = false;
      
      protected var _pressed:Boolean = false;
      
      protected var _glyph:int = 0;
      
      public var drawImage:Function = null;
      
      protected var _toolTip:PhantomToolTip;
      
      public function PhantomButton(param1:String, param2:Function, param3:DisplayObjectContainer, param4:Number, param5:Number, param6:Number = 88, param7:Number = 24, param8:Boolean = true, param9:Boolean = true)
      {
         super(param3,param4,param5,param6,param7,param8,param9);
         this._action = param2;
         _captionAlign = ALIGN_CENTER;
         this.caption = param1;
         addEventListener(MouseEvent.MOUSE_OVER,this.mouseOver);
         addEventListener(MouseEvent.MOUSE_OUT,this.mouseOut);
         addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDown);
         addEventListener(MouseEvent.MOUSE_UP,this.mouseUp);
         addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMove);
         buttonMode = param9;
      }
      
      private function mouseMove(param1:MouseEvent) : void
      {
         if(this._toolTip != null && this._toolTip.parent != null)
         {
            this._toolTip.dispose();
            this._toolTip = null;
         }
      }
      
      protected function mouseUp(param1:MouseEvent) : void
      {
         if(this.pressed)
         {
            this.pressed = false;
            if(this._action != null)
            {
               this._action(this);
            }
         }
      }
      
      protected function mouseDown(param1:MouseEvent) : void
      {
         if(enabled)
         {
            this.pressed = true;
         }
      }
      
      protected function mouseOut(param1:MouseEvent) : void
      {
         this.hover = false;
         if(this.pressed)
         {
            this.pressed = false;
         }
         if(this._toolTip != null)
         {
            this._toolTip.dispose();
            this._toolTip = null;
         }
      }
      
      protected function mouseOver(param1:MouseEvent) : void
      {
         if(enabled)
         {
            this.hover = true;
         }
         if(this._toolTip == null && this.drawImage != null)
         {
            this._toolTip = new PhantomToolTip(_caption,stage);
         }
      }
      
      override public function draw() : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc1_:uint = PhantomGUISettings.colorSchemes[colorScheme].colorBorder;
         var _loc2_:uint = this._hover ? PhantomGUISettings.colorSchemes[colorScheme].colorFaceHover : PhantomGUISettings.colorSchemes[colorScheme].colorFace;
         if(!enabled)
         {
            _loc1_ = PhantomGUISettings.colorSchemes[colorScheme].colorBorderDisabled;
            _loc2_ = PhantomGUISettings.colorSchemes[colorScheme].colorFaceDisabled;
         }
         if(_textField != null)
         {
            _textField.textColor = _loc1_;
         }
         buttonMode = enabled;
         var _loc3_:Number = PhantomGUISettings.cornerOuter;
         var _loc4_:Number = PhantomGUISettings.cornerInner;
         if(_controlHeight * 0.5 < _loc3_ || _controlWidth * 0.5 < _loc3_)
         {
            _loc3_ = PhantomGUISettings.borderWidth;
            _loc4_ = 0;
         }
         graphics.clear();
         graphics.beginFill(_loc1_);
         graphics.drawRoundRect(this._edge,this._edge,_controlWidth,_controlHeight,_loc3_);
         graphics.endFill();
         graphics.beginFill(_loc1_);
         graphics.drawRoundRect(0,0,_controlWidth,_controlHeight,_loc3_);
         graphics.endFill();
         graphics.beginFill(_loc2_);
         graphics.drawRoundRect(PhantomGUISettings.borderWidth,PhantomGUISettings.borderWidth,_controlWidth - PhantomGUISettings.borderWidth * 2,_controlHeight - PhantomGUISettings.borderWidth * 2,_loc4_);
         graphics.endFill();
         if(this._glyph > 0)
         {
            _loc6_ = _loc5_ = _controlHeight * 0.5;
            _loc7_ = _loc5_ * 1.6;
            graphics.beginFill(_loc1_);
            PhantomGlyph.drawGlyph(graphics,this._glyph,_loc6_,_loc5_,_loc7_);
            graphics.endFill();
         }
         if(this.drawImage != null)
         {
            this.drawImage(graphics,_controlHeight * 0.5,_controlWidth * 0.5,_controlHeight * 0.6,_loc1_);
            if(_textField.parent != null)
            {
               _textField.parent.removeChild(_textField);
            }
         }
      }
      
      public function get hover() : Boolean
      {
         return this._hover;
      }
      
      public function set hover(param1:Boolean) : void
      {
         if(this._hover != param1)
         {
            this._hover = param1;
            this.draw();
         }
      }
      
      public function get pressed() : Boolean
      {
         return this._pressed;
      }
      
      public function set pressed(param1:Boolean) : void
      {
         if(this._pressed != param1)
         {
            this._pressed = param1;
            if(this._pressed)
            {
               x += PhantomGUISettings.press;
               y += PhantomGUISettings.press;
               this._edge -= PhantomGUISettings.press;
            }
            else
            {
               x -= PhantomGUISettings.press;
               y -= PhantomGUISettings.press;
               this._edge += PhantomGUISettings.press;
            }
            this.draw();
         }
      }
      
      public function get glyph() : int
      {
         return this._glyph;
      }
      
      public function set glyph(param1:int) : void
      {
         this._glyph = param1;
         this.draw();
      }
   }
}

