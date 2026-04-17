package nl.jorisdormans.graph
{
   public class GraphSymbol
   {
      
      public var name:String;
      
      public var abbrivation:String;
      
      public var terminal:Number;
      
      public var colorLine:uint;
      
      public var colorFill:uint;
      
      public var colorText:uint;
      
      public var nodeClass:Class;
      
      public function GraphSymbol(param1:Class, param2:String, param3:String, param4:Number, param5:uint, param6:uint, param7:uint)
      {
         super();
         this.nodeClass = param1;
         this.name = param2;
         this.abbrivation = param3;
         this.terminal = param4;
         this.colorLine = param5;
         this.colorFill = param6;
         this.colorText = param7;
      }
   }
}

