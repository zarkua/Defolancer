package nl.jorisdormans.machinations.view
{
   import flash.display.DisplayObjectContainer;
   import nl.jorisdormans.graph.GraphElement;
   import nl.jorisdormans.machinations.model.ArtificialPlayer;
   import nl.jorisdormans.machinations.model.Chart;
   import nl.jorisdormans.machinations.model.Converter;
   import nl.jorisdormans.machinations.model.Drain;
   import nl.jorisdormans.machinations.model.EndCondition;
   import nl.jorisdormans.machinations.model.Gate;
   import nl.jorisdormans.machinations.model.GroupBox;
   import nl.jorisdormans.machinations.model.MachinationsConnection;
   import nl.jorisdormans.machinations.model.MachinationsNode;
   import nl.jorisdormans.machinations.model.Pool;
   import nl.jorisdormans.machinations.model.ResourceConnection;
   import nl.jorisdormans.machinations.model.Source;
   import nl.jorisdormans.machinations.model.StateConnection;
   import nl.jorisdormans.machinations.model.TextLabel;
   import nl.jorisdormans.machinations.model.Trader;
   import nl.jorisdormans.phantomGUI.PhantomControl;
   import nl.jorisdormans.phantomGUI.PhantomEditBox;
   import nl.jorisdormans.phantomGUI.PhantomEditNumberBox;
   import nl.jorisdormans.phantomGUI.PhantomLabel;
   import nl.jorisdormans.phantomGUI.PhantomPanel;
   import nl.jorisdormans.utils.StringUtil;
   
   public class EditElementPanel extends PhantomPanel
   {
      
      private var _element:GraphElement;
      
      private var color:PhantomEditBox;
      
      private var thickness:PhantomEditNumberBox;
      
      private var panelCaption:PhantomLabel;
      
      protected var view:MachinationsEditView;
      
      protected var labelX:Number;
      
      protected var controlX:Number;
      
      protected var controlY:Number;
      
      protected var controlW:Number;
      
      protected var controlNW:Number;
      
      public function EditElementPanel(param1:MachinationsEditView, param2:DisplayObjectContainer, param3:Number, param4:Number, param5:Number, param6:Number, param7:Boolean = true, param8:Boolean = true, param9:Boolean = false)
      {
         this.view = param1;
         super(param2,param3,param4,param5,param6,param7,param8);
         this.labelX = 4;
         this.controlX = param5 * 0.4;
         this.controlY = 2;
         this.controlW = param5 - this.controlX - 4;
         this.controlNW = 60;
         this.panelCaption = new PhantomLabel("*Element",this,this.labelX,this.controlY,100);
         this.controlY += 24;
         new PhantomLabel("Color",this,this.labelX,this.controlY);
         this.color = new PhantomEditBox("Color",this,this.controlX,this.controlY,this.controlW);
         this.color.onChange = this.changeValue;
         this.controlY += 28;
         if(!param9)
         {
            new PhantomLabel("Thickness",this,this.labelX,this.controlY);
            this.thickness = new PhantomEditNumberBox(1,0,1,this,this.controlX,this.controlY,this.controlNW);
            this.thickness.min = 0;
            this.thickness.onChange = this.changeValue;
            this.controlY += 28;
         }
      }
      
      public function get element() : GraphElement
      {
         return this._element;
      }
      
      public function set element(param1:GraphElement) : void
      {
         this._element = param1;
         if(this._element is Gate)
         {
            this.panelCaption.caption = "Gate";
         }
         if(this._element is Source)
         {
            this.panelCaption.caption = "Source";
         }
         if(this._element is Pool)
         {
            this.panelCaption.caption = "Pool";
         }
         if(this._element is Drain)
         {
            this.panelCaption.caption = "Drain";
         }
         if(this._element is Converter)
         {
            this.panelCaption.caption = "Converter";
         }
         if(this._element is Trader)
         {
            this.panelCaption.caption = "Trader";
         }
         if(this._element is EndCondition)
         {
            this.panelCaption.caption = "EndCondition";
         }
         if(this._element is TextLabel)
         {
            this.panelCaption.caption = "TextLabel";
         }
         if(this._element is GroupBox)
         {
            this.panelCaption.caption = "GroupBox";
         }
         if(this._element is Chart)
         {
            this.panelCaption.caption = "Chart";
         }
         if(this._element is ArtificialPlayer)
         {
            this.panelCaption.caption = "ArtificialPlayer";
         }
         if(this._element is ResourceConnection)
         {
            this.panelCaption.caption = "Flow";
         }
         if(this._element is StateConnection)
         {
            this.panelCaption.caption = "State";
         }
         if(this._element is MachinationsConnection)
         {
            this.color.caption = StringUtil.toColorString((this._element as MachinationsConnection).color);
            this.thickness.value = (this._element as MachinationsConnection).thickness;
         }
         if(this._element is MachinationsNode)
         {
            this.color.caption = StringUtil.toColorString((this._element as MachinationsNode).color);
            if(this.thickness)
            {
               this.thickness.value = (this._element as MachinationsNode).thickness;
            }
         }
      }
      
      protected function changeValue(param1:PhantomControl) : void
      {
         switch(param1)
         {
            case this.color:
               this.view.setValue("color",this.color.caption,0);
               break;
            case this.thickness:
               this.view.setValue("thickness",null,this.thickness.value);
         }
      }
   }
}

