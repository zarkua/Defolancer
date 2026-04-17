package nl.jorisdormans.machinations.view
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   
   public class MultiSelector extends Sprite
   {
      
      private var setWidth:Number;
      
      private var setHeight:Number;
      
      public function MultiSelector()
      {
         super();
      }
      
      public function setPosition(param1:DisplayObjectContainer, param2:Number, param3:Number) : void
      {
         this.x = param2;
         this.y = param3;
         param1.addChild(this);
         this.setSize(0,0);
      }
      
      public function setSize(param1:Number, param2:Number) : void
      {
         this.setWidth = param1;
         this.setHeight = param2;
         graphics.clear();
         graphics.lineStyle(2,MachinationsViewElement.SELECTED_COLOR);
         graphics.drawRect(0,0,param1,param2);
      }
      
      public function getRectangle() : Rectangle
      {
         var _loc1_:Rectangle = new Rectangle(0,0,Math.abs(this.setWidth),Math.abs(this.setHeight));
         _loc1_.x = Math.min(x,x + this.setWidth);
         _loc1_.y = Math.min(y,y + this.setHeight);
         return _loc1_;
      }
   }
}

