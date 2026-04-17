package nl.jorisdormans.machinations.model
{
   import nl.jorisdormans.phantomGraphics.DrawUtil;
   import nl.jorisdormans.utils.StringUtil;
   
   public class ChartData
   {
      
      public var data:Vector.<Number>;
      
      public var color:uint;
      
      public var color2:uint;
      
      public var thickness:int;
      
      public var connection:StateConnection;
      
      public var name:String;
      
      public var run:int;
      
      public function ChartData(param1:StateConnection, param2:int)
      {
         super();
         this.data = new Vector.<Number>();
         this.color = param1.color;
         this.color2 = DrawUtil.lerpColor(this.color,16777215,0.7);
         this.thickness = param1.thickness;
         this.connection = param1;
         this.data.push(param1.state);
         if(param1.start is Pool)
         {
            this.name = (param1.start as Pool).caption;
         }
         else
         {
            this.name = "";
         }
         this.run = param2;
      }
      
      public function toString() : String
      {
         var _loc1_:String = this.name + "," + this.thickness.toString() + "," + StringUtil.toColorString(this.color);
         var _loc2_:int = 0;
         while(_loc2_ < this.data.length)
         {
            _loc1_ += "," + this.data[_loc2_].toString();
            _loc2_++;
         }
         return _loc1_;
      }
   }
}

