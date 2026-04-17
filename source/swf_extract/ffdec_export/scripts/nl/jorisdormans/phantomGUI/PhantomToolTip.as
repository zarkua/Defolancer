package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   
   public class PhantomToolTip extends TextField
   {
      
      private var timer:Timer;
      
      private var _parent:DisplayObjectContainer;
      
      public function PhantomToolTip(param1:String, param2:DisplayObjectContainer)
      {
         super();
         defaultTextFormat = new TextFormat(PhantomGUISettings.fontName,PhantomGUISettings.fontSize);
         text = param1;
         width = textWidth + 5;
         height = textHeight + 5;
         border = true;
         borderColor = PhantomGUISettings.colorSchemes[0].colorBorder;
         background = true;
         backgroundColor = PhantomGUISettings.colorSchemes[0].colorFaceHover;
         textColor = PhantomGUISettings.colorSchemes[0].colorBorder;
         this.timer = new Timer(1000,1);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.timer.start();
         this._parent = param2;
         mouseEnabled = false;
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         if(!parent)
         {
            this._parent.addChild(this);
            x = stage.mouseX + 12;
            y = stage.mouseY - 12;
         }
      }
      
      public function show(param1:Number, param2:Number) : void
      {
         if(!parent)
         {
            this._parent.addChild(this);
            this.x = param1;
            this.y = param2;
         }
      }
      
      public function dispose() : void
      {
         this.timer.stop();
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
   }
}

