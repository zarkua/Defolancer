package nl.jorisdormans.graph
{
   import flash.geom.Vector3D;
   
   public class GraphNode extends GraphElement
   {
      
      public var position:Vector3D;
      
      public var symbol:GraphSymbol;
      
      public function GraphNode()
      {
         super();
         this.position = new Vector3D();
         this.symbol = null;
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
      
      override public function getPosition() : Vector3D
      {
         return this.position.clone();
      }
      
      override public function getConnection(param1:Vector3D) : Vector3D
      {
         return this.position.clone();
      }
      
      override public function moveBy(param1:Number, param2:Number, param3:Number = 0) : void
      {
         this.moveTo(this.position.x + param1,this.position.y + param2,this.position.z + param3);
      }
      
      override public function moveTo(param1:Number, param2:Number, param3:Number = 0) : void
      {
         this.position.x = param1;
         this.position.y = param2;
         this.position.z = param3;
         var _loc4_:int = int(inputs.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            inputs[_loc5_].calculateEndPosition();
            _loc5_++;
         }
         _loc4_ = int(outputs.length);
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            outputs[_loc5_].calculateStartPosition();
            _loc5_++;
         }
      }
      
      override public function generateXML() : XML
      {
         var _loc1_:XML = super.generateXML();
         _loc1_.setName("node");
         _loc1_.@symbol = this.symbol.name;
         _loc1_.@x = Math.round(this.position.x);
         _loc1_.@y = Math.round(this.position.y);
         return _loc1_;
      }
      
      override public function readXML(param1:XML) : void
      {
         super.readXML(param1);
         this.position.x = param1.@x;
         this.position.y = param1.@y;
      }
   }
}

