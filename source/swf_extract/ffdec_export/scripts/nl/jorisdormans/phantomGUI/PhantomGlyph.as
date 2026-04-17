package nl.jorisdormans.phantomGUI
{
   import flash.display.Graphics;
   import flash.display.GraphicsPathCommand;
   
   public class PhantomGlyph
   {
      
      public static const CHECK:int = 1;
      
      public static const PLAY:int = 2;
      
      public static const STOP:int = 3;
      
      public static const ARROW_LEFT:int = 10;
      
      public static const ARROW_RIGHT:int = 11;
      
      public static const ARROW_UP:int = 12;
      
      public static const ARROW_DOWN:int = 13;
      
      public function PhantomGlyph()
      {
         super();
      }
      
      public static function drawGlyph(param1:Graphics, param2:int, param3:Number, param4:Number, param5:Number) : void
      {
         var _loc6_:Vector.<int> = new Vector.<int>();
         var _loc7_:Vector.<Number> = new Vector.<Number>();
         switch(param2)
         {
            default:
               return;
            case CHECK:
               _loc6_.push(GraphicsPathCommand.MOVE_TO);
               _loc7_.push(param3 + param5 * 0,param4 + param5 * 0.1);
               _loc6_.push(GraphicsPathCommand.LINE_TO);
               _loc7_.push(param3 + param5 * 0.5,param4 - param5 * 0.5);
               _loc6_.push(GraphicsPathCommand.LINE_TO);
               _loc7_.push(param3 + param5 * 0,param4 + param5 * 0.4);
               _loc6_.push(GraphicsPathCommand.LINE_TO);
               _loc7_.push(param3 - param5 * 0.3,param4 - param5 * 0.2);
               break;
            case PLAY:
            case ARROW_RIGHT:
               _loc6_.push(GraphicsPathCommand.MOVE_TO);
               _loc7_.push(param3 - param5 * 0.3,param4 - param5 * 0.4);
               _loc6_.push(GraphicsPathCommand.LINE_TO);
               _loc7_.push(param3 + param5 * 0.3,param4 - param5 * 0);
               _loc6_.push(GraphicsPathCommand.LINE_TO);
               _loc7_.push(param3 - param5 * 0.3,param4 + param5 * 0.4);
               break;
            case ARROW_LEFT:
               _loc6_.push(GraphicsPathCommand.MOVE_TO);
               _loc7_.push(param3 + param5 * 0.3,param4 + param5 * 0.4);
               _loc6_.push(GraphicsPathCommand.LINE_TO);
               _loc7_.push(param3 - param5 * 0.3,param4 - param5 * 0);
               _loc6_.push(GraphicsPathCommand.LINE_TO);
               _loc7_.push(param3 + param5 * 0.3,param4 - param5 * 0.4);
               break;
            case ARROW_UP:
               _loc6_.push(GraphicsPathCommand.MOVE_TO);
               _loc7_.push(param3 + param5 * 0.4,param4 + param5 * 0.3);
               _loc6_.push(GraphicsPathCommand.LINE_TO);
               _loc7_.push(param3 - param5 * 0.4,param4 + param5 * 0.3);
               _loc6_.push(GraphicsPathCommand.LINE_TO);
               _loc7_.push(param3 + param5 * 0,param4 - param5 * 0.3);
               break;
            case ARROW_DOWN:
               _loc6_.push(GraphicsPathCommand.MOVE_TO);
               _loc7_.push(param3 - param5 * 0.4,param4 - param5 * 0.3);
               _loc6_.push(GraphicsPathCommand.LINE_TO);
               _loc7_.push(param3 + param5 * 0.4,param4 - param5 * 0.3);
               _loc6_.push(GraphicsPathCommand.LINE_TO);
               _loc7_.push(param3 + param5 * 0,param4 + param5 * 0.3);
               break;
            case STOP:
               _loc6_.push(GraphicsPathCommand.MOVE_TO);
               _loc7_.push(param3 - param5 * 0.3,param4 - param5 * 0.3);
               _loc6_.push(GraphicsPathCommand.LINE_TO);
               _loc7_.push(param3 + param5 * 0.3,param4 - param5 * 0.3);
               _loc6_.push(GraphicsPathCommand.LINE_TO);
               _loc7_.push(param3 + param5 * 0.3,param4 + param5 * 0.3);
               _loc6_.push(GraphicsPathCommand.LINE_TO);
               _loc7_.push(param3 - param5 * 0.3,param4 + param5 * 0.3);
         }
         param1.drawPath(_loc6_,_loc7_);
      }
   }
}

