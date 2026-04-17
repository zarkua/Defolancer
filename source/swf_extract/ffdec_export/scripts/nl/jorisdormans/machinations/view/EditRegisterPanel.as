package nl.jorisdormans.machinations.view
{
   import flash.display.DisplayObjectContainer;
   import nl.jorisdormans.graph.GraphElement;
   import nl.jorisdormans.machinations.model.Label;
   import nl.jorisdormans.machinations.model.MachinationsNode;
   import nl.jorisdormans.machinations.model.Register;
   import nl.jorisdormans.phantomGUI.PhantomCheckButton;
   import nl.jorisdormans.phantomGUI.PhantomControl;
   import nl.jorisdormans.phantomGUI.PhantomEditBox;
   import nl.jorisdormans.phantomGUI.PhantomEditNumberBox;
   import nl.jorisdormans.phantomGUI.PhantomLabel;
   
   public class EditRegisterPanel extends EditElementPanel
   {
      
      private var formulaLabel:PhantomLabel;
      
      private var label:PhantomEditBox;
      
      private var start:PhantomEditNumberBox;
      
      private var step:PhantomEditNumberBox;
      
      private var startLabel:PhantomLabel;
      
      private var stepLabel:PhantomLabel;
      
      private var interactive:PhantomCheckButton;
      
      private var min:PhantomEditNumberBox;
      
      private var max:PhantomEditNumberBox;
      
      public function EditRegisterPanel(param1:MachinationsEditView, param2:DisplayObjectContainer, param3:Number, param4:Number, param5:Number, param6:Number, param7:Boolean = true, param8:Boolean = true)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8);
         this.formulaLabel = new PhantomLabel("Formula",this,labelX,controlY);
         this.label = new PhantomEditBox("Label",this,controlX,controlY,controlW);
         this.label.onChange = this.changeValue;
         controlY += 28;
         new PhantomLabel("Min. Value",this,labelX,controlY);
         this.min = new PhantomEditNumberBox(-Register.LIMIT,0,100,this,controlX,controlY,controlNW);
         this.min.min = -Label.LIMIT;
         this.min.max = Label.LIMIT;
         this.min.onChange = this.changeValue;
         controlY += 28;
         new PhantomLabel("Max. Value",this,labelX,controlY);
         this.max = new PhantomEditNumberBox(Register.LIMIT,0,100,this,controlX,controlY,controlNW);
         this.max.onChange = this.changeValue;
         this.max.min = -Label.LIMIT;
         this.max.max = Label.LIMIT;
         controlY += 28;
         this.interactive = new PhantomCheckButton("Interactive",this.changeValue,this,controlX,controlY,controlW,24);
         controlY += 28;
         this.startLabel = new PhantomLabel("Starting Value",this,labelX,controlY);
         this.start = new PhantomEditNumberBox(0,0,1,this,controlX,controlY,controlNW);
         this.start.min = -Label.LIMIT;
         this.start.max = Label.LIMIT;
         this.start.onChange = this.changeValue;
         controlY += 28;
         this.stepLabel = new PhantomLabel("Step",this,labelX,controlY);
         this.step = new PhantomEditNumberBox(1,0,1,this,controlX,controlY,controlNW);
         this.step.min = -Label.LIMIT;
         this.step.max = Label.LIMIT;
         this.step.onChange = this.changeValue;
         controlY += 28;
      }
      
      override public function get element() : GraphElement
      {
         return super.element;
      }
      
      override public function set element(param1:GraphElement) : void
      {
         super.element = param1;
         if(param1 is Register)
         {
            this.label.caption = (param1 as Register).caption;
            this.min.value = (param1 as Register).minValue;
            this.max.value = (param1 as Register).maxValue;
            this.start.value = (param1 as Register).startValue;
            this.step.value = (param1 as Register).valueStep;
            this.interactive.checked = (param1 as Register).activationMode == MachinationsNode.MODE_INTERACTIVE;
            this.start.enabled = this.interactive.checked;
            this.step.enabled = this.interactive.checked;
            this.startLabel.enabled = this.interactive.checked;
            this.stepLabel.enabled = this.interactive.checked;
            if((param1 as Register).activationMode == MachinationsNode.MODE_INTERACTIVE)
            {
               this.formulaLabel.caption = "Label";
            }
            else
            {
               this.formulaLabel.caption = "Formula";
            }
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
         else if(param1 == this.start)
         {
            view.setValue("start","",this.start.value);
         }
         else if(param1 == this.step)
         {
            view.setValue("step","",this.step.value);
         }
         else if(param1 == this.interactive)
         {
            if(this.interactive.checked)
            {
               view.setValue("activationMode",MachinationsNode.MODE_INTERACTIVE,0);
               this.formulaLabel.caption = "Label";
            }
            else
            {
               view.setValue("activationMode",MachinationsNode.MODE_PASSIVE,0);
               this.formulaLabel.caption = "Formula";
            }
            this.start.enabled = this.interactive.checked;
            this.step.enabled = this.interactive.checked;
            this.startLabel.enabled = this.interactive.checked;
            this.stepLabel.enabled = this.interactive.checked;
         }
         else
         {
            super.changeValue(param1);
         }
      }
   }
}

