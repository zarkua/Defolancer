package
{
   import flash.display.Sprite;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import nl.jorisdormans.machinations.controller.MachinationsController;
   import nl.jorisdormans.machinations.model.MachinationsGraph;
   import nl.jorisdormans.machinations.view.MachinationsEditView;
   import nl.jorisdormans.machinations.view.MachinationsView;
   import nl.jorisdormans.phantomGraphics.PhantomFont;
   
   public class Main extends Sprite
   {
      
      public function Main()
      {
         super();
         if(stage)
         {
            this.init();
         }
         else
         {
            addEventListener(Event.ADDED_TO_STAGE,this.init);
         }
      }
      
      private function init(param1:Event = null) : void
      {
         var _loc2_:MachinationsController = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Boolean = false;
         removeEventListener(Event.ADDED_TO_STAGE,this.init);
         stage.scaleMode = StageScaleMode.SHOW_ALL;
         PhantomFont.createSimpleFont();
         var _loc3_:Boolean = false;
         stage.scaleMode = StageScaleMode.EXACT_FIT;
         if(this.loaderInfo.parameters.mode == "view")
         {
            _loc4_ = 800;
            _loc5_ = 600;
            if(this.loaderInfo.parameters.width != null)
            {
               _loc4_ = Number(this.loaderInfo.parameters.width);
            }
            if(this.loaderInfo.parameters.height != null)
            {
               _loc5_ = Number(this.loaderInfo.parameters.height);
            }
            _loc6_ = false;
            if(this.loaderInfo.parameters.quickrun == "true")
            {
               _loc6_ = true;
            }
            _loc2_ = new MachinationsController(new MachinationsGraph(),new MachinationsView(this,0,0,_loc4_,_loc5_));
            if(_loc6_ || _loc3_)
            {
               _loc2_.view.createQuickRunControls();
            }
            this.scaleX = 800 / _loc4_;
            this.scaleY = 600 / _loc5_;
            if(this.loaderInfo.parameters.start)
            {
               _loc2_.view.runAfterLoad = true;
            }
            if(this.loaderInfo.parameters.file != null && this.loaderInfo.parameters.file != "")
            {
               _loc2_.view.loadGraph(this.loaderInfo.parameters.file);
            }
         }
         else
         {
            _loc2_ = new MachinationsController(new MachinationsGraph(),new MachinationsEditView(this,0,0,800,600));
            if(this.loaderInfo.parameters.start)
            {
               _loc2_.view.runAfterLoad = true;
            }
            if(this.loaderInfo.parameters.file != null && this.loaderInfo.parameters.file != "")
            {
               _loc2_.view.loadGraph(this.loaderInfo.parameters.file);
            }
         }
      }
   }
}

