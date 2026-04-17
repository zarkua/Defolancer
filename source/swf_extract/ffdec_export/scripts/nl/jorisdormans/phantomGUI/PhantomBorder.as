package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   
   public class PhantomBorder extends PhantomControl
   {
      
      public function PhantomBorder(param1:DisplayObjectContainer, param2:Number, param3:Number, param4:Number, param5:Number, param6:Boolean = true, param7:Boolean = true)
      {
         super(param1,param2,param3,param4,param5,param6,param7);
      }
      
      override public function draw() : void
      {
         var _loc1_:uint = PhantomGUISettings.colorSchemes[colorScheme].colorBorder;
         graphics.clear();
         graphics.beginFill(_loc1_);
         graphics.drawRect(0,0,_controlWidth,_controlHeight);
         graphics.endFill();
      }
   }
}

