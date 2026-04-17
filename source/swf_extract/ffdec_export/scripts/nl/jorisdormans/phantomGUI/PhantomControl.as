package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class PhantomControl extends Sprite
   {
      
      protected var _parent:DisplayObjectContainer;
      
      private var _showing:Boolean = false;
      
      private var _enabled:Boolean = true;
      
      protected var _textField:TextField;
      
      protected var _caption:String = "";
      
      protected var _controlX:Number;
      
      protected var _controlY:Number;
      
      protected var _controlWidth:Number;
      
      protected var _controlHeight:Number;
      
      protected var _captionAlign:String;
      
      protected const ALIGN_CENTER:String = "center";
      
      protected const ALIGN_LEFT:String = "left";
      
      protected const ALIGN_RIGHT:String = "right";
      
      private var _colorScheme:int = -1;
      
      public function PhantomControl(param1:DisplayObjectContainer, param2:Number, param3:Number, param4:Number, param5:Number, param6:Boolean = true, param7:Boolean = true)
      {
         super();
         if(param1 == null)
         {
            throw new Error("Parent of a phantomControl cannot be null.");
         }
         this._parent = param1;
         this._controlX = this.x = param2;
         this._controlY = this.y = param3;
         this._controlWidth = param4;
         this._controlHeight = param5;
         this.showing = param6;
         this.enabled = param7;
         this.draw();
      }
      
      public function draw() : void
      {
      }
      
      public function get showing() : Boolean
      {
         return this._showing;
      }
      
      public function set showing(param1:Boolean) : void
      {
         this._showing = param1;
         if(!this._showing && parent != null)
         {
            parent.removeChild(this);
         }
         if(this._showing && parent == null)
         {
            this._parent.addChild(this);
         }
         if(this._showing)
         {
            this.redraw();
         }
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         var _loc3_:PhantomControl = null;
         this._enabled = param1;
         this.draw();
         var _loc2_:int = 0;
         while(_loc2_ < numChildren)
         {
            _loc3_ = getChildAt(_loc2_) as PhantomControl;
            if(_loc3_ != null)
            {
               _loc3_.enabled = param1;
            }
            _loc2_++;
         }
      }
      
      public function redraw() : void
      {
         var _loc2_:PhantomControl = null;
         this.draw();
         var _loc1_:int = 0;
         while(_loc1_ < numChildren)
         {
            _loc2_ = getChildAt(_loc1_) as PhantomControl;
            if(_loc2_ != null)
            {
               _loc2_.redraw();
            }
            _loc1_++;
         }
      }
      
      public function get caption() : String
      {
         return this._caption;
      }
      
      public function set caption(param1:String) : void
      {
         this._caption = param1;
         if(this._caption.length > 0)
         {
            if(this._textField == null)
            {
               this.createTextField(param1);
            }
            else
            {
               this._textField.text = param1;
            }
         }
         else if(this._textField != null)
         {
            this._textField.text = "";
         }
         if(this._textField != null)
         {
            switch(this._captionAlign)
            {
               case this.ALIGN_LEFT:
                  this._textField.x = PhantomGUISettings.borderWidth * 2;
                  break;
               case this.ALIGN_RIGHT:
                  this._textField.width = this._textField.textWidth;
                  this._textField.x = PhantomGUISettings.borderWidth * 2 + Math.max(0,this._controlWidth - PhantomGUISettings.borderWidth * 6 - this._textField.textWidth);
                  break;
               case this.ALIGN_CENTER:
                  this._textField.x = PhantomGUISettings.borderWidth * 2 + Math.max(0,this._controlWidth - PhantomGUISettings.borderWidth * 6 - this._textField.textWidth) * 0.5;
            }
         }
      }
      
      public function get controlWidth() : Number
      {
         return this._controlWidth;
      }
      
      public function get controlHeight() : Number
      {
         return this._controlHeight;
      }
      
      public function get colorScheme() : int
      {
         if(this._colorScheme < 0)
         {
            if(this._parent is PhantomControl)
            {
               return (this._parent as PhantomControl).colorScheme;
            }
            return 0;
         }
         return this._colorScheme;
      }
      
      public function set colorScheme(param1:int) : void
      {
         this._colorScheme = param1;
         this.redraw();
      }
      
      protected function createTextField(param1:String) : void
      {
         var _loc2_:uint = PhantomGUISettings.colorSchemes[this.colorScheme].colorFont;
         if(!this._enabled)
         {
            _loc2_ = PhantomGUISettings.colorSchemes[this.colorScheme].colorBorderDisabled;
         }
         this._textField = new TextField();
         this._textField.width = this._controlWidth - PhantomGUISettings.borderWidth * 4;
         this._textField.x = PhantomGUISettings.borderWidth * 2;
         this._textField.height = PhantomGUISettings.fontSize * 1.6;
         this._textField.y = (this._controlHeight - this._textField.height) / 2 - PhantomGUISettings.fontSize * 0;
         this._textField.selectable = false;
         this._textField.mouseEnabled = false;
         if(param1.charAt(0) == "*")
         {
            this._textField.defaultTextFormat = new TextFormat(PhantomGUISettings.fontName,PhantomGUISettings.fontSize,_loc2_,true);
            param1 = param1.substr(1);
         }
         else if(param1.charAt(0) == "/")
         {
            this._textField.defaultTextFormat = new TextFormat(PhantomGUISettings.fontName,PhantomGUISettings.fontSize,_loc2_,false,true);
            param1 = param1.substr(1);
         }
         else
         {
            this._textField.defaultTextFormat = new TextFormat(PhantomGUISettings.fontName,PhantomGUISettings.fontSize,_loc2_);
         }
         this._textField.text = param1;
         addChild(this._textField);
      }
      
      public function setPosition(param1:Number, param2:Number) : void
      {
         this.x = this._controlX = param1;
         this.y = this._controlY = param2;
      }
      
      public function setSize(param1:Number, param2:Number) : void
      {
         this._controlWidth = param1;
         this._controlHeight = param2;
         this.draw();
      }
      
      public function getStageX() : Number
      {
         var _loc1_:DisplayObjectContainer = parent;
         var _loc2_:Number = x;
         while(_loc1_ != null)
         {
            _loc2_ += _loc1_.x;
            _loc1_ = _loc1_.parent;
         }
         return _loc2_;
      }
      
      public function getStageY() : Number
      {
         var _loc1_:DisplayObjectContainer = parent;
         var _loc2_:Number = y;
         while(_loc1_ != null)
         {
            _loc2_ += _loc1_.y;
            _loc1_ = _loc1_.parent;
         }
         return _loc2_;
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
   }
}

