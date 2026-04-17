package nl.jorisdormans.graph
{
   import flash.events.EventDispatcher;
   import flash.geom.Vector3D;
   
   public class Graph extends EventDispatcher
   {
      
      public var elements:Vector.<GraphElement>;
      
      public var grammar:GraphGrammar;
      
      public function Graph()
      {
         super();
         this.elements = new Vector.<GraphElement>();
         this.clear();
      }
      
      public function addElement(param1:GraphElement) : void
      {
         param1.graph = this;
         this.elements.push(param1);
      }
      
      public function removeElement(param1:GraphElement) : void
      {
         var _loc2_:int = int(this.elements.length);
         var _loc3_:* = int(_loc2_ - 1);
         while(_loc3_ >= 0)
         {
            if(this.elements[_loc3_] == param1)
            {
               this.elements.splice(_loc3_,1);
            }
            _loc3_--;
         }
      }
      
      private function setIds() : void
      {
         var _loc1_:int = int(this.elements.length);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            this.elements[_loc2_].id = _loc2_;
            _loc2_++;
         }
      }
      
      public function generateXML() : XML
      {
         this.setIds();
         var _loc1_:XML = <graph/>;
         var _loc2_:int = int(this.elements.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_.appendChild(this.elements[_loc3_].generateXML());
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function readXML(param1:XML) : void
      {
         var _loc3_:XML = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:GraphConnection = null;
         this.clear();
         var _loc2_:XMLList = param1.children();
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_.localName() == "node")
            {
               this.addNodeXML(_loc3_);
            }
            if(_loc3_.localName() == "connection")
            {
               this.addConnectionXML(_loc3_);
            }
         }
         _loc4_ = int(this.elements.length);
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc6_ = this.elements[_loc5_] as GraphConnection;
            if(_loc6_)
            {
               if(_loc6_.startId >= 0)
               {
                  _loc6_.start = this.elements[_loc6_.startId];
               }
               if(_loc6_.endId >= 0)
               {
                  _loc6_.end = this.elements[_loc6_.endId];
               }
            }
            _loc5_++;
         }
      }
      
      public function addXML(param1:XML) : void
      {
         var _loc4_:XML = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:GraphConnection = null;
         var _loc2_:int = int(this.elements.length);
         var _loc3_:XMLList = param1.children();
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_.localName() == "node")
            {
               this.addNodeXML(_loc4_);
            }
            if(_loc4_.localName() == "connection")
            {
               this.addConnectionXML(_loc4_);
            }
         }
         _loc5_ = int(this.elements.length);
         _loc6_ = _loc2_;
         while(_loc6_ < _loc5_)
         {
            _loc7_ = this.elements[_loc6_] as GraphConnection;
            if(_loc7_)
            {
               if(_loc7_.startId >= 0)
               {
                  _loc7_.start = this.elements[_loc2_ + _loc7_.startId];
               }
               if(_loc7_.endId >= 0)
               {
                  _loc7_.end = this.elements[_loc2_ + _loc7_.endId];
               }
            }
            _loc6_++;
         }
      }
      
      private function addNodeXML(param1:XML) : void
      {
         var _loc2_:GraphSymbol = this.grammar.getSymbol(param1.@symbol);
         var _loc3_:GraphNode = new _loc2_.nodeClass();
         _loc3_.symbol = _loc2_;
         _loc3_.readXML(param1);
         this.addElement(_loc3_);
         dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_ADD,_loc3_));
      }
      
      public function addConnectionXML(param1:XML) : void
      {
         var _loc2_:GraphConnectionType = this.grammar.getConnectionType(param1.@type);
         var _loc3_:GraphConnection = new _loc2_.connectionClass();
         _loc3_.type = _loc2_;
         _loc3_.readXML(param1);
         this.addElement(_loc3_);
         dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_ADD,_loc3_));
      }
      
      public function clear() : void
      {
         var _loc1_:int = int(this.elements.length);
         var _loc2_:* = int(_loc1_ - 1);
         while(_loc2_ >= 0)
         {
            this.elements[_loc2_].dispose();
            _loc2_--;
         }
      }
      
      public function addNode(param1:String, param2:Vector3D) : GraphNode
      {
         var _loc3_:GraphSymbol = this.grammar.getSymbol(param1);
         var _loc4_:GraphNode = new _loc3_.nodeClass();
         _loc4_.symbol = _loc3_;
         _loc4_.position = param2.clone();
         this.addElement(_loc4_);
         dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_ADD,_loc4_));
         return _loc4_;
      }
      
      public function addConnection(param1:String, param2:Vector3D, param3:Vector3D) : GraphConnection
      {
         var _loc4_:GraphConnectionType = this.grammar.getConnectionType(param1);
         var _loc5_:GraphConnection = new _loc4_.connectionClass();
         _loc5_.type = _loc4_;
         _loc5_.points[0] = param2;
         _loc5_.points[1] = param3;
         _loc5_.calculateStartPosition(param2);
         _loc5_.calculateEndPosition(param3);
         this.addElement(_loc5_);
         dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_ADD,_loc5_));
         return _loc5_;
      }
   }
}

