package nl.jorisdormans.machinations.view
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import nl.jorisdormans.phantomGUI.PhantomGUISettings;
   import nl.jorisdormans.phantomGraphics.PhantomFont;
   
   public class RunReport extends Sprite
   {
      
      private var reportWidth:int;
      
      private var ends:Vector.<String>;
      
      private var counts:Vector.<int>;
      
      private var totalRuns:int;
      
      private var runs:int;
      
      private var totalTime:Number;
      
      private var minHeight:Number;
      
      public function RunReport(param1:DisplayObjectContainer, param2:int)
      {
         super();
         this.reportWidth = 200;
         x = (600 - this.reportWidth) * 0.5;
         y = 100;
         this.minHeight = 40;
         this.ends = new Vector.<String>();
         this.counts = new Vector.<int>();
         this.totalRuns = param2;
         this.runs = 0;
         this.draw();
         param1.addChild(this);
         this.totalTime = 0;
      }
      
      private function draw() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         graphics.clear();
         graphics.lineStyle(2,PhantomGUISettings.colorSchemes[0].colorBorder);
         graphics.beginFill(PhantomGUISettings.colorSchemes[0].colorFace);
         graphics.drawRect(0,0,this.reportWidth,Math.max(this.minHeight,this.ends.length * 20 + 62));
         graphics.endFill();
         graphics.lineStyle();
         var _loc1_:Number = this.totalTime / this.runs;
         if(this.runs == 1 && this.totalRuns == 1)
         {
            graphics.lineStyle(2,PhantomGUISettings.colorSchemes[0].colorBorder);
            PhantomFont.drawText("Time: " + _loc1_.toFixed(2),graphics,10,20,10,PhantomFont.ALIGN_LEFT);
            _loc2_ = int(this.ends.length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               PhantomFont.drawText("Ended by: " + this.ends[_loc3_],graphics,10,45 + 20 * _loc3_,10,PhantomFont.ALIGN_LEFT);
               _loc3_++;
            }
         }
         else
         {
            graphics.beginFill(PhantomGUISettings.colorSchemes[0].colorBorder);
            graphics.drawRect(4,4,this.reportWidth - 8,22);
            graphics.endFill();
            graphics.beginFill(PhantomGUISettings.colorSchemes[0].colorFaceDisabled);
            graphics.drawRect(6,6,this.reportWidth - 12,18);
            graphics.endFill();
            graphics.beginFill(PhantomGUISettings.colorSchemes[0].colorFaceHover);
            graphics.drawRect(6,6,(this.reportWidth - 12) * (this.runs / this.totalRuns),18);
            graphics.endFill();
            graphics.lineStyle(2,PhantomGUISettings.colorSchemes[0].colorBorder);
            PhantomFont.drawText("Runs: " + this.runs,graphics,10,20,10,PhantomFont.ALIGN_LEFT);
            PhantomFont.drawText("Average time: " + _loc1_.toFixed(2),graphics,10,45,10,PhantomFont.ALIGN_LEFT);
            _loc2_ = int(this.ends.length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               PhantomFont.drawText(this.ends[_loc3_] + ": " + this.counts[_loc3_].toString(),graphics,10,70 + 20 * _loc3_,10,PhantomFont.ALIGN_LEFT);
               _loc3_++;
            }
         }
      }
      
      public function countEnd(param1:String, param2:Number) : void
      {
         var _loc6_:int = 0;
         ++this.runs;
         _loc6_ = param1.indexOf("|");
         if(_loc6_ >= 0)
         {
            param1 = param1.substr(0,_loc6_) + " " + param1.substr(_loc6_ + 1);
         }
         this.totalTime += param2;
         var _loc3_:Boolean = false;
         var _loc4_:int = int(this.ends.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            if(this.ends[_loc5_] == param1)
            {
               ++this.counts[_loc5_];
               _loc3_ = true;
               break;
            }
            _loc5_++;
         }
         if(!_loc3_)
         {
            this.ends.push(param1);
            this.counts.push(1);
         }
         this.draw();
      }
   }
}

