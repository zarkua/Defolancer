package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextFieldType;
   
   public class PhantomTextArea extends PhantomControl
   {
      
      public var onChange:Function;
      
      public var onExit:Function;
      
      protected var _active:Boolean = false;
      
      public function PhantomTextArea(param1:String, param2:DisplayObjectContainer, param3:Number, param4:Number, param5:Number = 88, param6:Number = 24, param7:Boolean = true, param8:Boolean = true)
      {
         super(param2,param3,param4,param5,param6,param7,param8);
         if(_captionAlign == null)
         {
            _captionAlign = ALIGN_LEFT;
         }
         this.caption = "edit";
         this.caption = param1;
      }
      
      public function setFont(param1:String, param2:Number) : void
      {
         _textField.defaultTextFormat.font = param1;
         _textField.defaultTextFormat.size = param2;
      }
      
      override public function draw() : void
      {
         var _loc1_:uint = PhantomGUISettings.colorSchemes[colorScheme].colorBorder;
         var _loc2_:uint = PhantomGUISettings.colorSchemes[colorScheme].colorWindow;
         if(!this.enabled)
         {
            _loc1_ = PhantomGUISettings.colorSchemes[colorScheme].colorBorderDisabled;
            _loc2_ = PhantomGUISettings.colorSchemes[colorScheme].colorWindowDisabled;
         }
         if(_textField != null)
         {
            _textField.textColor = _loc1_;
         }
         graphics.beginFill(_loc1_);
         graphics.drawRect(0,0,_controlWidth,_controlHeight);
         graphics.endFill();
         graphics.beginFill(_loc2_);
         graphics.drawRect(PhantomGUISettings.borderWidth,PhantomGUISettings.borderWidth,_controlWidth - PhantomGUISettings.borderWidth * 2,_controlHeight - PhantomGUISettings.borderWidth * 2);
         graphics.endFill();
      }
      
      override protected function createTextField(param1:String) : void
      {
         super.createTextField(param1);
         _textField.selectable = this.enabled;
         _textField.mouseEnabled = this.enabled;
         _textField.multiline = true;
         _textField.wordWrap = true;
         _textField.y = 2;
         _textField.height = _controlHeight - 4;
         _textField.type = TextFieldType.INPUT;
         _textField.addEventListener(Event.CHANGE,this.doChange);
         _textField.addEventListener(MouseEvent.MOUSE_DOWN,this.onClick);
         _textField.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
         _textField.addEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onClick);
      }
      
      protected function onFocusOut(param1:FocusEvent) : void
      {
         if(this.onExit != null)
         {
            this.onExit(this);
         }
         this.active = false;
      }
      
      protected function onKeyUp(param1:KeyboardEvent) : void
      {
         if(this.onChange != null)
         {
            this.onChange(this);
         }
      }
      
      protected function onClick(param1:MouseEvent) : void
      {
         this.active = true;
         param1.stopPropagation();
      }
      
      protected function doChange(param1:Event) : void
      {
         _caption = _textField.text;
         if(this.onChange != null)
         {
            this.onChange(this);
         }
      }
      
      public function get active() : Boolean
      {
         return this._active;
      }
      
      public function set active(param1:Boolean) : void
      {
         if(this._active == param1)
         {
            return;
         }
         this._active = param1;
         if(this._active)
         {
            _textField.setSelection(0,_textField.text.length);
            _textField.stage.focus = _textField;
         }
         else
         {
            _textField.setSelection(0,0);
         }
      }
      
      override public function get enabled() : Boolean
      {
         return super.enabled;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         if(_textField != null)
         {
            _textField.selectable = this.enabled;
            _textField.mouseEnabled = this.enabled;
         }
      }
   }
}

