package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.text.TextFieldAutoSize;
   import flash.ui.Keyboard;
   
   public class PhantomEditNumberBox extends PhantomEditBox
   {
      
      private var _value:Number;
      
      public var min:Number = NaN;
      
      public var max:Number = NaN;
      
      public var precision:int;
      
      public var increment:Number;
      
      public function PhantomEditNumberBox(param1:Number, param2:int, param3:Number, param4:DisplayObjectContainer, param5:Number, param6:Number, param7:Number = 88, param8:Number = 24, param9:Boolean = true, param10:Boolean = true)
      {
         this.precision = param2;
         this._value = param1;
         super(this.valueToString(),param4,param5,param6,param7,param8,param9,param10);
         this.increment = param3;
         if(param3 > 0)
         {
            new PhantomButton("",this.up,this,param7 - 1,0,param8 * 0.5,param8 * 0.5).glyph = PhantomGlyph.ARROW_UP;
            new PhantomButton("",this.down,this,param7 - 1,param8 * 0.5 - 1,param8 * 0.5,param8 * 0.5).glyph = PhantomGlyph.ARROW_DOWN;
         }
         _captionAlign = ALIGN_RIGHT;
         caption = this.valueToString();
      }
      
      private function up(param1:PhantomButton) : void
      {
         this._value += this.increment;
         if(!isNaN(this.max) && this._value > this.max)
         {
            this._value = this.max;
         }
         caption = this.valueToString();
         if(onChange != null)
         {
            onChange(this);
         }
      }
      
      private function down(param1:PhantomButton) : void
      {
         this._value -= this.increment;
         if(!isNaN(this.min) && this._value < this.min)
         {
            this._value = this.min;
         }
         caption = this.valueToString();
         if(onChange != null)
         {
            onChange(this);
         }
      }
      
      private function valueToString() : String
      {
         if(this.precision <= 0)
         {
            return this._value.toString();
         }
         return this._value.toFixed(this.precision);
      }
      
      override protected function createTextField(param1:String) : void
      {
         super.createTextField(param1);
         _textField.autoSize = TextFieldAutoSize.RIGHT;
      }
      
      public function get value() : Number
      {
         var _loc1_:Number = this._value;
         if(!isNaN(this.max) && _loc1_ > this.max)
         {
            _loc1_ = this.max;
         }
         if(!isNaN(this.min) && _loc1_ < this.min)
         {
            _loc1_ = this.min;
         }
         return _loc1_;
      }
      
      public function set value(param1:Number) : void
      {
         this._value = param1;
         caption = this.valueToString();
      }
      
      override protected function onKeyUp(param1:KeyboardEvent) : void
      {
         var _loc2_:Number = NaN;
         if(_active && param1.charCode == Keyboard.ENTER)
         {
            stage.focus = null;
         }
         else
         {
            _loc2_ = parseFloat(_textField.text);
            if(!isNaN(this.max) && _loc2_ > this.max)
            {
               _loc2_ = this.max;
            }
            if(!isNaN(this.min) && _loc2_ < this.min)
            {
               _loc2_ = this.min;
            }
            if(!isNaN(_loc2_) && _loc2_ != this._value)
            {
               this._value = _loc2_;
               if(onChange != null)
               {
                  onChange(this);
               }
            }
         }
      }
      
      override protected function onFocusOut(param1:FocusEvent) : void
      {
         active = true;
         caption = this.valueToString();
         param1.stopPropagation();
      }
   }
}

