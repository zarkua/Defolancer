package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   
   public class PhantomLabel extends PhantomControl
   {
      
      public function PhantomLabel(param1:String, param2:DisplayObjectContainer, param3:Number, param4:Number, param5:Number = 88, param6:Number = 20, param7:Boolean = true, param8:Boolean = true)
      {
         super(param2,param3,param4,param5,param6,param7,param8);
         this.caption = param1;
      }
      
      override public function get enabled() : Boolean
      {
         return super.enabled;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         this.draw();
      }
      
      override public function draw() : void
      {
         if(_textField != null)
         {
            if(this.enabled)
            {
               _textField.textColor = PhantomGUISettings.colorSchemes[colorScheme].colorBorder;
            }
            else
            {
               _textField.textColor = PhantomGUISettings.colorSchemes[colorScheme].colorBorderDisabled;
            }
         }
      }
   }
}

