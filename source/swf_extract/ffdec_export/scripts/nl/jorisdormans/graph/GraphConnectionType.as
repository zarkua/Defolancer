package nl.jorisdormans.graph
{
   public class GraphConnectionType
   {
      
      public static var STYLE_SOLID:String = "solid";
      
      public static var STYLE_DOTTED:String = "dotted";
      
      public static var ARROW_NONE:String = "none";
      
      public static var ARROW_SMALL:String = "small";
      
      public static var ARROW_MEDIUM:String = "medium";
      
      public static var ARROW_LARGE:String = "large";
      
      public var name:String;
      
      public var color:uint;
      
      public var thickness:Number;
      
      public var lineStyle:String;
      
      public var arrowStart:String;
      
      public var arrowEnd:String;
      
      public var connectionClass:Class;
      
      public function GraphConnectionType(param1:Class, param2:String, param3:uint, param4:Number = 1, param5:String = "solid", param6:String = "none", param7:String = "medium")
      {
         super();
         this.connectionClass = param1;
         this.name = param2;
         this.color = param3;
         this.thickness = param4;
         this.lineStyle = param5;
         this.arrowStart = param6;
         this.arrowEnd = param7;
      }
   }
}

