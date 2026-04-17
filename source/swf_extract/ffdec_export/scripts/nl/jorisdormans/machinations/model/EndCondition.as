package nl.jorisdormans.machinations.model
{
   import flash.geom.Vector3D;
   import nl.jorisdormans.graph.GraphEvent;
   import nl.jorisdormans.utils.MathUtil;
   
   public class EndCondition extends MachinationsNode
   {
      
      public function EndCondition()
      {
         super();
      }
      
      override public function prepare(param1:Boolean) : void
      {
         super.prepare(param1);
         _inhibited = true;
         if(param1)
         {
            dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
         }
      }
      
      override public function update(param1:Number) : void
      {
         if(!inhibited && !(graph as MachinationsGraph).ended)
         {
            (graph as MachinationsGraph).end(caption);
            this.firing = 0.25;
            if(doEvents)
            {
               dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
            }
         }
         if(!inhibited)
         {
            if(this.firing >= 0)
            {
               this.firing -= param1;
               if(this.firing < 0 && doEvents)
               {
                  dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
               }
            }
            else
            {
               this.firing -= param1;
               if(this.firing < -0.25 && doEvents)
               {
                  this.firing += 0.5;
                  dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
               }
            }
         }
      }
      
      override public function fire() : void
      {
         super.fire();
         (graph as MachinationsGraph).end(caption);
         this.firing = 0.25;
         _inhibited = false;
      }
      
      override public function getConnection(param1:Vector3D) : Vector3D
      {
         var _loc2_:Vector3D = position.clone();
         var _loc3_:Vector3D = param1.subtract(position);
         _loc3_.normalize();
         var _loc4_:Vector3D = MathUtil.getSquareOutlinePoint(_loc3_,0.5 * size + thickness + 1);
         _loc2_.incrementBy(_loc4_);
         return _loc2_;
      }
   }
}

