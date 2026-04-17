package nl.jorisdormans.machinations.model
{
   import flash.display.Sprite;
   
   public class Resource extends Sprite
   {
      
      public var color:uint;
      
      public var position:Number;
      
      public var connection:ResourceConnection;
      
      public function Resource(param1:uint, param2:Number)
      {
         super();
         this.color = param1;
         this.position = param2;
         this.connection = null;
      }
   }
}

