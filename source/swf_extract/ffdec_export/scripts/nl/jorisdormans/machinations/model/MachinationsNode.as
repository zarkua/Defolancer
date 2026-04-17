package nl.jorisdormans.machinations.model
{
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import nl.jorisdormans.graph.GraphConnection;
   import nl.jorisdormans.graph.GraphEvent;
   import nl.jorisdormans.graph.GraphNode;
   import nl.jorisdormans.phantomGraphics.PhantomFont;
   import nl.jorisdormans.utils.MathUtil;
   import nl.jorisdormans.utils.StringUtil;
   
   public class MachinationsNode extends GraphNode
   {
      
      public static const MODE_AUTOMATIC:String = "automatic";
      
      public static const MODE_INTERACTIVE:String = "interactive";
      
      public static const MODE_PASSIVE:String = "passive";
      
      public static const MODE_ONSTART:String = "onstart";
      
      public static const PULL_MODE_PULL_ANY:String = "pull any";
      
      public static const PULL_MODE_PULL_ALL:String = "pull all";
      
      public static const PULL_MODE_PUSH_ANY:String = "push any";
      
      public static const PULL_MODE_PUSH_ALL:String = "push all";
      
      public var thickness:Number;
      
      public var color:uint;
      
      public var size:Number;
      
      public var caption:String;
      
      public var actions:int;
      
      protected var _captionPosition:Number;
      
      public var captionAlign:String;
      
      public var captionCalculatedPosition:Vector3D;
      
      public var captionSize:Point;
      
      public var activationMode:String;
      
      public var pullMode:String;
      
      protected var doEvents:Boolean;
      
      public var resourceInputCount:int;
      
      public var resourceOutputCount:int;
      
      public var stateOutputCount:int;
      
      public var stateInputCount:int;
      
      protected var _inhibited:Boolean;
      
      public var aiControled:Boolean;
      
      public var firing:Number;
      
      public var fireFlag:Boolean;
      
      public function MachinationsNode()
      {
         super();
         this.size = 20;
         this.thickness = 2;
         this.color = 0;
         this.caption = "";
         this.captionCalculatedPosition = new Vector3D(0,0);
         this.captionPosition = 0.25;
         this.captionSize = new Point();
         this.activationMode = MODE_PASSIVE;
         this.actions = 1;
         this.fireFlag = false;
         this.pullMode = PULL_MODE_PULL_ANY;
      }
      
      override public function getConnection(param1:Vector3D) : Vector3D
      {
         var _loc2_:Vector3D = position.clone();
         var _loc3_:Vector3D = param1.subtract(position);
         _loc3_.normalize();
         _loc3_.scaleBy(this.size + this.thickness + 2);
         _loc2_.incrementBy(_loc3_);
         return _loc2_;
      }
      
      override public function generateXML() : XML
      {
         var _loc1_:XML = super.generateXML();
         _loc1_.@color = StringUtil.toColorString(this.color);
         _loc1_.@caption = this.caption;
         if(!(this is TextLabel))
         {
            _loc1_.@thickness = this.thickness;
            _loc1_.@captionPos = Math.round(this.captionPosition * 100) / 100;
            _loc1_.@activationMode = this.activationMode;
            _loc1_.@pullMode = this.pullMode;
            _loc1_.@actions = this.actions;
         }
         return _loc1_;
      }
      
      override public function readXML(param1:XML) : void
      {
         super.readXML(param1);
         this.color = StringUtil.toColor(param1.@color);
         this.caption = param1.@caption;
         if(!(this is TextLabel))
         {
            this.thickness = param1.@thickness;
            this.captionPosition = param1.@captionPos;
            if(param1.@activationMode.length() > 0)
            {
               this.activationMode = param1.@activationMode;
            }
            if(param1.@pullMode.length() > 0)
            {
               this.pullMode = param1.@pullMode;
            }
            if(param1.@interactive == "1")
            {
               this.activationMode = MODE_INTERACTIVE;
            }
            this.actions = param1.@actions;
         }
      }
      
      public function pointInCaption(param1:Number, param2:Number) : Boolean
      {
         param1 -= position.x;
         param2 -= position.y;
         switch(this.captionAlign)
         {
            default:
            case PhantomFont.ALIGN_LEFT:
               return param1 >= this.captionCalculatedPosition.x - 5 && param1 <= this.captionCalculatedPosition.x + this.captionSize.x + 5 && param2 >= this.captionCalculatedPosition.y - 10 && param2 <= this.captionCalculatedPosition.y + this.captionSize.y;
            case PhantomFont.ALIGN_CENTER:
               return param1 >= this.captionCalculatedPosition.x - this.captionSize.x * 0.5 - 5 && param1 <= this.captionCalculatedPosition.x + this.captionSize.x * 0.5 + 5 && param2 >= this.captionCalculatedPosition.y - 10 && param2 <= this.captionCalculatedPosition.y + this.captionSize.y;
            case PhantomFont.ALIGN_RIGHT:
               return param1 >= this.captionCalculatedPosition.x - this.captionSize.x - 5 && param1 <= this.captionCalculatedPosition.x + 5 && param2 >= this.captionCalculatedPosition.y - 10 && param2 <= this.captionCalculatedPosition.y + this.captionSize.y;
         }
      }
      
      public function get captionPosition() : Number
      {
         return this._captionPosition;
      }
      
      public function set captionPosition(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         if(Math.abs(param1 - 0) < 0.05)
         {
            param1 = 0;
         }
         if(Math.abs(param1 - 0.25) < 0.05)
         {
            param1 = 0.25;
         }
         if(Math.abs(param1 - 0.5) < 0.05)
         {
            param1 = 0.5;
         }
         if(Math.abs(param1 - 0.75) < 0.05)
         {
            param1 = 0.75;
         }
         if(Math.abs(param1 - 1) < 0.05)
         {
            param1 = 0;
         }
         this._captionPosition = param1;
         if(this.size == 0)
         {
            this.captionCalculatedPosition.x = 0;
            this.captionCalculatedPosition.y = 0;
         }
         else
         {
            this.captionCalculatedPosition.x = Math.cos(this._captionPosition * Math.PI * 2);
            this.captionCalculatedPosition.y = Math.sin(this._captionPosition * Math.PI * 2);
            if(this is Register || this is EndCondition || this is ArtificialPlayer)
            {
               this.captionCalculatedPosition = MathUtil.getSquareOutlinePoint(this.captionCalculatedPosition,0.5 * this.size + this.thickness + 7);
            }
            else
            {
               this.captionCalculatedPosition.scaleBy(this.size + 10);
            }
            if(this._captionPosition == 0.25 || this._captionPosition == 0.75)
            {
               this.captionAlign = PhantomFont.ALIGN_CENTER;
               if(this._captionPosition == 0.75)
               {
                  _loc2_ = 0;
                  _loc3_ = 0;
                  while(_loc3_ < this.caption.length)
                  {
                     if(this.caption.charAt(_loc3_) == "|")
                     {
                        _loc2_ += 16;
                     }
                     _loc3_++;
                  }
                  this.captionCalculatedPosition.y -= _loc2_;
               }
            }
            else if(this._captionPosition < 0.25 || this._captionPosition > 0.75)
            {
               this.captionAlign = PhantomFont.ALIGN_LEFT;
            }
            else
            {
               this.captionAlign = PhantomFont.ALIGN_RIGHT;
            }
         }
      }
      
      public function get inhibited() : Boolean
      {
         return this._inhibited;
      }
      
      public function set inhibited(param1:Boolean) : void
      {
         var _loc3_:int = 0;
         if(this._inhibited == param1)
         {
            return;
         }
         this._inhibited = param1;
         if(this.doEvents)
         {
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this));
         }
         var _loc2_:int = int(outputs.length);
         while(_loc3_ < _loc2_)
         {
            if(outputs[_loc3_] is ResourceConnection)
            {
               (outputs[_loc3_] as ResourceConnection).checkInhibition();
            }
            if(outputs[_loc3_] is StateConnection)
            {
               (outputs[_loc3_] as StateConnection).checkInhibition();
            }
            _loc3_++;
         }
      }
      
      public function checkInhibition() : void
      {
         var _loc5_:int = 0;
         var _loc1_:Boolean = false;
         var _loc2_:int = 0;
         var _loc3_:int = int(inputs.length);
         var _loc4_:int = 0;
         while(_loc5_ < _loc3_)
         {
            if(inputs[_loc5_] is StateConnection && (inputs[_loc5_] as StateConnection).label.type != Label.TYPE_TRIGGER && !((inputs[_loc5_] as StateConnection).start is Gate) && (inputs[_loc5_] as StateConnection).inhibited)
            {
               _loc1_ = true;
            }
            if(inputs[_loc5_] is StateConnection && this is Pool && !(inputs[_loc5_] as StateConnection).inhibited && (inputs[_loc5_] as StateConnection).isSetter())
            {
               _loc2_++;
            }
            if(inputs[_loc5_] is ResourceConnection && !(inputs[_loc5_] as ResourceConnection).inhibited)
            {
               _loc2_++;
            }
            if(inputs[_loc5_] is ResourceConnection && (inputs[_loc5_] as ResourceConnection).requestQueue != null && (inputs[_loc5_] as ResourceConnection).requestQueue.length > 0)
            {
               _loc4_++;
            }
            _loc5_++;
         }
         if(_loc2_ == 0)
         {
            if(this is Pool)
            {
               if((this as Pool).resources.length == 0)
               {
                  _loc1_ = true;
               }
            }
         }
         if(_loc4_ > 0)
         {
            _loc1_ = false;
         }
         this.inhibited = _loc1_;
      }
      
      public function prepare(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         _loc2_ = int(outputs.length);
         this.resourceOutputCount = 0;
         this.stateOutputCount = 0;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(outputs[_loc3_] is ResourceConnection)
            {
               ++this.resourceOutputCount;
            }
            if(outputs[_loc3_] is StateConnection)
            {
               ++this.stateOutputCount;
            }
            _loc3_++;
         }
         _loc2_ = int(inputs.length);
         this.resourceInputCount = 0;
         this.stateInputCount = 0;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(inputs[_loc3_] is ResourceConnection)
            {
               ++this.resourceInputCount;
            }
            if(inputs[_loc3_] is StateConnection)
            {
               ++this.stateInputCount;
            }
            _loc3_++;
         }
         this.aiControled = false;
         this.firing = 0;
         this.doEvents = param1;
         if(param1)
         {
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this));
         }
      }
      
      public function stop() : void
      {
         this.firing = 0;
         this.inhibited = false;
         if(this.doEvents)
         {
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this));
         }
      }
      
      public function autoFire() : void
      {
         if((this.activationMode == MODE_AUTOMATIC || this.fireFlag) && !this._inhibited && !this.aiControled)
         {
            this.fire();
            this.fireFlag = false;
         }
      }
      
      public function update(param1:Number) : void
      {
         if(this.firing > 0)
         {
            this.firing -= param1;
            if(this.firing <= 0)
            {
               this.firing = 0;
               if(this.doEvents)
               {
                  dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
               }
            }
         }
      }
      
      public function click() : void
      {
         if((graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_SYNCHRONOUS)
         {
            this.fireFlag = true;
            if(this.doEvents)
            {
               dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
            }
         }
         else
         {
            this.fire();
            if((graph as MachinationsGraph).actionsPerTurn > 0 && this.activationMode == MODE_INTERACTIVE)
            {
               (graph as MachinationsGraph).actionsThisTurn += this.actions;
            }
         }
      }
      
      public function fire() : void
      {
         this.setFiring();
      }
      
      public function setFiring() : void
      {
         if(this.activationMode == MODE_AUTOMATIC && !(this is ArtificialPlayer) && !this.aiControled)
         {
            return;
         }
         this.firing = Math.min((graph as MachinationsGraph).fireInterval * 0.75,0.5);
         if(this.doEvents)
         {
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this));
         }
      }
      
      public function satisfy() : void
      {
         this.checkInhibition();
      }
      
      public function receiveResource(param1:uint, param2:ResourceConnection) : void
      {
         if(this.checkInputs())
         {
            this.satisfy();
         }
      }
      
      public function pull() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:ResourceConnection = null;
         var _loc1_:int = int(inputs.length);
         var _loc5_:Boolean = false;
         _loc3_ = 0;
         while(_loc3_ < _loc1_)
         {
            _loc4_ = inputs[_loc3_] as ResourceConnection;
            if(_loc4_)
            {
               if(!_loc4_.inhibited)
               {
                  _loc2_ = _loc4_.delivered;
                  _loc2_ += _loc4_.resources.length;
                  if(!_loc4_.pull(_loc2_))
                  {
                     _loc5_ = true;
                  }
               }
               else
               {
                  _loc5_ = true;
               }
            }
            _loc3_++;
         }
         if(_loc5_)
         {
            _loc3_ = 0;
            while(_loc3_ < outputs.length)
            {
               if(outputs[_loc3_] is StateConnection && (outputs[_loc3_] as StateConnection).label.type == Label.TYPE_REVERSE_TRIGGER)
               {
                  (outputs[_loc3_] as StateConnection).reverseFire();
               }
               _loc3_++;
            }
         }
         if(_loc5_ && this.pullMode == PULL_MODE_PULL_ALL)
         {
            this.undoPull();
         }
         if(this.checkInputs())
         {
            this.satisfy();
         }
      }
      
      public function checkInputs() : Boolean
      {
         var _loc4_:ResourceConnection = null;
         var _loc5_:int = 0;
         var _loc1_:int = int(inputs.length);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            _loc4_ = inputs[_loc2_] as ResourceConnection;
            if(_loc4_)
            {
               if(_loc4_.requestQueue.length > 0 && _loc4_.delivered < _loc4_.requestQueue[0])
               {
                  return false;
               }
               if(_loc4_.requestQueue.length == 0)
               {
                  return false;
               }
            }
            _loc2_++;
         }
         var _loc3_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            _loc4_ = inputs[_loc2_] as ResourceConnection;
            if(_loc4_)
            {
               if(_loc4_.requestQueue.length > 0)
               {
                  _loc5_ = _loc4_.requestQueue[0];
                  _loc4_.delivered -= _loc5_;
                  if(_loc4_.delivered < 0)
                  {
                     _loc4_.delivered = 0;
                  }
                  _loc4_.requestQueue.splice(0,1);
                  _loc3_ += _loc5_;
               }
            }
            _loc2_++;
         }
         return _loc3_ > 0;
      }
      
      public function undoPull() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < inputs.length)
         {
            if(inputs[_loc1_] is ResourceConnection)
            {
               (inputs[_loc1_] as ResourceConnection).undoPull(false);
            }
            _loc1_++;
         }
      }
      
      override public function removeInput(param1:GraphConnection) : void
      {
         super.removeInput(param1);
         if(param1 is ResourceConnection)
         {
            --this.resourceInputCount;
            if(this.doEvents)
            {
               dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this));
            }
         }
      }
   }
}

