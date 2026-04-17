package nl.jorisdormans.machinations.model
{
   import flash.geom.Vector3D;
   import nl.jorisdormans.phantomGraphics.PhantomFont;
   import nl.jorisdormans.utils.MathUtil;
   
   public class GroupBox extends TextLabel
   {
      
      private static const yPlus:Number = 10;
      
      private static const yMinus:Number = -10;
      
      private static const xPlus:Number = 4;
      
      private var _width:Number = 100;
      
      private var _height:Number = 100;
      
      public var points:Vector.<Vector3D>;
      
      public function GroupBox()
      {
         super();
         this.points = new Vector.<Vector3D>();
         this.points.push(new Vector3D(0,0),new Vector3D(this._width,0),new Vector3D(0,this._height),new Vector3D(this._width,this._height));
         this.points.push(new Vector3D(xPlus,yMinus),new Vector3D(this._width * 0.5,yMinus),new Vector3D(this._width - xPlus,yMinus));
         this.points.push(new Vector3D(xPlus,yPlus),new Vector3D(this._width * 0.5,yPlus),new Vector3D(this._width - xPlus,yPlus));
         this.points.push(new Vector3D(xPlus,this._height + yMinus),new Vector3D(this._width * 0.5,this._height + yMinus),new Vector3D(this._width - xPlus,this._height + yMinus));
         this.points.push(new Vector3D(xPlus,this._height + yPlus),new Vector3D(this._width * 0.5,this._height + yPlus),new Vector3D(this._width - xPlus,this._height + yPlus));
         this.captionPosition = 7;
      }
      
      override public function get captionPosition() : Number
      {
         return super.captionPosition;
      }
      
      override public function set captionPosition(param1:Number) : void
      {
         var _loc2_:int = Math.min(15,Math.max(4,Math.floor(param1)));
         _captionPosition = _loc2_;
         if(this.points)
         {
            captionCalculatedPosition = this.points[_loc2_].clone();
         }
         else
         {
            captionCalculatedPosition = new Vector3D();
         }
         switch(_loc2_)
         {
            default:
               captionAlign = PhantomFont.ALIGN_CENTER;
               break;
            case 4:
            case 7:
            case 10:
            case 13:
               captionAlign = PhantomFont.ALIGN_LEFT;
               break;
            case 6:
            case 9:
            case 12:
            case 15:
               captionAlign = PhantomFont.ALIGN_RIGHT;
         }
      }
      
      override public function generateXML() : XML
      {
         var _loc1_:XML = super.generateXML();
         _loc1_.@width = this.width;
         _loc1_.@height = this.height;
         _loc1_.@captionPos = this.captionPosition;
         return _loc1_;
      }
      
      override public function readXML(param1:XML) : void
      {
         super.readXML(param1);
         this.width = param1.@width;
         this.height = param1.@height;
         this.captionPosition = param1.@captionPos;
      }
      
      public function get width() : Number
      {
         return this._width;
      }
      
      public function set width(param1:Number) : void
      {
         this._width = param1;
         this.points[1].x = this._width;
         this.points[3].x = this._width;
         this.points[5].x = this._width * 0.5;
         this.points[6].x = this._width - xPlus;
         this.points[8].x = this._width * 0.5;
         this.points[9].x = this._width - xPlus;
         this.points[11].x = this._width * 0.5;
         this.points[12].x = this._width - xPlus;
         this.points[14].x = this._width * 0.5;
         this.points[15].x = this._width - xPlus;
         this.captionPosition = this.captionPosition;
      }
      
      public function get height() : Number
      {
         return this._height;
      }
      
      public function set height(param1:Number) : void
      {
         this._height = param1;
         this.points[2].y = this._height;
         this.points[3].y = this._height;
         this.points[10].y = this._height + yMinus;
         this.points[11].y = this._height + yMinus;
         this.points[12].y = this._height + yMinus;
         this.points[13].y = this._height + yPlus;
         this.points[14].y = this._height + yPlus;
         this.points[15].y = this._height + yPlus;
         this.captionPosition = this.captionPosition;
      }
      
      override public function getConnection(param1:Vector3D) : Vector3D
      {
         var _loc2_:Vector3D = position.clone();
         _loc2_.x += this.width * 0.5;
         _loc2_.y += this.height * 0.5;
         var _loc3_:Vector3D = param1.subtract(_loc2_);
         _loc3_.normalize();
         var _loc4_:Vector3D = MathUtil.getRectangleOutlinePoint(_loc3_,0.5 * this.width + thickness + 1,0.5 * this.height + thickness + 1);
         _loc2_.incrementBy(_loc4_);
         return _loc2_;
      }
      
      override public function getPosition() : Vector3D
      {
         var _loc1_:Vector3D = position.clone();
         _loc1_.x += this.width * 0.5;
         _loc1_.y += this.height * 0.5;
         return _loc1_;
      }
   }
}

