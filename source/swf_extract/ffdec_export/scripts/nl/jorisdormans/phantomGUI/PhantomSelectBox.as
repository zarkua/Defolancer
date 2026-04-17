package nl.jorisdormans.phantomGUI
{
   import flash.display.DisplayObjectContainer;
   import flash.events.MouseEvent;
   
   public class PhantomSelectBox extends PhantomPanel
   {
      
      private var _cells:Vector.<PhantomSelectCell>;
      
      private var _selectedOption:String;
      
      private var _selectedIndex:int;
      
      public var cellHeight:Number = 20;
      
      public var onSelect:Function;
      
      public function PhantomSelectBox(param1:DisplayObjectContainer, param2:Number, param3:Number, param4:Number, param5:Number, param6:Boolean = true, param7:Boolean = true)
      {
         super(param1,param2,param3,param4,param5,param6,param7);
         verticalScrollBarAlwaysVisible = true;
         checkSize();
         this._cells = new Vector.<PhantomSelectCell>();
         this._selectedIndex = -1;
         this._selectedOption = "";
         addEventListener(MouseEvent.MOUSE_UP,this.doMouseUp);
      }
      
      private function doMouseUp(param1:MouseEvent) : void
      {
         if(param1.target == this)
         {
            this._selectedIndex = -1;
            this._selectedOption = "";
            if(this.onSelect != null)
            {
               this.onSelect(this);
            }
         }
      }
      
      public function addOption(param1:String) : void
      {
         scrollTo(0,0);
         this._cells.push(new PhantomSelectCell(param1,this.changeCell,this,0,this._cells.length * this.cellHeight,_controlWidth - PhantomVerticalScrollbar.BARSIZE,this.cellHeight,showing,enabled));
         this._cells[this._cells.length - 1].index = this._cells.length - 1;
         checkSize();
         scrollTo(0,Math.max(0,this._cells.length * 20 - _controlHeight));
      }
      
      private function changeCell(param1:PhantomSelectCell) : void
      {
         if(param1.selected)
         {
            this._selectedOption = param1.caption;
            this._selectedIndex = param1.index;
         }
         else
         {
            this._selectedOption = "";
            this._selectedIndex = -1;
         }
         if(this.onSelect != null)
         {
            this.onSelect(this);
         }
      }
      
      public function get optionCount() : int
      {
         return this._cells.length;
      }
      
      public function get selectedOption() : String
      {
         return this._selectedOption;
      }
      
      public function set selectedOption(param1:String) : void
      {
         var _loc2_:PhantomSelectCell = null;
         if(this._selectedOption == param1)
         {
            return;
         }
         if(this._selectedIndex >= 0)
         {
            this._cells[this._selectedIndex].selected = false;
         }
         this._selectedOption = param1;
         this._selectedIndex = -1;
         for each(_loc2_ in this._cells)
         {
            if(_loc2_.caption == param1)
            {
               this._selectedIndex = _loc2_.index;
               break;
            }
         }
         if(this._selectedIndex >= 0)
         {
            this._cells[this._selectedIndex].selected = true;
         }
         else
         {
            this._selectedOption = "";
         }
      }
      
      public function findOption(param1:String) : void
      {
         var _loc2_:int = 0;
         if(this._selectedIndex >= 0 && this._selectedIndex < this._cells.length)
         {
            this._cells[this._selectedIndex].selected = false;
         }
         this._selectedIndex = -1;
         if(param1.length > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < this._cells.length)
            {
               if(this._cells[_loc2_].caption.substr(0,param1.length).toLowerCase() == param1.toLowerCase())
               {
                  this._selectedIndex = _loc2_;
                  break;
               }
               _loc2_++;
            }
         }
         if(this._selectedIndex >= 0)
         {
            this._cells[this._selectedIndex].selected = true;
            this._selectedOption = this._cells[this._selectedIndex].caption;
         }
         else
         {
            this._selectedOption = "";
         }
      }
      
      public function get selectedIndex() : int
      {
         return this._selectedIndex;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         if(this._selectedIndex == param1)
         {
            return;
         }
         if(this._selectedIndex >= this._cells.length)
         {
            this._selectedIndex = this._cells.length - 1;
         }
         if(this._selectedIndex >= 0)
         {
            this._cells[this._selectedIndex].selected = false;
         }
         this._selectedIndex = param1;
         if(this._selectedIndex >= 0)
         {
            this._cells[this._selectedIndex].selected = true;
            this._selectedOption = this._cells[this._selectedIndex].caption;
         }
         else
         {
            this._selectedOption = "";
            this._selectedIndex = -1;
         }
      }
      
      public function setOptions(param1:Vector.<String>) : void
      {
         scrollTo(0,0);
         var _loc2_:String = this._selectedOption;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            if(_loc3_ < this._cells.length)
            {
               this._cells[_loc3_].caption = param1[_loc3_];
            }
            else
            {
               this._cells.push(new PhantomSelectCell(param1[_loc3_],this.changeCell,this,0,_loc3_ * this.cellHeight,_controlWidth - PhantomVerticalScrollbar.BARSIZE,this.cellHeight,showing,enabled));
               this._cells[_loc3_].index = _loc3_;
            }
            _loc3_++;
         }
         if(param1.length < this._cells.length)
         {
            _loc3_ = int(param1.length);
            while(_loc3_ < this._cells.length)
            {
               this._cells[_loc3_].dispose();
               _loc3_++;
            }
            this._cells.splice(param1.length,this._cells.length - param1.length);
         }
         checkSize();
      }
      
      public function clearOptions() : void
      {
         scrollTo(0,0);
         var _loc1_:int = 0;
         while(_loc1_ < this._cells.length)
         {
            this._cells[_loc1_].dispose();
            _loc1_++;
         }
         this._cells.splice(0,this._cells.length);
         checkSize();
         this._selectedIndex = -1;
         this._selectedOption = "";
      }
      
      override public function draw() : void
      {
         var _loc1_:uint = PhantomGUISettings.colorSchemes[colorScheme].colorFaceDisabled;
         graphics.clear();
         graphics.beginFill(_loc1_);
         graphics.drawRect(0,0,_controlWidth,_controlHeight);
         graphics.endFill();
      }
      
      public function changeOption(param1:String) : void
      {
         if(this.selectedIndex < 0)
         {
            return;
         }
         this._cells[this.selectedIndex].caption = param1;
      }
      
      public function scrollToOption(param1:int) : void
      {
         if(param1 < 0)
         {
            return;
         }
         if(this._cells.length == 0)
         {
            scrollTo(0,0);
            return;
         }
         var _loc2_:Number = this._cells[0].controlHeight;
         var _loc3_:int = _controlHeight / _loc2_;
         scrollTo(0,Math.min(this.optionCount - _loc3_,Math.max(0,(param1 - Math.floor(_loc3_ / 2)) * _loc2_)));
      }
      
      public function setOption(param1:int, param2:String) : void
      {
         if(param1 >= 0 && param1 < this._cells.length)
         {
            this._cells[param1].caption = param2;
         }
      }
      
      public function enableOption(param1:int, param2:Boolean) : void
      {
         if(param1 >= 0 && param1 < this._cells.length)
         {
            this._cells[param1].enabled = param2;
         }
      }
   }
}

