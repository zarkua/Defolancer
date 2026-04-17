package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextFieldType;
   import flash.ui.Keyboard;
   
   public class PhantomComboBox extends PhantomEditBox
   {
      
      private var _border:PhantomBorder;
      
      private var _selectBox:PhantomSelectBox;
      
      private var _button:PhantomButton;
      
      public function PhantomComboBox(param1:String, param2:DisplayObjectContainer, param3:Stage, param4:Number, param5:Number, param6:Number = 88, param7:Number = 24, param8:Boolean = true, param9:Boolean = true)
      {
         super(param1,param2,param4,param5,param6,param7,param8,param9);
         this._button = new PhantomButton("",this.showSelect,this,param6 - param7,0,param7 - 2,param7 - 2,param8,param9);
         this._button.glyph = PhantomGlyph.ARROW_DOWN;
         this._border = new PhantomBorder(param3,getStageX(),getStageY() + param7,param6,5 * 20 + 4,false);
         this._selectBox = new PhantomSelectBox(this._border,2,2,param6 - 4,5 * 20);
         this._selectBox.onSelect = this.doSelect;
         _textField.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         _textField.type = TextFieldType.DYNAMIC;
      }
      
      private function doSelect(param1:PhantomSelectBox) : void
      {
         caption = param1.selectedOption;
         this._border.showing = false;
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.removeSelect);
         if(onChange != null)
         {
            onChange(this);
         }
      }
      
      private function showSelect(param1:PhantomButton) : void
      {
         this._border.showing = true;
         this._selectBox.scrollToOption(this._selectBox.selectedIndex);
         this._border.colorScheme = colorScheme;
         stage.addEventListener(MouseEvent.MOUSE_DOWN,this.removeSelect);
      }
      
      private function removeSelect(param1:MouseEvent) : void
      {
         if(param1.stageX < this._border.x || param1.stageX >= this._border.x + this._border.controlWidth || param1.stageY < this._border.y - _controlHeight || param1.stageY >= this._border.y + this._border.controlHeight)
         {
            this._border.showing = false;
            if(stage != null)
            {
               stage.removeEventListener(MouseEvent.MOUSE_UP,this.removeSelect);
            }
         }
      }
      
      public function findOption(param1:String) : void
      {
         this._selectBox.findOption(param1);
         caption = this._selectBox.selectedOption;
      }
      
      public function get selectedIndex() : int
      {
         return this._selectBox.selectedIndex;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         this._selectBox.selectedIndex = param1;
         caption = this._selectBox.selectedOption;
      }
      
      public function updateOption(param1:String) : void
      {
         if(this._selectBox.selectedIndex < 0)
         {
            return;
         }
         this._selectBox.changeOption(param1);
         caption = param1;
      }
      
      public function addOption(param1:String) : void
      {
         this._selectBox.addOption(param1);
      }
      
      public function clearOptions() : void
      {
         this._selectBox.clearOptions();
      }
      
      public function setOptions(param1:Vector.<String>) : void
      {
         this._selectBox.setOptions(param1);
      }
      
      public function get optionCount() : int
      {
         return this._selectBox.optionCount;
      }
      
      override protected function doChange(param1:Event) : void
      {
         var _loc2_:String = null;
         this._selectBox.findOption(_textField.text);
         if(this._selectBox.selectedIndex >= 0)
         {
            _loc2_ = _textField.text;
            _textField.text = this._selectBox.selectedOption;
            _textField.setSelection(_loc2_.length,_textField.text.length);
         }
         if(onChange != null)
         {
            onChange(this);
         }
      }
      
      override protected function onFocusOut(param1:FocusEvent) : void
      {
         var _loc2_:String = null;
         this._selectBox.findOption(_textField.text);
         if(this._selectBox.selectedIndex >= 0)
         {
            _loc2_ = _textField.text;
            _textField.text = this._selectBox.selectedOption;
            _textField.setSelection(0,0);
         }
         else
         {
            _textField.text = "";
            _textField.setSelection(0,0);
         }
         if(onExit != null)
         {
            onExit(this);
         }
         active = false;
      }
      
      protected function onKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.DOWN)
         {
            if(this._selectBox.selectedIndex < this._selectBox.optionCount - 1)
            {
               ++this._selectBox.selectedIndex;
               _textField.text = this._selectBox.selectedOption;
               _textField.setSelection(0,_textField.text.length);
               param1.stopImmediatePropagation();
               if(onChange != null)
               {
                  onChange(this);
               }
            }
         }
         else if(param1.keyCode == Keyboard.UP)
         {
            if(this._selectBox.selectedIndex > -1)
            {
               --this._selectBox.selectedIndex;
               _textField.text = this._selectBox.selectedOption;
               _textField.setSelection(0,_textField.text.length);
               param1.stopImmediatePropagation();
               if(onChange != null)
               {
                  onChange(this);
               }
            }
         }
         else if(param1.keyCode > 32 && param1.keyCode < 128)
         {
            this._selectBox.findOption(String.fromCharCode(param1.keyCode));
         }
      }
   }
}

