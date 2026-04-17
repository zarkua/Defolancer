package nl.jorisdormans.graph
{
   public class GraphGrammar
   {
      
      public var symbols:Vector.<GraphSymbol>;
      
      public var connectionTypes:Vector.<GraphConnectionType>;
      
      public var name:String;
      
      public function GraphGrammar()
      {
         super();
         this.symbols = new Vector.<GraphSymbol>();
         this.connectionTypes = new Vector.<GraphConnectionType>();
         this.clear();
         this.createDefaultGrammar();
      }
      
      public function clear() : void
      {
         this.symbols.splice(0,this.symbols.length);
         this.connectionTypes.splice(0,this.connectionTypes.length);
         this.name = "";
      }
      
      public function createDefaultGrammar() : void
      {
         this.symbols.push(new GraphSymbol(GraphNode,"node","n",1,0,16777215,0));
         this.connectionTypes.push(new GraphConnectionType(GraphConnection,"connection",0,1,GraphConnectionType.STYLE_SOLID,GraphConnectionType.ARROW_NONE,GraphConnectionType.ARROW_MEDIUM));
      }
      
      public function getSymbol(param1:String) : GraphSymbol
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.symbols.length)
         {
            if(this.symbols[_loc2_].name == param1)
            {
               return this.symbols[_loc2_];
            }
            _loc2_++;
         }
         if(this.symbols.length > 0)
         {
            return this.symbols[0];
         }
         return null;
      }
      
      public function getConnectionType(param1:String) : GraphConnectionType
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.connectionTypes.length)
         {
            if(this.connectionTypes[_loc2_].name == param1)
            {
               return this.connectionTypes[_loc2_];
            }
            _loc2_++;
         }
         if(this.connectionTypes.length > 0)
         {
            return this.connectionTypes[0];
         }
         return null;
      }
   }
}

