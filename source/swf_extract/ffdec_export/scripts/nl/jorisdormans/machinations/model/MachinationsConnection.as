package nl.jorisdormans.machinations.model
{
   import flash.geom.Vector3D;
   import nl.jorisdormans.graph.GraphConnection;
   import nl.jorisdormans.graph.GraphEvent;
   import nl.jorisdormans.phantomGraphics.PhantomFont;
   import nl.jorisdormans.utils.MathUtil;
   import nl.jorisdormans.utils.StringUtil;
   
   public class MachinationsConnection extends GraphConnection
   {
      
      public var color:uint;
      
      public var thickness:Number;
      
      public var label:Label;
      
      public var doEvents:Boolean;
      
      public var firing:Number;
      
      public var blocked:Number;
      
      private var _inhibited:Boolean;
      
      protected var communicateInhibition:Boolean = true;
      
      public function MachinationsConnection()
      {
         super();
         this.thickness = 2;
         this.color = 0;
         this.label = new Label(this,0.5,"");
      }
      
      override protected function calculateTotalLength() : void
      {
         super.calculateTotalLength();
         this.calculateModifierPosition();
      }
      
      public function calculateModifierPosition(param1:Number = -1, param2:Number = -1) : void
      {
         var _loc6_:Vector3D = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Vector3D = null;
         var _loc10_:Number = NaN;
         var _loc3_:Number = this.label.position * totalLength;
         var _loc4_:int = 1;
         this.label.calculatedNormal = new Vector3D(1,0);
         this.label.calculatedPosition = points[0].clone();
         while(_loc4_ < points.length)
         {
            _loc6_ = points[_loc4_].subtract(points[_loc4_ - 1]);
            _loc7_ = _loc6_.normalize();
            if(_loc7_ >= _loc3_)
            {
               this.label.calculatedNormal = _loc6_;
               this.label.calculatedPosition = points[_loc4_ - 1].clone();
               this.label.calculatedPosition.x += _loc6_.x * _loc3_;
               this.label.calculatedPosition.y += _loc6_.y * _loc3_;
               if(param1 > -1)
               {
                  _loc9_ = this.label.calculatedPosition.clone();
                  _loc9_.x -= param1;
                  _loc9_.y -= param2;
                  _loc9_.z = _loc9_.x;
                  _loc9_.x = -_loc9_.y;
                  _loc9_.y = _loc9_.z;
                  _loc10_ = _loc9_.dotProduct(_loc6_);
                  if(_loc10_ > 0)
                  {
                     this.label.side = 1;
                  }
                  else
                  {
                     this.label.side = -1;
                  }
               }
               _loc8_ = 10 * this.label.side;
               if(_loc6_.x > 0.94 || _loc6_.x < -0.94)
               {
                  this.label.align = PhantomFont.ALIGN_CENTER;
               }
               else if(_loc6_.y * this.label.side < 0)
               {
                  this.label.align = PhantomFont.ALIGN_LEFT;
               }
               else
               {
                  this.label.align = PhantomFont.ALIGN_RIGHT;
               }
               this.label.calculatedPosition.x -= _loc6_.y * _loc8_;
               this.label.calculatedPosition.y += _loc6_.x * _loc8_;
               break;
            }
            _loc3_ -= _loc7_;
            _loc4_++;
         }
         var _loc5_:int = int(inputs.length);
         _loc4_ = 0;
         while(_loc4_ < _loc5_)
         {
            if(inputs[_loc4_] != this)
            {
               inputs[_loc4_].calculateEndPosition();
            }
            _loc4_++;
         }
         _loc5_ = int(outputs.length);
         _loc4_ = 0;
         while(_loc4_ < _loc5_)
         {
            if(outputs[_loc4_] != this)
            {
               outputs[_loc4_].calculateStartPosition();
            }
            _loc4_++;
         }
      }
      
      override public function getPosition() : Vector3D
      {
         return this.label.calculatedPosition.clone();
      }
      
      override public function getConnection(param1:Vector3D) : Vector3D
      {
         var _loc2_:Vector3D = this.label.calculatedPosition.clone();
         switch(this.label.align)
         {
            case PhantomFont.ALIGN_LEFT:
               _loc2_.x += this.label.size.x * 0.5;
               break;
            case PhantomFont.ALIGN_RIGHT:
               _loc2_.x -= this.label.size.x * 0.5;
         }
         var _loc3_:Vector3D = param1.subtract(_loc2_);
         _loc3_.normalize();
         var _loc4_:Vector3D = MathUtil.getRectangleOutlinePoint(_loc3_,0.5 * this.label.size.x + 3,0.5 * this.label.size.y + 3);
         _loc2_.incrementBy(_loc4_);
         return _loc2_;
      }
      
      override public function generateXML() : XML
      {
         var _loc1_:XML = super.generateXML();
         _loc1_.@label = this.label.getRealText();
         _loc1_.@position = Math.round(this.label.position * 100) * 0.01 * this.label.side;
         _loc1_.@color = StringUtil.toColorString(this.color);
         _loc1_.@thickness = this.thickness;
         if(this.label.min > -Label.LIMIT)
         {
            _loc1_.@min = this.label.min.toFixed(2);
         }
         if(this.label.max < Label.LIMIT)
         {
            _loc1_.@max = this.label.max.toFixed(2);
         }
         return _loc1_;
      }
      
      override public function readXML(param1:XML) : void
      {
         super.readXML(param1);
         this.label.text = param1.@label;
         this.label.position = param1.@position;
         if(this.label.position < 0)
         {
            this.label.position *= -1;
            this.label.side = -1;
         }
         else
         {
            this.label.side = 1;
         }
         this.color = StringUtil.toColor(param1.@color);
         if(param1.@min.length() > 0)
         {
            this.label.min = parseFloat(param1.@min);
         }
         if(param1.@max.length() > 0)
         {
            this.label.max = parseFloat(param1.@max);
         }
         this.thickness = param1.@thickness;
      }
      
      public function prepare(param1:Boolean) : void
      {
         this.doEvents = param1;
         this.firing = 0;
         this.blocked = 0;
         this._inhibited = false;
         if(start is MachinationsNode)
         {
            this._inhibited = (start as MachinationsNode).inhibited;
            (start as MachinationsNode).checkInhibition();
         }
      }
      
      public function stop() : void
      {
         this.firing = 0;
         this.blocked = 0;
         this.label.stop();
         this.inhibited = false;
         dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
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
         if(this.blocked > 0)
         {
            this.blocked -= param1;
            if(this.blocked <= 0)
            {
               this.blocked = 0;
            }
            if(this.doEvents)
            {
               dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
            }
         }
      }
      
      public function get inhibited() : Boolean
      {
         return this._inhibited;
      }
      
      public function set inhibited(param1:Boolean) : void
      {
         if(this._inhibited == param1)
         {
            return;
         }
         this._inhibited = param1;
         if(end is MachinationsNode && this.communicateInhibition)
         {
            (end as MachinationsNode).checkInhibition();
         }
         if(end is ResourceConnection && this.communicateInhibition)
         {
            (end as ResourceConnection).checkInhibition();
         }
         if(this.doEvents)
         {
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE,this));
         }
      }
   }
}

