package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   import flash.events.MouseEvent;
   
   public class PhantomTabButton extends PhantomButton
   {
      
      private var _selected:Boolean;
      
      public var tab:PhantomPanel;
      
      public function PhantomTabButton(param1:String, param2:Function, param3:DisplayObjectContainer, param4:Number, param5:Number, param6:Number, param7:Number, param8:Boolean = true, param9:Boolean = true, param10:Boolean = true)
      {
         this._selected = param8;
         super(param1,param2,param3,param4,param5,param6,param7,param9,param10);
      }
      
      override protected function mouseUp(param1:MouseEvent) : void
      {
         if(this.pressed)
         {
            if(!this._selected)
            {
               this.selected = true;
            }
            this.pressed = false;
            if(_action != null)
            {
               _action(this);
            }
         }
      }
      
      override protected function mouseDown(param1:MouseEvent) : void
      {
         if(enabled)
         {
            this.pressed = true;
         }
      }
      
      override protected function mouseOut(param1:MouseEvent) : void
      {
         hover = false;
         if(this.pressed)
         {
            this.pressed = false;
         }
      }
      
      override protected function mouseOver(param1:MouseEvent) : void
      {
         if(enabled)
         {
            hover = true;
         }
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:PhantomTabButton = null;
         if(this._selected == param1)
         {
            return;
         }
         this._selected = param1;
         _hover = this._selected;
         if(this._selected)
         {
            if(this.tab != null)
            {
               this.tab.showing = true;
            }
         }
         else if(this.tab != null)
         {
            this.tab.showing = false;
         }
         if(this._selected && parent != null)
         {
            _loc2_ = 0;
            while(_loc2_ < parent.numChildren)
            {
               _loc3_ = parent.getChildAt(_loc2_) as PhantomTabButton;
               if(_loc3_ != null && _loc3_ != this)
               {
                  _loc3_.selected = false;
               }
               _loc2_++;
            }
         }
         this.draw();
      }
      
      override public function draw() : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         graphics.clear();
         var _loc1_:uint = PhantomGUISettings.colorSchemes[colorScheme].colorBorder;
         var _loc2_:uint = _hover ? PhantomGUISettings.colorSchemes[colorScheme].colorFaceHover : PhantomGUISettings.colorSchemes[colorScheme].colorFace;
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
         graphics.beginFill(_loc2_);
         if(this._selected)
         {
            graphics.drawRect(PhantomGUISettings.borderWidth * 0.5,PhantomGUISettings.borderWidth,_controlWidth - PhantomGUISettings.borderWidth * 1,_controlHeight - PhantomGUISettings.borderWidth * 1);
         }
         else
         {
            graphics.drawRect(PhantomGUISettings.borderWidth * 0.5,PhantomGUISettings.borderWidth + 1,_controlWidth - PhantomGUISettings.borderWidth * 1,_controlHeight - PhantomGUISettings.borderWidth * 2 - 1);
         }
         graphics.endFill();
         if(_glyph > 0)
         {
            _loc3_ = _controlHeight * 0.5;
            _loc4_ = _loc3_;
            _loc5_ = _loc3_ * 1.6;
            graphics.beginFill(_loc1_);
            PhantomGlyph.drawGlyph(graphics,_glyph,_loc4_,_loc3_,_loc5_);
            graphics.endFill();
         }
         if(drawImage != null)
         {
            drawImage(graphics,_controlHeight * 0.5,_controlWidth * 0.5,_controlHeight * 0.6,_loc1_);
            if(_textField.parent != null)
            {
               _textField.parent.removeChild(_textField);
            }
         }
      }
      
      override public function get pressed() : Boolean
      {
         return super.pressed;
      }
      
      override public function set pressed(param1:Boolean) : void
      {
         if(_pressed != param1)
         {
            _pressed = param1;
         }
      }
   }
}

