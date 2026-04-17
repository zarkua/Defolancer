package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   import flash.events.MouseEvent;
   
   public class PhantomSelectCell extends PhantomControl
   {
      
      public var onChange:Function;
      
      protected var _selected:Boolean = false;
      
      protected var _hover:Boolean = false;
      
      public var index:int;
      
      public function PhantomSelectCell(param1:String, param2:Function, param3:DisplayObjectContainer, param4:Number, param5:Number, param6:Number = 88, param7:Number = 20, param8:Boolean = true, param9:Boolean = true)
      {
         super(param3,param4,param5,param6,param7,param8,param9);
         if(_captionAlign == null)
         {
            _captionAlign = ALIGN_LEFT;
         }
         this.caption = param1;
         buttonMode = true;
         addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.onChange = param2;
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         this.hover = false;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         this.hover = true;
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:PhantomSelectCell = null;
         if(!this.enabled)
         {
            return;
         }
         this.selected = true;
         if(this._selected)
         {
            _loc2_ = 0;
            while(_loc2_ < _parent.numChildren)
            {
               _loc3_ = _parent.getChildAt(_loc2_) as PhantomSelectCell;
               if(_loc3_ != null && _loc3_ != this && _loc3_._selected)
               {
                  _loc3_.selected = false;
               }
               _loc2_++;
            }
         }
         if(this.onChange != null)
         {
            this.onChange(this);
         }
      }
      
      override public function draw() : void
      {
         var _loc1_:uint = this._selected ? PhantomGUISettings.colorSchemes[colorScheme].colorBorder : (this._hover ? PhantomGUISettings.colorSchemes[colorScheme].colorFace : PhantomGUISettings.colorSchemes[colorScheme].colorWindow);
         var _loc2_:uint = this._selected ? (this._hover ? PhantomGUISettings.colorSchemes[colorScheme].colorFace : PhantomGUISettings.colorSchemes[colorScheme].colorWindow) : PhantomGUISettings.colorSchemes[colorScheme].colorBorder;
         if(!this.enabled)
         {
            _loc2_ = PhantomGUISettings.colorSchemes[colorScheme].colorFaceDisabled;
            _loc1_ = PhantomGUISettings.colorSchemes[colorScheme].colorBorderDisabled;
         }
         if(_textField != null)
         {
            _textField.textColor = _loc2_;
         }
         graphics.beginFill(_loc1_);
         graphics.drawRect(0,0,_controlWidth,_controlHeight);
         graphics.endFill();
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
         this.draw();
      }
      
      public function get hover() : Boolean
      {
         return this._hover;
      }
      
      public function set hover(param1:Boolean) : void
      {
         this._hover = param1;
         this.draw();
      }
      
      override public function get enabled() : Boolean
      {
         return super.enabled;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         buttonMode = this.enabled;
      }
   }
}

