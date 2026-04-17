package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class PhantomDrawControl extends PhantomControl
   {
      
      protected var _hover:Boolean = false;
      
      protected var _selected:Boolean = false;
      
      private var _mouseDownX:Number;
      
      private var _mouseDownY:Number;
      
      private var _moving:Boolean;
      
      public var onSelect:Function;
      
      public var onDeselect:Function;
      
      public var onMove:Function;
      
      public var onEndMove:Function;
      
      public var rotationPointX:Number;
      
      public var rotationPointY:Number;
      
      public var tag:int = -1;
      
      public function PhantomDrawControl(param1:Function, param2:Function, param3:DisplayObjectContainer, param4:Number, param5:Number)
      {
         super(param3,param4,param5,PhantomGUISettings.drawControlSize,PhantomGUISettings.drawControlSize);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         this.onMove = param1;
         this.onEndMove = param2;
      }
      
      public function onMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:PhantomDrawControl = null;
         if(!param1.shiftKey)
         {
            if(parent != null)
            {
               _loc2_ = 0;
               while(_loc2_ < parent.numChildren)
               {
                  _loc3_ = parent.getChildAt(_loc2_) as PhantomDrawControl;
                  if(_loc3_ != null && _loc3_.selected && _loc3_ != this)
                  {
                     _loc3_.selected = false;
                  }
                  _loc2_++;
               }
            }
         }
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         this._mouseDownX = param1.stageX;
         this._mouseDownY = param1.stageY;
         this._moving = false;
         this.selected = true;
         parent.setChildIndex(this,parent.numChildren - 1);
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Point = null;
         var _loc10_:int = 0;
         var _loc11_:PhantomDrawControl = null;
         if(param1.target != this && param1.target != this.parent)
         {
            return;
         }
         var _loc2_:Number = param1.stageX - this._mouseDownX;
         var _loc3_:Number = param1.stageY - this._mouseDownY;
         var _loc4_:Boolean = false;
         if(param1.ctrlKey && (this.rotationPointX != _controlX || this.rotationPointY != _controlY))
         {
            _loc4_ = true;
         }
         if(_loc4_)
         {
            _loc5_ = _controlX - this.rotationPointX;
            _loc6_ = _controlY - this.rotationPointY;
            _loc7_ = Math.sqrt(_loc5_ * _loc5_ + _loc6_ * _loc6_);
            _loc5_ += _loc2_;
            _loc6_ += _loc3_;
            _loc8_ = Math.atan2(_loc6_,_loc5_);
            _loc2_ = this.rotationPointX + Math.cos(_loc8_) * _loc7_ - _controlX;
            _loc3_ = this.rotationPointY + Math.sin(_loc8_) * _loc7_ - _controlY;
         }
         if(parent is PhantomDrawPanel && !_loc4_)
         {
            _loc9_ = (parent as PhantomDrawPanel).trySnap(_controlX + _loc2_,_controlY + _loc3_);
            _loc2_ += _loc9_.x;
            _loc3_ += _loc9_.y;
         }
         if(!this._moving)
         {
            if(_loc2_ * _loc2_ + _loc3_ * _loc3_ > 25)
            {
               this._moving = true;
            }
         }
         if(this._moving)
         {
            if(param1.shiftKey && !_loc4_)
            {
               if(Math.abs(_loc2_) > Math.abs(_loc3_))
               {
                  _loc3_ = 0;
               }
               else
               {
                  _loc2_ = 0;
               }
            }
            if(parent != null)
            {
               _loc10_ = 0;
               while(_loc10_ < parent.numChildren)
               {
                  _loc11_ = parent.getChildAt(_loc10_) as PhantomDrawControl;
                  if(_loc11_ != null && _loc11_.selected)
                  {
                     if(parent is PhantomDrawPanel)
                     {
                        _loc11_.x = Math.min((parent as PhantomDrawPanel).controlWidth - 1,Math.max(0,_loc11_._controlX + _loc2_));
                        _loc11_.y = Math.min((parent as PhantomDrawPanel).controlHeight - 1,Math.max(0,_loc11_._controlY + _loc3_));
                     }
                     else
                     {
                        _loc11_.x = _loc11_._controlX + _loc2_;
                        _loc11_.y = _loc11_._controlY + _loc3_;
                     }
                     if(_loc11_.onMove != null)
                     {
                        _loc11_.onMove(_loc11_);
                     }
                  }
                  _loc10_++;
               }
            }
         }
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:PhantomDrawControl = null;
         if(stage == null)
         {
            return;
         }
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         if(parent != null)
         {
            _loc2_ = 0;
            while(_loc2_ < parent.numChildren)
            {
               _loc3_ = parent.getChildAt(_loc2_) as PhantomDrawControl;
               if(_loc3_ != null && _loc3_.selected)
               {
                  _loc3_.setPosition(_loc3_.x,_loc3_.y);
                  if(_loc3_.onEndMove != null)
                  {
                     _loc3_.onEndMove(_loc3_);
                  }
               }
               _loc2_++;
            }
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.hover = true;
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.hover = false;
      }
      
      override public function draw() : void
      {
         graphics.clear();
         graphics.beginFill(PhantomGUISettings.colorSchemes[colorScheme].colorDrawControlOutline,0);
         graphics.drawCircle(0.5,0.5,PhantomGUISettings.drawControlSize);
         graphics.endFill();
         graphics.beginFill(PhantomGUISettings.colorSchemes[colorScheme].colorDrawControlOutline,1);
         graphics.drawCircle(0.5,0.5,PhantomGUISettings.drawControlSize);
         graphics.drawCircle(0.5,0.5,PhantomGUISettings.drawControlSize - 3);
         graphics.endFill();
         if(this._selected)
         {
            graphics.beginFill(PhantomGUISettings.colorSchemes[colorScheme].colorDrawControlSelected);
         }
         else if(this._hover)
         {
            graphics.beginFill(PhantomGUISettings.colorSchemes[colorScheme].colorDrawControlHover);
         }
         else
         {
            graphics.beginFill(PhantomGUISettings.colorSchemes[colorScheme].colorDrawControl);
         }
         graphics.drawCircle(0.5,0.5,PhantomGUISettings.drawControlSize - 0.5);
         graphics.drawCircle(0.5,0.5,PhantomGUISettings.drawControlSize - 2.5);
         graphics.endFill();
      }
      
      public function get hover() : Boolean
      {
         return this._hover;
      }
      
      public function set hover(param1:Boolean) : void
      {
         this._hover = param1;
         this.draw();
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         if(this._selected == param1)
         {
            return;
         }
         this._selected = param1;
         if(this._selected && this.onSelect != null)
         {
            this.onSelect(this);
         }
         if(!this._selected && this.onDeselect != null)
         {
            this.onDeselect(this);
         }
         this.draw();
      }
      
      override public function setPosition(param1:Number, param2:Number) : void
      {
         super.setPosition(param1,param2);
         this.rotationPointX = param1;
         this.rotationPointY = param2;
      }
   }
}

