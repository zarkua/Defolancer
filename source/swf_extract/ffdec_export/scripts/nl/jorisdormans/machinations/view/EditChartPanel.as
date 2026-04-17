package nl.jorisdormans.machinations.view
{
   import flash.display.DisplayObjectContainer;
   import nl.jorisdormans.graph.GraphElement;
   import nl.jorisdormans.machinations.model.Chart;
   import nl.jorisdormans.phantomGUI.PhantomControl;
   import nl.jorisdormans.phantomGUI.PhantomEditNumberBox;
   import nl.jorisdormans.phantomGUI.PhantomLabel;
   
   public class EditChartPanel extends EditLabelPanel
   {
      
      private var defaultScaleX:PhantomEditNumberBox;
      
      private var defaultScaleY:PhantomEditNumberBox;
      
      public function EditChartPanel(param1:MachinationsEditView, param2:DisplayObjectContainer, param3:Number, param4:Number, param5:Number, param6:Number, param7:Boolean = true, param8:Boolean = true)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8);
         new PhantomLabel("Scale X",this,labelX,controlY);
         this.defaultScaleX = new PhantomEditNumberBox(0,0,10,this,controlX,controlY,controlNW);
         this.defaultScaleX.min = 0;
         this.defaultScaleX.onChange = this.changeValue;
         controlY += 28;
         new PhantomLabel("Scale Y",this,labelX,controlY);
         this.defaultScaleY = new PhantomEditNumberBox(0,0,12,this,controlX,controlY,controlNW);
         this.defaultScaleY.onChange = this.changeValue;
         controlY += 28;
      }
      
      override public function get element() : GraphElement
      {
         return super.element;
      }
      
      override public function set element(param1:GraphElement) : void
      {
         super.element = param1;
         if(param1 is Chart)
         {
            this.defaultScaleX.value = (param1 as Chart).defaultScaleX;
            this.defaultScaleY.value = (param1 as Chart).defaultScaleY;
         }
      }
      
      override protected function changeValue(param1:PhantomControl) : void
      {
         if(param1 == this.defaultScaleX)
         {
            view.setValue("defaultScaleX",null,this.defaultScaleX.value);
         }
         else if(param1 == this.defaultScaleY)
         {
            view.setValue("defaultScaleY",null,this.defaultScaleY.value);
         }
         else
         {
            super.changeValue(param1);
         }
      }
   }
}

