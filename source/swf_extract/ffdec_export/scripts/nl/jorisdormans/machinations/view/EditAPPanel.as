package nl.jorisdormans.machinations.view
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import nl.jorisdormans.graph.GraphElement;
   import nl.jorisdormans.machinations.model.ArtificialPlayer;
   import nl.jorisdormans.machinations.model.MachinationsGraph;
   import nl.jorisdormans.phantomGUI.PhantomControl;
   import nl.jorisdormans.phantomGUI.PhantomEditNumberBox;
   import nl.jorisdormans.phantomGUI.PhantomLabel;
   import nl.jorisdormans.phantomGUI.PhantomTextArea;
   
   public class EditAPPanel extends EditNodePanel
   {
      
      private var actionsPerTurn:PhantomEditNumberBox;
      
      private var actionsPerTurnLabel:PhantomLabel;
      
      private var script:PhantomTextArea;
      
      public function EditAPPanel(param1:MachinationsEditView, param2:DisplayObjectContainer, param3:Stage, param4:Number, param5:Number, param6:Number, param7:Number, param8:Boolean = true, param9:Boolean = true)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9,true,false,false);
         this.actionsPerTurnLabel = new PhantomLabel("Actions/turn",this,labelX,controlY);
         this.actionsPerTurn = new PhantomEditNumberBox(1,0,1,this,controlX,controlY,controlNW);
         this.actionsPerTurn.min = 1;
         this.actionsPerTurn.onChange = this.changeValue;
         controlY += 18;
         new PhantomLabel("Script:",this,labelX,controlY);
         controlY += 20;
         this.script = new PhantomTextArea("script",this,labelX,controlY,controlWidth - 8,controlHeight - 4 - controlY);
         this.script.setFont("Courier New",10);
         this.script.onChange = this.changeValue;
      }
      
      override public function get element() : GraphElement
      {
         return super.element;
      }
      
      override public function set element(param1:GraphElement) : void
      {
         super.element = param1;
         if(param1 is ArtificialPlayer)
         {
            this.actionsPerTurn.value = (param1 as ArtificialPlayer).actionsPerTurn;
            this.script.caption = (param1 as ArtificialPlayer).script;
            if((param1.graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_TURN_BASED)
            {
               this.actionsPerTurnLabel.enabled = true;
               this.actionsPerTurn.enabled = true;
            }
            else
            {
               this.actionsPerTurnLabel.enabled = false;
               this.actionsPerTurn.enabled = false;
            }
         }
      }
      
      override protected function changeValue(param1:PhantomControl) : void
      {
         if(param1 == this.actionsPerTurn)
         {
            view.setValue("actionsPerTurn",null,this.actionsPerTurn.value);
         }
         else if(param1 == this.script)
         {
            view.setValue("script",this.script.caption,0);
         }
         else
         {
            super.changeValue(param1);
         }
      }
   }
}

