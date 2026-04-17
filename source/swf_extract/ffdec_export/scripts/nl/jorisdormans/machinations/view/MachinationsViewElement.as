package nl.jorisdormans.machinations.view
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import nl.jorisdormans.graph.GraphElement;
   import nl.jorisdormans.graph.GraphEvent;
   import nl.jorisdormans.machinations.model.ArtificialPlayer;
   import nl.jorisdormans.machinations.model.Chart;
   import nl.jorisdormans.machinations.model.Converter;
   import nl.jorisdormans.machinations.model.Delay;
   import nl.jorisdormans.machinations.model.Drain;
   import nl.jorisdormans.machinations.model.EndCondition;
   import nl.jorisdormans.machinations.model.Gate;
   import nl.jorisdormans.machinations.model.GroupBox;
   import nl.jorisdormans.machinations.model.Label;
   import nl.jorisdormans.machinations.model.MachinationsConnection;
   import nl.jorisdormans.machinations.model.MachinationsGraph;
   import nl.jorisdormans.machinations.model.MachinationsNode;
   import nl.jorisdormans.machinations.model.Pool;
   import nl.jorisdormans.machinations.model.Register;
   import nl.jorisdormans.machinations.model.ResourceConnection;
   import nl.jorisdormans.machinations.model.Source;
   import nl.jorisdormans.machinations.model.TextLabel;
   import nl.jorisdormans.machinations.model.Trader;
   import nl.jorisdormans.phantomGUI.PhantomDrawPanel;
   import nl.jorisdormans.phantomGraphics.DrawUtil;
   import nl.jorisdormans.phantomGraphics.PhantomFont;
   import nl.jorisdormans.utils.MathUtil;
   import nl.jorisdormans.utils.StringUtil;
   
   public class MachinationsViewElement extends Sprite
   {
      
      public static const SELECTED_COLOR:uint = 35071;
      
      private static const SELECTED_COLOR2:uint = 8961023;
      
      private static const HOVER_COLOR:uint = 16759552;
      
      private static const CONTROL_COLOR:uint = 16777215;
      
      private static const SELECTED_THICKNESS:Number = 5;
      
      public static const CONTROL_SIZE:Number = 6;
      
      public static const FIRE_COLOR:uint = 35071;
      
      public static const INHIBITED_COLOR:uint = 14540253;
      
      public static const BLOCKED_COLOR:uint = 16777215;
      
      private var _element:GraphElement;
      
      private var _selected:Boolean = false;
      
      private var _unique:Boolean = false;
      
      private var _control:int = -1;
      
      private var _hovering:Boolean = false;
      
      private var _hoveringControl:int = -1;
      
      public var pinsOnly:Boolean;
      
      public function MachinationsViewElement(param1:DisplayObjectContainer, param2:GraphElement)
      {
         super();
         this.element = param2;
         param1.addChild(this);
         param2.addEventListener(GraphEvent.ELEMENT_CHANGE,this.onElementChanged);
         param2.addEventListener(GraphEvent.ELEMENT_DISPOSE,this.onElementDisposed);
         this.draw();
      }
      
      private function onElementDisposed(param1:GraphEvent) : void
      {
         (parent.parent.parent as MachinationsView).removeElement(this);
      }
      
      private function onElementChanged(param1:GraphEvent) : void
      {
         this.draw();
      }
      
      public function get element() : GraphElement
      {
         return this._element;
      }
      
      public function set element(param1:GraphElement) : void
      {
         this._element = param1;
         this.draw();
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
         this._hoveringControl = -1;
         this.draw();
      }
      
      public function get unique() : Boolean
      {
         return this._unique;
      }
      
      public function set unique(param1:Boolean) : void
      {
         this._unique = param1;
         this.draw();
      }
      
      public function get control() : int
      {
         return this._control;
      }
      
      public function set control(param1:int) : void
      {
         this._control = param1;
         this.draw();
      }
      
      public function get hovering() : Boolean
      {
         return this._hovering;
      }
      
      public function set hovering(param1:Boolean) : void
      {
         this._hovering = param1;
         this.draw();
      }
      
      public function get hoveringControl() : int
      {
         return this._hoveringControl;
      }
      
      public function set hoveringControl(param1:int) : void
      {
         this._hoveringControl = param1;
         this.draw();
      }
      
      public function draw() : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:GroupBox = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Vector.<int> = null;
         var _loc14_:Vector.<Number> = null;
         var _loc15_:Vector3D = null;
         var _loc16_:ResourceConnection = null;
         var _loc17_:Vector3D = null;
         if(!parent)
         {
            return;
         }
         var _loc1_:Number = 0;
         var _loc2_:Number = 0;
         graphics.clear();
         var _loc3_:MachinationsNode = this.element as MachinationsNode;
         if(_loc3_)
         {
            this.x = _loc3_.position.x + _loc1_;
            this.y = _loc3_.position.y + _loc2_;
            _loc5_ = Math.max(_loc3_.thickness,1);
            _loc6_ = 0;
            if(this._selected)
            {
               _loc6_ = SELECTED_COLOR;
            }
            else if(this._hovering)
            {
               _loc6_ = HOVER_COLOR;
            }
            if(_loc6_ != 0)
            {
               if(_loc3_ is Drain)
               {
                  MachinationsDraw.drawDrain(this.graphics,0,0,_loc5_ + SELECTED_THICKNESS,_loc6_,16777215,_loc3_.size,_loc3_.activationMode,_loc3_.pullMode);
               }
               else if(_loc3_ is Pool)
               {
                  MachinationsDraw.drawPool(this.graphics,0,0,_loc5_ + SELECTED_THICKNESS,_loc6_,16777215,_loc3_.size,_loc3_.activationMode,_loc3_.pullMode,_loc3_.resourceInputCount);
               }
               else if(_loc3_ is Delay)
               {
                  MachinationsDraw.drawDelay(this.graphics,0,0,_loc5_ + SELECTED_THICKNESS,_loc6_,16777215,_loc3_.size,_loc3_.activationMode,(_loc3_ as Delay).delayType);
               }
               else if(_loc3_ is Converter)
               {
                  MachinationsDraw.drawConverter(this.graphics,0,0,_loc5_ + SELECTED_THICKNESS,_loc6_,16777215,_loc3_.size,_loc3_.activationMode,_loc3_.pullMode);
               }
               else if(_loc3_ is Trader)
               {
                  MachinationsDraw.drawTrader(this.graphics,0,0,_loc5_ + SELECTED_THICKNESS,_loc6_,16777215,_loc3_.size,_loc3_.activationMode,_loc3_.pullMode);
               }
               else if(_loc3_ is Source)
               {
                  MachinationsDraw.drawSource(this.graphics,0,0,_loc5_ + SELECTED_THICKNESS,_loc6_,16777215,_loc3_.size,_loc3_.activationMode,_loc3_.pullMode);
               }
               else if(_loc3_ is Gate)
               {
                  MachinationsDraw.drawGate(this.graphics,0,0,_loc5_ + SELECTED_THICKNESS,_loc6_,16777215,_loc3_.size,(_loc3_ as Gate).gateType,_loc3_.activationMode,_loc3_.pullMode);
               }
               else if(_loc3_ is Register)
               {
                  MachinationsDraw.drawRegister(this.graphics,0,0,_loc5_ + SELECTED_THICKNESS,_loc6_,16777215,_loc3_.size,"",_loc3_.activationMode);
               }
               else if(_loc3_ is EndCondition)
               {
                  MachinationsDraw.drawEndCondition(this.graphics,0,0,_loc5_ + SELECTED_THICKNESS,_loc6_,16777215,_loc3_.size,_loc3_.activationMode);
               }
               else if(_loc3_ is ArtificialPlayer)
               {
                  MachinationsDraw.drawArtificialPlayer(this.graphics,0,0,_loc5_ + SELECTED_THICKNESS,_loc6_,16777215,_loc3_.size,_loc3_.activationMode);
               }
               else if(_loc3_ is Chart)
               {
                  MachinationsDraw.drawChart(this.graphics,0,0,_loc5_ + SELECTED_THICKNESS,_loc6_,(_loc3_ as Chart).width,(_loc3_ as Chart).height);
               }
               else if(_loc3_ is GroupBox)
               {
                  MachinationsDraw.drawGroupBox(this.graphics,0,0,_loc5_ + SELECTED_THICKNESS,_loc6_,(_loc3_ as GroupBox).width,(_loc3_ as GroupBox).height);
               }
            }
            _loc7_ = _loc3_.color;
            if(_loc3_.inhibited)
            {
               _loc7_ = INHIBITED_COLOR;
            }
            if(_loc3_.firing > 0 || _loc3_.fireFlag)
            {
               _loc7_ = FIRE_COLOR;
            }
            if(_loc3_ is Drain)
            {
               MachinationsDraw.drawDrain(this.graphics,0,0,_loc5_,_loc7_,16777215,_loc3_.size,_loc3_.activationMode,_loc3_.pullMode);
            }
            else if(_loc3_ is Pool)
            {
               MachinationsDraw.drawPool(this.graphics,0,0,_loc5_,_loc7_,16777215,_loc3_.size,_loc3_.activationMode,_loc3_.pullMode,_loc3_.resourceInputCount);
            }
            else if(_loc3_ is Delay)
            {
               if((_loc3_ as Delay).delayed)
               {
                  MachinationsDraw.drawDelay(this.graphics,0,0,_loc5_,16777215,_loc7_,_loc3_.size,_loc3_.activationMode,(_loc3_ as Delay).delayType);
               }
               else
               {
                  MachinationsDraw.drawDelay(this.graphics,0,0,_loc5_,_loc7_,16777215,_loc3_.size,_loc3_.activationMode,(_loc3_ as Delay).delayType);
               }
            }
            else if(_loc3_ is Converter)
            {
               MachinationsDraw.drawConverter(this.graphics,0,0,_loc5_,_loc7_,16777215,_loc3_.size,_loc3_.activationMode,_loc3_.pullMode);
            }
            else if(_loc3_ is Trader)
            {
               MachinationsDraw.drawTrader(this.graphics,0,0,_loc5_,_loc7_,16777215,_loc3_.size,_loc3_.activationMode,_loc3_.pullMode);
            }
            else if(_loc3_ is Source)
            {
               MachinationsDraw.drawSource(this.graphics,0,0,_loc5_,_loc7_,16777215,_loc3_.size,_loc3_.activationMode,_loc3_.pullMode);
            }
            else if(_loc3_ is Gate)
            {
               if((this.element as Gate).displayValue > 0)
               {
                  MachinationsDraw.drawGateValue(this.graphics,0,0,_loc5_,_loc7_,16777215,_loc3_.size,(_loc3_ as Gate).value);
               }
               else
               {
                  MachinationsDraw.drawGate(this.graphics,0,0,_loc5_,_loc7_,16777215,_loc3_.size,(_loc3_ as Gate).gateType,_loc3_.activationMode,_loc3_.pullMode);
               }
            }
            else if(_loc3_ is Register)
            {
               _loc9_ = "x";
               if(_loc3_.activationMode == MachinationsNode.MODE_INTERACTIVE || (_loc3_.graph as MachinationsGraph).running)
               {
                  _loc9_ = (_loc3_ as Register).value.toString();
               }
               MachinationsDraw.drawRegister(this.graphics,0,0,_loc5_,_loc7_,16777215,_loc3_.size,_loc9_,_loc3_.activationMode);
            }
            else if(_loc3_ is EndCondition)
            {
               MachinationsDraw.drawEndCondition(this.graphics,0,0,_loc5_,_loc7_,16777215,_loc3_.size,_loc3_.activationMode);
            }
            else if(_loc3_ is ArtificialPlayer)
            {
               MachinationsDraw.drawArtificialPlayer(this.graphics,0,0,_loc5_,_loc7_,16777215,_loc3_.size,_loc3_.activationMode);
            }
            else if(_loc3_ is Chart)
            {
               (_loc3_ as Chart).draw(this.graphics,0,0);
            }
            else if(_loc3_ is GroupBox)
            {
               MachinationsDraw.drawGroupBox(this.graphics,0,0,_loc5_,_loc7_,(_loc3_ as GroupBox).width,(_loc3_ as GroupBox).height);
            }
            _loc8_ = _loc3_.caption;
            if(_loc3_ is TextLabel && !(_loc3_ is GroupBox))
            {
               if(!_loc8_ || StringUtil.trim(_loc8_) == "")
               {
                  _loc8_ = "TextLabel";
               }
            }
            if(Boolean(_loc8_) && _loc8_ != "")
            {
               if(_loc6_ == 0)
               {
                  _loc6_ = 16777215;
               }
               if(this._hoveringControl == 0)
               {
                  _loc6_ = HOVER_COLOR;
               }
               graphics.lineStyle(6,_loc6_);
               PhantomFont.drawText(_loc8_,graphics,_loc3_.captionCalculatedPosition.x,_loc3_.captionCalculatedPosition.y + 4.5,9,_loc3_.captionAlign);
               graphics.lineStyle();
               graphics.lineStyle(2,_loc7_);
               _loc3_.captionSize = PhantomFont.drawText(_loc8_,graphics,_loc3_.captionCalculatedPosition.x,_loc3_.captionCalculatedPosition.y + 4.5,9,_loc3_.captionAlign);
               graphics.lineStyle();
            }
            if(this.element is Pool)
            {
               this.drawResources(this.element as Pool);
            }
            if(this.unique && _loc3_ is GroupBox)
            {
               _loc10_ = _loc3_ as GroupBox;
               _loc11_ = Math.min(_loc10_.points.length,4);
               _loc12_ = 0;
               while(_loc12_ < _loc11_)
               {
                  _loc6_ = SELECTED_COLOR;
                  if(_loc12_ + 1 == this._hoveringControl)
                  {
                     _loc6_ = HOVER_COLOR;
                  }
                  if(this._control >= 0 && this._control == _loc12_ + 1)
                  {
                     _loc6_ = SELECTED_COLOR2;
                  }
                  graphics.beginFill(_loc6_);
                  graphics.drawCircle(_loc10_.points[_loc12_].x,_loc10_.points[_loc12_].y,CONTROL_SIZE);
                  graphics.endFill();
                  graphics.beginFill(CONTROL_COLOR);
                  graphics.drawCircle(_loc10_.points[_loc12_].x,_loc10_.points[_loc12_].y,CONTROL_SIZE - 2);
                  graphics.endFill();
                  _loc12_++;
               }
            }
            return;
         }
         var _loc4_:MachinationsConnection = this.element as MachinationsConnection;
         if((Boolean(_loc4_)) && _loc4_.points.length > 1)
         {
            this.x = _loc4_.points[0].x + _loc1_;
            this.y = _loc4_.points[0].y + _loc2_;
            _loc13_ = new Vector.<int>();
            _loc14_ = new Vector.<Number>();
            this.pinsOnly = false;
            if(_loc4_.end is Chart)
            {
               if(parent.parent.parent is MachinationsEditView)
               {
                  this.pinsOnly = !this.selected;
               }
               else
               {
                  this.pinsOnly = true;
               }
            }
            _loc5_ = _loc4_.thickness;
            if(_loc5_ == 0)
            {
               if(_loc4_ is ResourceConnection)
               {
                  _loc5_ = 1;
               }
               else
               {
                  _loc5_ = 1;
                  if(parent.parent.parent is MachinationsEditView)
                  {
                     this.pinsOnly = !this.selected;
                  }
                  else
                  {
                     this.pinsOnly = true;
                  }
               }
            }
            MachinationsDraw.generateConnectionData(_loc4_,_loc13_,_loc14_,-this.x,-this.y,this.pinsOnly);
            _loc6_ = 0;
            if(this.selected)
            {
               _loc6_ = SELECTED_COLOR;
            }
            else if(this._hovering)
            {
               _loc6_ = HOVER_COLOR;
            }
            if(_loc6_ != 0)
            {
               graphics.lineStyle(_loc5_ + SELECTED_THICKNESS,_loc6_);
               graphics.drawPath(_loc13_,_loc14_);
               graphics.lineStyle();
            }
            _loc7_ = _loc4_.color;
            if(_loc4_.firing > 0)
            {
               _loc7_ = FIRE_COLOR;
            }
            if(_loc4_.inhibited || _loc5_ == 0)
            {
               _loc7_ = INHIBITED_COLOR;
            }
            if(_loc4_.blocked > 0 && _loc4_.blocked % 0.1 < 0.05)
            {
               _loc7_ = BLOCKED_COLOR;
            }
            graphics.lineStyle(_loc5_,_loc7_);
            graphics.drawPath(_loc13_,_loc14_);
            graphics.lineStyle();
            if(this.pinsOnly)
            {
               return;
            }
            if(_loc6_ == 0)
            {
               _loc6_ = 16777215;
            }
            if(this._hoveringControl == _loc4_.points.length)
            {
               _loc6_ = HOVER_COLOR;
            }
            graphics.lineStyle(6,_loc6_);
            PhantomFont.drawText(_loc4_.label.text,graphics,_loc4_.label.calculatedPosition.x - x,_loc4_.label.calculatedPosition.y - y + 4.5,9,_loc4_.label.align);
            graphics.lineStyle();
            graphics.lineStyle(2,_loc7_);
            _loc4_.label.size = PhantomFont.drawText(_loc4_.label.text,graphics,_loc4_.label.calculatedPosition.x - x,_loc4_.label.calculatedPosition.y - y + 4.5,9,_loc4_.label.align);
            graphics.lineStyle();
            _loc15_ = _loc4_.getPosition();
            switch(_loc4_.label.align)
            {
               case PhantomFont.ALIGN_RIGHT:
                  _loc15_.x -= _loc4_.label.size.x;
                  break;
               case PhantomFont.ALIGN_CENTER:
                  _loc15_.x -= _loc4_.label.size.x * 0.5;
            }
            _loc15_.x -= this.x;
            _loc15_.y -= this.y + 1;
            switch(_loc4_.label.type)
            {
               case Label.TYPE_DICE:
                  if(_loc6_ != 16777215)
                  {
                     graphics.lineStyle(6,_loc6_);
                  }
                  MachinationsDraw.drawDice(graphics,_loc15_.x,_loc15_.y,14,_loc7_);
                  graphics.lineStyle();
                  MachinationsDraw.drawDice(graphics,_loc15_.x,_loc15_.y,14,_loc7_);
                  break;
               case Label.TYPE_SKILL:
                  if(_loc6_ != 16777215)
                  {
                     graphics.lineStyle(6,_loc6_);
                  }
                  MachinationsDraw.drawSkill(graphics,_loc15_.x,_loc15_.y,14,_loc7_);
                  graphics.lineStyle();
                  MachinationsDraw.drawSkill(graphics,_loc15_.x,_loc15_.y,14,_loc7_);
                  break;
               case Label.TYPE_MULTIPLAYER:
                  if(_loc6_ != 16777215)
                  {
                     graphics.lineStyle(6,_loc6_);
                  }
                  MachinationsDraw.drawMultiplayer(graphics,_loc15_.x,_loc15_.y,14,_loc7_);
                  graphics.lineStyle();
                  MachinationsDraw.drawMultiplayer(graphics,_loc15_.x,_loc15_.y,14,_loc7_);
                  break;
               case Label.TYPE_STRATEGY:
                  if(_loc6_ != 16777215)
                  {
                     graphics.lineStyle(6,_loc6_);
                  }
                  MachinationsDraw.drawStrategy(graphics,_loc15_.x,_loc15_.y,14,_loc7_);
                  graphics.lineStyle();
                  MachinationsDraw.drawStrategy(graphics,_loc15_.x,_loc15_.y,14,_loc7_);
            }
            if(this.unique)
            {
               _loc11_ = int(_loc4_.points.length);
               _loc12_ = 0;
               while(_loc12_ < _loc11_)
               {
                  _loc6_ = SELECTED_COLOR;
                  if(_loc12_ == this._hoveringControl)
                  {
                     _loc6_ = HOVER_COLOR;
                  }
                  if(this._control >= 0 && this._control == _loc12_)
                  {
                     _loc6_ = SELECTED_COLOR2;
                  }
                  graphics.beginFill(_loc6_);
                  graphics.drawCircle(_loc4_.points[_loc12_].x - x,_loc4_.points[_loc12_].y - y,CONTROL_SIZE);
                  graphics.endFill();
                  graphics.beginFill(CONTROL_COLOR);
                  graphics.drawCircle(_loc4_.points[_loc12_].x - x,_loc4_.points[_loc12_].y - y,CONTROL_SIZE - 2);
                  graphics.endFill();
                  _loc12_++;
               }
            }
            _loc16_ = _loc4_ as ResourceConnection;
            if((Boolean(_loc16_)) && !_loc16_.instantaneous)
            {
               _loc11_ = int(_loc16_.resources.length);
               _loc12_ = 0;
               while(_loc12_ < _loc11_)
               {
                  if(_loc16_.resources[_loc12_].position >= 0)
                  {
                     _loc17_ = _loc16_.getPositionOnLine(_loc16_.resources[_loc12_].position);
                     _loc17_.x -= x;
                     _loc17_.y -= y;
                     MachinationsDraw.drawResource(graphics,_loc17_.x,_loc17_.y,_loc16_.resources[_loc12_].color);
                  }
                  _loc12_++;
               }
            }
            return;
         }
      }
      
      public function drawToSVG(param1:XML) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:Vector.<int> = null;
         var _loc10_:Vector.<Number> = null;
         var _loc11_:Boolean = false;
         var _loc12_:Vector3D = null;
         if(!parent)
         {
            return;
         }
         var _loc2_:MachinationsNode = this.element as MachinationsNode;
         if(_loc2_)
         {
            _loc4_ = Math.max(_loc2_.thickness,1);
            _loc5_ = 0;
            _loc6_ = _loc2_.color;
            if(_loc2_ is Drain)
            {
               MachinationsDraw.drawDrainToSVG(param1,_loc2_.position.x,_loc2_.position.y,_loc4_,_loc6_,16777215,_loc2_.size,_loc2_.activationMode,_loc2_.pullMode);
            }
            else if(_loc2_ is Pool)
            {
               MachinationsDraw.drawPoolToSVG(param1,_loc2_.position.x,_loc2_.position.y,_loc4_,_loc6_,16777215,_loc2_.size,_loc2_.activationMode,_loc2_.pullMode,_loc2_.resourceInputCount);
            }
            else if(_loc2_ is Delay)
            {
               MachinationsDraw.drawDelayToSVG(param1,_loc2_.position.x,_loc2_.position.y,_loc4_,_loc6_,16777215,_loc2_.size,_loc2_.activationMode,(_loc2_ as Delay).delayType);
            }
            else if(_loc2_ is Converter)
            {
               MachinationsDraw.drawConverterToSVG(param1,_loc2_.position.x,_loc2_.position.y,_loc4_,_loc6_,16777215,_loc2_.size,_loc2_.activationMode,_loc2_.pullMode);
            }
            else if(_loc2_ is Trader)
            {
               MachinationsDraw.drawTraderToSVG(param1,_loc2_.position.x,_loc2_.position.y,_loc4_,_loc6_,16777215,_loc2_.size,_loc2_.activationMode,_loc2_.pullMode);
            }
            else if(_loc2_ is Source)
            {
               MachinationsDraw.drawSourceToSVG(param1,_loc2_.position.x,_loc2_.position.y,_loc4_,_loc6_,16777215,_loc2_.size,_loc2_.activationMode,_loc2_.pullMode);
            }
            else if(_loc2_ is Gate)
            {
               MachinationsDraw.drawGateToSVG(param1,_loc2_.position.x,_loc2_.position.y,_loc4_,_loc6_,16777215,_loc2_.size,(_loc2_ as Gate).gateType,_loc2_.activationMode,_loc2_.pullMode);
            }
            else if(_loc2_ is Register)
            {
               _loc8_ = "x";
               if(_loc2_.activationMode == MachinationsNode.MODE_INTERACTIVE || (_loc2_.graph as MachinationsGraph).running)
               {
                  _loc8_ = (_loc2_ as Register).value.toString();
               }
               MachinationsDraw.drawRegisterToSVG(param1,_loc2_.position.x,_loc2_.position.y,_loc4_,_loc6_,16777215,_loc2_.size,_loc8_,_loc2_.activationMode);
            }
            else if(_loc2_ is EndCondition)
            {
               MachinationsDraw.drawEndConditionToSVG(param1,_loc2_.position.x,_loc2_.position.y,_loc4_,_loc6_,16777215,_loc2_.size,_loc2_.activationMode);
            }
            else if(_loc2_ is ArtificialPlayer)
            {
               MachinationsDraw.drawArtificialPlayerToSVG(param1,_loc2_.position.x,_loc2_.position.y,_loc4_,_loc6_,16777215,_loc2_.size,_loc2_.activationMode);
            }
            else if(_loc2_ is Chart)
            {
               (_loc2_ as Chart).toSVG(param1);
            }
            else if(_loc2_ is GroupBox)
            {
               MachinationsDraw.drawGroupBoxToSVG(param1,_loc2_.position.x,_loc2_.position.y,_loc4_,_loc6_,16777215,(_loc2_ as GroupBox).width,(_loc2_ as GroupBox).height);
            }
            _loc7_ = _loc2_.caption;
            if(_loc2_ is TextLabel && !_loc2_ is GroupBox)
            {
               if(!_loc7_ || StringUtil.trim(_loc7_) == "")
               {
                  _loc7_ = "TextLabel";
               }
            }
            if(Boolean(_loc7_) && _loc7_ != "")
            {
               if(_loc5_ == 0)
               {
                  _loc5_ = 16777215;
               }
               if(this._hoveringControl == 0)
               {
                  _loc5_ = HOVER_COLOR;
               }
               PhantomFont.drawTextToSVG(_loc7_,param1,_loc2_.captionCalculatedPosition.x + x,_loc2_.captionCalculatedPosition.y + 4.5 + y,9,_loc2_.captionAlign,"none",StringUtil.toColorStringSVG(_loc6_),2);
            }
            if(this.element is Pool)
            {
               this.drawResourcesToSVG(this.element as Pool,param1);
            }
            return;
         }
         var _loc3_:MachinationsConnection = this.element as MachinationsConnection;
         if(Boolean(_loc3_) && _loc3_.points.length > 1)
         {
            _loc9_ = new Vector.<int>();
            _loc10_ = new Vector.<Number>();
            _loc11_ = false;
            if(_loc3_.end is Chart)
            {
               _loc11_ = true;
            }
            _loc4_ = _loc3_.thickness;
            if(_loc4_ == 0)
            {
               if(_loc3_ is ResourceConnection)
               {
                  _loc4_ = 2;
               }
               else
               {
                  _loc4_ = 1;
                  _loc11_ = true;
               }
            }
            MachinationsDraw.generateConnectionData(_loc3_,_loc9_,_loc10_,0,0,_loc11_);
            _loc6_ = _loc3_.color;
            param1.appendChild(DrawUtil.drawPathToSVG(_loc9_,_loc10_,"none",StringUtil.toColorStringSVG(_loc6_),_loc4_));
            if(_loc11_)
            {
               return;
            }
            if(_loc5_ == 0)
            {
               _loc5_ = 16777215;
            }
            if(this._hoveringControl == _loc3_.points.length)
            {
               _loc5_ = HOVER_COLOR;
            }
            PhantomFont.drawTextToSVG(_loc3_.label.text,param1,_loc3_.label.calculatedPosition.x,_loc3_.label.calculatedPosition.y + 4.5,9,_loc3_.label.align,"none",StringUtil.toColorStringSVG(_loc5_),6);
            PhantomFont.drawTextToSVG(_loc3_.label.text,param1,_loc3_.label.calculatedPosition.x,_loc3_.label.calculatedPosition.y + 4.5,9,_loc3_.label.align,"none",StringUtil.toColorStringSVG(_loc6_),2);
            _loc12_ = _loc3_.getPosition();
            switch(_loc3_.label.align)
            {
               case PhantomFont.ALIGN_RIGHT:
                  _loc12_.x -= _loc3_.label.size.x;
                  break;
               case PhantomFont.ALIGN_CENTER:
                  _loc12_.x -= _loc3_.label.size.x * 0.5;
            }
            _loc12_.x -= this.x;
            _loc12_.y -= this.y + 1;
            switch(_loc3_.label.type)
            {
               case Label.TYPE_DICE:
                  MachinationsDraw.drawDiceToSVG(param1,_loc12_.x + x,_loc12_.y + y,14,_loc6_);
                  break;
               case Label.TYPE_SKILL:
                  MachinationsDraw.drawSkillToSVG(param1,_loc12_.x + x,_loc12_.y + y,14,_loc6_);
                  break;
               case Label.TYPE_MULTIPLAYER:
                  MachinationsDraw.drawMultiplayerToSVG(param1,_loc12_.x + x,_loc12_.y + y,14,_loc6_);
                  break;
               case Label.TYPE_STRATEGY:
                  MachinationsDraw.drawStrategyToSVG(param1,_loc12_.x + x,_loc12_.y + y,14,_loc6_);
            }
            return;
         }
      }
      
      private function drawResources(param1:Pool) : void
      {
         var _loc2_:uint = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc3_:int = param1.resourceCount;
         if(_loc3_ >= 0 && _loc3_ <= param1.displayCapacity)
         {
            _loc4_ = -12;
            _loc5_ = -2;
            _loc6_ = 0;
            while(_loc6_ < _loc3_)
            {
               _loc2_ = param1.resources[_loc6_].color;
               if(param1.inhibited)
               {
                  _loc2_ = INHIBITED_COLOR;
               }
               MachinationsDraw.drawResource(graphics,_loc4_,_loc5_,_loc2_);
               _loc5_ -= 4;
               if(_loc6_ % 5 == 4)
               {
                  _loc5_ += 20;
                  _loc4_ += 12;
               }
               if(_loc6_ % 15 == 14)
               {
                  _loc5_ += 10;
                  _loc4_ -= 12 * 2.5;
               }
               _loc6_++;
            }
         }
         else
         {
            _loc7_ = 12;
            if(param1.activationMode == MachinationsNode.MODE_INTERACTIVE)
            {
               _loc7_ = 9;
            }
            if(_loc3_ >= 1000)
            {
               _loc7_ *= 0.8;
            }
            _loc8_ = _loc7_ / 12 * 3;
            if(_loc3_ > 0)
            {
               _loc2_ = param1.resources[_loc3_ - 1].color;
            }
            else
            {
               _loc2_ = param1.resourceColor;
            }
            if(param1.inhibited)
            {
               _loc2_ = INHIBITED_COLOR;
            }
            graphics.lineStyle(_loc8_,_loc2_);
            PhantomFont.drawText(_loc3_.toString(),graphics,0,_loc7_ * 0.5,_loc7_,PhantomFont.ALIGN_CENTER);
            graphics.lineStyle();
         }
      }
      
      private function drawResourcesToSVG(param1:Pool, param2:XML) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc3_:int = int(param1.resources.length);
         if(_loc3_ >= 0 && _loc3_ <= param1.displayCapacity)
         {
            _loc4_ = -12;
            _loc5_ = -2;
            _loc6_ = 0;
            while(_loc6_ < _loc3_)
            {
               MachinationsDraw.drawResourceToSVG(param2,_loc4_ + this.x,_loc5_ + this.y,param1.resources[_loc6_].color);
               _loc5_ -= 4;
               if(_loc6_ % 5 == 4)
               {
                  _loc5_ += 20;
                  _loc4_ += 12;
               }
               if(_loc6_ % 15 == 14)
               {
                  _loc5_ += 10;
                  _loc4_ -= 12 * 2.5;
               }
               _loc6_++;
            }
         }
         else
         {
            _loc7_ = 12;
            if(param1.activationMode == MachinationsNode.MODE_INTERACTIVE)
            {
               _loc7_ = 9;
            }
            if(_loc3_ >= 1000)
            {
               _loc7_ *= 0.8;
            }
            _loc8_ = _loc7_ / 12 * 3;
            if(_loc3_ > 0)
            {
               PhantomFont.drawTextToSVG(_loc3_.toString(),param2,this.x,this.y + _loc7_ * 0.5,_loc7_,PhantomFont.ALIGN_CENTER,"none",StringUtil.toColorStringSVG(param1.resources[_loc3_ - 1].color),_loc8_);
            }
         }
      }
      
      public function pointInElement(param1:Number, param2:Number) : Boolean
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Vector3D = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Vector3D = null;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc3_:GroupBox = this.element as GroupBox;
         if(_loc3_)
         {
            if(_loc3_.pointInCaption(param1,param2))
            {
               return true;
            }
            if(_loc3_ is Chart)
            {
               return param1 > _loc3_.position.x - 5 && param1 < _loc3_.position.x + _loc3_.width + 5 && param2 > _loc3_.position.y - 5 && param2 < _loc3_.position.y + _loc3_.height + 25;
            }
            _loc6_ = param1 - _loc3_.position.x;
            _loc7_ = param2 - _loc3_.position.y;
            if(Math.abs(_loc6_) < 5 && _loc7_ > -5 && _loc7_ < _loc3_.height + 5)
            {
               return true;
            }
            if(Math.abs(_loc3_.width - _loc6_) < 5 && _loc7_ > -5 && _loc7_ < _loc3_.height + 5)
            {
               return true;
            }
            if(Math.abs(_loc7_) < 5 && _loc6_ > -5 && _loc6_ < _loc3_.width + 5)
            {
               return true;
            }
            if(Math.abs(_loc3_.height - _loc7_) < 5 && _loc6_ > -5 && _loc7_ < _loc3_.width + 5)
            {
               return true;
            }
            return false;
         }
         var _loc4_:MachinationsNode = this.element as MachinationsNode;
         if(_loc4_)
         {
            _loc6_ = param1 - _loc4_.position.x;
            _loc7_ = param2 - _loc4_.position.y;
            _loc8_ = _loc6_ * _loc6_ + _loc7_ * _loc7_;
            if(_loc8_ < _loc4_.size * _loc4_.size)
            {
               return true;
            }
            if(_loc4_.pointInCaption(param1,param2))
            {
               return true;
            }
         }
         var _loc5_:MachinationsConnection = this.element as MachinationsConnection;
         if(_loc5_)
         {
            _loc9_ = new Vector3D(param1,param2);
            if(this.pinsOnly)
            {
               _loc12_ = _loc5_.points[1].subtract(_loc5_.points[0]);
               _loc12_.normalize();
               _loc12_.scaleBy(7);
               _loc12_.incrementBy(_loc5_.points[0]);
               _loc12_.decrementBy(_loc9_);
               if(_loc12_.length < 7)
               {
                  return true;
               }
               _loc12_ = _loc5_.points[_loc5_.points.length - 1].subtract(_loc5_.points[_loc5_.points.length - 2]);
               _loc12_.normalize();
               _loc12_.scaleBy(-7);
               _loc12_.incrementBy(_loc5_.points[_loc5_.points.length - 1]);
               _loc12_.decrementBy(_loc9_);
               if(_loc12_.length < 7)
               {
                  return true;
               }
               return false;
            }
            if(_loc5_.label.pointInModifier(param1,param2))
            {
               return true;
            }
            _loc10_ = int(_loc5_.points.length);
            _loc11_ = 1;
            while(_loc11_ < _loc10_)
            {
               _loc12_ = _loc5_.points[_loc11_].subtract(_loc5_.points[_loc11_ - 1]);
               _loc13_ = _loc12_.normalize();
               _loc14_ = MathUtil.distanceToLine(_loc5_.points[_loc11_ - 1],_loc12_,_loc13_,_loc9_);
               if(_loc14_ < SELECTED_THICKNESS)
               {
                  return true;
               }
               _loc11_++;
            }
         }
         return false;
      }
      
      public function pointOnControl(param1:Number, param2:Number) : int
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Vector3D = null;
         var _loc3_:GroupBox = this.element as GroupBox;
         if(_loc3_)
         {
            if(_loc3_.pointInCaption(param1,param2))
            {
               return 0;
            }
            _loc6_ = int(_loc3_.points.length);
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               _loc8_ = param1 - _loc3_.points[_loc7_].x - _loc3_.position.x;
               _loc9_ = param2 - _loc3_.points[_loc7_].y - _loc3_.position.y;
               _loc10_ = _loc8_ * _loc8_ + _loc9_ * _loc9_;
               if(_loc10_ < CONTROL_SIZE * CONTROL_SIZE)
               {
                  return _loc7_ + 1;
               }
               _loc7_++;
            }
            return -1;
         }
         var _loc4_:MachinationsNode = this.element as MachinationsNode;
         if(_loc4_ is TextLabel)
         {
            return -1;
         }
         if(_loc4_)
         {
            if(_loc4_.pointInCaption(param1,param2))
            {
               return 0;
            }
         }
         var _loc5_:MachinationsConnection = this.element as MachinationsConnection;
         if(_loc5_)
         {
            _loc11_ = new Vector3D(param1,param2);
            _loc6_ = int(_loc5_.points.length);
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               _loc8_ = param1 - _loc5_.points[_loc7_].x;
               _loc9_ = param2 - _loc5_.points[_loc7_].y;
               _loc10_ = _loc8_ * _loc8_ + _loc9_ * _loc9_;
               if(_loc10_ < CONTROL_SIZE * CONTROL_SIZE)
               {
                  return _loc7_;
               }
               _loc7_++;
            }
            if(_loc5_.label.pointInModifier(param1,param2))
            {
               return _loc5_.points.length;
            }
         }
         return -1;
      }
      
      public function moveBy(param1:int, param2:int) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:MachinationsNode = this.element as MachinationsNode;
         if(_loc3_)
         {
            x += param1;
            y += param2;
            _loc3_.moveBy(param1,param2);
         }
         var _loc4_:MachinationsConnection = this.element as MachinationsConnection;
         if(_loc4_)
         {
            _loc5_ = int(_loc4_.points.length);
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               if(_loc6_ == 0 && Boolean(_loc4_.start))
               {
                  _loc4_.calculateStartPosition();
               }
               else if(_loc6_ == _loc5_ - 1 && Boolean(_loc4_.end))
               {
                  _loc4_.calculateEndPosition();
               }
               else
               {
                  _loc4_.points[_loc6_].x += param1;
                  _loc4_.points[_loc6_].y += param2;
               }
               _loc6_++;
            }
            _loc4_.calculateModifierPosition();
            this.draw();
         }
      }
      
      public function moveControl(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc5_:GroupBox = this.element as GroupBox;
         if(_loc5_)
         {
            switch(this._control)
            {
               case 0:
                  _loc8_ = 0;
                  _loc9_ = 999999;
                  _loc10_ = 15;
                  if(_loc5_ is Chart)
                  {
                     _loc10_ = 6;
                  }
                  _loc11_ = 4;
                  while(_loc11_ <= _loc10_)
                  {
                     param1 = _loc5_.points[_loc11_].x + _loc5_.position.x - param3;
                     param2 = _loc5_.points[_loc11_].y + _loc5_.position.y - param4;
                     _loc12_ = param1 * param1 + param2 * param2;
                     if(_loc12_ < _loc9_)
                     {
                        _loc8_ = _loc11_;
                        _loc9_ = _loc12_;
                     }
                     _loc11_++;
                  }
                  if(_loc8_ > 0)
                  {
                     _loc5_.captionPosition = _loc8_;
                  }
                  break;
               case 1:
                  _loc5_.width = _loc5_.width - param3 + _loc5_.position.x;
                  _loc5_.position.x = param3;
                  _loc5_.height = _loc5_.height - param4 + _loc5_.position.y;
                  _loc5_.position.y = param4;
                  break;
               case 2:
                  _loc5_.width = param3 - _loc5_.position.x;
                  _loc5_.height = _loc5_.height - param4 + _loc5_.position.y;
                  _loc5_.position.y = param4;
                  break;
               case 3:
                  _loc5_.width = _loc5_.width - param3 + _loc5_.position.x;
                  _loc5_.position.x = param3;
                  _loc5_.height = param4 - _loc5_.position.y;
                  break;
               case 4:
                  _loc5_.width = param3 - _loc5_.position.x;
                  _loc5_.height = param4 - _loc5_.position.y;
            }
            return;
         }
         var _loc6_:MachinationsNode = this.element as MachinationsNode;
         if(_loc6_)
         {
            if(this._control == 0)
            {
               _loc13_ = Math.atan2(param4 - y,param3 - x);
               _loc13_ = _loc13_ / (Math.PI * 2);
               _loc13_ = _loc13_ % 1;
               if(_loc13_ < 0)
               {
                  _loc13_ += 1;
               }
               _loc6_.captionPosition = _loc13_;
               this.draw();
            }
         }
         var _loc7_:MachinationsConnection = this.element as MachinationsConnection;
         if(_loc7_)
         {
            if(this._control == _loc7_.points.length)
            {
               _loc7_.label.position = _loc7_.findClosestPointTo(param3,param4);
               if(Math.abs(_loc7_.label.position - 0.5) < 0.05)
               {
                  _loc7_.label.position = 0.5;
               }
               _loc7_.calculateModifierPosition(param3,param4);
               this.draw();
            }
            else
            {
               _loc7_.points[this._control].x = param3;
               _loc7_.points[this._control].y = param4;
               if(this._control == 0)
               {
                  _loc7_.start = null;
                  _loc7_.calculateStartPosition(_loc7_.points[this._control]);
               }
               else if(this._control == _loc7_.points.length - 1)
               {
                  _loc7_.end = null;
                  _loc7_.calculateEndPosition(_loc7_.points[this._control]);
               }
               else
               {
                  _loc7_.recalculatePoint(this._control);
               }
               this.draw();
            }
         }
      }
      
      public function deleteControl() : void
      {
         var _loc1_:MachinationsConnection = this.element as MachinationsConnection;
         if(_loc1_)
         {
            if(this.control > 0 && this.control < _loc1_.points.length - 1)
            {
               _loc1_.points.splice(this.control,1);
               _loc1_.recalculatePoint(this.control);
               _loc1_.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
            }
            else
            {
               _loc1_.dispose();
            }
         }
      }
      
      public function elementInRectangle(param1:Rectangle) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:MachinationsNode = this.element as MachinationsNode;
         if(_loc2_)
         {
            return _loc2_.position.x + _loc2_.size >= param1.x && _loc2_.position.x - _loc2_.size <= param1.right && _loc2_.position.y + _loc2_.size >= param1.y && _loc2_.position.y - _loc2_.size <= param1.bottom;
         }
         var _loc3_:MachinationsConnection = this.element as MachinationsConnection;
         if(_loc3_)
         {
            _loc4_ = int(_loc3_.points.length);
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               if(_loc3_.points[_loc5_].x >= param1.x && _loc3_.points[_loc5_].x <= param1.right && _loc3_.points[_loc5_].y >= param1.y && _loc3_.points[_loc5_].y <= param1.bottom)
               {
                  return true;
               }
               _loc5_++;
            }
         }
         return false;
      }
      
      public function getSnap() : Point
      {
         var _loc2_:Vector3D = null;
         var _loc1_:Point = new Point(0,0);
         if(this.element is MachinationsNode)
         {
            _loc2_ = (this.element as MachinationsNode).getPosition();
            _loc1_ = (parent as PhantomDrawPanel).trySnap(_loc2_.x,_loc2_.y);
         }
         return _loc1_;
      }
   }
}

