package nl.jorisdormans.machinations.view
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import nl.jorisdormans.graph.GraphElement;
   import nl.jorisdormans.machinations.model.Gate;
   import nl.jorisdormans.phantomGUI.PhantomControl;
   import nl.jorisdormans.phantomGUI.PhantomLabel;
   import nl.jorisdormans.phantomGUI.PhantomToolButton;
   
   public class EditGatePanel extends EditNodePanel
   {
      
      private var deterministic:PhantomToolButton;
      
      private var dice:PhantomToolButton;
      
      private var skill:PhantomToolButton;
      
      private var multiplayer:PhantomToolButton;
      
      private var strategy:PhantomToolButton;
      
      public function EditGatePanel(param1:MachinationsEditView, param2:DisplayObjectContainer, param3:Stage, param4:Number, param5:Number, param6:Number, param7:Number, param8:Boolean = true, param9:Boolean = true)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9);
         new PhantomLabel("Type",this,labelX,controlY);
         this.deterministic = new PhantomToolButton("Deterministic",this.changeValue,this,controlX,controlY,24,24,false);
         this.deterministic.drawImage = MachinationsDraw.drawGateGlyph;
         this.dice = new PhantomToolButton("Dice",this.changeValue,this,controlX + 28,controlY,24,24,false);
         this.dice.drawImage = MachinationsDraw.drawDice;
         this.skill = new PhantomToolButton("Skill",this.changeValue,this,controlX + 28 * 2,controlY,24,24,false);
         this.skill.drawImage = MachinationsDraw.drawSkill;
         controlY += 28;
         this.multiplayer = new PhantomToolButton("Multiplayer",this.changeValue,this,controlX,controlY,24,24,false);
         this.multiplayer.drawImage = MachinationsDraw.drawMultiplayer;
         this.strategy = new PhantomToolButton("Strategy",this.changeValue,this,controlX + 28 * 1,controlY,24,24,false);
         this.strategy.drawImage = MachinationsDraw.drawStrategy;
         controlY += 28;
      }
      
      override public function get element() : GraphElement
      {
         return super.element;
      }
      
      override public function set element(param1:GraphElement) : void
      {
         super.element = param1;
         if(param1 is Gate)
         {
            this.deterministic.selected = (param1 as Gate).gateType == Gate.GATE_DETERMINISTIC;
            this.dice.selected = (param1 as Gate).gateType == Gate.GATE_DICE;
            this.skill.selected = (param1 as Gate).gateType == Gate.GATE_SKILL;
            this.strategy.selected = (param1 as Gate).gateType == Gate.GATE_STRATEGY;
            this.multiplayer.selected = (param1 as Gate).gateType == Gate.GATE_MULTIPLAYER;
         }
      }
      
      override protected function changeValue(param1:PhantomControl) : void
      {
         if(param1 == this.deterministic)
         {
            view.setValue("gateType",Gate.GATE_DETERMINISTIC,0);
         }
         else if(param1 == this.dice)
         {
            view.setValue("gateType",Gate.GATE_DICE,0);
         }
         else if(param1 == this.skill)
         {
            view.setValue("gateType",Gate.GATE_SKILL,0);
         }
         else if(param1 == this.strategy)
         {
            view.setValue("gateType",Gate.GATE_STRATEGY,0);
         }
         else if(param1 == this.multiplayer)
         {
            view.setValue("gateType",Gate.GATE_MULTIPLAYER,0);
         }
         else
         {
            super.changeValue(param1);
         }
      }
   }
}

