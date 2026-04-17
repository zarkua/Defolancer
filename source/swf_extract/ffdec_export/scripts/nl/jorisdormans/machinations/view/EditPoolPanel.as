package nl.jorisdormans.machinations.view
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import nl.jorisdormans.graph.GraphElement;
   import nl.jorisdormans.machinations.model.Pool;
   import nl.jorisdormans.phantomGUI.PhantomControl;
   import nl.jorisdormans.phantomGUI.PhantomEditNumberBox;
   import nl.jorisdormans.phantomGUI.PhantomLabel;
   
   public class EditPoolPanel extends EditSourcePanel
   {
      
      private var number:PhantomEditNumberBox;
      
      private var max:PhantomEditNumberBox;
      
      private var tokenLimit:PhantomEditNumberBox;
      
      public function EditPoolPanel(param1:MachinationsEditView, param2:DisplayObjectContainer, param3:Stage, param4:Number, param5:Number, param6:Number, param7:Number, param8:Boolean = true, param9:Boolean = true)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9);
         new PhantomLabel("Number",this,labelX,controlY);
         this.number = new PhantomEditNumberBox(0,0,1,this,controlX,controlY,controlNW);
         this.number.min = 0;
         this.number.max = 9999;
         this.number.onChange = this.changeValue;
         controlY += 28;
         new PhantomLabel("Capacity",this,labelX,controlY);
         this.max = new PhantomEditNumberBox(0,0,1,this,controlX,controlY,controlNW);
         this.max.min = -1;
         this.max.max = 9999;
         this.max.onChange = this.changeValue;
         controlY += 28;
         new PhantomLabel("Display Cap.",this,labelX,controlY);
         this.tokenLimit = new PhantomEditNumberBox(0,0,5,this,controlX,controlY,controlNW);
         this.tokenLimit.min = -1;
         this.tokenLimit.max = 25;
         this.tokenLimit.onChange = this.changeValue;
         controlY += 28;
      }
      
      override public function get element() : GraphElement
      {
         return super.element;
      }
      
      override public function set element(param1:GraphElement) : void
      {
         super.element = param1;
         if(param1 is Pool)
         {
            this.number.value = (param1 as Pool).startingResources;
            this.max.value = (param1 as Pool).capacity;
            this.tokenLimit.value = (param1 as Pool).displayCapacity;
         }
      }
      
      override protected function changeValue(param1:PhantomControl) : void
      {
         if(param1 == this.number)
         {
            view.setValue("startingResources",null,this.number.value);
         }
         else if(param1 == this.max)
         {
            view.setValue("capacity",null,this.max.value);
         }
         else if(param1 == this.tokenLimit)
         {
            view.setValue("displayCapacity",null,this.tokenLimit.value);
         }
         else
         {
            super.changeValue(param1);
         }
      }
   }
}

