package nl.jorisdormans.phantomGUI
{
   import flash.display.Graphics;
   import flash.display.GraphicsPathCommand;
   
   public class PhantomGUISettings
   {
      
      public static var press:Number = 1;
      
      public static var fontName:String = "Tahoma";
      
      public static var fontSize:Number = 11;
      
      public static var borderWidth:Number = 2;
      
      public static var cornerOuter:Number = 10;
      
      public static var cornerInner:Number = 9;
      
      public static var drawControlSize:Number = 7;
      
      public static var colorSchemes:Vector.<PhantomColorScheme> = new Vector.<PhantomColorScheme>();
      
      colorSchemes.push(new PhantomColorScheme());
      
      public function PhantomGUISettings()
      {
         super();
      }
      
      public static function drawCheck(param1:Graphics, param2:Number, param3:Number, param4:Number) : void
      {
         var _loc5_:Vector.<int> = new Vector.<int>();
         var _loc6_:Vector.<Number> = new Vector.<Number>();
         _loc5_.push(GraphicsPathCommand.MOVE_TO);
         _loc6_.push(param2 + param4 * 0,param3 + param4 * 0.1);
         _loc5_.push(GraphicsPathCommand.LINE_TO);
         _loc6_.push(param2 + param4 * 0.5,param3 - param4 * 0.5);
         _loc5_.push(GraphicsPathCommand.LINE_TO);
         _loc6_.push(param2 + param4 * 0,param3 + param4 * 0.4);
         _loc5_.push(GraphicsPathCommand.LINE_TO);
         _loc6_.push(param2 - param4 * 0.3,param3 - param4 * 0.2);
         _loc5_.push(GraphicsPathCommand.MOVE_TO);
         _loc6_.push(param2 + param4 * 0,param3 + param4 * 0.2);
         param1.drawPath(_loc5_,_loc6_);
      }
   }
}

