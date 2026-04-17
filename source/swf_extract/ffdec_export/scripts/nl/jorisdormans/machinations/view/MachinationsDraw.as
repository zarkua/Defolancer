package nl.jorisdormans.machinations.view
{
   import flash.display.Graphics;
   import flash.display.GraphicsPathCommand;
   import flash.geom.Vector3D;
   import nl.jorisdormans.graph.GraphConnectionType;
   import nl.jorisdormans.machinations.model.Delay;
   import nl.jorisdormans.machinations.model.Gate;
   import nl.jorisdormans.machinations.model.MachinationsConnection;
   import nl.jorisdormans.machinations.model.MachinationsNode;
   import nl.jorisdormans.phantomGraphics.DrawUtil;
   import nl.jorisdormans.phantomGraphics.PhantomFont;
   import nl.jorisdormans.phantomGraphics.PhantomShape;
   import nl.jorisdormans.utils.StringUtil;
   
   public class MachinationsDraw
   {
      
      private static var skillShape:PhantomShape = new PhantomShape(new Array(1,2,2,2,2,2,3,3,3,2,2,2,2,2),new Array(-20,8.8,-20,22.4,20,22.4,20,8.8,6.6,8.8,5.4,-13.8,11.2,-17.4,8,-24.4,0,-32,-7,-24.2,-10,-17.8,-4.6,-13.8,-6.2,8.8,-10,8.8,-10,5.8,-16.8,5.8,-17,8.8),0);
      
      private static var multiplayerShape:PhantomShape = new PhantomShape(new Array(1,2,3,2,3,3,3,3,3,1,2,3,2,3,3,3,3,3),new Array(-22.4,16.6,-2.4,16.6,-2.4,6.6,-8.4,-3.4,-8.4,-3.4,-3.8,-6.2,-3.8,-11.8,-3.8,-20,-12.4,-20.4,-20.8,-19.6,-20.4,-11.4,-20.2,-6.4,-16.8,-3.4,-22.4,6.6,-22.4,16.6,2.4,16.6,22.2,16.6,22.2,6.6,16.8,-3.4,16.7,-3.4,21,-5.8,21.4,-11.8,22,-20.41,11.79,-20.61,3.4,-19.6,3.39,-11.4,3.4,-5.4,6.8,-3.4,2.2,6.6,2.2,16.6),0);
      
      private static var strategyShape:PhantomShape = new PhantomShape(new Array(1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2),new Array(-10,0,10,0,7.2,2.2,10,5.6,6.8,7.4,10,10,6.8,12.4,10,15,7.2,16.8,10,20,5.4,20,0,25.4,-4.4,20,-10,20,-6.4,17.2,-10,15,-6.6,12.4,-10,10,-6.4,7,-10,5,-6.6,2.8),0);
      
      private static var timeShape:PhantomShape = new PhantomShape(new Array(1,3,2,3,3,2,3),new Array(0,0,-10,-10,-10,-20,10,-20,10,-10,0,0,-10,10,-10,20,10,20,10,10,0,0),0);
      
      public static var shapeGate:PhantomShape = new PhantomShape(new Array(1,2,2,2,2),new Array(-18.63,0,0,18.63,18.63,0,0,-18.63,-18.63,0),0);
      
      public static var shapeSource:PhantomShape = new PhantomShape(new Array(1,2,2,2),new Array(-18.63,12.42,18.63,12.42,0,-18.63,-18.63,12.42),0);
      
      public static var shapeDrain:PhantomShape = new PhantomShape(new Array(1,2,2,2),new Array(-18.63,-12.42,18.63,-12.42,0,18.63,-18.63,-12.42),0);
      
      public static var shapeConverter:PhantomShape = new PhantomShape(new Array(1,2,2,2,1,2),new Array(-12.42,18.63,-12.42,-18.63,18.63,0,-12.42,18.63,0,-18.63,0,18.63),0);
      
      public static var shapeTrader:PhantomShape = new PhantomShape(new Array(1,2,2,2,1,2,2,2,1,2),new Array(-15.03,-18.78,15.03,-7.51,-15.03,3.76,-15.03,-18.78,15.03,-3.76,-15.03,7.51,15.03,18.78,15.03,-3.76,0,-20,0,20),0);
      
      public static var shapeTrader2:PhantomShape = new PhantomShape(new Array(1,2,2,2,1,2,2,2),new Array(-12.03,-13.98,6.8,-7.51,-12,-1.4,-12,-14.2,12,1.2,-6.8,7.4,12,13.8,12,1.2),0);
      
      public static var shapeSelect:PhantomShape = new PhantomShape(new Array(1,2,2,2,2,2,2,2),new Array(-7.72,-19.97,-7.72,13.84,-0.53,4.53,5.32,20.23,10.91,17.57,3.73,3.46,13.84,3.46,-7.66,-20.04),0);
      
      public static var shapeFlow:PhantomShape = new PhantomShape(new Array(1,2,2,1,2),new Array(-20,0,20,0,10,10,10,-10,20,0),0);
      
      public static var shapeState:PhantomShape = new PhantomShape(new Array(1,2,1,2,1,2,1,2,1,2),new Array(-20,0,-15,0,-5,0,0,0,10,0,15,0,20,0,10,10,10,-10,20,0),0);
      
      public function MachinationsDraw()
      {
         super();
      }
      
      public static function drawDice(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         param1.beginFill(param5);
         param1.drawRoundRect(param2 - param4 * 0.5,param3 - param4 * 0.5,param4,param4,param4 * 0.5);
         param1.drawCircle(param2 - param4 * 0.25,param3 - param4 * 0.25,param4 * 0.1);
         param1.drawCircle(param2 + param4 * 0.25,param3 - param4 * 0.25,param4 * 0.1);
         param1.drawCircle(param2 - param4 * 0,param3 - param4 * 0,param4 * 0.1);
         param1.drawCircle(param2 - param4 * 0.25,param3 + param4 * 0.25,param4 * 0.1);
         param1.drawCircle(param2 + param4 * 0.25,param3 + param4 * 0.25,param4 * 0.1);
         param1.endFill();
      }
      
      public static function drawDiceToSVG(param1:XML, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         param1.appendChild(DrawUtil.drawRoundRectToSVG(param2 - param4 * 0.5,param3 - param4 * 0.5,param4,param4,param4 * 0.2,param4 * 0.2,StringUtil.toColorStringSVG(param5),null,0));
         param1.appendChild(DrawUtil.drawCircleToSVG(param2 - param4 * 0.25,param3 - param4 * 0.25,param4 * 0.1,StringUtil.toColorStringSVG(16777215),null,0));
         param1.appendChild(DrawUtil.drawCircleToSVG(param2 + param4 * 0.25,param3 - param4 * 0.25,param4 * 0.1,StringUtil.toColorStringSVG(16777215),null,0));
         param1.appendChild(DrawUtil.drawCircleToSVG(param2 + param4 * 0,param3 + param4 * 0,param4 * 0.1,StringUtil.toColorStringSVG(16777215),null,0));
         param1.appendChild(DrawUtil.drawCircleToSVG(param2 - param4 * 0.25,param3 + param4 * 0.25,param4 * 0.1,StringUtil.toColorStringSVG(16777215),null,0));
         param1.appendChild(DrawUtil.drawCircleToSVG(param2 + param4 * 0.25,param3 + param4 * 0.25,param4 * 0.1,StringUtil.toColorStringSVG(16777215),null,0));
      }
      
      public static function drawSkill(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         var _loc6_:Number = param4 / 50;
         param1.beginFill(param5);
         skillShape.drawScaled(param1,param2,param3,_loc6_,_loc6_);
         param1.endFill();
      }
      
      public static function drawSkillToSVG(param1:XML, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         var _loc6_:Number = param4 / 50;
         param1.appendChild(skillShape.toSVG(param2,param3,_loc6_,_loc6_,0,StringUtil.toColorStringSVG(param5),null,0));
      }
      
      public static function drawMultiplayer(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         var _loc6_:Number = param4 / 40;
         param1.beginFill(param5);
         multiplayerShape.drawScaled(param1,param2,param3,_loc6_,_loc6_);
         param1.endFill();
      }
      
      public static function drawMultiplayerToSVG(param1:XML, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         var _loc6_:Number = param4 / 40;
         param1.appendChild(multiplayerShape.toSVG(param2,param3,_loc6_,_loc6_,0,StringUtil.toColorStringSVG(param5),null,0));
      }
      
      public static function drawStrategy(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         var _loc6_:Number = param4 / 34;
         param1.beginFill(param5);
         strategyShape.drawScaled(param1,param2,param3,_loc6_,_loc6_);
         param1.endFill();
         param1.beginFill(param5);
         param1.drawCircle(param2,param3 - param4 * 0.25,param4 * 0.4);
         param1.drawCircle(param2,param3 - param4 * 0.25,param4 * 0.3);
         param1.endFill();
      }
      
      public static function drawStrategyToSVG(param1:XML, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         var _loc6_:Number = param4 / 34;
         param1.appendChild(strategyShape.toSVG(param2,param3,_loc6_,_loc6_,0,StringUtil.toColorStringSVG(param5),null,0));
         param1.appendChild(DrawUtil.drawCircleToSVG(param2,param3 - param4 * 0.25,param4 * 0.4,StringUtil.toColorStringSVG(param5),null,0));
         param1.appendChild(DrawUtil.drawCircleToSVG(param2,param3 - param4 * 0.25,param4 * 0.3,StringUtil.toColorStringSVG(16777215),null,0));
      }
      
      public static function drawTime(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         var _loc6_:Number = param4 / 40;
         param1.lineStyle(2,param5);
         timeShape.drawScaled(param1,param2,param3,_loc6_,_loc6_);
         param1.lineStyle();
      }
      
      public static function drawTimeToSVG(param1:XML, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         var _loc6_:Number = param4 / 40;
         param1.appendChild(timeShape.toSVG(param2,param3,_loc6_,_loc6_,0,"none",StringUtil.toColorStringSVG(param5),2));
      }
      
      public static function drawPassiveGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         drawPool(param1,param2,param3,2,param5,16777215,param4 / 40 * 16,MachinationsNode.MODE_PASSIVE,MachinationsNode.PULL_MODE_PULL_ANY,0);
      }
      
      public static function drawInteractiveGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         drawPool(param1,param2,param3,2,param5,16777215,param4 / 40 * 16,MachinationsNode.MODE_PASSIVE,MachinationsNode.PULL_MODE_PULL_ANY,0);
         drawPool(param1,param2,param3,2,param5,16777215,param4 / 40 * 16 - 3,MachinationsNode.MODE_PASSIVE,MachinationsNode.PULL_MODE_PULL_ANY,0);
      }
      
      public static function drawAutomaticGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         param1.lineStyle(2,param5);
         PhantomFont.drawText("*",param1,param2,param3 + param4 * 0.4,param4 * 0.8,PhantomFont.ALIGN_CENTER);
         param1.lineStyle();
      }
      
      public static function drawOnStartGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         param1.lineStyle(2,param5);
         PhantomFont.drawText("s",param1,param2,param3 + param4 * 0.4,param4 * 0.8,PhantomFont.ALIGN_CENTER);
         param1.lineStyle();
      }
      
      public static function drawPoolGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         drawPool(param1,param2,param3,2,param5,16777215,param4 / 40 * 20,MachinationsNode.MODE_PASSIVE,MachinationsNode.PULL_MODE_PULL_ANY,0);
      }
      
      public static function drawPool(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String, param9:String, param10:int) : void
      {
         param1.lineStyle(param4,param5);
         param1.beginFill(param6);
         param1.drawCircle(param2,param3,param7);
         param1.endFill();
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            param1.drawCircle(param2,param3,param7 * 0.75);
         }
         if(param8 == MachinationsNode.MODE_AUTOMATIC)
         {
            PhantomFont.drawText("*",param1,param2 + param7 * 1.1,param3 - param7 * 0.8 + 6,12,PhantomFont.ALIGN_CENTER);
         }
         if(param8 == MachinationsNode.MODE_ONSTART)
         {
            PhantomFont.drawText("s",param1,param2 + param7 * 1.1,param3 - param7 * 0.8 + 3,10,PhantomFont.ALIGN_CENTER);
         }
         if(param9 == MachinationsNode.PULL_MODE_PULL_ALL)
         {
            PhantomFont.drawText("&",param1,param2 + param7 * 1.1,param3 + param7 * 0.8 + 3,10,PhantomFont.ALIGN_CENTER);
         }
         if(param9 == MachinationsNode.PULL_MODE_PUSH_ANY && param10 > 0 && param8 != MachinationsNode.MODE_PASSIVE)
         {
            PhantomFont.drawText("p",param1,param2 + param7 * 1.1,param3 + param7 * 0.8 + 3,10,PhantomFont.ALIGN_CENTER);
         }
         if(param9 == MachinationsNode.PULL_MODE_PUSH_ALL && param10 > 0 && param8 != MachinationsNode.MODE_PASSIVE)
         {
            PhantomFont.drawText("p&",param1,param2 + param7 * 1.1 + 4,param3 + param7 * 0.8 + 3,10,PhantomFont.ALIGN_CENTER);
         }
         if(param9 == MachinationsNode.PULL_MODE_PUSH_ALL && (param10 == 0 || param8 == MachinationsNode.MODE_PASSIVE))
         {
            PhantomFont.drawText("&",param1,param2 + param7 * 1.1 + 4,param3 + param7 * 0.8 + 3,10,PhantomFont.ALIGN_CENTER);
         }
         param1.lineStyle();
      }
      
      public static function drawPoolToSVG(param1:XML, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String, param9:String, param10:int) : void
      {
         param1.appendChild(DrawUtil.drawCircleToSVG(param2,param3,param7,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            param1.appendChild(DrawUtil.drawCircleToSVG(param2,param3,param7 * 0.75,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         }
         if(param8 == MachinationsNode.MODE_AUTOMATIC)
         {
            PhantomFont.drawTextToSVG("*",param1,param2 + param7 * 1.1,param3 - param7 * 0.8 + 14,18,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param8 == MachinationsNode.MODE_ONSTART)
         {
            PhantomFont.drawTextToSVG("s",param1,param2 + param7 * 1.1,param3 - param7 * 0.8 + 3,10,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param9 == MachinationsNode.PULL_MODE_PULL_ALL)
         {
            PhantomFont.drawTextToSVG("&",param1,param2 + param7 * 1.1,param3 + param7 * 0.8 + 3,10,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param9 == MachinationsNode.PULL_MODE_PUSH_ANY && param10 > 0 && param8 != MachinationsNode.MODE_PASSIVE)
         {
            PhantomFont.drawTextToSVG("p",param1,param2 + param7 * 1.1,param3 + param7 * 0.8 + 3,10,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param9 == MachinationsNode.PULL_MODE_PUSH_ALL && param10 > 0 && param8 != MachinationsNode.MODE_PASSIVE)
         {
            PhantomFont.drawTextToSVG("p&",param1,param2 + param7 * 1.1 + 4,param3 + param7 * 0.8 + 3,10,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param9 == MachinationsNode.PULL_MODE_PUSH_ALL && (param10 == 0 || param8 == MachinationsNode.MODE_PASSIVE))
         {
            PhantomFont.drawTextToSVG("&",param1,param2 + param7 * 1.1 + 4,param3 + param7 * 0.8 + 3,10,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
      }
      
      public static function drawGateGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         drawGate(param1,param2,param3,2,param5,16777215,param4 / 40 * 16,Gate.GATE_DETERMINISTIC,MachinationsNode.MODE_PASSIVE,MachinationsNode.PULL_MODE_PULL_ANY);
      }
      
      public static function drawGate(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String, param9:String, param10:String) : void
      {
         var _loc11_:Number = param7 / 20;
         param1.lineStyle(param4,param5);
         param1.beginFill(param6);
         shapeGate.drawScaled(param1,param2,param3,_loc11_,_loc11_);
         param1.endFill();
         if(param9 == MachinationsNode.MODE_INTERACTIVE)
         {
            shapeGate.drawScaled(param1,param2,param3,_loc11_ * 0.65,_loc11_ * 0.65);
         }
         if(param9 == MachinationsNode.MODE_AUTOMATIC)
         {
            PhantomFont.drawText("*",param1,param2 + param7 * 0.9,param3 - param7 * 0.7 + 6,12,PhantomFont.ALIGN_CENTER);
         }
         if(param9 == MachinationsNode.MODE_ONSTART)
         {
            PhantomFont.drawText("s",param1,param2 + param7 * 0.9,param3 - param7 * 0.7 + 3,10,PhantomFont.ALIGN_CENTER);
         }
         if(param10 == MachinationsNode.PULL_MODE_PULL_ALL)
         {
            PhantomFont.drawText("&",param1,param2 + param7 * 0.9,param3 + param7 * 0.7 + 5,10,PhantomFont.ALIGN_CENTER);
         }
         param1.lineStyle();
         if(param9 == MachinationsNode.MODE_INTERACTIVE)
         {
            param7 *= 0.6;
         }
         else
         {
            param7 *= 0.8;
         }
         switch(param8)
         {
            case Gate.GATE_DICE:
               drawDice(param1,param2,param3,param7,param5);
               break;
            case Gate.GATE_SKILL:
               drawSkill(param1,param2,param3,param7,param5);
               break;
            case Gate.GATE_MULTIPLAYER:
               drawMultiplayer(param1,param2,param3,param7,param5);
               break;
            case Gate.GATE_STRATEGY:
               drawStrategy(param1,param2,param3,param7,param5);
         }
      }
      
      public static function drawGateToSVG(param1:XML, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String, param9:String, param10:String) : void
      {
         var _loc11_:Number = param7 / 20;
         param1.appendChild(shapeGate.toSVG(param2,param3,_loc11_,_loc11_,0,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         if(param9 == MachinationsNode.MODE_INTERACTIVE)
         {
            param1.appendChild(shapeGate.toSVG(param2,param3,_loc11_ * 0.6,_loc11_ * 0.6,0,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         }
         if(param9 == MachinationsNode.MODE_AUTOMATIC)
         {
            PhantomFont.drawTextToSVG("*",param1,param2 + param7 * 0.9,param3 - param7 * 0.7 + 14,18,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param9 == MachinationsNode.MODE_ONSTART)
         {
            PhantomFont.drawTextToSVG("s",param1,param2 + param7 * 0.9,param3 - param7 * 0.7 + 3,10,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param10 == MachinationsNode.PULL_MODE_PULL_ALL)
         {
            PhantomFont.drawTextToSVG("&",param1,param2 + param7 * 0.9,param3 + param7 * 0.7 + 5,10,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param9 == MachinationsNode.MODE_INTERACTIVE)
         {
            param7 *= 0.6;
         }
         else
         {
            param7 *= 0.8;
         }
         switch(param8)
         {
            case Gate.GATE_DICE:
               drawDiceToSVG(param1,param2,param3,param7,param5);
               break;
            case Gate.GATE_SKILL:
               drawSkillToSVG(param1,param2,param3,param7,param5);
               break;
            case Gate.GATE_MULTIPLAYER:
               drawMultiplayerToSVG(param1,param2,param3,param7,param5);
               break;
            case Gate.GATE_STRATEGY:
               drawStrategyToSVG(param1,param2,param3,param7,param5);
         }
      }
      
      public static function drawGateValue(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:Number) : void
      {
         var _loc9_:Number = param7 / 20;
         param1.lineStyle(param4,param5);
         param1.beginFill(param5);
         shapeGate.drawScaled(param1,param2,param3,_loc9_,_loc9_);
         param1.endFill();
         param1.lineStyle();
         param1.lineStyle(2,param6);
         var _loc10_:int = Math.floor(param8);
         PhantomFont.drawText(_loc10_.toString(),param1,param2,param3 + 4,8,PhantomFont.ALIGN_CENTER);
         param1.lineStyle();
      }
      
      public static function drawSourceGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         drawSource(param1,param2,param3,2,param5,16777215,param4 / 40 * 20,MachinationsNode.MODE_PASSIVE,MachinationsNode.PULL_MODE_PULL_ANY);
      }
      
      public static function drawSource(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String, param9:String) : void
      {
         var _loc10_:Number = param7 / 20;
         param1.lineStyle(param4,param5);
         param1.beginFill(param6);
         shapeSource.drawScaled(param1,param2,param3,_loc10_,_loc10_);
         param1.endFill();
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            shapeSource.drawScaled(param1,param2,param3 + _loc10_,_loc10_ * 0.6,_loc10_ * 0.6);
         }
         if(param8 == MachinationsNode.MODE_AUTOMATIC)
         {
            PhantomFont.drawText("*",param1,param2 + param7 * 0.7,param3 - param7 * 0.7 + 6,12,PhantomFont.ALIGN_CENTER);
         }
         if(param8 == MachinationsNode.MODE_ONSTART)
         {
            PhantomFont.drawText("s",param1,param2 + param7 * 0.7,param3 - param7 * 0.7 + 3,10,PhantomFont.ALIGN_CENTER);
         }
         param1.lineStyle();
      }
      
      public static function drawSourceToSVG(param1:XML, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String, param9:String) : void
      {
         var _loc10_:Number = param7 / 20;
         param1.appendChild(shapeSource.toSVG(param2,param3,_loc10_,_loc10_,0,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            param1.appendChild(shapeSource.toSVG(param2,param3 + _loc10_,_loc10_ * 0.6,_loc10_ * 0.6,0,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         }
         if(param8 == MachinationsNode.MODE_AUTOMATIC)
         {
            PhantomFont.drawTextToSVG("*",param1,param2 + param7 * 0.7,param3 - param7 * 0.7 + 14,18,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param8 == MachinationsNode.MODE_ONSTART)
         {
            PhantomFont.drawTextToSVG("s",param1,param2 + param7 * 0.7,param3 - param7 * 0.7 + 3,10,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
      }
      
      public static function drawDrainGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         drawDrain(param1,param2,param3,2,param5,16777215,param4 / 40 * 20,MachinationsNode.MODE_PASSIVE,MachinationsNode.PULL_MODE_PULL_ANY);
      }
      
      public static function drawDrain(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String, param9:String) : void
      {
         var _loc10_:Number = param7 / 20;
         param1.lineStyle(param4,param5);
         param1.beginFill(param6);
         shapeDrain.drawScaled(param1,param2,param3,_loc10_,_loc10_);
         param1.endFill();
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            shapeDrain.drawScaled(param1,param2,param3 - _loc10_,_loc10_ * 0.6,_loc10_ * 0.6);
         }
         if(param8 == MachinationsNode.MODE_AUTOMATIC)
         {
            PhantomFont.drawText("*",param1,param2 + param7 * 1.2,param3 - param7 * 0.3 + 6,12,PhantomFont.ALIGN_CENTER);
         }
         if(param8 == MachinationsNode.MODE_ONSTART)
         {
            PhantomFont.drawText("s",param1,param2 + param7 * 1.2,param3 - param7 * 0.3 + 3,10,PhantomFont.ALIGN_CENTER);
         }
         if(param9 == MachinationsNode.PULL_MODE_PULL_ALL)
         {
            PhantomFont.drawText("&",param1,param2 + param7 * 0.6,param3 + param7 * 0.7 + 5,10,PhantomFont.ALIGN_CENTER);
         }
         param1.lineStyle();
      }
      
      public static function drawDrainToSVG(param1:XML, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String, param9:String) : void
      {
         var _loc10_:Number = param7 / 20;
         param1.appendChild(shapeDrain.toSVG(param2,param3,_loc10_,_loc10_,0,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            param1.appendChild(shapeDrain.toSVG(param2,param3 - _loc10_,_loc10_ * 0.6,_loc10_ * 0.6,0,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         }
         if(param8 == MachinationsNode.MODE_AUTOMATIC)
         {
            PhantomFont.drawTextToSVG("*",param1,param2 + param7 * 1.2,param3 - param7 * 0.3 + 14,18,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param8 == MachinationsNode.MODE_ONSTART)
         {
            PhantomFont.drawTextToSVG("s",param1,param2 + param7 * 1.2,param3 - param7 * 0.3 + 3,10,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param9 == MachinationsNode.PULL_MODE_PULL_ALL)
         {
            PhantomFont.drawTextToSVG("&",param1,param2 + param7 * 0.6,param3 + param7 * 0.7 + 5,10,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
      }
      
      public static function drawConverterGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         drawConverter(param1,param2,param3,2,param5,16777215,param4 / 40 * 20,MachinationsNode.MODE_PASSIVE,MachinationsNode.PULL_MODE_PULL_ANY);
      }
      
      public static function drawConverter(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String, param9:String) : void
      {
         var _loc10_:Number = param7 / 20;
         param1.lineStyle(param4,param5);
         param1.beginFill(param6);
         shapeConverter.drawScaled(param1,param2,param3,_loc10_,_loc10_);
         param1.endFill();
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            shapeConverter.drawScaled(param1,param2,param3,_loc10_ * 0.6,_loc10_ * 0.6);
         }
         if(param8 == MachinationsNode.MODE_AUTOMATIC)
         {
            PhantomFont.drawText("*",param1,param2 + param7 * 0.7,param3 - param7 * 0.7 + 6,12,PhantomFont.ALIGN_CENTER);
         }
         if(param8 == MachinationsNode.MODE_ONSTART)
         {
            PhantomFont.drawText("s",param1,param2 + param7 * 0.7,param3 - param7 * 0.7 + 3,10,PhantomFont.ALIGN_CENTER);
         }
         if(param9 == MachinationsNode.PULL_MODE_PULL_ALL)
         {
            PhantomFont.drawText("&",param1,param2 + param7 * 0.7,param3 + param7 * 0.7 + 5,10,PhantomFont.ALIGN_CENTER);
         }
         param1.lineStyle();
      }
      
      public static function drawConverterToSVG(param1:XML, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String, param9:String) : void
      {
         var _loc10_:Number = param7 / 20;
         param1.appendChild(shapeConverter.toSVG(param2,param3,_loc10_,_loc10_,0,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            param1.appendChild(shapeConverter.toSVG(param2,param3,_loc10_ * 0.6,_loc10_ * 0.6,0,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         }
         if(param8 == MachinationsNode.MODE_AUTOMATIC)
         {
            PhantomFont.drawTextToSVG("*",param1,param2 + param7 * 0.7,param3 - param7 * 0.7 + 14,18,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param8 == MachinationsNode.MODE_ONSTART)
         {
            PhantomFont.drawTextToSVG("s",param1,param2 + param7 * 0.7,param3 - param7 * 0.7 + 3,10,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param9 == MachinationsNode.PULL_MODE_PULL_ALL)
         {
            PhantomFont.drawTextToSVG("&",param1,param2 + param7 * 0.7,param3 + param7 * 0.7 + 5,10,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
      }
      
      public static function drawTraderGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         drawTrader(param1,param2,param3,2,param5,16777215,param4 / 40 * 20,MachinationsNode.MODE_PASSIVE,MachinationsNode.PULL_MODE_PULL_ANY);
      }
      
      public static function drawTrader(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String, param9:String) : void
      {
         var _loc10_:Number = param7 / 20;
         param1.lineStyle(param4,param5);
         param1.beginFill(param6);
         shapeTrader.drawScaled(param1,param2,param3,_loc10_,_loc10_);
         param1.endFill();
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            shapeTrader2.drawScaled(param1,param2,param3,_loc10_,_loc10_);
         }
         if(param8 == MachinationsNode.MODE_AUTOMATIC)
         {
            PhantomFont.drawText("*",param1,param2 + param7 * 0.8,param3 - param7 * 0.7 + 6,12,PhantomFont.ALIGN_CENTER);
         }
         if(param8 == MachinationsNode.MODE_ONSTART)
         {
            PhantomFont.drawText("s",param1,param2 + param7 * 0.8,param3 - param7 * 0.7 + 3,10,PhantomFont.ALIGN_CENTER);
         }
         if(param9 == MachinationsNode.PULL_MODE_PULL_ALL)
         {
            PhantomFont.drawText("&",param1,param2 + param7 * 1.1,param3 + param7 * 0.7 + 5,10,PhantomFont.ALIGN_CENTER);
         }
         param1.lineStyle();
      }
      
      public static function drawTraderToSVG(param1:XML, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String, param9:String) : void
      {
         var _loc10_:Number = param7 / 20;
         param1.appendChild(shapeTrader.toSVG(param2,param3,_loc10_,_loc10_,0,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            param1.appendChild(shapeTrader2.toSVG(param2,param3,_loc10_,_loc10_,0,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         }
         if(param8 == MachinationsNode.MODE_AUTOMATIC)
         {
            PhantomFont.drawTextToSVG("*",param1,param2 + param7 * 0.8,param3 - param7 * 0.7 + 14,18,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param8 == MachinationsNode.MODE_ONSTART)
         {
            PhantomFont.drawTextToSVG("s",param1,param2 + param7 * 0.8,param3 - param7 * 0.7 + 3,10,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param9 == MachinationsNode.PULL_MODE_PULL_ALL)
         {
            PhantomFont.drawTextToSVG("&",param1,param2 + param7 * 1.1,param3 + param7 * 0.7 + 5,10,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
      }
      
      public static function drawSelectGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         var _loc6_:Number = param4 / 40;
         param1.lineStyle(1,param5);
         param1.beginFill(16777215,0.5);
         shapeSelect.drawScaled(param1,param2,param3,_loc6_,_loc6_);
         param1.endFill();
         param1.lineStyle();
      }
      
      public static function drawFlowGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         var _loc6_:Number = param4 / 40;
         param1.lineStyle(2,param5);
         shapeFlow.drawScaled(param1,param2,param3,_loc6_,_loc6_);
         param1.lineStyle();
      }
      
      public static function drawStateGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         var _loc6_:Number = param4 / 40;
         param1.lineStyle(2,param5);
         shapeState.drawScaled(param1,param2,param3,_loc6_,_loc6_);
         param1.lineStyle();
      }
      
      public static function drawRegisterGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         drawRegister(param1,param2,param3,2,param5,16777215,param4 * 0.85,"x",MachinationsNode.MODE_PASSIVE);
      }
      
      public static function drawRegister(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String, param9:String) : void
      {
         param1.lineStyle(param4,param5);
         param1.beginFill(param5);
         param1.drawRect(param2 - param7 * 0.45,param3 - param7 * 0.45,param7 * 0.9,param7 * 0.9);
         param1.endFill();
         param1.lineStyle(param4,param5);
         if(param9 == MachinationsNode.MODE_INTERACTIVE)
         {
            param1.lineStyle();
            param1.beginFill(param6);
            param1.moveTo(param2,param3 - param7 * 0.42);
            param1.lineTo(param2 - param7 * 0.3,param3 - param7 * 0.25);
            param1.lineTo(param2 + param7 * 0.3,param3 - param7 * 0.25);
            param1.lineTo(param2,param3 - param7 * 0.42);
            param1.moveTo(param2,param3 + param7 * 0.42);
            param1.lineTo(param2 - param7 * 0.3,param3 + param7 * 0.25);
            param1.lineTo(param2 + param7 * 0.3,param3 + param7 * 0.25);
            param1.lineTo(param2,param3 + param7 * 0.42);
            param1.endFill();
         }
         param1.lineStyle(2,param6);
         param7 = 8;
         PhantomFont.drawText(param8,param1,param2,param3 + param7 * 0.5,param7,PhantomFont.ALIGN_CENTER);
      }
      
      public static function drawRegisterToSVG(param1:XML, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String, param9:String) : void
      {
         var _loc10_:Vector.<int> = null;
         var _loc11_:Vector.<Number> = null;
         param1.appendChild(DrawUtil.drawRectToSVG(param2 - param7 * 0.45,param3 - param7 * 0.45,param7 * 0.9,param7 * 0.9,StringUtil.toColorStringSVG(param5),StringUtil.toColorStringSVG(param5),param4));
         if(param9 == MachinationsNode.MODE_INTERACTIVE)
         {
            _loc10_ = new Vector.<int>();
            _loc11_ = new Vector.<Number>();
            _loc10_.push(GraphicsPathCommand.MOVE_TO,GraphicsPathCommand.LINE_TO,GraphicsPathCommand.LINE_TO,GraphicsPathCommand.LINE_TO);
            _loc10_.push(GraphicsPathCommand.MOVE_TO,GraphicsPathCommand.LINE_TO,GraphicsPathCommand.LINE_TO,GraphicsPathCommand.LINE_TO);
            _loc11_.push(param2,param3 - param7 * 0.42);
            _loc11_.push(param2 - param7 * 0.3,param3 - param7 * 0.25);
            _loc11_.push(param2 + param7 * 0.3,param3 - param7 * 0.25);
            _loc11_.push(param2,param3 - param7 * 0.42);
            _loc11_.push(param2,param3 + param7 * 0.42);
            _loc11_.push(param2 - param7 * 0.3,param3 + param7 * 0.25);
            _loc11_.push(param2 + param7 * 0.3,param3 + param7 * 0.25);
            _loc11_.push(param2,param3 + param7 * 0.42);
            param1.appendChild(DrawUtil.drawPathToSVG(_loc10_,_loc11_,StringUtil.toColorStringSVG(param6),"none",0));
         }
         param7 = 8;
         PhantomFont.drawTextToSVG(param8,param1,param2,param3 + param7 * 0.5,param7,PhantomFont.ALIGN_CENTER,"none",StringUtil.toColorStringSVG(param6),2);
      }
      
      public static function drawDelayGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         drawDelay(param1,param2,param3,2,param5,16777215,param4 * 0.4,MachinationsNode.MODE_PASSIVE,Delay.TYPE_NORMAL);
      }
      
      public static function drawDelay(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String, param9:String) : void
      {
         param1.lineStyle(param4,param5);
         param1.beginFill(param6);
         param1.drawCircle(param2,param3,param7);
         param1.endFill();
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            param1.drawCircle(param2,param3,param7 * 0.75);
         }
         if(param8 == MachinationsNode.MODE_AUTOMATIC)
         {
            PhantomFont.drawText("*",param1,param2 + param7 * 1.1,param3 - param7 * 0.8 + 6,12,PhantomFont.ALIGN_CENTER);
         }
         if(param8 == MachinationsNode.MODE_ONSTART)
         {
            PhantomFont.drawText("s",param1,param2 + param7 * 1.1,param3 - param7 * 0.8 + 3,10,PhantomFont.ALIGN_CENTER);
         }
         param1.lineStyle();
         switch(param9)
         {
            case Delay.TYPE_NORMAL:
               drawTime(param1,param2,param3,param7,param5);
               break;
            case Delay.TYPE_QUEUE:
               drawTime(param1,param2 - param7 * 0.4,param3,param7 * 0.9,param5);
               drawTime(param1,param2 + param7 * 0.4,param3,param7 * 0.9,param5);
         }
      }
      
      public static function drawDelayToSVG(param1:XML, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String, param9:String) : void
      {
         param1.appendChild(DrawUtil.drawCircleToSVG(param2,param3,param7,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            param1.appendChild(DrawUtil.drawCircleToSVG(param2,param3,param7 * 0.75,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         }
         if(param8 == MachinationsNode.MODE_AUTOMATIC)
         {
            PhantomFont.drawTextToSVG("*",param1,param2 + param7 * 1.1,param3 - param7 * 0.8 + 14,18,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param8 == MachinationsNode.MODE_ONSTART)
         {
            PhantomFont.drawTextToSVG("s",param1,param2 + param7 * 1.1,param3 - param7 * 0.8 + 3,10,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         switch(param9)
         {
            case Delay.TYPE_NORMAL:
               drawTimeToSVG(param1,param2,param3,param7,param5);
               break;
            case Delay.TYPE_QUEUE:
               drawTimeToSVG(param1,param2 - param7 * 0.4,param3,param7 * 0.9,param5);
               drawTimeToSVG(param1,param2 + param7 * 0.4,param3,param7 * 0.9,param5);
         }
      }
      
      public static function drawEndConditionGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         drawEndCondition(param1,param2,param3,2,param5,16777215,param4 * 0.85,MachinationsNode.MODE_PASSIVE);
      }
      
      public static function drawEndCondition(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String) : void
      {
         param1.lineStyle(param4,param5);
         param1.beginFill(param6);
         param1.drawRect(param2 - param7 * 0.45,param3 - param7 * 0.45,param7 * 0.9,param7 * 0.9);
         param1.endFill();
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            param1.drawRect(param2 - param7 * 0.3,param3 - param7 * 0.3,param7 * 0.6,param7 * 0.6);
         }
         param1.lineStyle();
         param1.beginFill(param5);
         param1.drawRect(param2 - param7 * 0.25,param3 - param7 * 0.25,param7 * 0.5,param7 * 0.5);
         param1.endFill();
      }
      
      public static function drawEndConditionToSVG(param1:XML, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String) : void
      {
         param1.appendChild(DrawUtil.drawRectToSVG(param2 - param7 * 0.45,param3 - param7 * 0.45,param7 * 0.9,param7 * 0.9,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            param1.appendChild(DrawUtil.drawRectToSVG(param2 - param7 * 0.3,param3 - param7 * 0.3,param7 * 0.6,param7 * 0.6,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         }
         param1.appendChild(DrawUtil.drawRectToSVG(param2 - param7 * 0.25,param3 - param7 * 0.25,param7 * 0.5,param7 * 0.5,StringUtil.toColorStringSVG(param5),StringUtil.toColorStringSVG(param5),param4));
      }
      
      public static function drawArtificialPlayerGlyph(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint) : void
      {
         drawArtificialPlayer(param1,param2,param3,2,param5,16777215,param4 * 0.8,MachinationsNode.MODE_PASSIVE);
      }
      
      public static function drawArtificialPlayer(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String) : void
      {
         param1.lineStyle(param4,param5);
         param1.beginFill(param6);
         param1.drawRect(param2 - param7 * 0.5,param3 - param7 * 0.5,param7 * 1,param7 * 1);
         param1.endFill();
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            param1.drawRect(param2 - param7 * 0.35,param3 - param7 * 0.35,param7 * 0.7,param7 * 0.7);
         }
         if(param8 == MachinationsNode.MODE_AUTOMATIC)
         {
            PhantomFont.drawText("*",param1,param2 + param7 * 0.8,param3 - param7 * 0.6 + 6,12,PhantomFont.ALIGN_CENTER);
         }
         if(param8 == MachinationsNode.MODE_ONSTART)
         {
            PhantomFont.drawText("s",param1,param2 + param7 * 0.8,param3 - param7 * 0.6 + 6,10,PhantomFont.ALIGN_CENTER);
         }
         param1.lineStyle(2,param5);
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            PhantomFont.drawText("AP",param1,param2,param3 + param7 * 0.15,param7 * 0.3,PhantomFont.ALIGN_CENTER);
         }
         else
         {
            PhantomFont.drawText("AP",param1,param2,param3 + param7 * 0.22,param7 * 0.44,PhantomFont.ALIGN_CENTER);
         }
         param1.lineStyle();
      }
      
      public static function drawArtificialPlayerToSVG(param1:XML, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:String) : void
      {
         param1.appendChild(DrawUtil.drawRectToSVG(param2 - param7 * 0.45,param3 - param7 * 0.45,param7 * 0.9,param7 * 0.9,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            param1.appendChild(DrawUtil.drawRectToSVG(param2 - param7 * 0.3,param3 - param7 * 0.3,param7 * 0.6,param7 * 0.6,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4));
         }
         if(param8 == MachinationsNode.MODE_AUTOMATIC)
         {
            PhantomFont.drawTextToSVG("*",param1,param2 + param7 * 0.8,param3 - param7 * 0.6 + 6,12,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param8 == MachinationsNode.MODE_ONSTART)
         {
            PhantomFont.drawTextToSVG("s",param1,param2 + param7 * 0.8,param3 - param7 * 0.6 + 6,10,PhantomFont.ALIGN_CENTER,StringUtil.toColorStringSVG(param6),StringUtil.toColorStringSVG(param5),param4);
         }
         if(param8 == MachinationsNode.MODE_INTERACTIVE)
         {
            PhantomFont.drawTextToSVG("AP",param1,param2,param3 + param7 * 0.15,param7 * 0.3,PhantomFont.ALIGN_CENTER,"none",StringUtil.toColorStringSVG(param5),2);
         }
         else
         {
            PhantomFont.drawTextToSVG("AP",param1,param2,param3 + param7 * 0.22,param7 * 0.44,PhantomFont.ALIGN_CENTER,"none",StringUtil.toColorStringSVG(param5),2);
         }
      }
      
      public static function drawGroupBox(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint, param6:Number, param7:Number) : void
      {
         var _loc8_:Vector.<int> = new Vector.<int>();
         var _loc9_:Vector.<Number> = new Vector.<Number>();
         var _loc10_:Number = 0;
         while(_loc10_ < param6)
         {
            _loc8_.push(GraphicsPathCommand.MOVE_TO);
            _loc9_.push(param2 + _loc10_,param3);
            _loc8_.push(GraphicsPathCommand.LINE_TO);
            _loc9_.push(param2 + Math.min(_loc10_ + 7,param6),param3);
            _loc8_.push(GraphicsPathCommand.MOVE_TO);
            _loc9_.push(param2 + _loc10_,param3 + param7);
            _loc8_.push(GraphicsPathCommand.LINE_TO);
            _loc9_.push(param2 + Math.min(_loc10_ + 7,param6),param3 + param7);
            _loc10_ += 16;
         }
         var _loc11_:Number = 0;
         while(_loc11_ < param7)
         {
            _loc8_.push(GraphicsPathCommand.MOVE_TO);
            _loc9_.push(param2,param3 + _loc11_);
            _loc8_.push(GraphicsPathCommand.LINE_TO);
            _loc9_.push(param2,param3 + Math.min(_loc11_ + 7,param7));
            _loc8_.push(GraphicsPathCommand.MOVE_TO);
            _loc9_.push(param2 + param6,param3 + _loc11_);
            _loc8_.push(GraphicsPathCommand.LINE_TO);
            _loc9_.push(param2 + param6,param3 + Math.min(_loc11_ + 7,param7));
            _loc11_ += 16;
         }
         param1.lineStyle(param4,param5);
         param1.drawPath(_loc8_,_loc9_);
         param1.lineStyle();
      }
      
      public static function drawGroupBoxToSVG(param1:XML, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:Number, param8:Number) : void
      {
         var _loc9_:XML = DrawUtil.drawRectToSVG(param2,param3,param7,param8,"none",StringUtil.toColorStringSVG(param5),1);
         _loc9_["stroke-dasharray"] = "6,7";
         param1.appendChild(_loc9_);
      }
      
      public static function drawChart(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:uint, param6:Number, param7:Number) : void
      {
         param1.lineStyle(param4,param5);
         param1.drawRect(0,0,param6,param7);
         param1.lineStyle();
      }
      
      public static function drawResource(param1:Graphics, param2:Number, param3:Number, param4:uint) : void
      {
         var _loc5_:uint = 0;
         if(DrawUtil.colorToIllumination(param4) < 0.15)
         {
            _loc5_ = DrawUtil.lerpColor(param4,16777215,0.5);
            param1.beginFill(param4);
            param1.drawCircle(param2,param3,6);
            param1.endFill();
            param1.beginFill(_loc5_);
            param1.drawCircle(param2,param3,4);
            param1.endFill();
            param1.beginFill(param4);
            param1.drawCircle(param2,param3,3);
            param1.endFill();
         }
         else
         {
            _loc5_ = DrawUtil.lerpColor(param4,0,0.5);
            param1.beginFill(_loc5_);
            param1.drawCircle(param2,param3,6);
            param1.endFill();
            param1.beginFill(param4);
            param1.drawCircle(param2,param3,4);
            param1.endFill();
         }
      }
      
      public static function drawResourceToSVG(param1:XML, param2:Number, param3:Number, param4:uint) : void
      {
         var _loc6_:uint = 0;
         var _loc5_:XML = <g/>;
         if(DrawUtil.colorToIllumination(param4) < 0.15)
         {
            _loc6_ = DrawUtil.lerpColor(param4,16777215,0.5);
            _loc5_.appendChild(DrawUtil.drawCircleToSVG(param2,param3,6,StringUtil.toColorStringSVG(param4),"none",0));
            _loc5_.appendChild(DrawUtil.drawCircleToSVG(param2,param3,4,StringUtil.toColorStringSVG(_loc6_),"none",0));
            _loc5_.appendChild(DrawUtil.drawCircleToSVG(param2,param3,3,StringUtil.toColorStringSVG(param4),"none",0));
         }
         else
         {
            _loc6_ = DrawUtil.lerpColor(param4,0,0.5);
            _loc5_.appendChild(DrawUtil.drawCircleToSVG(param2,param3,6,StringUtil.toColorStringSVG(_loc6_),"none",0));
            _loc5_.appendChild(DrawUtil.drawCircleToSVG(param2,param3,4,StringUtil.toColorStringSVG(param4),"none",0));
         }
         param1.appendChild(_loc5_);
      }
      
      public static function generateConnectionData(param1:MachinationsConnection, param2:Vector.<int>, param3:Vector.<Number>, param4:Number, param5:Number, param6:Boolean) : void
      {
         var _loc7_:Vector3D = null;
         var _loc8_:Vector3D = null;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:int = 0;
         var _loc14_:Number = NaN;
         var _loc15_:int = 0;
         var _loc16_:Vector3D = null;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         if(param1.points.length < 2)
         {
            return;
         }
         if(param6)
         {
            _loc7_ = param1.points[param1.points.length - 1].clone();
            _loc8_ = _loc7_.subtract(param1.points[param1.points.length - 2]);
            _loc7_.x += param4;
            _loc7_.y += param5;
            _loc8_.normalize();
            param2.push(GraphicsPathCommand.MOVE_TO,GraphicsPathCommand.LINE_TO,GraphicsPathCommand.MOVE_TO,GraphicsPathCommand.LINE_TO,GraphicsPathCommand.LINE_TO);
            param3.push(_loc7_.x,_loc7_.y,_loc7_.x - _loc8_.x * 7,_loc7_.y - _loc8_.y * 7,_loc7_.x - _loc8_.x * 3 + _loc8_.y * 3,_loc7_.y - _loc8_.y * 3 - _loc8_.x * 3,_loc7_.x - _loc8_.x * 0,_loc7_.y - _loc8_.y * 0,_loc7_.x - _loc8_.x * 3 - _loc8_.y * 3,_loc7_.y - _loc8_.y * 3 + _loc8_.x * 3);
            _loc7_ = param1.points[0].clone();
            _loc8_ = _loc7_.subtract(param1.points[1]);
            _loc7_.x += param4;
            _loc7_.y += param5;
            _loc8_.normalize();
            param2.push(GraphicsPathCommand.MOVE_TO,GraphicsPathCommand.LINE_TO,GraphicsPathCommand.MOVE_TO,GraphicsPathCommand.LINE_TO,GraphicsPathCommand.LINE_TO);
            param3.push(_loc7_.x,_loc7_.y,_loc7_.x - _loc8_.x * 7,_loc7_.y - _loc8_.y * 7,_loc7_.x - _loc8_.x * 4 + _loc8_.y * 3,_loc7_.y - _loc8_.y * 4 - _loc8_.x * 3,_loc7_.x - _loc8_.x * 7,_loc7_.y - _loc8_.y * 7,_loc7_.x - _loc8_.x * 4 - _loc8_.y * 3,_loc7_.y - _loc8_.y * 4 + _loc8_.x * 3);
            return;
         }
         switch(param1.type.lineStyle)
         {
            default:
            case GraphConnectionType.STYLE_SOLID:
               param2.push(GraphicsPathCommand.MOVE_TO);
               param3.push(param1.points[0].x + param4,param1.points[0].y + param5);
               _loc15_ = 1;
               while(_loc15_ < param1.points.length)
               {
                  param2.push(GraphicsPathCommand.LINE_TO);
                  param3.push(param1.points[_loc15_].x + param4,param1.points[_loc15_].y + param5);
                  _loc15_++;
               }
               break;
            case GraphConnectionType.STYLE_DOTTED:
               _loc9_ = 0;
               _loc10_ = 0;
               _loc13_ = GraphicsPathCommand.MOVE_TO;
               _loc14_ = 5;
               while(_loc9_ < param1.points.length - 1)
               {
                  _loc16_ = param1.points[_loc9_ + 1].subtract(param1.points[_loc9_]);
                  _loc17_ = _loc16_.normalize();
                  _loc11_ = param1.points[_loc9_].x;
                  _loc12_ = param1.points[_loc9_].y;
                  _loc11_ += _loc16_.x * _loc10_;
                  _loc12_ += _loc16_.y * _loc10_;
                  while(_loc10_ < _loc17_)
                  {
                     param2.push(_loc13_);
                     param3.push(_loc11_ + param4,_loc12_ + param5);
                     if(_loc13_ == GraphicsPathCommand.MOVE_TO)
                     {
                        _loc13_ = GraphicsPathCommand.LINE_TO;
                        _loc14_ = Math.max(2,param1.thickness);
                     }
                     else
                     {
                        _loc13_ = GraphicsPathCommand.MOVE_TO;
                        _loc14_ = 5 + param1.thickness;
                     }
                     _loc10_ += _loc14_;
                     _loc11_ += _loc16_.x * _loc14_;
                     _loc12_ += _loc16_.y * _loc14_;
                  }
                  _loc11_ = param1.points[_loc9_ + 1].x;
                  _loc12_ = param1.points[_loc9_ + 1].y;
                  param2.push(_loc13_);
                  param3.push(_loc11_ + param4,_loc12_ + param5);
                  _loc10_ -= _loc17_;
                  _loc9_++;
               }
         }
         if(param1.type.arrowEnd != GraphConnectionType.ARROW_NONE)
         {
            _loc7_ = param1.points[param1.points.length - 1].clone();
            _loc8_ = _loc7_.subtract(param1.points[param1.points.length - 2]);
            _loc7_.x += param4;
            _loc7_.y += param5;
            _loc8_.normalize();
            param2.push(GraphicsPathCommand.MOVE_TO,GraphicsPathCommand.LINE_TO,GraphicsPathCommand.LINE_TO);
            switch(param1.type.arrowEnd)
            {
               default:
               case GraphConnectionType.ARROW_SMALL:
                  _loc18_ = 3;
                  break;
               case GraphConnectionType.ARROW_MEDIUM:
                  _loc18_ = 5;
                  break;
               case GraphConnectionType.ARROW_LARGE:
                  _loc18_ = 7;
            }
            _loc8_.scaleBy(_loc18_);
            param3.push(_loc7_.x - _loc8_.x - _loc8_.y,_loc7_.y - _loc8_.y + _loc8_.x,_loc7_.x,_loc7_.y,_loc7_.x - _loc8_.x + _loc8_.y,_loc7_.y - _loc8_.y - _loc8_.x);
         }
         if(param1.type.arrowStart != GraphConnectionType.ARROW_NONE)
         {
            _loc7_ = param1.points[0].clone();
            _loc8_ = _loc7_.subtract(param1.points[1]);
            _loc7_.x += param4;
            _loc7_.y += param5;
            _loc8_.normalize();
            param2.push(GraphicsPathCommand.MOVE_TO,GraphicsPathCommand.LINE_TO,GraphicsPathCommand.LINE_TO);
            switch(param1.type.arrowStart)
            {
               default:
               case GraphConnectionType.ARROW_SMALL:
                  _loc18_ = 3;
                  break;
               case GraphConnectionType.ARROW_MEDIUM:
                  _loc18_ = 5;
                  break;
               case GraphConnectionType.ARROW_LARGE:
                  _loc18_ = 7;
            }
            _loc8_.scaleBy(_loc18_);
            param3.push(_loc7_.x - _loc8_.x - _loc8_.y,_loc7_.y - _loc8_.y + _loc8_.x,_loc7_.x,_loc7_.y,_loc7_.x - _loc8_.x + _loc8_.y,_loc7_.y - _loc8_.y - _loc8_.x);
         }
      }
   }
}

