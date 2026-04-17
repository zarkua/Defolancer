package nl.jorisdormans.machinations.view
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import nl.jorisdormans.machinations.model.MachinationsGraph;
   import nl.jorisdormans.phantomGUI.PhantomCheckButton;
   import nl.jorisdormans.phantomGUI.PhantomComboBox;
   import nl.jorisdormans.phantomGUI.PhantomControl;
   import nl.jorisdormans.phantomGUI.PhantomEditBox;
   import nl.jorisdormans.phantomGUI.PhantomEditNumberBox;
   import nl.jorisdormans.phantomGUI.PhantomLabel;
   import nl.jorisdormans.phantomGUI.PhantomPanel;
   
   public class EditGraphPanel extends PhantomPanel
   {
      
      private var _graph:MachinationsGraph;
      
      private var graphName:PhantomEditBox;
      
      private var author:PhantomEditBox;
      
      private var actions:PhantomEditNumberBox;
      
      private var dice:PhantomEditBox;
      
      private var skill:PhantomEditBox;
      
      private var multiplayer:PhantomEditBox;
      
      private var strategy:PhantomEditBox;
      
      private var editWidth:PhantomEditNumberBox;
      
      private var editHeight:PhantomEditNumberBox;
      
      private var interval:PhantomEditNumberBox;
      
      private var intervalLabel:PhantomLabel;
      
      private var actionsLabel:PhantomLabel;
      
      private var timeMode:PhantomComboBox;
      
      private var distributionMode:PhantomComboBox;
      
      private var colorCoded:PhantomCheckButton;
      
      protected var labelX:Number;
      
      protected var controlX:Number;
      
      protected var controlY:Number;
      
      protected var controlW:Number;
      
      protected var controlNW:Number;
      
      private var view:MachinationsEditView;
      
      public function EditGraphPanel(param1:DisplayObjectContainer, param2:Stage, param3:MachinationsEditView, param4:Number, param5:Number, param6:Number, param7:Number, param8:Boolean = true, param9:Boolean = true)
      {
         super(param1,param4,param5,param6,param7,param8,param9);
         this.view = param3;
         this.labelX = 4;
         this.controlX = param6 * 0.4;
         this.controlY = 2;
         this.controlW = param6 - this.controlX - 4;
         this.controlNW = 60;
         var _loc10_:int = 27;
         new PhantomLabel("*Machinations Diagram",this,this.labelX,this.controlY);
         this.controlY += 24;
         new PhantomLabel("Name",this,this.labelX,this.controlY);
         this.graphName = new PhantomEditBox("Name",this,this.controlX,this.controlY,this.controlW);
         this.graphName.onChange = this.changeValue;
         this.controlY += _loc10_;
         new PhantomLabel("Author",this,this.labelX,this.controlY);
         this.author = new PhantomEditBox("Author",this,this.controlX,this.controlY,this.controlW);
         this.author.onChange = this.changeValue;
         this.controlY += _loc10_;
         new PhantomLabel("Time Mode",this,this.labelX,this.controlY);
         this.timeMode = new PhantomComboBox("timeMode",this,param2,this.controlX,this.controlY,this.controlW);
         this.timeMode.addOption(MachinationsGraph.TIME_MODE_ASYNCHRONOUS);
         this.timeMode.addOption(MachinationsGraph.TIME_MODE_SYNCHRONOUS);
         this.timeMode.addOption(MachinationsGraph.TIME_MODE_TURN_BASED);
         this.timeMode.onChange = this.changeValue;
         this.controlY += _loc10_;
         this.intervalLabel = new PhantomLabel("Interval",this,this.labelX,this.controlY);
         this.interval = new PhantomEditNumberBox(100,1,0.1,this,this.controlX,this.controlY,this.controlNW);
         this.interval.min = 0.1;
         this.interval.onChange = this.changeValue;
         this.actionsLabel = new PhantomLabel("Actions/Turn",this,this.labelX,this.controlY,100);
         this.actionsLabel.visible = false;
         this.actions = new PhantomEditNumberBox(1,0,1,this,this.controlX,this.controlY,this.controlNW);
         this.actions.min = 1;
         this.actions.onChange = this.changeValue;
         this.actions.visible = false;
         this.controlY += _loc10_;
         new PhantomLabel("Distribution",this,this.labelX,this.controlY);
         this.distributionMode = new PhantomComboBox("distribution",this,param2,this.controlX,this.controlY,this.controlW);
         this.distributionMode.addOption(MachinationsGraph.DISTRIBUTION_MODE_FIXED_SPEED);
         this.distributionMode.addOption(MachinationsGraph.DISTRIBUTION_MODE_INSTANTANEOUS);
         this.distributionMode.onChange = this.changeValue;
         this.controlY += _loc10_;
         new PhantomLabel("Color Coding",this,this.labelX,this.controlY);
         this.colorCoded = new PhantomCheckButton("Color Coded",this.changeValue,this,this.controlX,this.controlY,this.controlW,24);
         this.controlY += _loc10_;
         new PhantomLabel("Dice",this,this.labelX,this.controlY);
         this.dice = new PhantomEditBox("Dice",this,this.controlX,this.controlY,this.controlW);
         this.dice.onChange = this.changeValue;
         this.controlY += _loc10_;
         new PhantomLabel("Skill",this,this.labelX,this.controlY);
         this.skill = new PhantomEditBox("Skill",this,this.controlX,this.controlY,this.controlW);
         this.skill.onChange = this.changeValue;
         this.controlY += _loc10_;
         new PhantomLabel("Multiplayer",this,this.labelX,this.controlY);
         this.multiplayer = new PhantomEditBox("Multiplayer",this,this.controlX,this.controlY,this.controlW);
         this.multiplayer.onChange = this.changeValue;
         this.controlY += _loc10_;
         new PhantomLabel("Strategy",this,this.labelX,this.controlY);
         this.strategy = new PhantomEditBox("Strategy",this,this.controlX,this.controlY,this.controlW);
         this.strategy.onChange = this.changeValue;
         this.controlY += _loc10_;
         new PhantomLabel("Width",this,this.labelX,this.controlY);
         this.editWidth = new PhantomEditNumberBox(100,0,100,this,this.controlX,this.controlY,this.controlNW);
         this.editWidth.min = 0;
         this.editWidth.onChange = this.changeValue;
         this.controlY += _loc10_;
         new PhantomLabel("Height",this,this.labelX,this.controlY);
         this.editHeight = new PhantomEditNumberBox(100,0,100,this,this.controlX,this.controlY,this.controlNW);
         this.editHeight.min = 0;
         this.editHeight.onChange = this.changeValue;
         this.controlY += _loc10_;
      }
      
      public function get graph() : MachinationsGraph
      {
         return this._graph;
      }
      
      public function set graph(param1:MachinationsGraph) : void
      {
         var _loc2_:Boolean = false;
         this._graph = param1;
         if(this._graph)
         {
            this.graphName.caption = this._graph.name;
            this.author.caption = this._graph.author;
            this.dice.caption = this._graph.dice;
            this.skill.caption = this._graph.skill;
            this.strategy.caption = this._graph.strategy;
            this.multiplayer.caption = this._graph.multiplayer;
            this.interval.value = this._graph.fireInterval;
            this.timeMode.findOption(this._graph.timeMode);
            this.distributionMode.findOption(this._graph.distributionMode);
            this.actions.value = this._graph.actionsPerTurn;
            this.editWidth.value = this._graph.width;
            this.editHeight.value = this._graph.height;
            this.colorCoded.checked = this.graph.colorCoding == 1;
            _loc2_ = this._graph.timeMode == MachinationsGraph.TIME_MODE_TURN_BASED;
            this.actions.visible = _loc2_;
            this.actionsLabel.visible = _loc2_;
            this.interval.visible = !_loc2_;
            this.intervalLabel.visible = !_loc2_;
         }
      }
      
      protected function changeValue(param1:PhantomControl) : void
      {
         var _loc2_:Boolean = false;
         if(this._graph)
         {
            this._graph.name = this.graphName.caption;
            this._graph.author = this.author.caption;
            this._graph.dice = this.dice.caption;
            this._graph.skill = this.skill.caption;
            this._graph.strategy = this.strategy.caption;
            this._graph.multiplayer = this.multiplayer.caption;
            this._graph.fireInterval = this.interval.value;
            this._graph.timeMode = this.timeMode.caption;
            this._graph.distributionMode = this.distributionMode.caption;
            this._graph.actionsPerTurn = this.actions.value;
            this._graph.width = this.editWidth.value;
            this._graph.height = this.editHeight.value;
            this._graph.colorCoding = this.colorCoded.checked ? 1 : 0;
            if(param1 == this.editWidth || param1 == this.editHeight)
            {
               this.view.changeSize();
            }
            _loc2_ = this._graph.timeMode == MachinationsGraph.TIME_MODE_TURN_BASED;
            this.actions.visible = _loc2_;
            this.actionsLabel.visible = _loc2_;
            this.interval.visible = !_loc2_;
            this.intervalLabel.visible = !_loc2_;
         }
      }
   }
}

