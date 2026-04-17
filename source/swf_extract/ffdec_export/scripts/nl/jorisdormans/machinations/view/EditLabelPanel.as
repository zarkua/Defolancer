package nl.jorisdormans.machinations.view
{
   import flash.display.DisplayObjectContainer;
   import nl.jorisdormans.graph.GraphElement;
   import nl.jorisdormans.machinations.model.MachinationsNode;
   import nl.jorisdormans.phantomGUI.PhantomControl;
   import nl.jorisdormans.phantomGUI.PhantomEditBox;
   import nl.jorisdormans.phantomGUI.PhantomLabel;
   
   public class EditLabelPanel extends EditElementPanel
   {
      
      private var label:PhantomEditBox;
      
      public function EditLabelPanel(param1:MachinationsEditView, param2:DisplayObjectContainer, param3:Number, param4:Number, param5:Number, param6:Number, param7:Boolean = true, param8:Boolean = true)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,true);
         new PhantomLabel("Label",this,labelX,controlY);
         this.label = new PhantomEditBox("Label",this,controlX,controlY,controlW);
         this.label.onChange = this.changeValue;
         controlY += 28;
      }
      
      override public function get element() : GraphElement
      {
         return super.element;
      }
      
      override public function set element(param1:GraphElement) : void
      {
         super.element = param1;
         if(param1 is MachinationsNode)
         {
            this.label.caption = (param1 as MachinationsNode).caption;
         }
      }
      
      override protected function changeValue(param1:PhantomControl) : void
      {
         if(param1 == this.label)
         {
            view.setValue("label",this.label.caption,0);
         }
         else
         {
            super.changeValue(param1);
         }
      }
   }
}

