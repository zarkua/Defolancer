package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   import flash.events.MouseEvent;
   
   public class PhantomCheckButton extends PhantomButton
   {
      
      private var _checked:Boolean;
      
      public function PhantomCheckButton(param1:String, param2:Function, param3:DisplayObjectContainer, param4:Number, param5:Number, param6:Number, param7:Number, param8:Boolean = true, param9:Boolean = true, param10:Boolean = true)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param9,param10);
         this._checked = param8;
         _textField.x += param7 * 0.3;
      }
      
      override public function draw() : void
      {
         super.draw();
         var _loc1_:uint = PhantomGUISettings.colorSchemes[colorScheme].colorBorder;
         var _loc2_:uint = PhantomGUISettings.colorSchemes[colorScheme].colorWindow;
         if(!enabled)
         {
            _loc1_ = PhantomGUISettings.colorSchemes[colorScheme].colorBorderDisabled;
            _loc2_ = PhantomGUISettings.colorSchemes[colorScheme].colorWindowDisabled;
         }
         var _loc3_:Number = _controlHeight * 0.5;
         var _loc4_:Number = _loc3_;
         var _loc5_:Number = _loc3_ * 1.6;
         graphics.beginFill(_loc2_);
         graphics.drawRoundRect(_loc4_ - _loc5_ * 0.35,_loc3_ - _loc5_ * 0.35,_loc5_ * 0.7,_loc5_ * 0.7,_loc5_ * 0.3);
         graphics.endFill();
         if(!this._checked)
         {
            return;
         }
         graphics.beginFill(_loc1_);
         PhantomGlyph.drawGlyph(graphics,PhantomGlyph.CHECK,_loc4_,_loc3_,_loc5_);
         graphics.endFill();
      }
      
      public function get checked() : Boolean
      {
         return this._checked;
      }
      
      public function set checked(param1:Boolean) : void
      {
         this._checked = param1;
         this.draw();
      }
      
      override protected function mouseUp(param1:MouseEvent) : void
      {
         if(pressed && enabled)
         {
            this.checked = !this._checked;
         }
         super.mouseUp(param1);
      }
   }
}

