package nl.jorisdormans.machinations.view
{
   import flash.display.DisplayObjectContainer;
   import flash.events.MouseEvent;
   import nl.jorisdormans.graph.GraphEvent;
   import nl.jorisdormans.machinations.model.ArtificialPlayer;
   import nl.jorisdormans.machinations.model.Chart;
   import nl.jorisdormans.machinations.model.MachinationsGraph;
   import nl.jorisdormans.machinations.model.MachinationsNode;
   import nl.jorisdormans.machinations.model.Register;
   import nl.jorisdormans.phantomGUI.PhantomBorder;
   import nl.jorisdormans.phantomGUI.PhantomButton;
   import nl.jorisdormans.phantomGUI.PhantomControl;
   import nl.jorisdormans.phantomGUI.PhantomDrawPanel;
   import nl.jorisdormans.phantomGUI.PhantomGlyph;
   import nl.jorisdormans.phantomGUI.PhantomLabel;
   import nl.jorisdormans.phantomGUI.PhantomPanel;
   import nl.jorisdormans.phantomGUI.PhantomToolTip;
   import nl.jorisdormans.utils.FileIO;
   
   public class MachinationsView extends PhantomBorder
   {
      
      protected static const topPanelHeight:Number = 34;
      
      private var title:PhantomLabel;
      
      private var data:PhantomLabel;
      
      public var drawPanel:PhantomDrawPanel;
      
      public var drawContainer:PhantomPanel;
      
      protected var _graph:MachinationsGraph;
      
      protected var _elements:Vector.<MachinationsViewElement>;
      
      protected var selectAddedElements:Boolean = false;
      
      protected var topBorder:PhantomBorder;
      
      protected var topPanel:PhantomPanel;
      
      public var runButton:PhantomButton;
      
      public var quickRun:PhantomButton;
      
      public var multipleRuns:PhantomButton;
      
      public var runAfterLoad:Boolean;
      
      protected var _zoomed:Boolean = false;
      
      protected var _hover:MachinationsViewElement = null;
      
      protected var fileIO:FileIO;
      
      private var toolTip:PhantomToolTip;
      
      private var popup:PopUp;
      
      public function MachinationsView(param1:DisplayObjectContainer, param2:Number, param3:Number, param4:Number, param5:Number)
      {
         super(param1,param2,param3,param4 - 2,param5 - topPanelHeight - 2);
         this._elements = new Vector.<MachinationsViewElement>();
         this.createControls();
         this.fileIO = new FileIO();
         this.runAfterLoad = false;
      }
      
      protected function createControls() : void
      {
         this.drawContainer = new PhantomPanel(this,2,2,this._controlWidth - 4,this._controlHeight - 4);
         this.drawPanel = new PhantomDrawPanel(this.drawContainer,0,0,this._controlWidth - 4,this._controlHeight - 4);
         this.drawPanel.background = 16777215;
         this.drawPanel.foreground = 12303325;
         this.drawPanel.gridX = 0;
         this.drawPanel.gridY = 0;
         this.drawPanel.draw();
         this.drawPanel.mouseChildren = false;
         this.topBorder = new PhantomBorder(parent,x,y + _controlHeight,_controlWidth,topPanelHeight + 2);
         this.topPanel = new PhantomPanel(this.topBorder,2,0,_controlWidth - 4,topPanelHeight);
         this.runButton = new PhantomButton("Run (R)",this.run,this.topPanel,4,4,88,24);
         this.runButton.glyph = PhantomGlyph.PLAY;
         this.title = new PhantomLabel("*title",this.topPanel,92,-2,_controlWidth - 100);
         this.data = new PhantomLabel("data",this.topPanel,92,14,_controlWidth - 100);
         this.title.caption = "Loading file...";
         this.data.caption = "...";
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownView);
         addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveView);
      }
      
      protected function onMouseDownView(param1:MouseEvent) : void
      {
         var _loc2_:ArtificialPlayer = null;
         if(Boolean(this.hover) && this.hover.element is ArtificialPlayer)
         {
            _loc2_ = this.hover.element as ArtificialPlayer;
            switch(_loc2_.activationMode)
            {
               case MachinationsNode.MODE_AUTOMATIC:
                  _loc2_.activationMode = MachinationsNode.MODE_PASSIVE;
                  break;
               case MachinationsNode.MODE_PASSIVE:
                  _loc2_.activationMode = MachinationsNode.MODE_AUTOMATIC;
            }
            this.hover.draw();
         }
         if(Boolean(this.hover) && this.hover.element is Chart)
         {
            this.clickChartButtons(this.hover.element as Chart,param1);
         }
         if(Boolean(this.hover) && Boolean(this.hover.element is MachinationsNode) && (this.hover.element as MachinationsNode).activationMode == MachinationsNode.MODE_INTERACTIVE)
         {
            if((this.hover.element as MachinationsNode).inhibited)
            {
               this.hover = null;
               return;
            }
            if(this.hover.element is Register)
            {
               if(param1.localY > (this.hover.element as Register).position.y)
               {
                  (this.hover.element as Register).interaction -= (this.hover.element as Register).valueStep;
               }
               else
               {
                  (this.hover.element as Register).interaction += (this.hover.element as Register).valueStep;
               }
            }
            (this.hover.element as MachinationsNode).click();
         }
      }
      
      protected function onMouseMoveView(param1:MouseEvent) : void
      {
         if(this.toolTip != null)
         {
            this.toolTip.dispose();
            this.toolTip = null;
         }
         var _loc2_:MachinationsViewElement = this.getElementAt(param1.localX,param1.localY);
         var _loc3_:MachinationsViewElement = null;
         if(_loc2_)
         {
            if(_loc2_.pinsOnly)
            {
               _loc3_ = _loc2_;
            }
            if(this.graph.running && !this.graph.ended)
            {
               if(_loc2_.element is MachinationsNode && (_loc2_.element as MachinationsNode).activationMode == MachinationsNode.MODE_INTERACTIVE && !(_loc2_.element as MachinationsNode).inhibited)
               {
                  _loc3_ = _loc2_;
               }
               if(_loc2_.element is ArtificialPlayer && ((_loc2_.element as ArtificialPlayer).activationMode == MachinationsNode.MODE_PASSIVE || (_loc2_.element as ArtificialPlayer).activationMode == MachinationsNode.MODE_AUTOMATIC))
               {
                  _loc3_ = _loc2_;
               }
            }
            else
            {
               if(_loc2_.element is ArtificialPlayer)
               {
                  _loc3_ = _loc2_;
                  this.toolTip = new PhantomToolTip((_loc2_.element as ArtificialPlayer).script,this);
               }
               if(_loc2_.element is Chart && this.checkChartButtons(_loc2_.element as Chart,param1))
               {
                  _loc3_ = _loc2_;
               }
            }
         }
         this.hover = _loc3_;
         if(Boolean(_loc3_) && _loc3_.element is MachinationsNode)
         {
            buttonMode = true;
         }
         else
         {
            buttonMode = false;
         }
      }
      
      public function createQuickRunControls() : void
      {
         this.quickRun = new PhantomButton("Quick Run",this.startQuickRun,this.topPanel,_controlWidth - 200,4,88,24);
         this.multipleRuns = new PhantomButton("Multiple Runs",this.startMultipleRuns,this.topPanel,_controlWidth - 100,4,88,24);
      }
      
      public function get hover() : MachinationsViewElement
      {
         return this._hover;
      }
      
      public function set hover(param1:MachinationsViewElement) : void
      {
         if(this._hover)
         {
            this._hover.hovering = false;
         }
         this._hover = param1;
         if(this._hover)
         {
            this._hover.hovering = true;
         }
      }
      
      public function get graph() : MachinationsGraph
      {
         return this._graph;
      }
      
      public function set graph(param1:MachinationsGraph) : void
      {
         if(this._graph != null)
         {
            this._graph.removeEventListener(GraphEvent.ELEMENT_ADD,this.onElementAdd);
            this._graph.removeEventListener(GraphEvent.GRAPH_WARNING,this.onWarning);
            this._graph.removeEventListener(GraphEvent.GRAPH_ERROR,this.onError);
         }
         this._graph = param1;
         if(this._graph != null)
         {
            this._graph.addEventListener(GraphEvent.ELEMENT_ADD,this.onElementAdd);
            this._graph.addEventListener(GraphEvent.GRAPH_WARNING,this.onWarning);
            this._graph.addEventListener(GraphEvent.GRAPH_ERROR,this.onError);
         }
      }
      
      private function onElementAdd(param1:GraphEvent) : void
      {
         this._elements.push(new MachinationsViewElement(this.drawPanel,param1.element));
         if(this.selectAddedElements)
         {
            this._elements[this._elements.length - 1].selected = true;
         }
      }
      
      public function getElementAt(param1:Number, param2:Number, param3:MachinationsViewElement = null) : MachinationsViewElement
      {
         var _loc4_:int = int(this._elements.length);
         var _loc5_:* = int(_loc4_ - 1);
         while(_loc5_ >= 0)
         {
            if(this._elements[_loc5_] != param3 && this._elements[_loc5_].pointInElement(param1,param2))
            {
               return this._elements[_loc5_];
            }
            _loc5_--;
         }
         return null;
      }
      
      public function removeElement(param1:MachinationsViewElement) : void
      {
         this.drawPanel.removeChild(param1);
         var _loc2_:int = int(this._elements.length);
         var _loc3_:* = int(_loc2_ - 1);
         while(_loc3_ >= 0)
         {
            if(this._elements[_loc3_] == param1)
            {
               this._elements.splice(_loc3_,1);
            }
            _loc3_--;
         }
      }
      
      public function onLoadGraph() : void
      {
         var _loc1_:String = null;
         this.graph.readXML(this.fileIO.data);
         this.graph = this.graph;
         if(this.title)
         {
            this.title.caption = this.graph.name;
         }
         if(this.data)
         {
            _loc1_ = "";
            if(this.graph.author != "")
            {
               _loc1_ += "by: " + this.graph.author;
            }
            if(this.graph.dice != "" && this.graph.dice != "D6")
            {
               _loc1_ += ", dice: " + this.graph.dice;
            }
            if(this.graph.skill != "")
            {
               _loc1_ += ", skill: " + this.graph.skill;
            }
            if(this.graph.strategy != "")
            {
               _loc1_ += ", strategy: " + this.graph.strategy;
            }
            if(this.graph.multiplayer != "")
            {
               _loc1_ += ", multiplayer: " + this.graph.multiplayer;
            }
            if(this.graph.timeMode == MachinationsGraph.TIME_MODE_TURN_BASED)
            {
               if(this.graph.actionsPerTurn > 1)
               {
                  _loc1_ += ", actions: " + this.graph.actionsPerTurn.toString() + " per turn";
               }
               if(this.graph.actionsPerTurn == 1)
               {
                  _loc1_ += ", actions: 1 per turn";
               }
            }
            if(_loc1_.charAt(0) == ",")
            {
               _loc1_ = _loc1_.substr(2);
            }
            this.data.caption = _loc1_;
         }
         this.changeSize();
         if(this.runAfterLoad)
         {
            this.run(null);
         }
      }
      
      public function loadGraph(param1:String) : void
      {
         this.fileIO.onLoadComplete = this.onLoadGraph;
         this.fileIO.openFile(param1);
      }
      
      public function setInteraction(param1:Boolean) : void
      {
      }
      
      public function refresh() : void
      {
         var _loc1_:int = int(this._elements.length);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            this._elements[_loc2_].draw();
            _loc2_++;
         }
      }
      
      protected function checkChartButtons(param1:Chart, param2:MouseEvent) : Boolean
      {
         if(param1.clickClear(param2.localX,param2.localY))
         {
            return true;
         }
         if(param1.clickNext(param2.localX,param2.localY))
         {
            return true;
         }
         if(param1.clickPrevious(param2.localX,param2.localY))
         {
            return true;
         }
         if(param1.clickExport(param2.localX,param2.localY))
         {
            return true;
         }
         return false;
      }
      
      protected function clickChartButtons(param1:Chart, param2:MouseEvent) : Boolean
      {
         if(param1.clickClear(param2.localX,param2.localY))
         {
            param1.clear();
            param1.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,param1));
            return true;
         }
         if(param1.clickNext(param2.localX,param2.localY))
         {
            param1.doNext();
            param1.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,param1));
            return true;
         }
         if(param1.clickPrevious(param2.localX,param2.localY))
         {
            param1.doPrevious();
            param1.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,param1));
            return true;
         }
         if(param1.clickExport(param2.localX,param2.localY))
         {
            param1.export();
            return true;
         }
         return false;
      }
      
      public function setControls(param1:Boolean) : void
      {
         this.topPanel.enabled = param1;
      }
      
      protected function run(param1:PhantomButton) : void
      {
         dispatchEvent(new GraphEvent(GraphEvent.GRAPH_RUN));
         if(this.graph.running)
         {
            this.runButton.caption = "Stop (R)";
            this.runButton.glyph = PhantomGlyph.STOP;
            this.setControls(false);
            this.runButton.enabled = true;
         }
         else
         {
            this.runButton.caption = "Run (R)";
            this.runButton.glyph = PhantomGlyph.PLAY;
            this.setControls(true);
         }
      }
      
      protected function startQuickRun(param1:PhantomButton) : void
      {
         dispatchEvent(new GraphEvent(GraphEvent.GRAPH_QUICKRUN));
         if(this.graph.running)
         {
            if(this.graph.ended)
            {
               this.quickRun.caption = "Reset";
            }
            else
            {
               this.quickRun.caption = "Stop";
            }
            this.setControls(false);
            this.quickRun.enabled = true;
         }
         else
         {
            this.quickRun.caption = "Quick Run";
            this.setControls(true);
         }
      }
      
      protected function startMultipleRuns(param1:PhantomButton) : void
      {
         dispatchEvent(new GraphEvent(GraphEvent.GRAPH_MULTIPLERUN));
         if(this.graph.running)
         {
            if(this.graph.ended)
            {
               this.multipleRuns.caption = "Reset";
            }
            else
            {
               this.multipleRuns.caption = "Stop";
            }
            this.setControls(false);
            this.multipleRuns.enabled = true;
         }
         else
         {
            this.multipleRuns.caption = "Multiple Runs";
            this.setControls(true);
         }
      }
      
      public function changeSize() : void
      {
         if(this.graph.width < 600)
         {
            this.graph.width = 600;
         }
         if(this.graph.height < 560)
         {
            this.graph.height = 560;
         }
         this.drawPanel.setSize(this.graph.width,this.graph.height);
         this._zoomed = false;
         this.zoom(null);
      }
      
      protected function zoom(param1:PhantomControl) : void
      {
      }
      
      public function pushToTop(param1:MachinationsViewElement) : void
      {
         var _loc2_:int = int(this._elements.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_ - 1)
         {
            if(this._elements[_loc3_] == param1)
            {
               this._elements.splice(_loc3_,1);
               this._elements.push(param1);
               break;
            }
            _loc3_++;
         }
      }
      
      private function onWarning(param1:GraphEvent) : void
      {
         if(Boolean(this.popup) && Boolean(this.popup.parent))
         {
            this.popup.parent.removeChild(this.popup);
         }
         this.popup = new PopUp(stage,(600 - 300) * 0.5,100,"Warning!",param1.message);
      }
      
      private function onError(param1:GraphEvent) : void
      {
         this.graph.end("Error");
         if(Boolean(this.popup) && Boolean(this.popup.parent))
         {
            this.popup.parent.removeChild(this.popup);
         }
         this.popup = new PopUp(stage,(600 - 300) * 0.5,100,"Error!",param1.message);
      }
   }
}

