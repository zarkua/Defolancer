package nl.jorisdormans.machinations.view
{
   import flash.display.DisplayObjectContainer;
   import nl.jorisdormans.graph.GraphElement;
   import nl.jorisdormans.machinations.model.Label;
   import nl.jorisdormans.machinations.model.MachinationsConnection;
   import nl.jorisdormans.phantomGUI.PhantomControl;
   import nl.jorisdormans.phantomGUI.PhantomEditBox;
   import nl.jorisdormans.phantomGUI.PhantomEditNumberBox;
   import nl.jorisdormans.phantomGUI.PhantomLabel;
   
   public class EditConnectionPanel extends EditElementPanel
   {
      
      private var label:PhantomEditBox;
      
      private var min:PhantomEditNumberBox;
      
      private var max:PhantomEditNumberBox;
      
      public function EditConnectionPanel(param1:MachinationsEditView, param2:DisplayObjectContainer, param3:Number, param4:Number, param5:Number, param6:Number, param7:Boolean = true, param8:Boolean = true)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8);
         new PhantomLabel("Label",this,labelX,controlY);
         this.label = new PhantomEditBox("Label",this,controlX,controlY,controlW);
         this.label.onChange = this.changeValue;
         controlY += 28;
         new PhantomLabel("Min. Value",this,labelX,controlY);
         this.min = new PhantomEditNumberBox(-Label.LIMIT,2,100,this,controlX,controlY,controlNW);
         this.min.min = -Label.LIMIT;
         this.min.max = Label.LIMIT;
         this.min.onChange = this.changeValue;
         controlY += 28;
         new PhantomLabel("Max. Value",this,labelX,controlY);
         this.max = new PhantomEditNumberBox(Label.LIMIT,2,100,this,controlX,controlY,controlNW);
         this.max.onChange = this.changeValue;
         this.max.min = -Label.LIMIT;
         this.max.max = Label.LIMIT;
         controlY += 28;
         new PhantomLabel("Press W to add way points",this,labelX,controlY,180);
         controlY += 28;
      }
      
      override public function get element() : GraphElement
      {
         return super.element;
      }
      
      override public function set element(param1:GraphElement) : void
      {
         super.element = param1;
         if(param1 is MachinationsConnection)
         {
            this.label.caption = (param1 as MachinationsConnection).label.getRealText();
            this.min.value = (param1 as MachinationsConnection).label.min;
            this.max.value = (param1 as MachinationsConnection).label.max;
         }
      }
      
      override protected function changeValue(param1:PhantomControl) : void
      {
         if(param1 == this.label)
         {
            view.setValue("label",this.label.caption,0);
         }
         else if(param1 == this.min)
         {
            view.setValue("min","",this.min.value);
         }
         else if(param1 == this.max)
         {
            view.setValue("max","",this.max.value);
         }
         else
         {
            super.changeValue(param1);
         }
      }
   }
}

