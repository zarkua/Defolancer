package nl.jorisdormans.machinations.model
{
   import nl.jorisdormans.graph.GraphEvent;
   import nl.jorisdormans.utils.StringUtil;
   
   public class APInstruction
   {
      
      private var condition:Array;
      
      private var parameters:Vector.<String>;
      
      private var command:String;
      
      private var counter:int;
      
      private var actionsOfCommand:int;
      
      private var artificialPlayer:ArtificialPlayer;
      
      public function APInstruction(param1:ArtificialPlayer, param2:String)
      {
         var _loc4_:String = null;
         super();
         this.artificialPlayer = param1;
         this.command = StringUtil.getCommand(param2);
         param2 = param2.substr(this.command.length);
         this.command = StringUtil.trim(this.command);
         switch(this.command.toLowerCase())
         {
            case "if":
               _loc4_ = StringUtil.getCondition(param2);
               param2 = param2.substr(_loc4_.length);
               _loc4_ = StringUtil.trim(_loc4_);
               this.condition = MachinationsScriptExpression.toPostFix(_loc4_);
               this.command = StringUtil.getCommand(param2);
               param2 = param2.substr(this.command.length);
               this.command = StringUtil.trim(this.command);
         }
         this.parameters = StringUtil.getParameters(param2);
         var _loc3_:int = 0;
         while(_loc3_ < this.parameters.length)
         {
            this.parameters[_loc3_] = StringUtil.trim(this.parameters[_loc3_]);
            _loc3_++;
         }
         this.counter = 0;
         this.actionsOfCommand = 0;
      }
      
      public function getVariable(param1:String) : Number
      {
         var _loc2_:MachinationsNode = null;
         var _loc3_:String = null;
         if((this.artificialPlayer.graph as MachinationsGraph).colorCoding > 0)
         {
            _loc2_ = (this.artificialPlayer.graph as MachinationsGraph).findNodeByCaptionAndColor(param1,this.artificialPlayer.color);
         }
         else
         {
            _loc2_ = (this.artificialPlayer.graph as MachinationsGraph).findNodeByCaption(param1);
         }
         if(_loc2_ is Pool)
         {
            return (_loc2_ as Pool).resourceCount;
         }
         if(_loc2_ is Register)
         {
            return (_loc2_ as Register).value;
         }
         switch(param1.toLowerCase())
         {
            case "pregen0":
               return this.artificialPlayer.pregeneratedRandom[0];
            case "pregen1":
               return this.artificialPlayer.pregeneratedRandom[1];
            case "pregen2":
               return this.artificialPlayer.pregeneratedRandom[2];
            case "pregen3":
               return this.artificialPlayer.pregeneratedRandom[3];
            case "pregen4":
               return this.artificialPlayer.pregeneratedRandom[4];
            case "pregen5":
               return this.artificialPlayer.pregeneratedRandom[5];
            case "pregen6":
               return this.artificialPlayer.pregeneratedRandom[6];
            case "pregen7":
               return this.artificialPlayer.pregeneratedRandom[7];
            case "pregen8":
               return this.artificialPlayer.pregeneratedRandom[8];
            case "pregen9":
               return this.artificialPlayer.pregeneratedRandom[9];
            case "random":
               return Math.random();
            case "actions":
               return this.artificialPlayer.actionsExecuted;
            case "steps":
               return (this.artificialPlayer.graph as MachinationsGraph).steps;
            case "actionsofcommand":
               return this.actionsOfCommand;
            case "actionsperstep":
               return this.artificialPlayer.actionsPerStep;
            default:
               _loc3_ = "Cannot find pool, register or variable| labeled \'" + param1 + "\'";
               if((this.artificialPlayer.graph as MachinationsGraph).colorCoding > 0)
               {
                  _loc3_ += " (color " + StringUtil.toColorString(this.artificialPlayer.color).toLowerCase() + ")";
               }
               this.artificialPlayer.graph.dispatchEvent(new GraphEvent(GraphEvent.GRAPH_WARNING,null,_loc3_));
               return 0;
         }
      }
      
      public function activate() : Boolean
      {
         if(this.condition)
         {
            if(MachinationsScriptExpression.evaluate(this.condition,this) == 0)
            {
               return false;
            }
         }
         ++this.actionsOfCommand;
         switch(this.command.toLowerCase())
         {
            case "fire":
               this.commandFire();
               return true;
            case "fireall":
               this.commandFireAll();
               return true;
            case "firesequence":
            case "do":
               this.commandFireSequence();
               return true;
            case "firerandom":
            case "choose":
               this.commandFireRandom();
               return true;
            case "increase":
               this.changeRegister(1);
               return true;
            case "decrease":
               this.changeRegister(-1);
               return true;
            case "endturn":
               this.endTurn();
               return true;
            case "stopdiagram":
               this.stopDiagram();
               return true;
            case "activate":
               this.activateAP();
               return true;
            case "deactivate":
               this.artificialPlayer.deactivate();
               return true;
            default:
               return false;
         }
      }
      
      private function clickNode(param1:MachinationsNode) : void
      {
         if(!param1)
         {
            return;
         }
         param1.click();
         param1.setFiring();
      }
      
      private function fireNode(param1:String) : void
      {
         var _loc3_:Vector.<MachinationsNode> = null;
         var _loc5_:String = null;
         var _loc2_:MachinationsGraph = this.artificialPlayer.graph as MachinationsGraph;
         if(!_loc2_)
         {
            return;
         }
         if(_loc2_.colorCoding > 0)
         {
            _loc3_ = _loc2_.findAllNodesByCaptionAndColor(param1,this.artificialPlayer.color);
         }
         else
         {
            _loc3_ = _loc2_.findAllNodesByCaption(param1);
         }
         if(_loc3_.length < 1)
         {
            _loc5_ = "Cannot find node \'" + param1 + "\'";
            if(_loc2_.colorCoding > 0)
            {
               _loc5_ += "|(color " + StringUtil.toColorString(this.artificialPlayer.color).toLowerCase() + ")";
            }
            _loc2_.dispatchEvent(new GraphEvent(GraphEvent.GRAPH_ERROR,null,_loc5_));
         }
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            this.clickNode(_loc3_[_loc4_]);
            _loc4_++;
         }
      }
      
      private function commandFire() : void
      {
         if(this.parameters.length > 0)
         {
            this.fireNode(this.parameters[0]);
         }
      }
      
      private function commandFireAll() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.parameters.length)
         {
            this.fireNode(this.parameters[_loc1_]);
            _loc1_++;
         }
      }
      
      private function commandFireSequence() : void
      {
         if(this.parameters.length > 0)
         {
            this.fireNode(this.parameters[this.counter]);
            ++this.counter;
            this.counter %= this.parameters.length;
         }
      }
      
      private function commandFireRandom() : void
      {
         var _loc1_:int = 0;
         if(this.parameters.length > 0)
         {
            _loc1_ = Math.random() * this.parameters.length;
            this.fireNode(this.parameters[_loc1_]);
         }
      }
      
      private function changeRegister(param1:int) : void
      {
         var _loc3_:Register = null;
         var _loc2_:MachinationsGraph = this.artificialPlayer.graph as MachinationsGraph;
         if(this.parameters.length > 0 && Boolean(_loc2_))
         {
            _loc3_ = _loc2_.findNodeByCaptionAndColor(this.parameters[0],this.artificialPlayer.color) as Register;
            if(Boolean(_loc3_) && _loc3_.activationMode == MachinationsNode.MODE_INTERACTIVE)
            {
               _loc3_.interaction = param1 * _loc3_.valueStep;
               _loc3_.fire();
            }
         }
      }
      
      private function endTurn() : void
      {
         var _loc1_:MachinationsGraph = this.artificialPlayer.graph as MachinationsGraph;
         if(Boolean(_loc1_) && _loc1_.actionsPerTurn > 0)
         {
            _loc1_.actionsThisTurn = _loc1_.actionsPerTurn;
         }
      }
      
      private function stopDiagram() : void
      {
         var _loc1_:MachinationsGraph = this.artificialPlayer.graph as MachinationsGraph;
         if(Boolean(_loc1_) && _loc1_.running)
         {
            if(this.parameters.length > 0)
            {
               _loc1_.end(this.parameters[0]);
            }
            else
            {
               _loc1_.end(this.artificialPlayer.caption);
            }
         }
      }
      
      private function activateAP() : void
      {
         var _loc2_:MachinationsNode = null;
         var _loc1_:MachinationsGraph = this.artificialPlayer.graph as MachinationsGraph;
         if(this.parameters.length > 0 && Boolean(_loc1_))
         {
            _loc2_ = _loc1_.findNodeByCaptionAndColor(this.parameters[this.counter],this.artificialPlayer.color);
            ++this.counter;
            this.counter %= this.parameters.length;
            if(_loc2_ is ArtificialPlayer)
            {
               (_loc2_ as ArtificialPlayer).activate();
            }
         }
         this.artificialPlayer.deactivate();
      }
   }
}

