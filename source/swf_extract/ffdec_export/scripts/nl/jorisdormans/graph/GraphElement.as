package nl.jorisdormans.graph
{
   import flash.events.EventDispatcher;
   import flash.geom.Vector3D;
   
   public class GraphElement extends EventDispatcher
   {
      
      public var id:int;
      
      public var graph:Graph;
      
      public var inputs:Vector.<GraphConnection>;
      
      public var outputs:Vector.<GraphConnection>;
      
      public function GraphElement()
      {
         super();
         this.id = -1;
         this.inputs = new Vector.<GraphConnection>();
         this.outputs = new Vector.<GraphConnection>();
      }
      
      public function dispose() : void
      {
         var _loc1_:int = int(this.inputs.length);
         var _loc2_:* = int(_loc1_ - 1);
         while(_loc2_ > 0)
         {
            this.inputs[_loc2_].end = null;
            _loc2_--;
         }
         this.inputs.splice(0,_loc1_);
         this.inputs = null;
         _loc1_ = int(this.outputs.length);
         _loc2_ = int(_loc1_ - 1);
         while(_loc2_ >= 0)
         {
            this.outputs[_loc2_].start = null;
            _loc2_--;
         }
         this.outputs.splice(0,_loc1_);
         this.outputs = null;
         if(this.graph)
         {
            this.graph.removeElement(this);
            this.graph = null;
         }
         dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_DISPOSE));
      }
      
      public function generateXML() : XML
      {
         return <element/>;
      }
      
      public function readXML(param1:XML) : void
      {
      }
      
      public function removeInput(param1:GraphConnection) : void
      {
         if(!this.inputs)
         {
            return;
         }
         var _loc2_:int = int(this.inputs.length);
         var _loc3_:* = int(_loc2_ - 1);
         while(_loc3_ >= 0)
         {
            if(this.inputs[_loc3_] == param1)
            {
               this.inputs.splice(_loc3_,1);
            }
            _loc3_--;
         }
      }
      
      public function removeOutput(param1:GraphConnection) : void
      {
         if(!this.outputs)
         {
            return;
         }
         var _loc2_:int = int(this.outputs.length);
         var _loc3_:* = int(_loc2_ - 1);
         while(_loc3_ >= 0)
         {
            if(this.outputs[_loc3_] == param1)
            {
               this.outputs.splice(_loc3_,1);
            }
            _loc3_--;
         }
      }
      
      public function getPosition() : Vector3D
      {
         return new Vector3D();
      }
      
      public function getConnection(param1:Vector3D) : Vector3D
      {
         return new Vector3D();
      }
      
      public function moveBy(param1:Number, param2:Number, param3:Number = 0) : void
      {
      }
      
      public function moveTo(param1:Number, param2:Number, param3:Number = 0) : void
      {
      }
   }
}

