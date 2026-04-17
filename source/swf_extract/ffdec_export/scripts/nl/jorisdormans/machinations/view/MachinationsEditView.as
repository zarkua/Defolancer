package nl.jorisdormans.machinations.view
{
   import flash.display.DisplayObjectContainer;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import nl.jorisdormans.graph.GraphConnection;
   import nl.jorisdormans.graph.GraphElement;
   import nl.jorisdormans.graph.GraphEvent;
   import nl.jorisdormans.machinations.model.ArtificialPlayer;
   import nl.jorisdormans.machinations.model.Chart;
   import nl.jorisdormans.machinations.model.Delay;
   import nl.jorisdormans.machinations.model.EndCondition;
   import nl.jorisdormans.machinations.model.Gate;
   import nl.jorisdormans.machinations.model.Label;
   import nl.jorisdormans.machinations.model.MachinationsConnection;
   import nl.jorisdormans.machinations.model.MachinationsGrammar;
   import nl.jorisdormans.machinations.model.MachinationsGraph;
   import nl.jorisdormans.machinations.model.MachinationsNode;
   import nl.jorisdormans.machinations.model.Pool;
   import nl.jorisdormans.machinations.model.Register;
   import nl.jorisdormans.machinations.model.Source;
   import nl.jorisdormans.machinations.model.StateConnection;
   import nl.jorisdormans.machinations.model.TextLabel;
   import nl.jorisdormans.phantomGUI.PhantomBorder;
   import nl.jorisdormans.phantomGUI.PhantomButton;
   import nl.jorisdormans.phantomGUI.PhantomControl;
   import nl.jorisdormans.phantomGUI.PhantomDrawPanel;
   import nl.jorisdormans.phantomGUI.PhantomEditNumberBox;
   import nl.jorisdormans.phantomGUI.PhantomGlyph;
   import nl.jorisdormans.phantomGUI.PhantomLabel;
   import nl.jorisdormans.phantomGUI.PhantomPanel;
   import nl.jorisdormans.phantomGUI.PhantomTabButton;
   import nl.jorisdormans.phantomGUI.PhantomToolButton;
   import nl.jorisdormans.utils.FileIO;
   import nl.jorisdormans.utils.StringUtil;
   
   public class MachinationsEditView extends MachinationsView
   {
      
      private static const editPanelWidth:Number = 194;
      
      private static const editPanelHeight:Number = 182;
      
      private static const topPanelHeight:Number = 34;
      
      private var lastElement:GraphElement;
      
      private var _lastSelected:MachinationsViewElement;
      
      private var mouseDownX:Number;
      
      private var mouseDownY:Number;
      
      private var editPanel:PhantomBorder;
      
      private var panelGraph:PhantomPanel;
      
      private var panelEdit:PhantomPanel;
      
      private var panelFile:PhantomPanel;
      
      private var panelRun:PhantomPanel;
      
      private var _selectTool:PhantomToolButton;
      
      private var tool:String;
      
      private var undoList:Vector.<XML>;
      
      private var undoPosition:int;
      
      private var copiedData:XML;
      
      private var copyShift:int;
      
      private var addingConnection:Boolean = false;
      
      private var fileIOImport:FileIO;
      
      private var fileIOSVG:FileIO;
      
      private var multiSelector:MultiSelector;
      
      private var dragging:Boolean = false;
      
      private var _activePanel:PhantomPanel;
      
      private var editElement:EditElementPanel;
      
      private var editConnection:EditConnectionPanel;
      
      private var editNode:EditNodePanel;
      
      private var editRegister:EditRegisterPanel;
      
      private var editDelay:EditDelayPanel;
      
      private var editEnd:EditNodePanel;
      
      private var editSource:EditSourcePanel;
      
      private var editPool:EditSourcePanel;
      
      private var editGate:EditGatePanel;
      
      private var editLabel:EditLabelPanel;
      
      private var editChart:EditChartPanel;
      
      private var editAP:EditAPPanel;
      
      private var editGraph:EditGraphPanel;
      
      private var editNumberOfRuns:PhantomEditNumberBox;
      
      private var editVisibleRuns:PhantomEditNumberBox;
      
      public function MachinationsEditView(param1:DisplayObjectContainer, param2:Number, param3:Number, param4:Number, param5:Number)
      {
         super(param1,param2,param3 + topPanelHeight + 2,param4 - editPanelWidth - 2,param5);
         this.undoList = new Vector.<XML>();
         this.fileIOImport = new FileIO();
         this.fileIOSVG = new FileIO();
      }
      
      override protected function createControls() : void
      {
         drawContainer = new PhantomPanel(this,2,2,this._controlWidth - 4,this._controlHeight - 4);
         drawPanel = new PhantomDrawPanel(drawContainer,0,0,this._controlWidth - 4,this._controlHeight - 4);
         drawPanel.background = 16777215;
         drawPanel.foreground = 12303325;
         drawPanel.draw();
         drawPanel.mouseChildren = false;
         topBorder = new PhantomBorder(parent,x,y - topPanelHeight - 2,_controlWidth + editPanelWidth + 2,topPanelHeight + 2);
         topPanel = new PhantomPanel(topBorder,2,2,_controlWidth + editPanelWidth - 2,topPanelHeight);
         runButton = new PhantomButton("Run (R)",run,topPanel,4,4);
         runButton.glyph = PhantomGlyph.PLAY;
         new PhantomLabel("Machinations " + MachinationsGrammar.version + " by Joris Dormans (2009-2013), www.jorisdormans.nl/machinations",topPanel,100,6,450);
         this.editPanel = new PhantomBorder(parent,_controlWidth + x,y,editPanelWidth + 2,_controlHeight);
         var _loc1_:int = 0;
         var _loc2_:int = 2;
         this.panelGraph = new PhantomPanel(this.editPanel,_loc1_,_loc2_ + 20,editPanelWidth,editPanelHeight,true);
         this.panelEdit = new PhantomPanel(this.editPanel,_loc1_,_loc2_ + 20,editPanelWidth,editPanelHeight,false);
         this.panelFile = new PhantomPanel(this.editPanel,_loc1_,_loc2_ + 20,editPanelWidth,editPanelHeight,false);
         this.panelRun = new PhantomPanel(this.editPanel,_loc1_,_loc2_ + 20,editPanelWidth,editPanelHeight,false);
         new PhantomTabButton("*Graph",this.changeTab,this.editPanel,_loc1_,_loc2_,50,20,true).tab = this.panelGraph;
         new PhantomTabButton("*Edit",this.changeTab,this.editPanel,_loc1_ + 50,_loc2_,50,20,false).tab = this.panelEdit;
         new PhantomTabButton("*File",this.changeTab,this.editPanel,_loc1_ + 100,_loc2_,50,20,false).tab = this.panelFile;
         new PhantomTabButton("*Run",this.changeTab,this.editPanel,_loc1_ + 150,_loc2_,44,20,false).tab = this.panelRun;
         var _loc3_:int = 40;
         var _loc4_:int = 44;
         var _loc5_:int = 10;
         var _loc6_:int = 6;
         this._selectTool = new PhantomToolButton("Select",this.selectTool,this.panelGraph,_loc5_ + 0 * _loc4_,_loc6_ + 0 * _loc4_,_loc3_,_loc3_,false);
         this._selectTool.drawImage = MachinationsDraw.drawSelectGlyph;
         new PhantomToolButton("TextL",this.selectTool,this.panelGraph,_loc5_ + 1 * _loc4_,_loc6_ + 0 * _loc4_,_loc3_,_loc3_,false);
         new PhantomToolButton("GroupBox",this.selectTool,this.panelGraph,_loc5_ + 2 * _loc4_,_loc6_ + 0 * _loc4_,_loc3_,_loc3_,false);
         new PhantomToolButton("Chart",this.selectTool,this.panelGraph,_loc5_ + 3 * _loc4_,_loc6_ + 0 * _loc4_,_loc3_,_loc3_,false);
         new PhantomToolButton("Pool",this.selectTool,this.panelGraph,_loc5_ + 0 * _loc4_,_loc6_ + 1 * _loc4_,_loc3_,_loc3_,false).drawImage = MachinationsDraw.drawPoolGlyph;
         new PhantomToolButton("Gate",this.selectTool,this.panelGraph,_loc5_ + 1 * _loc4_,_loc6_ + 1 * _loc4_,_loc3_,_loc3_,false).drawImage = MachinationsDraw.drawGateGlyph;
         new PhantomToolButton("Resource Connection",this.selectTool,this.panelGraph,_loc5_ + 2 * _loc4_,_loc6_ + 1 * _loc4_,_loc3_,_loc3_,false).drawImage = MachinationsDraw.drawFlowGlyph;
         new PhantomToolButton("State Connection",this.selectTool,this.panelGraph,_loc5_ + 3 * _loc4_,_loc6_ + 1 * _loc4_,_loc3_,_loc3_,false).drawImage = MachinationsDraw.drawStateGlyph;
         new PhantomToolButton("Source",this.selectTool,this.panelGraph,_loc5_ + 0 * _loc4_,_loc6_ + 2 * _loc4_,_loc3_,_loc3_,false).drawImage = MachinationsDraw.drawSourceGlyph;
         new PhantomToolButton("Drain",this.selectTool,this.panelGraph,_loc5_ + 1 * _loc4_,_loc6_ + 2 * _loc4_,_loc3_,_loc3_,false).drawImage = MachinationsDraw.drawDrainGlyph;
         new PhantomToolButton("Converter",this.selectTool,this.panelGraph,_loc5_ + 2 * _loc4_,_loc6_ + 2 * _loc4_,_loc3_,_loc3_,false).drawImage = MachinationsDraw.drawConverterGlyph;
         new PhantomToolButton("Trader",this.selectTool,this.panelGraph,_loc5_ + 3 * _loc4_,_loc6_ + 2 * _loc4_,_loc3_,_loc3_,false).drawImage = MachinationsDraw.drawTraderGlyph;
         new PhantomToolButton("Delay",this.selectTool,this.panelGraph,_loc5_ + 0 * _loc4_,_loc6_ + 3 * _loc4_,_loc3_,_loc3_,false).drawImage = MachinationsDraw.drawDelayGlyph;
         new PhantomToolButton("Register",this.selectTool,this.panelGraph,_loc5_ + 1 * _loc4_,_loc6_ + 3 * _loc4_,_loc3_,_loc3_,false).drawImage = MachinationsDraw.drawRegisterGlyph;
         new PhantomToolButton("EndCondition",this.selectTool,this.panelGraph,_loc5_ + 2 * _loc4_,_loc6_ + 3 * _loc4_,_loc3_,_loc3_,false).drawImage = MachinationsDraw.drawEndConditionGlyph;
         new PhantomToolButton("ArtificialPlayer",this.selectTool,this.panelGraph,_loc5_ + 3 * _loc4_,_loc6_ + 3 * _loc4_,_loc3_,_loc3_,false).drawImage = MachinationsDraw.drawArtificialPlayerGlyph;
         this.panelGraph.redraw();
         this.activateSelect();
         _loc5_ = editPanelWidth * 0.4;
         var _loc7_:Number = editPanelWidth - _loc5_ - 4;
         _loc6_ = 4;
         new PhantomButton("New (N)",this.newGraph,this.panelFile,_loc5_,_loc6_,_loc7_);
         _loc6_ += 28;
         new PhantomButton("Open (O)",this.openGraph,this.panelFile,_loc5_,_loc6_,_loc7_);
         _loc6_ += 28;
         new PhantomButton("Import (I)",this.importGraph,this.panelFile,_loc5_,_loc6_,_loc7_);
         _loc6_ += 28;
         new PhantomButton("Save (S)",this.saveGraph,this.panelFile,_loc5_,_loc6_,_loc7_);
         _loc6_ += 28;
         new PhantomButton("Export Selection (E)",this.saveSelection,this.panelFile,_loc5_,_loc6_,_loc7_);
         _loc6_ += 28;
         new PhantomButton("Save as SVG (G)",this.saveAsSVG,this.panelFile,_loc5_,_loc6_,_loc7_);
         _loc6_ += 28;
         _loc6_ = 4;
         new PhantomButton("Select All (A)",this.selectAll,this.panelEdit,_loc5_,_loc6_,_loc7_);
         _loc6_ += 28;
         new PhantomButton("Copy (C)",this.copySelected,this.panelEdit,_loc5_,_loc6_,_loc7_);
         _loc6_ += 28;
         new PhantomButton("Paste (V)",this.pasteSelected,this.panelEdit,_loc5_,_loc6_,_loc7_);
         _loc6_ += 28;
         new PhantomButton("Undo (Z)",this.doUndo,this.panelEdit,_loc5_,_loc6_,_loc7_);
         _loc6_ += 28;
         new PhantomButton("Redo (Y)",this.doRedo,this.panelEdit,_loc5_,_loc6_,_loc7_);
         _loc6_ += 28;
         new PhantomButton("Zoom (M)",this.zoom,this.panelEdit,_loc5_,_loc6_,_loc7_);
         _loc6_ += 28;
         _loc6_ = 4;
         quickRun = new PhantomButton("Quick Run",startQuickRun,this.panelRun,_loc5_,_loc6_,_loc7_);
         _loc6_ += 28;
         multipleRuns = new PhantomButton("Multiple Runs",startMultipleRuns,this.panelRun,_loc5_,_loc6_,_loc7_);
         _loc6_ += 28;
         new PhantomLabel("Runs",this.panelRun,4,_loc6_);
         this.editNumberOfRuns = new PhantomEditNumberBox(10,0,10,this.panelRun,_loc5_,_loc6_,60);
         _loc6_ += 28;
         this.editNumberOfRuns.min = 1;
         this.editNumberOfRuns.onChange = this.changeNumberOfRuns;
         new PhantomLabel("Visible Runs",this.panelRun,4,_loc6_);
         this.editVisibleRuns = new PhantomEditNumberBox(10,0,10,this.panelRun,_loc5_,_loc6_,60);
         _loc6_ += 28;
         this.editVisibleRuns.min = 1;
         this.editVisibleRuns.onChange = this.changeVisibleRuns;
         _loc2_ = _loc2_ + 20 + 2 + editPanelHeight + topPanelHeight + 2;
         var _loc8_:Number = _controlHeight - _loc2_ + topPanelHeight;
         this.editElement = new EditElementPanel(this,parent,_controlWidth + x,_loc2_,editPanelWidth,_loc8_,false);
         this.editConnection = new EditConnectionPanel(this,parent,_controlWidth + x,_loc2_,editPanelWidth,_loc8_,false);
         this.editNode = new EditNodePanel(this,parent,stage,_controlWidth + x,_loc2_,editPanelWidth,_loc8_,false);
         this.editRegister = new EditRegisterPanel(this,parent,_controlWidth + x,_loc2_,editPanelWidth,_loc8_,false);
         this.editDelay = new EditDelayPanel(this,parent,stage,_controlWidth + x,_loc2_,editPanelWidth,_loc8_,false);
         this.editEnd = new EditNodePanel(this,parent,stage,_controlWidth + x,_loc2_,editPanelWidth,_loc8_,false,true,false);
         this.editSource = new EditSourcePanel(this,parent,stage,_controlWidth + x,_loc2_,editPanelWidth,_loc8_,false);
         this.editPool = new EditPoolPanel(this,parent,stage,_controlWidth + x,_loc2_,editPanelWidth,_loc8_,false);
         this.editGate = new EditGatePanel(this,parent,stage,_controlWidth + x,_loc2_,editPanelWidth,_loc8_,false);
         this.editLabel = new EditLabelPanel(this,parent,_controlWidth + x,_loc2_,editPanelWidth,_loc8_,false);
         this.editChart = new EditChartPanel(this,parent,_controlWidth + x,_loc2_,editPanelWidth,_loc8_,false);
         this.editAP = new EditAPPanel(this,parent,stage,_controlWidth + x,_loc2_,editPanelWidth,_loc8_,false);
         this.editGraph = new EditGraphPanel(parent,stage,this,_controlWidth + x,_loc2_,editPanelWidth,_loc8_,true);
         this.editGraph.graph = this.graph;
         this.setInteraction(true);
      }
      
      private function changeTab(param1:PhantomControl) : void
      {
         this.activateSelect();
      }
      
      private function changeVisibleRuns(param1:PhantomEditNumberBox) : void
      {
         this.graph.visibleRuns = param1.value;
      }
      
      private function changeNumberOfRuns(param1:PhantomEditNumberBox) : void
      {
         this.graph.numberOfRuns = param1.value;
      }
      
      override public function setControls(param1:Boolean) : void
      {
         super.setControls(param1);
         if(!param1)
         {
            this.deselectAll();
            this.lastSelected = null;
         }
         this.editPanel.enabled = param1;
      }
      
      private function newGraph(param1:PhantomButton) : void
      {
         this.graph.clear();
         _zoomed = false;
         changeSize();
         this.graph = this.graph;
         fileIO.fileName = "";
         this.fileIOSVG.fileName = "";
      }
      
      private function openGraph(param1:PhantomButton) : void
      {
         fileIO.onLoadComplete = this.onLoadGraph;
         fileIO.openFileDialog("Open File");
      }
      
      private function importGraph(param1:PhantomButton) : void
      {
         this.fileIOImport.onLoadComplete = this.onImportGraph;
         this.fileIOImport.openFileDialog("Import File");
      }
      
      public function onImportGraph() : void
      {
         selectAddedElements = true;
         this.graph.addXML(this.fileIOImport.data);
         selectAddedElements = false;
      }
      
      private function openLibary(param1:PhantomButton) : void
      {
      }
      
      private function saveGraph(param1:PhantomButton) : void
      {
         fileIO.data = this.graph.generateXML();
         if(fileIO.fileName != "")
         {
            fileIO.saveFile(fileIO.fileName);
         }
         else
         {
            fileIO.saveFile("new_diagram.xml");
         }
      }
      
      private function saveSelection(param1:PhantomButton) : void
      {
         this.fileIOImport.data = this.generateSelectionXML();
         this.fileIOImport.saveFileDialog("Save Selection");
      }
      
      private function saveAsSVG(param1:PhantomButton) : void
      {
         var _loc6_:MachinationsViewElement = null;
         var _loc2_:XML = <svg/>;
         _loc2_.@width = (this.graph.width / 50).toFixed(2) + "cm";
         _loc2_.@height = (this.graph.height / 50).toFixed(2) + "cm";
         _loc2_.@viewBox = "0 0 " + this.graph.width.toString() + " " + height.toString();
         _loc2_.@xmlns = "http://www.w3.org/2000/svg";
         _loc2_.@version = "1.1";
         var _loc3_:XML = <g/>;
         _loc3_["stroke-linecap"] = "round";
         _loc3_["stroke-linejoin"] = "round";
         var _loc4_:int = drawPanel.numChildren;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc6_ = drawPanel.getChildAt(_loc5_) as MachinationsViewElement;
            if(_loc6_)
            {
               _loc2_.appendChild(_loc6_.drawToSVG(_loc3_));
            }
            _loc5_++;
         }
         _loc2_.appendChild(_loc3_);
         this.fileIOSVG.data = _loc2_;
         if(this.fileIOSVG.fileName != "")
         {
            this.fileIOSVG.saveFile(this.fileIOSVG.fileName);
         }
         else if(fileIO.fileName != "")
         {
            this.fileIOSVG.saveFile(StringUtil.setFileExtention(fileIO.fileName,"svg"));
         }
         else
         {
            this.fileIOSVG.saveFile("new_diagram.svg");
         }
      }
      
      private function selectAll(param1:PhantomButton) : void
      {
         var _loc2_:int = int(_elements.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(!_elements[_loc3_].selected)
            {
               _elements[_loc3_].selected = true;
            }
            _loc3_++;
         }
      }
      
      private function copySelected(param1:PhantomButton) : void
      {
         this.copiedData = this.generateSelectionXML();
         this.copyShift = 0;
      }
      
      private function pasteSelected(param1:PhantomButton) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this.copiedData != null)
         {
            this.copyShift += 20;
            this.deselectAll();
            selectAddedElements = true;
            this.graph.addXML(this.copiedData);
            selectAddedElements = false;
            _loc2_ = int(_elements.length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(_elements[_loc3_].selected)
               {
                  _elements[_loc3_].moveBy(this.copyShift,this.copyShift);
               }
               _loc3_++;
            }
         }
      }
      
      public function addUndo() : void
      {
         var _loc1_:XML = this.graph.generateXML();
         this.undoList.splice(this.undoPosition,this.undoList.length - this.undoPosition);
         this.undoList.push(_loc1_);
         if(this.undoList.length > 16)
         {
            this.undoList.splice(0,1);
         }
         this.undoPosition = this.undoList.length;
      }
      
      private function doUndo(param1:PhantomControl) : void
      {
         if(this.undoPosition == 0)
         {
            return;
         }
         if(this.undoPosition == this.undoList.length)
         {
            this.addUndo();
            --this.undoPosition;
         }
         --this.undoPosition;
         this.graph.readXML(this.undoList[this.undoPosition]);
         this.activateSelect();
      }
      
      private function doRedo(param1:PhantomControl) : void
      {
         if(this.undoPosition > this.undoList.length - 2)
         {
            return;
         }
         ++this.undoPosition;
         this.graph.readXML(this.undoList[this.undoPosition]);
         this.activateSelect();
      }
      
      private function selectTool(param1:PhantomToolButton) : void
      {
         this.tool = param1.caption;
         this.deselectAll();
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.target is TextField)
         {
            return;
         }
         if(param1.keyCode == Keyboard.INSERT || param1.keyCode == 87)
         {
            if(Boolean(this.lastSelected) && Boolean(this.lastSelected.unique) && this.lastSelected.element is GraphConnection)
            {
               this.addUndo();
               (this.lastSelected.element as GraphConnection).addPoint(drawPanel.mouseX,drawPanel.mouseY);
            }
         }
         if(param1.keyCode == Keyboard.SHIFT || param1.keyCode == Keyboard.ESCAPE)
         {
            if(this.addingConnection)
            {
               this.deleteSelected();
            }
            this.activateSelect();
         }
         if(param1.keyCode == Keyboard.DELETE || param1.keyCode == Keyboard.BACKSPACE)
         {
            this.deleteSelected();
         }
         if(param1.keyCode == 65)
         {
            this.selectAll(null);
         }
         if(param1.keyCode == 67)
         {
            this.copySelected(null);
         }
         if(param1.keyCode == 69)
         {
            this.saveSelection(null);
         }
         if(param1.keyCode == 71)
         {
            this.saveAsSVG(null);
         }
         if(param1.keyCode == 73)
         {
            this.importGraph(null);
         }
         if(param1.keyCode == 76)
         {
            this.openLibary(null);
         }
         if(param1.keyCode == 77)
         {
            this.zoom(null);
         }
         if(param1.keyCode == 78)
         {
            this.newGraph(null);
         }
         if(param1.keyCode == 79)
         {
            this.openGraph(null);
         }
         if(param1.keyCode == 82)
         {
            run(null);
         }
         if(param1.keyCode == 83)
         {
            this.saveGraph(null);
         }
         if(param1.keyCode == 86)
         {
            this.pasteSelected(null);
         }
         if(param1.keyCode == 89)
         {
            this.doRedo(null);
         }
         if(param1.keyCode == 90)
         {
            this.doUndo(null);
         }
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Number = param1.localX;
         var _loc3_:Number = param1.localY;
         var _loc4_:MachinationsViewElement = getElementAt(_loc2_,_loc3_);
         if((Boolean(_loc4_)) && Boolean(_loc4_ == this.lastSelected) && _loc4_.unique)
         {
            _loc4_.hoveringControl = _loc4_.pointOnControl(_loc2_,_loc3_);
         }
         _loc4_ = getElementAt(_loc2_,_loc3_,this.lastSelected);
         if(!_loc4_ || !_loc4_.selected)
         {
            hover = _loc4_;
         }
         if(this.addingConnection)
         {
            (this.lastSelected.element as GraphConnection).calculateEndPosition(new Vector3D(_loc2_,_loc3_));
         }
      }
      
      public function get selectedCount() : int
      {
         var _loc1_:int = int(_elements.length);
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_)
         {
            if(_elements[_loc3_].selected)
            {
               _loc2_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function get activePanel() : PhantomPanel
      {
         return this._activePanel;
      }
      
      public function set activePanel(param1:PhantomPanel) : void
      {
         if(this._activePanel)
         {
            this._activePanel.showing = false;
         }
         this._activePanel = param1;
         if(this._activePanel)
         {
            this._activePanel.showing = true;
            if(Boolean(this._lastSelected) && this._activePanel is EditElementPanel)
            {
               (this._activePanel as EditElementPanel).element = this._lastSelected.element;
            }
            if(this._activePanel is EditGraphPanel)
            {
               (this._activePanel as EditGraphPanel).graph = this.graph;
            }
         }
      }
      
      public function get lastSelected() : MachinationsViewElement
      {
         return this._lastSelected;
      }
      
      public function set lastSelected(param1:MachinationsViewElement) : void
      {
         this._lastSelected = param1;
         this.activePanel = null;
         if(this._lastSelected)
         {
            this.lastElement = this._lastSelected.element;
         }
         if(Boolean(this._lastSelected) && this.selectedCount == 1)
         {
            this._lastSelected.unique = true;
            this.determinePanel();
         }
         else if(this._lastSelected)
         {
            this.determinePanel();
         }
         else
         {
            this.activePanel = this.editGraph;
         }
      }
      
      private function determinePanel() : void
      {
         var _loc1_:String = this._lastSelected.element.toString();
         var _loc2_:int = int(_elements.length);
         var _loc3_:int = 0;
         for(; _loc3_ < _elements.length; _loc3_++)
         {
            if(!_elements[_loc3_].selected)
            {
               continue;
            }
            switch(_loc1_)
            {
               case "[object Pool]":
                  if(_elements[_loc3_].element is MachinationsConnection)
                  {
                     _loc1_ = "multi";
                  }
                  else if(_elements[_loc3_].element is TextLabel)
                  {
                     _loc1_ = "multi";
                  }
                  else if(_elements[_loc3_].element is Pool)
                  {
                     _loc1_ = "[object Pool]";
                  }
                  else if(_elements[_loc3_].element is Source)
                  {
                     _loc1_ = "[object Source]";
                  }
                  else if(_elements[_loc3_].element is MachinationsNode)
                  {
                     _loc1_ = "[object MachinationsNode]";
                  }
                  break;
               case "[object Source]":
               case "[object Trader]":
               case "[object Converter]":
                  if(_elements[_loc3_].element is MachinationsConnection)
                  {
                     _loc1_ = "multi";
                  }
                  else if(_elements[_loc3_].element is TextLabel)
                  {
                     _loc1_ = "multi";
                  }
                  else if(_elements[_loc3_].element is EndCondition)
                  {
                     _loc1_ = "multi";
                  }
                  else if(!(_elements[_loc3_].element is Source))
                  {
                     _loc1_ = "[object MachinationsNode]";
                  }
                  break;
               case "[object ResourceConnection]":
               case "[object StateConnection]":
                  if(_elements[_loc3_].element is MachinationsNode)
                  {
                     _loc1_ = "multi";
                  }
                  break;
               case "[object Gate]":
                  if(_elements[_loc3_].element is MachinationsConnection)
                  {
                     _loc1_ = "multi";
                  }
                  else if(_elements[_loc3_].element is EndCondition)
                  {
                     _loc1_ = "multi";
                  }
                  else if(_elements[_loc3_].element is TextLabel)
                  {
                     _loc1_ = "multi";
                  }
                  else if(!(_elements[_loc3_].element is Gate))
                  {
                     _loc1_ = "[object MachinationsNode]";
                  }
                  break;
               case "[object Chart]":
                  if(_elements[_loc3_].element is Chart)
                  {
                     _loc1_ = "[object Chart]";
                  }
                  else if(_elements[_loc3_].element is TextLabel)
                  {
                     _loc1_ = "[object TextLabel]";
                  }
                  else
                  {
                     _loc1_ = "multi";
                  }
                  break;
               case "[object GroupBox]":
               case "[object TextLabel]":
                  if(!(_elements[_loc3_].element is TextLabel))
                  {
                     _loc1_ = "multi";
                  }
                  break;
               case "[object Drain]":
               case "[object MachinationsNode]":
                  if(_elements[_loc3_].element is EndCondition)
                  {
                     _loc1_ = "multi";
                  }
                  else if(_elements[_loc3_].element is MachinationsConnection)
                  {
                     _loc1_ = "multi";
                  }
                  break;
               case "[object Register]":
                  if(!(_elements[_loc3_].element is Register))
                  {
                     _loc1_ = "multi";
                  }
                  break;
               case "[object Delay]":
                  if(!(_elements[_loc3_].element is Delay))
                  {
                     _loc1_ = "multi";
                  }
                  break;
               case "[object EndCondition]":
                  if(!(_elements[_loc3_].element is EndCondition))
                  {
                     _loc1_ = "multi";
                  }
                  break;
               case "[object ArtificialPlayer]":
                  if(_elements[_loc3_].element is MachinationsConnection)
                  {
                     _loc1_ = "multi";
                  }
                  else if(_elements[_loc3_].element is TextLabel)
                  {
                     _loc1_ = "multi";
                  }
                  else if(_elements[_loc3_].element is ArtificialPlayer)
                  {
                     _loc1_ = "[object ArtificialPlayer]";
                  }
                  else if(_elements[_loc3_].element is MachinationsNode)
                  {
                     _loc1_ = "[object MachinationsNode]";
                  }
            }
         }
         switch(_loc1_)
         {
            default:
            case "multi":
               this.activePanel = this.editElement;
               break;
            case "[object ResourceConnection]":
            case "[object StateConnection]":
               this.activePanel = this.editConnection;
               break;
            case "[object Gate]":
               this.activePanel = this.editGate;
               break;
            case "[object Chart]":
               this.activePanel = this.editChart;
               break;
            case "[object GroupBox]":
            case "[object TextLabel]":
               this.activePanel = this.editLabel;
               break;
            case "[object Register]":
               this.activePanel = this.editRegister;
               break;
            case "[object Delay]":
               this.activePanel = this.editDelay;
               break;
            case "[object EndCondition]":
               this.activePanel = this.editEnd;
               break;
            case "[object Drain]":
            case "[object MachinationsNode]":
               this.activePanel = this.editNode;
               break;
            case "[object ArtificialPlayer]":
               this.activePanel = this.editAP;
               break;
            case "[object Source]":
            case "[object Trader]":
            case "[object Converter]":
               this.activePanel = this.editSource;
               break;
            case "[object Pool]":
               this.activePanel = this.editPool;
         }
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(this.addingConnection)
         {
            this.addConnectionPoint(param1);
         }
         else
         {
            switch(this.tool)
            {
               default:
               case "Select":
                  this.doSelect(param1);
                  break;
               case "Pool":
               case "Gate":
               case "Source":
               case "Drain":
               case "Converter":
               case "Trader":
               case "Delay":
               case "Register":
               case "EndCondition":
               case "ArtificialPlayer":
               case "TextL":
               case "GroupBox":
               case "Chart":
                  this.addNode(param1);
                  break;
               case "State Connection":
               case "Resource Connection":
                  this.addConnection(param1);
            }
         }
      }
      
      private function addConnection(param1:MouseEvent) : void
      {
         var _loc2_:MachinationsViewElement = getElementAt(param1.localX,param1.localY);
         if(Boolean(_loc2_) && Boolean(_loc2_.selected) && _loc2_.element is GraphConnection)
         {
            this.activateSelect();
            this.doSelect(param1);
            return;
         }
         this.deselectAll();
         var _loc3_:Point = drawPanel.trySnap(param1.localX,param1.localY);
         var _loc4_:MachinationsConnection = this.graph.addConnection(this.tool,new Vector3D(param1.localX + _loc3_.x,param1.localY + _loc3_.y),new Vector3D(param1.localX,param1.localY)) as MachinationsConnection;
         _elements[_elements.length - 1].selected = true;
         if(Boolean(_loc4_) && Boolean(_loc2_))
         {
            _loc4_.start = _loc2_.element;
            if(_loc2_.element is MachinationsNode)
            {
               _loc4_.color = (_loc2_.element as MachinationsNode).color;
               _loc4_.thickness = (_loc2_.element as MachinationsNode).thickness;
            }
            else if(_loc2_.element is MachinationsConnection)
            {
               _loc4_.color = (_loc2_.element as MachinationsConnection).color;
               _loc4_.thickness = (_loc2_.element as MachinationsConnection).thickness;
            }
         }
         else if(Boolean(_loc4_) && this.lastElement is MachinationsNode)
         {
            _loc4_.color = (this.lastElement as MachinationsNode).color;
            _loc4_.thickness = (this.lastElement as MachinationsNode).thickness;
         }
         else if(Boolean(_loc4_) && this.lastElement is MachinationsConnection)
         {
            _loc4_.color = (this.lastElement as MachinationsConnection).color;
            _loc4_.thickness = (this.lastElement as MachinationsConnection).thickness;
         }
         this.lastSelected = _elements[_elements.length - 1];
         this.addingConnection = true;
      }
      
      private function addConnectionPoint(param1:MouseEvent) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Point = null;
         this.addUndo();
         var _loc2_:GraphConnection = this.lastSelected.element as GraphConnection;
         var _loc3_:MachinationsViewElement = getElementAt(param1.localX,param1.localY,this.lastSelected);
         if(_loc3_)
         {
            _loc2_.end = _loc3_.element;
            this.setDefaultModifier(_loc2_ as MachinationsConnection);
            this.addingConnection = false;
         }
         else
         {
            _loc4_ = param1.localX - _loc2_.points[_loc2_.points.length - 2].x;
            _loc5_ = param1.localY - _loc2_.points[_loc2_.points.length - 2].y;
            _loc6_ = _loc4_ * _loc4_ + _loc5_ * _loc5_;
            if(_loc6_ < MachinationsViewElement.CONTROL_SIZE * MachinationsViewElement.CONTROL_SIZE)
            {
               _loc2_.points.splice(_loc2_.points.length - 1,1);
               _loc2_.calculateEndPosition();
               this.addingConnection = false;
               this.setDefaultModifier(_loc2_ as MachinationsConnection);
            }
            else
            {
               _loc7_ = drawPanel.trySnap(param1.localX,param1.localY);
               _loc2_.points[_loc2_.points.length - 1].x = param1.localX + _loc7_.x;
               _loc2_.points[_loc2_.points.length - 1].y = param1.localY + _loc7_.y;
               _loc2_.points.push(new Vector3D(param1.localX,param1.localY));
               _loc2_.calculateEndPosition();
            }
         }
      }
      
      private function setDefaultModifier(param1:MachinationsConnection) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         if(param1 is StateConnection)
         {
            if(param1.end is Pool || param1.end is MachinationsConnection)
            {
               param1.label.text = "+1";
               this.editConnection.element = param1;
               param1.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,param1));
               if(param1.end is MachinationsConnection && (param1.end as MachinationsConnection).label.getRealText() == "")
               {
                  (param1.end as MachinationsConnection).label.text = "1";
               }
            }
            else if(param1.end is Register)
            {
               _loc2_ = 97;
               _loc3_ = int(param1.end.inputs.length);
               while(_loc2_ < 97 + 26 && _loc3_ > 0)
               {
                  _loc4_ = false;
                  _loc5_ = 0;
                  while(_loc5_ < _loc3_)
                  {
                     if(param1.end.inputs[_loc5_] is StateConnection && (param1.end.inputs[_loc5_] as StateConnection).label.text.charCodeAt(0) == _loc2_)
                     {
                        _loc4_ = true;
                        break;
                     }
                     _loc5_++;
                  }
                  if(!_loc4_)
                  {
                     break;
                  }
                  _loc2_++;
               }
               param1.label.text = String.fromCharCode(_loc2_);
               this.editConnection.element = param1;
               param1.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,param1));
            }
            else if(!(param1.end is TextLabel))
            {
               if(param1.end is MachinationsNode)
               {
                  if(param1.start is Pool || param1.start is Register)
                  {
                     param1.label.text = ">0";
                  }
                  else if(param1.start is Gate)
                  {
                     param1.label.text = "";
                  }
                  else
                  {
                     param1.label.text = "*";
                  }
                  this.editConnection.element = param1;
                  param1.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,param1));
               }
            }
         }
      }
      
      private function addNode(param1:MouseEvent) : void
      {
         this.addUndo();
         this.deselectAll();
         var _loc2_:MachinationsViewElement = getElementAt(param1.localX,param1.localY);
         if(_loc2_)
         {
            this.activateSelect();
            this.doSelect(param1);
            return;
         }
         var _loc3_:Point = drawPanel.trySnap(param1.localX,param1.localY);
         var _loc4_:String = this.tool;
         if(_loc4_ == "TextL")
         {
            _loc4_ = "TextLabel";
         }
         var _loc5_:MachinationsNode = this.graph.addNode(_loc4_,new Vector3D(param1.localX + _loc3_.x,param1.localY + _loc3_.y)) as MachinationsNode;
         if((Boolean(_loc5_)) && this.lastElement is MachinationsNode)
         {
            _loc5_.color = (this.lastElement as MachinationsNode).color;
            _loc5_.thickness = (this.lastElement as MachinationsNode).thickness;
         }
         if(Boolean(_loc5_) && this.lastElement is MachinationsConnection)
         {
            _loc5_.color = (this.lastElement as MachinationsConnection).color;
            _loc5_.thickness = (this.lastElement as MachinationsConnection).thickness;
         }
         _elements[_elements.length - 1].selected = true;
         this.lastSelected = _elements[_elements.length - 1];
      }
      
      private function activateSelect() : void
      {
         if(this.tool == "Select")
         {
            return;
         }
         this.tool = "Select";
         this._selectTool.selected = true;
      }
      
      private function doSelect(param1:MouseEvent) : void
      {
         var _loc2_:Number = param1.localX;
         var _loc3_:Number = param1.localY;
         this.mouseDownX = _loc2_;
         this.mouseDownY = _loc3_;
         var _loc4_:MachinationsViewElement = getElementAt(_loc2_,_loc3_);
         if(Boolean(this.lastSelected) && Boolean(this.lastSelected.unique) && this.lastSelected != _loc4_)
         {
            this.lastSelected.unique = false;
         }
         if(!param1.shiftKey && !(_loc4_ && _loc4_.selected))
         {
            this.deselectAll();
         }
         if(_loc4_ != null)
         {
            if(_loc4_.element is Chart)
            {
               if(clickChartButtons(_loc4_.element as Chart,param1))
               {
                  return;
               }
            }
            _loc4_.selected = true;
            if(this.selectedCount == 1)
            {
               _loc4_.unique = true;
               _loc4_.control = _loc4_.pointOnControl(_loc2_,_loc3_);
            }
            this.dragging = false;
            if(_loc4_.control < 0)
            {
               addEventListener(MouseEvent.MOUSE_MOVE,this.dragElements);
               addEventListener(MouseEvent.MOUSE_UP,this.endDragElements);
            }
            else
            {
               addEventListener(MouseEvent.MOUSE_MOVE,this.dragControl);
               addEventListener(MouseEvent.MOUSE_UP,this.endDragControl);
            }
         }
         else if(param1.target is PhantomDrawPanel)
         {
            addEventListener(MouseEvent.MOUSE_MOVE,this.multiSelect);
            addEventListener(MouseEvent.MOUSE_UP,this.endMultiSelect);
            if(this.multiSelector == null)
            {
               this.multiSelector = new MultiSelector();
            }
            this.multiSelector.setPosition(drawPanel,param1.localX,param1.localY);
         }
         this.lastSelected = _loc4_;
         if(this.lastSelected)
         {
            pushToTop(this._lastSelected);
            this.graph.pushToTop(this._lastSelected.element);
            drawPanel.setChildIndex(this._lastSelected,drawPanel.numChildren - 1);
         }
      }
      
      private function multiSelect(param1:MouseEvent) : void
      {
         this.multiSelector.setSize(param1.localX - this.multiSelector.x,param1.localY - this.multiSelector.y);
      }
      
      private function endMultiSelect(param1:MouseEvent) : void
      {
         removeEventListener(MouseEvent.MOUSE_MOVE,this.multiSelect);
         removeEventListener(MouseEvent.MOUSE_UP,this.endMultiSelect);
         this.multiSelector.parent.removeChild(this.multiSelector);
         if(!param1.shiftKey)
         {
            this.deselectAll();
         }
         var _loc2_:Rectangle = this.multiSelector.getRectangle();
         var _loc3_:int = int(_elements.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(_elements[_loc4_].elementInRectangle(_loc2_))
            {
               _elements[_loc4_].selected = true;
               this.lastSelected = _elements[_loc4_];
            }
            _loc4_++;
         }
      }
      
      private function dragControl(param1:MouseEvent) : void
      {
         var _loc2_:Number = param1.localX;
         var _loc3_:Number = param1.localY;
         var _loc4_:int = _loc2_ - this.mouseDownX;
         var _loc5_:int = _loc3_ - this.mouseDownY;
         if(this.dragging || _loc4_ * _loc4_ + _loc5_ * _loc5_ > 25)
         {
            if(!this.dragging)
            {
               this.dragging = true;
               this.addUndo();
            }
            this.lastSelected.moveControl(_loc4_,_loc5_,param1.localX,param1.localY);
            this.mouseDownX += _loc4_;
            this.mouseDownY += _loc5_;
         }
      }
      
      private function endDragControl(param1:MouseEvent) : void
      {
         var _loc5_:Point = null;
         var _loc2_:Number = param1.localX;
         var _loc3_:Number = param1.localY;
         if(this.dragging)
         {
            _loc5_ = drawPanel.trySnap(_loc2_,_loc3_);
            if(_loc5_.x != 0 && _loc5_.y != 0)
            {
               this.lastSelected.moveControl(_loc5_.x,_loc5_.y,_loc2_ + _loc5_.x,_loc3_ + _loc5_.y);
               this.lastSelected.draw();
            }
         }
         var _loc4_:MachinationsConnection = this.lastSelected.element as MachinationsConnection;
         if(_loc4_)
         {
            if(this.lastSelected.control == 0 && this.dragging)
            {
               if(hover)
               {
                  _loc4_.start = hover.element;
               }
               else
               {
                  _loc4_.start = null;
               }
            }
            if(this.lastSelected.control == _loc4_.points.length - 1 && this.dragging)
            {
               if(hover)
               {
                  _loc4_.end = hover.element;
               }
               else
               {
                  _loc4_.end = null;
               }
            }
            this.lastSelected.draw();
         }
         removeEventListener(MouseEvent.MOUSE_MOVE,this.dragControl);
         removeEventListener(MouseEvent.MOUSE_UP,this.endDragControl);
      }
      
      private function deselectAll() : void
      {
         var _loc1_:int = int(_elements.length);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            if(_elements[_loc2_].selected)
            {
               _elements[_loc2_].selected = false;
               if(_elements[_loc2_].unique)
               {
                  _elements[_loc2_].unique = false;
               }
            }
            _loc2_++;
         }
      }
      
      private function endDragElements(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this.lastSelected.element is MachinationsNode && this.dragging)
         {
            _loc2_ = this.lastSelected.getSnap();
            if(_loc2_.x != 0 && _loc2_.y != 0)
            {
               _loc3_ = int(_elements.length);
               _loc4_ = 0;
               while(_loc4_ < _loc3_)
               {
                  if(_elements[_loc4_].selected)
                  {
                     _elements[_loc4_].moveBy(_loc2_.x,_loc2_.y);
                  }
                  _loc4_++;
               }
            }
         }
         removeEventListener(MouseEvent.MOUSE_MOVE,this.dragElements);
         removeEventListener(MouseEvent.MOUSE_UP,this.endDragElements);
      }
      
      private function dragElements(param1:MouseEvent) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:Number = param1.localX;
         var _loc3_:Number = param1.localY;
         var _loc4_:int = _loc2_ - this.mouseDownX;
         var _loc5_:int = _loc3_ - this.mouseDownY;
         if(this.dragging || _loc4_ * _loc4_ + _loc5_ * _loc5_ > 25)
         {
            if(!this.dragging)
            {
               this.dragging = true;
               this.addUndo();
            }
            _loc6_ = int(_elements.length);
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               if(_elements[_loc7_].selected)
               {
                  _elements[_loc7_].moveBy(_loc4_,_loc5_);
               }
               _loc7_++;
            }
            this.mouseDownX += _loc4_;
            this.mouseDownY += _loc5_;
         }
      }
      
      private function deleteSelected() : void
      {
         var _loc1_:int = 0;
         var _loc2_:* = 0;
         if(Boolean(this.lastSelected) && Boolean(this.lastSelected.unique) && this.lastSelected.control >= 0)
         {
            this.addUndo();
            this.lastSelected.deleteControl();
         }
         else
         {
            this.addUndo();
            _loc1_ = int(_elements.length);
            _loc2_ = int(_loc1_ - 1);
            while(_loc2_ >= 0)
            {
               if(_elements[_loc2_].selected)
               {
                  _elements[_loc2_].element.dispose();
               }
               _loc2_--;
            }
            this.activateSelect();
         }
         if(this.addingConnection)
         {
            this.addingConnection = false;
         }
      }
      
      override public function removeElement(param1:MachinationsViewElement) : void
      {
         if(param1 == this.lastSelected)
         {
            this.lastSelected = null;
         }
         if(param1 == _hover)
         {
            _hover = null;
         }
         super.removeElement(param1);
      }
      
      public function generateSelectionXML() : XML
      {
         var _loc1_:int = 0;
         var _loc2_:int = int(_elements.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(_elements[_loc3_].selected)
            {
               _elements[_loc3_].element.id = _loc1_;
               _loc1_++;
            }
            else
            {
               _elements[_loc3_].element.id = -1;
            }
            _loc3_++;
         }
         var _loc4_:XML = <graph/>;
         _loc4_.@version = MachinationsGrammar.version;
         _loc4_.@name = this.graph.name;
         _loc4_.@author = this.graph.author;
         _loc4_.@interval = this.graph.fireInterval;
         _loc4_.@timeMode = this.graph.timeMode;
         _loc4_.@distributionMode = this.graph.distributionMode;
         _loc4_.@speed = this.graph.resourceSpeed;
         _loc4_.@actions = this.graph.actionsPerTurn;
         _loc4_.@dice = this.graph.dice;
         _loc4_.@skill = this.graph.skill;
         _loc4_.@strategy = this.graph.strategy;
         _loc4_.@multiplayer = this.graph.multiplayer;
         _loc4_.@width = this.graph.width;
         _loc4_.@height = this.graph.height;
         _loc4_.@numberOfRuns = this.graph.numberOfRuns;
         _loc4_.@visibleRuns = this.graph.visibleRuns;
         _loc4_.@colorCoding = this.graph.colorCoding;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(_elements[_loc3_].selected)
            {
               _loc4_.appendChild(_elements[_loc3_].element.generateXML());
            }
            _loc3_++;
         }
         return _loc4_;
      }
      
      public function setValue(param1:String, param2:String, param3:Number) : void
      {
         var _loc4_:int = int(_elements.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            if(_elements[_loc5_].selected)
            {
               switch(param1)
               {
                  case "color":
                     if(_elements[_loc5_].element is MachinationsConnection)
                     {
                        (_elements[_loc5_].element as MachinationsConnection).color = StringUtil.toColor(param2);
                     }
                     if(_elements[_loc5_].element is MachinationsNode)
                     {
                        (_elements[_loc5_].element as MachinationsNode).color = StringUtil.toColor(param2);
                     }
                     break;
                  case "thickness":
                     if(_elements[_loc5_].element is MachinationsConnection)
                     {
                        (_elements[_loc5_].element as MachinationsConnection).thickness = param3;
                     }
                     if(_elements[_loc5_].element is MachinationsNode)
                     {
                        (_elements[_loc5_].element as MachinationsNode).thickness = param3;
                     }
                     break;
                  case "label":
                     if(_elements[_loc5_].element is MachinationsConnection)
                     {
                        (_elements[_loc5_].element as MachinationsConnection).label.text = param2;
                     }
                     if(_elements[_loc5_].element is MachinationsNode)
                     {
                        (_elements[_loc5_].element as MachinationsNode).caption = param2;
                     }
                     break;
                  case "min":
                     if(_elements[_loc5_].element is MachinationsConnection)
                     {
                        (_elements[_loc5_].element as MachinationsConnection).label.min = Math.max(param3,-Label.LIMIT);
                     }
                     if(_elements[_loc5_].element is Register)
                     {
                        (_elements[_loc5_].element as Register).minValue = Math.max(param3,-Register.LIMIT);
                     }
                     break;
                  case "max":
                     if(_elements[_loc5_].element is MachinationsConnection)
                     {
                        (_elements[_loc5_].element as MachinationsConnection).label.max = Math.min(param3,Label.LIMIT);
                     }
                     if(_elements[_loc5_].element is Register)
                     {
                        (_elements[_loc5_].element as Register).maxValue = Math.min(param3,Register.LIMIT);
                     }
                     break;
                  case "start":
                     if(_elements[_loc5_].element is Register)
                     {
                        (_elements[_loc5_].element as Register).startValue = Math.max(Math.min(param3,Register.LIMIT),-Register.LIMIT);
                     }
                     break;
                  case "step":
                     if(_elements[_loc5_].element is Register)
                     {
                        (_elements[_loc5_].element as Register).valueStep = Math.max(Math.min(param3,Register.LIMIT),-Register.LIMIT);
                     }
                     break;
                  case "pullMode":
                     if(_elements[_loc5_].element is MachinationsNode)
                     {
                        (_elements[_loc5_].element as MachinationsNode).pullMode = param2;
                     }
                     break;
                  case "activationMode":
                     if(_elements[_loc5_].element is MachinationsNode)
                     {
                        (_elements[_loc5_].element as MachinationsNode).activationMode = param2;
                     }
                     break;
                  case "actions":
                     if(_elements[_loc5_].element is MachinationsNode)
                     {
                        (_elements[_loc5_].element as MachinationsNode).actions = param3;
                     }
                     break;
                  case "resourceColor":
                     if(_elements[_loc5_].element is Source)
                     {
                        (_elements[_loc5_].element as Source).resourceColor = StringUtil.toColor(param2);
                     }
                     break;
                  case "startingResources":
                     if(_elements[_loc5_].element is Pool)
                     {
                        (_elements[_loc5_].element as Pool).startingResources = param3;
                     }
                     break;
                  case "capacity":
                     if(_elements[_loc5_].element is Pool)
                     {
                        (_elements[_loc5_].element as Pool).capacity = param3;
                     }
                     break;
                  case "displayCapacity":
                     if(_elements[_loc5_].element is Pool)
                     {
                        (_elements[_loc5_].element as Pool).displayCapacity = param3;
                     }
                     break;
                  case "gateType":
                     if(_elements[_loc5_].element is Gate)
                     {
                        (_elements[_loc5_].element as Gate).gateType = param2;
                     }
                     break;
                  case "defaultScaleX":
                     if(_elements[_loc5_].element is Chart)
                     {
                        (_elements[_loc5_].element as Chart).defaultScaleX = param3;
                     }
                     break;
                  case "defaultScaleY":
                     if(_elements[_loc5_].element is Chart)
                     {
                        (_elements[_loc5_].element as Chart).defaultScaleY = param3;
                     }
                     break;
                  case "delayType":
                     if(_elements[_loc5_].element is Delay)
                     {
                        (_elements[_loc5_].element as Delay).delayType = param2;
                     }
                     break;
                  case "actionsPerTurn":
                     if(_elements[_loc5_].element is ArtificialPlayer)
                     {
                        (_elements[_loc5_].element as ArtificialPlayer).actionsPerTurn = param3;
                     }
                     break;
                  case "script":
                     if(_elements[_loc5_].element is ArtificialPlayer)
                     {
                        (_elements[_loc5_].element as ArtificialPlayer).script = param2;
                     }
               }
               _elements[_loc5_].draw();
            }
            _loc5_++;
         }
      }
      
      override public function setInteraction(param1:Boolean) : void
      {
         super.setInteraction(param1);
         if(param1)
         {
            removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDownView);
            removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMoveView);
         }
         else
         {
            addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownView);
            addEventListener(MouseEvent.MOUSE_MOVE,onMouseMoveView);
         }
         if(param1)
         {
            addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
            addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
            stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
            this.editGraph.enabled = true;
         }
         else
         {
            removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
            removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
            stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
            this.editGraph.enabled = false;
         }
      }
      
      override public function get graph() : MachinationsGraph
      {
         return super.graph;
      }
      
      override public function set graph(param1:MachinationsGraph) : void
      {
         super.graph = param1;
         if(this.editGraph)
         {
            this.editGraph.graph = param1;
         }
         this.editVisibleRuns.value = this.graph.visibleRuns;
         this.editNumberOfRuns.value = this.graph.numberOfRuns;
      }
      
      override protected function zoom(param1:PhantomControl) : void
      {
         var _loc2_:Number = NaN;
         if(!_zoomed)
         {
            _loc2_ = Math.min(drawContainer.controlWidth / drawPanel.controlWidth,drawContainer.controlHeight / drawPanel.controlHeight);
            drawPanel.scaleX = _loc2_;
            drawPanel.scaleY = _loc2_;
            _zoomed = true;
         }
         else
         {
            drawPanel.scaleX = 1;
            drawPanel.scaleY = 1;
            _zoomed = false;
         }
         drawContainer.scrollTo(0,0);
         drawContainer.checkSize();
         drawPanel.redraw();
      }
      
      override public function onLoadGraph() : void
      {
         super.onLoadGraph();
         this.fileIOSVG.fileName = "";
      }
   }
}

