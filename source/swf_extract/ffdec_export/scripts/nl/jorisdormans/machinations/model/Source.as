package nl.jorisdormans.machinations.model
{
   import nl.jorisdormans.utils.StringUtil;
   
   public class Source extends MachinationsNode
   {
      
      private var _resourceColor:uint;
      
      public function Source()
      {
         super();
         this.resourceColor = StringUtil.toColor("Black");
         activationMode = MODE_AUTOMATIC;
      }
      
      override public function generateXML() : XML
      {
         var _loc1_:XML = super.generateXML();
         _loc1_.@resourceColor = StringUtil.toColorString(this.resourceColor);
         return _loc1_;
      }
      
      override public function readXML(param1:XML) : void
      {
         super.readXML(param1);
         this.resourceColor = StringUtil.toColor(param1.@resourceColor);
      }
      
      public function get resourceColor() : uint
      {
         return this._resourceColor;
      }
      
      public function set resourceColor(param1:uint) : void
      {
         this._resourceColor = param1;
      }
      
      override public function fire() : void
      {
         super.fire();
         this.satisfy();
      }
      
      override public function satisfy() : void
      {
         var _loc1_:int = int(outputs.length);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            if(outputs[_loc2_] is ResourceConnection && !(outputs[_loc2_] as ResourceConnection).inhibited)
            {
               (outputs[_loc2_] as ResourceConnection).produce(this);
            }
            if(outputs[_loc2_] is StateConnection)
            {
               (outputs[_loc2_] as StateConnection).fire();
            }
            _loc2_++;
         }
         super.satisfy();
      }
   }
}

