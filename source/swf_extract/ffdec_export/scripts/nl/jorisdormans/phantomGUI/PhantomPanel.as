package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   
   public class PhantomPanel extends PhantomControl
   {
      
      protected var _scrollX:Number;
      
      protected var _scrollY:Number;
      
      private var _maskShape:Sprite;
      
      private var _scrollH:PhantomHorizontalScrollbar;
      
      private var _scrollV:PhantomVerticalScrollbar;
      
      private var _filler:Sprite;
      
      public var horizontalScrollBarAlwaysVisible:Boolean;
      
      public var verticalScrollBarAlwaysVisible:Boolean;
      
      public function PhantomPanel(param1:DisplayObjectContainer, param2:Number, param3:Number, param4:Number, param5:Number, param6:Boolean = true, param7:Boolean = true)
      {
         super(param1,param2,param3,param4,param5,param6,param7);
         this.horizontalScrollBarAlwaysVisible = false;
         this.verticalScrollBarAlwaysVisible = false;
         this._scrollX = 0;
         this._scrollY = 0;
         this.setSize(param4,param5);
      }
      
      override public function draw() : void
      {
         var _loc1_:uint = PhantomGUISettings.colorSchemes[colorScheme].colorFace;
         if(!enabled)
         {
            _loc1_ = PhantomGUISettings.colorSchemes[colorScheme].colorFaceDisabled;
         }
         graphics.clear();
         graphics.beginFill(_loc1_);
         graphics.drawRect(0,0,_controlWidth,_controlHeight);
         graphics.endFill();
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         var _loc8_:PhantomControl = null;
         var _loc3_:int = 0;
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         while(_loc3_ < numChildren)
         {
            _loc8_ = getChildAt(_loc3_) as PhantomControl;
            if(_loc8_ != null)
            {
               if(_loc8_.x + _loc8_.controlWidth > _loc4_)
               {
                  _loc4_ = _loc8_.x + _loc8_.controlWidth * _loc8_.scaleX;
               }
               if(_loc8_.y + _loc8_.controlHeight > _loc5_)
               {
                  _loc5_ = _loc8_.y + _loc8_.controlHeight * _loc8_.scaleY;
               }
            }
            _loc3_++;
         }
         _controlWidth = param1;
         _controlHeight = param2;
         var _loc6_:Number = 0;
         var _loc7_:Number = 0;
         if(_loc4_ > param1 || this.horizontalScrollBarAlwaysVisible)
         {
            _loc7_ = PhantomVerticalScrollbar.BARSIZE;
         }
         if(_loc5_ > param2 - _loc7_ || this.verticalScrollBarAlwaysVisible)
         {
            _loc6_ = PhantomHorizontalScrollbar.BARSIZE;
         }
         if(_loc4_ > param1 - _loc6_ || this.horizontalScrollBarAlwaysVisible)
         {
            _loc7_ = PhantomVerticalScrollbar.BARSIZE;
         }
         if(_loc7_ > 0)
         {
            if(this._scrollH == null)
            {
               this._scrollH = new PhantomHorizontalScrollbar(this._scrollX,Math.round(_loc4_),Math.round(_controlWidth - _loc6_),_parent,_controlX,_controlY + _controlHeight - PhantomHorizontalScrollbar.BARSIZE,_controlWidth - _loc6_,showing,enabled);
               this._scrollH.onChange = this.moveChildren;
            }
            else
            {
               this._scrollH.x = _controlX;
               this._scrollH.y = _controlY + _controlHeight - PhantomHorizontalScrollbar.BARSIZE;
               this._scrollH.setLength(_controlWidth - _loc6_);
               this._scrollH.setValues(this._scrollX,Math.round(_loc4_),Math.round(_controlWidth - _loc6_));
            }
         }
         else if(this._scrollH != null)
         {
            if(this._scrollH.parent != null)
            {
               this._scrollH.parent.removeChild(this._scrollH);
            }
            this._scrollH = null;
         }
         if(_loc6_ > 0)
         {
            if(this._scrollV == null)
            {
               this._scrollV = new PhantomVerticalScrollbar(this._scrollY,Math.round(_loc5_),Math.round(_controlHeight - _loc7_),_parent,_controlX + _controlWidth - PhantomVerticalScrollbar.BARSIZE,_controlY,_controlHeight - _loc7_,showing,enabled);
               this._scrollV.onChange = this.moveChildren;
            }
            else
            {
               this._scrollV.x = _controlX + _controlWidth - PhantomVerticalScrollbar.BARSIZE;
               this._scrollV.y = _controlY;
               this._scrollV.setLength(_controlHeight - _loc7_);
               this._scrollV.setValues(this._scrollY,Math.round(_loc5_),Math.round(_controlHeight - _loc7_));
            }
         }
         else if(this._scrollV != null)
         {
            if(this._scrollV.parent != null)
            {
               this._scrollV.parent.removeChild(this._scrollV);
            }
            this._scrollV = null;
         }
         if(_loc7_ > 0 && _loc6_ > 0)
         {
            if(this._filler == null)
            {
               this._filler = new Sprite();
               _parent.addChild(this._filler);
            }
            this._filler.x = x + _controlWidth - PhantomVerticalScrollbar.BARSIZE;
            this._filler.y = y + _controlHeight - PhantomHorizontalScrollbar.BARSIZE;
            this._filler.graphics.clear();
            this._filler.graphics.beginFill(PhantomGUISettings.colorSchemes[colorScheme].colorFaceDisabled);
            this._filler.graphics.drawRect(0,0,PhantomVerticalScrollbar.BARSIZE,PhantomHorizontalScrollbar.BARSIZE);
            this._filler.graphics.endFill();
         }
         else if(this._filler != null)
         {
            this._filler.parent.removeChild(this._filler);
            this._filler = null;
         }
         if(this._maskShape != null && this._maskShape.parent != null)
         {
            this._maskShape.parent.removeChild(this._maskShape);
         }
         this._maskShape = new Sprite();
         this._maskShape.x = getStageX();
         this._maskShape.y = getStageY();
         this._maskShape.x = 0;
         this._maskShape.y = 0;
         addChild(this._maskShape);
         this._maskShape.graphics.clear();
         this._maskShape.graphics.beginFill(8912896,0.6);
         this._maskShape.graphics.drawRect(0,0,_controlWidth - _loc6_,_controlHeight - _loc7_);
         this._maskShape.graphics.endFill();
         mask = this._maskShape;
         this.draw();
      }
      
      public function checkSize() : void
      {
         this.setSize(_controlWidth,_controlHeight);
      }
      
      private function moveChildren(param1:PhantomControl) : void
      {
         var _loc4_:int = 0;
         var _loc5_:PhantomControl = null;
         var _loc2_:Number = this._scrollX;
         var _loc3_:Number = this._scrollY;
         if(this._scrollH != null)
         {
            _loc2_ = this._scrollH.currentValue;
         }
         if(this._scrollV != null)
         {
            _loc3_ = this._scrollV.currentValue;
         }
         if(_loc2_ != this._scrollX || _loc3_ != this._scrollY)
         {
            _loc4_ = 0;
            while(_loc4_ < numChildren)
            {
               _loc5_ = getChildAt(_loc4_) as PhantomControl;
               if(_loc5_ is PhantomControl)
               {
                  _loc5_.setPosition(_loc5_.x - _loc2_ + this._scrollX,_loc5_.y - _loc3_ + this._scrollY);
               }
               _loc4_++;
            }
            this._scrollX = _loc2_;
            this._scrollY = _loc3_;
         }
      }
      
      public function scrollTo(param1:Number, param2:Number) : void
      {
         var _loc5_:int = 0;
         var _loc6_:PhantomControl = null;
         var _loc3_:Number = param1;
         var _loc4_:Number = param2;
         if(_loc3_ != this._scrollX || _loc4_ != this._scrollY)
         {
            _loc5_ = 0;
            while(_loc5_ < numChildren)
            {
               _loc6_ = getChildAt(_loc5_) as PhantomControl;
               if(_loc6_ is PhantomControl)
               {
                  _loc6_.setPosition(_loc6_.x - _loc3_ + this._scrollX,_loc6_.y - _loc4_ + this._scrollY);
               }
               _loc5_++;
            }
            this._scrollX = _loc3_;
            this._scrollY = _loc4_;
         }
         if(this._scrollH != null)
         {
            this._scrollH.setValues(this._scrollX);
         }
         if(this._scrollV != null)
         {
            this._scrollV.setValues(this._scrollY);
         }
      }
   }
}

