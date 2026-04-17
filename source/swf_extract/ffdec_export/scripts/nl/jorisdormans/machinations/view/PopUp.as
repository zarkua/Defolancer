package nl.jorisdormans.machinations.view
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import nl.jorisdormans.phantomGUI.PhantomGUISettings;
   import nl.jorisdormans.phantomGraphics.PhantomFont;
   
   public class PopUp extends Sprite
   {
      
      public function PopUp(param1:DisplayObjectContainer, param2:Number, param3:Number, param4:String, param5:String)
      {
         var _loc7_:Number = NaN;
         super();
         var _loc6_:Number = 300;
         _loc7_ = 70;
         this.x = param2;
         this.y = param3;
         graphics.clear();
         graphics.lineStyle(2,PhantomGUISettings.colorSchemes[0].colorBorder);
         graphics.beginFill(PhantomGUISettings.colorSchemes[0].colorFace);
         graphics.drawRect(0,0,_loc6_,_loc7_);
         graphics.endFill();
         graphics.lineStyle(2,PhantomGUISettings.colorSchemes[0].colorBorder);
         graphics.beginFill(PhantomGUISettings.colorSchemes[0].colorBorder);
         graphics.drawRect(0,0,_loc6_,30);
         graphics.endFill();
         graphics.lineStyle();
         graphics.lineStyle(2,PhantomGUISettings.colorSchemes[0].colorFaceHover);
         PhantomFont.drawText(param4,graphics,10,20,10,PhantomFont.ALIGN_LEFT);
         PhantomFont.drawText("X",graphics,290,20,10,PhantomFont.ALIGN_RIGHT);
         graphics.lineStyle(2,PhantomGUISettings.colorSchemes[0].colorBorder);
         PhantomFont.drawText(param5,graphics,10,45,10,PhantomFont.ALIGN_LEFT);
         param1.addChild(this);
         var _loc8_:Timer = new Timer(3);
         _loc8_.addEventListener(TimerEvent.TIMER,this.onTimer);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
      }
   }
}

