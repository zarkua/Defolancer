package nl.jorisdormans.machinations.view
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import nl.jorisdormans.graph.GraphElement;
   import nl.jorisdormans.machinations.model.Source;
   import nl.jorisdormans.phantomGUI.PhantomControl;
   import nl.jorisdormans.phantomGUI.PhantomEditBox;
   import nl.jorisdormans.phantomGUI.PhantomLabel;
   import nl.jorisdormans.utils.StringUtil;
   
   public class EditSourcePanel extends EditNodePanel
   {
      
      private var resourceColor:PhantomEditBox;
      
      public function EditSourcePanel(param1:MachinationsEditView, param2:DisplayObjectContainer, param3:Stage, param4:Number, param5:Number, param6:Number, param7:Number, param8:Boolean = true, param9:Boolean = true)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9);
         new PhantomLabel("Resources",this,labelX,controlY);
         this.resourceColor = new PhantomEditBox("Color",this,controlX,controlY,controlW);
         this.resourceColor.onChange = this.changeValue;
         controlY += 28;
      }
      
      override public function get element() : GraphElement
      {
         return super.element;
      }
      
      override public function set element(param1:GraphElement) : void
      {
         super.element = param1;
         if(param1 is Source)
         {
            this.resourceColor.caption = StringUtil.toColorString((param1 as Source).resourceColor);
         }
      }
      
      override protected function changeValue(param1:PhantomControl) : void
      {
         if(param1 == this.resourceColor)
         {
            view.setValue("resourceColor",this.resourceColor.caption,0);
         }
         else
         {
            super.changeValue(param1);
         }
      }
   }
}

