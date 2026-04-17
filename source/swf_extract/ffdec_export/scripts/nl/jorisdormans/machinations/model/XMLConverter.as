package nl.jorisdormans.machinations.model
{
   public class XMLConverter
   {
      
      public function XMLConverter()
      {
         super();
      }
      
      public static function convertV35V40(param1:XML) : XML
      {
         var _loc4_:XML = null;
         var _loc2_:XML = new XML(param1.toXMLString());
         var _loc3_:XMLList = _loc2_.children();
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_.localName() == "node" && _loc4_.@symbol == "ArtificialPlayer")
            {
               _loc4_.@actionsPerTurn = _loc4_.@interval;
            }
            if(_loc4_.localName() == "node" && _loc4_.@symbol == "Delayer")
            {
               _loc4_.@symbol = "Delay";
            }
         }
         return _loc2_;
      }
      
      public static function convertV30V35(param1:XML) : XML
      {
         var _loc4_:XML = null;
         var _loc2_:XML = <graph/>;
         _loc2_.@version = "v3.5";
         _loc2_.@name = param1.@name;
         _loc2_.@author = param1.@author;
         _loc2_.@interval = param1.@interval;
         if(param1.@actions == "0")
         {
            _loc2_.@timeMode = "asynchronous";
            _loc2_.@actions = "1";
         }
         else
         {
            _loc2_.@timeMode = "turn-based";
            _loc2_.@actions = param1.@actions;
         }
         _loc2_.@distributionMode = "fixed speed";
         _loc2_.@speed = param1.@speed;
         _loc2_.@dice = param1.@dice;
         _loc2_.@skill = param1.@skill;
         _loc2_.@strategy = param1.@strategy;
         _loc2_.@multiplayer = param1.@multiplayer;
         _loc2_.@width = param1.@width;
         _loc2_.@height = param1.@height;
         _loc2_.@numberOfRuns = param1.@numberOfRuns;
         _loc2_.@visibleRuns = param1.@visibleRuns;
         var _loc3_:XMLList = param1.children();
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_.localName() == "node")
            {
               _loc2_.appendChild(convertNodeV30V35(_loc4_));
            }
            if(_loc4_.localName() == "connection")
            {
               _loc2_.appendChild(convertConnectionV30V35(_loc4_));
            }
         }
         return _loc2_;
      }
      
      private static function convertNodeV30V35(param1:XML) : XML
      {
         var _loc2_:XML = new XML(param1.toXMLString());
         if(_loc2_.@symbol == "Label")
         {
            _loc2_.@symbol = "TextLabel";
         }
         return _loc2_;
      }
      
      private static function convertConnectionV30V35(param1:XML) : XML
      {
         var _loc2_:XML = new XML(param1.toXMLString());
         if(_loc2_.@type == "State")
         {
            _loc2_.@type = "State Connection";
         }
         _loc2_.@label = param1.@modifier;
         return _loc2_;
      }
      
      public static function convertV2V30(param1:XML) : XML
      {
         var _loc5_:XML = null;
         var _loc2_:XML = <graph/>;
         _loc2_.@version = "v3.0";
         _loc2_.@name = param1.@name;
         _loc2_.@author = param1.@author;
         _loc2_.@interval = "1";
         _loc2_.@speed = param1.@speed;
         _loc2_.@actions = param1.@actions;
         _loc2_.@dice = param1.@dice;
         _loc2_.@skill = param1.@skill;
         _loc2_.@strategy = param1.@strategy;
         _loc2_.@multiplayer = param1.@multiplayer;
         _loc2_.@width = param1.@width;
         _loc2_.@height = param1.@height;
         var _loc3_:int = 0;
         var _loc4_:XMLList = param1.children();
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_.localName() == "node")
            {
               _loc2_.appendChild(convertNodeV2V30(_loc5_));
               _loc3_++;
            }
         }
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_.localName() == "connection")
            {
               _loc2_.appendChild(convertConnectionV2V30(_loc5_,_loc3_));
            }
         }
         return _loc2_;
      }
      
      private static function convertNodeV2V30(param1:XML) : XML
      {
         var _loc4_:String = null;
         var _loc2_:XML = <node/>;
         _loc2_.@symbol = param1.@symbol;
         _loc2_.@x = param1.@x;
         _loc2_.@y = param1.@y;
         _loc2_.@color = param1.@colorLine;
         _loc2_.@caption = param1.@label;
         _loc2_.@thickness = param1.@thickness;
         _loc2_.@captionPos = param1.@labelPosition == "1" ? "0.25" : "0.75";
         _loc2_.@interactive = param1.@clickable == "true" ? "1" : "0";
         _loc2_.@actions = param1.@free == "true" ? "0" : "1";
         var _loc3_:String = _loc2_.@symbol;
         switch(_loc3_)
         {
            case "Source":
            case "Converter":
            case "Drain":
               _loc2_.@resourceColor = param1.@colorResources;
               break;
            case "Pool":
               _loc2_.@resourceColor = param1.@colorResources;
               _loc2_.@startingResources = param1.@startingResources;
               _loc2_.@maxResources = param1.@maxResources;
               break;
            case "Knot":
            case "Gate":
               _loc2_.@symbol = "Gate";
               _loc4_ = param1.@type;
               _loc4_ = _loc4_.toLowerCase();
               _loc2_.@gateType = _loc4_;
               break;
            case "Chart":
               _loc2_.@width = param1.@width;
               _loc2_.@height = param1.@height;
               _loc2_.@scaleX = param1.@scaleX;
               _loc2_.@scaleY = param1.@scaleY;
               break;
            case "AIBox":
            case "ArtificialPlayer":
               _loc2_.@symbol = "ArtificialPlayer";
         }
         return _loc2_;
      }
      
      private static function convertConnectionV2V30(param1:XML, param2:int) : XML
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc8_:XML = null;
         var _loc11_:XML = null;
         var _loc3_:XML = <connection/>;
         var _loc6_:String = param1.@type;
         _loc3_.@type = _loc6_;
         _loc3_.@start = param1.@start;
         _loc4_ = int(param1.@start);
         if(_loc4_ < 0)
         {
            _loc11_ = <point/>;
            _loc11_.@x = param1.@startX;
            _loc11_.@y = param1.@startY;
            _loc3_.appendChild(_loc11_);
         }
         var _loc7_:XMLList = param1.children();
         for each(_loc8_ in _loc7_)
         {
            if(_loc8_.localName() == "waypoint")
            {
               _loc11_ = <point/>;
               _loc11_.@x = _loc8_.@x;
               _loc11_.@y = _loc8_.@y;
               _loc3_.appendChild(_loc11_);
            }
         }
         _loc3_.@end = param1.@end;
         _loc5_ = int(param1.@end);
         if(_loc5_ < 0)
         {
            _loc11_ = <point/>;
            _loc11_.@x = param1.@endX;
            _loc11_.@y = param1.@endY;
            _loc3_.appendChild(_loc11_);
         }
         var _loc9_:String = "";
         var _loc10_:Number = 0.5;
         if(param1.@startModifier != "" && param1.@endModifier != "")
         {
            if(param1.@endModifier == "*")
            {
               _loc9_ = param1.@startModifier;
               if(_loc6_ == "State")
               {
                  if(_loc9_.charAt(0) != "<" && _loc9_.charAt(1) != "=" && _loc9_.charAt(0) != ">")
                  {
                     _loc9_ = ">=" + _loc9_;
                  }
               }
            }
            else
            {
               _loc9_ = param1.@endModifier + "/" + param1.@startModifier;
            }
         }
         else if(param1.@startModifier != "")
         {
            _loc9_ = param1.@startModifier;
            _loc10_ = 0.25;
            if(_loc6_ == "State")
            {
               _loc9_ = "1/" + _loc9_;
            }
         }
         else if(param1.@endModifier != "")
         {
            _loc9_ = param1.@endModifier;
            _loc10_ = 0.75;
         }
         if(_loc9_ == "*/*")
         {
            _loc9_ = "*";
         }
         if(_loc6_ == "State" && _loc9_ == "*")
         {
            _loc9_ = ">0";
            _loc10_ = 0.5;
         }
         if(_loc6_ == "Flow" && _loc9_ == "*")
         {
            _loc10_ = 0.5;
            _loc3_.@type = "State";
         }
         _loc3_.@modifier = _loc9_;
         _loc3_.@position = _loc10_;
         _loc3_.@color = param1.@color;
         _loc3_.@thickness = param1.@thickness;
         if(_loc5_ > param2)
         {
            _loc5_ -= param2;
            _loc5_ = Math.floor(_loc5_ / 2);
            _loc5_ = _loc5_ + param2;
            _loc3_.@end = _loc5_;
         }
         if(_loc4_ > param2)
         {
            _loc4_ -= param2;
            _loc4_ = Math.floor(_loc4_ / 2);
            _loc4_ = _loc4_ + param2;
            _loc3_.@start = _loc4_;
         }
         return _loc3_;
      }
   }
}

