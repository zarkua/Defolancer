package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   import flash.events.MouseEvent;
   
   public class PhantomToolButton extends PhantomButton
   {
      
      private var _selected:Boolean = false;
      
      public var group:int;
      
      public function PhantomToolButton(param1:String, param2:Function, param3:DisplayObjectContainer, param4:Number, param5:Number, param6:Number, param7:Number, param8:Boolean = true, param9:Boolean = true, param10:Boolean = true)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param9,param10);
         this.selected = param8;
         this.group = 0;
      }
      
      override protected function mouseUp(param1:MouseEvent) : void
      {
         if(pressed)
         {
            if(!this._selected)
            {
               this.selected = true;
            }
            pressed = false;
            if(_action != null)
            {
               _action(this);
            }
         }
      }
      
      override protected function mouseOut(param1:MouseEvent) : void
      {
         hover = this._selected;
         if(pressed)
         {
            pressed = false;
         }
         if(_toolTip != null)
         {
            _toolTip.dispose();
            _toolTip = null;
         }
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:PhantomToolButton = null;
         if(this._selected == param1)
         {
            return;
         }
         this._selected = param1;
         _hover = this._selected;
         if(this._selected)
         {
            _edge -= PhantomGUISettings.press;
            x += PhantomGUISettings.press;
            y += PhantomGUISettings.press;
         }
         else
         {
            _edge += PhantomGUISettings.press;
            x -= PhantomGUISettings.press;
            y -= PhantomGUISettings.press;
         }
         if(this._selected && parent != null)
         {
            _loc2_ = 0;
            while(_loc2_ < parent.numChildren)
            {
               _loc3_ = parent.getChildAt(_loc2_) as PhantomToolButton;
               if(_loc3_ != null && _loc3_ != this && _loc3_.group == this.group)
               {
                  _loc3_.selected = false;
               }
               _loc2_++;
            }
         }
         draw();
      }
   }
}

