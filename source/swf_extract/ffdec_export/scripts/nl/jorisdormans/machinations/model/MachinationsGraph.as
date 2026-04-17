package nl.jorisdormans.machinations.model
{
   import flash.geom.Vector3D;
   import nl.jorisdormans.graph.Graph;
   import nl.jorisdormans.graph.GraphElement;
   import nl.jorisdormans.utils.StringUtil;
   
   public class MachinationsGraph extends Graph
   {
      
      public static const TIME_MODE_ASYNCHRONOUS:String = "asynchronous";
      
      public static const TIME_MODE_SYNCHRONOUS:String = "synchronous";
      
      public static const TIME_MODE_TURN_BASED:String = "turn-based";
      
      public static const DISTRIBUTION_MODE_INSTANTANEOUS:String = "instantaneous";
      
      public static const DISTRIBUTION_MODE_FIXED_SPEED:String = "fixed speed";
      
      private var _running:Boolean;
      
      public var fireInterval:Number;
      
      private var fireIntervalCounter:Number;
      
      public var resourceSpeed:Number;
      
      public var originalActionsPerTurn:int;
      
      public var actionsPerTurn:int;
      
      public var actionsThisTurn:int;
      
      public var name:String;
      
      public var author:String;
      
      public var dice:String;
      
      public var skill:String;
      
      public var strategy:String;
      
      public var multiplayer:String;
      
      public var width:int;
      
      public var height:int;
      
      public var visibleRuns:int;
      
      public var numberOfRuns:int;
      
      public var timeMode:String;
      
      public var distributionMode:String;
      
      public var colorCoding:int;
      
      private var dicePostFix:Array;
      
      private var skillPostFix:Array;
      
      private var strategyPostFix:Array;
      
      private var multiplayerPostFix:Array;
      
      private var dicePercentage:Number;
      
      private var skillPercentage:Number;
      
      private var strategyPercentage:Number;
      
      private var multiplayerPercentage:Number;
      
      public var ended:Boolean;
      
      public var endCondition:String;
      
      public var doEvents:Boolean;
      
      public var steps:int;
      
      private var up:Boolean;
      
      private var fireUp:Boolean;
      
      public function MachinationsGraph()
      {
         super();
         grammar = new MachinationsGrammar();
         this._running = false;
      }
      
      override public function clear() : void
      {
         super.clear();
         this.fireInterval = 1;
         this.fireIntervalCounter = 0;
         this.resourceSpeed = 100;
         this.actionsPerTurn = 1;
         this.name = "";
         this.author = "";
         this.dice = "D6";
         this.skill = "";
         this.strategy = "";
         this.multiplayer = "";
         this.width = 600;
         this.height = 560;
         this.ended = false;
         this.visibleRuns = 25;
         this.numberOfRuns = 100;
         this.colorCoding = 0;
         this.timeMode = TIME_MODE_ASYNCHRONOUS;
         this.distributionMode = DISTRIBUTION_MODE_FIXED_SPEED;
      }
      
      override public function generateXML() : XML
      {
         var _loc1_:XML = super.generateXML();
         _loc1_.@version = MachinationsGrammar.version;
         _loc1_.@name = this.name;
         _loc1_.@author = this.author;
         _loc1_.@interval = this.fireInterval;
         _loc1_.@timeMode = this.timeMode;
         _loc1_.@distributionMode = this.distributionMode;
         _loc1_.@speed = this.resourceSpeed;
         _loc1_.@actions = this.actionsPerTurn;
         _loc1_.@dice = this.dice;
         _loc1_.@skill = this.skill;
         _loc1_.@strategy = this.strategy;
         _loc1_.@multiplayer = this.multiplayer;
         _loc1_.@width = this.width;
         _loc1_.@height = this.height;
         _loc1_.@numberOfRuns = this.numberOfRuns;
         _loc1_.@visibleRuns = this.visibleRuns;
         _loc1_.@colorCoding = this.colorCoding;
         return _loc1_;
      }
      
      override public function readXML(param1:XML) : void
      {
         if(param1.@version.length() == 0)
         {
            param1 = XMLConverter.convertV2V30(param1);
         }
         if(param1.@version.substring(0,4) == "v3.0")
         {
            param1 = XMLConverter.convertV30V35(param1);
         }
         if(param1.@version.substring(0,4) == "v3.5")
         {
            param1 = XMLConverter.convertV35V40(param1);
         }
         super.readXML(param1);
         this.name = param1.@name;
         this.author = param1.@author;
         this.fireInterval = param1.@interval;
         if(param1.@timeMode.length() > 0)
         {
            this.timeMode = param1.@timeMode;
         }
         if(param1.@distributionMode.length() > 0)
         {
            this.distributionMode = param1.@distributionMode;
         }
         this.actionsPerTurn = param1.@actions;
         this.dice = param1.@dice;
         this.skill = param1.@skill;
         this.strategy = param1.@strategy;
         this.multiplayer = param1.@multiplayer;
         this.width = param1.@width;
         this.height = param1.@height;
         this.numberOfRuns = param1.@numberOfRuns;
         this.visibleRuns = param1.@visibleRuns;
         if(param1.@colorCoding.length() > 0)
         {
            this.colorCoding = param1.@colorCoding;
         }
         else
         {
            this.colorCoding = 1;
         }
      }
      
      public function buildTestGraph() : void
      {
         addNode("pool",new Vector3D(200,200));
         addNode("pool",new Vector3D(250,150));
         addNode("pool",new Vector3D(250,250));
         addConnection("flow",new Vector3D(100,100),new Vector3D(300,150));
      }
      
      public function get running() : Boolean
      {
         return this._running;
      }
      
      public function set running(param1:Boolean) : void
      {
         this._running = param1;
         if(this._running)
         {
            this.prepare();
         }
         else
         {
            this.stop();
         }
      }
      
      public function end(param1:String) : void
      {
         this.ended = true;
         this.endCondition = param1;
         this.updateCharts();
         this.actionsPerTurn = this.originalActionsPerTurn;
      }
      
      public function prepare() : void
      {
         var _loc2_:* = 0;
         this.steps = 0;
         this.actionsThisTurn = 0;
         this.originalActionsPerTurn = this.actionsPerTurn;
         this.ended = false;
         if(this.dice.indexOf("%") == this.dice.length - 1)
         {
            this.dicePercentage = parseFloat(this.dice.substr(0,this.dice.length - 1));
            this.dicePostFix = null;
         }
         else
         {
            this.dicePostFix = MachinationsExpression.toPostFix(this.dice);
         }
         if(this.skill.indexOf("%") == this.skill.length - 1)
         {
            this.skillPercentage = parseFloat(this.skill.substr(0,this.skill.length - 1));
            this.skillPostFix = null;
         }
         else
         {
            this.skillPostFix = MachinationsExpression.toPostFix(this.skill);
         }
         if(this.strategy.indexOf("%") == this.strategy.length - 1)
         {
            this.strategyPercentage = parseFloat(this.strategy.substr(0,this.strategy.length - 1));
            this.strategyPostFix = null;
         }
         else
         {
            this.strategyPostFix = MachinationsExpression.toPostFix(this.strategy);
         }
         if(this.multiplayer.indexOf("%") == this.multiplayer.length - 1)
         {
            this.multiplayerPercentage = parseFloat(this.multiplayer.substr(0,this.multiplayer.length - 1));
            this.multiplayerPostFix = null;
         }
         else
         {
            this.multiplayerPostFix = MachinationsExpression.toPostFix(this.multiplayer);
         }
         var _loc1_:int = int(elements.length);
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            if(elements[_loc2_] is Register)
            {
               (elements[_loc2_] as Register).reset();
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            if(elements[_loc2_] is MachinationsConnection)
            {
               (elements[_loc2_] as MachinationsConnection).prepare(this.doEvents);
               (elements[_loc2_] as MachinationsConnection).label.prepare();
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            if(elements[_loc2_] is MachinationsNode)
            {
               (elements[_loc2_] as MachinationsNode).prepare(this.doEvents);
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            if(elements[_loc2_] is ArtificialPlayer)
            {
               (elements[_loc2_] as ArtificialPlayer).readInstructions();
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            if(elements[_loc2_] is Register)
            {
               (elements[_loc2_] as Register).prepare(this.doEvents);
            }
            _loc2_++;
         }
         _loc2_ = int(_loc1_ - 1);
         while(_loc2_ >= 0)
         {
            if(elements[_loc2_] is MachinationsConnection)
            {
               (elements[_loc2_] as MachinationsConnection).prepare(this.doEvents);
            }
            _loc2_--;
         }
         this.fireIntervalCounter = this.fireInterval;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            if(elements[_loc2_] is Gate)
            {
               (elements[_loc2_] as Gate).checkDynamicProbabilities();
            }
            _loc2_++;
         }
         this.up = false;
         this.fireUp = false;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            if(elements[_loc2_] is MachinationsNode && (elements[_loc2_] as MachinationsNode).activationMode == MachinationsNode.MODE_ONSTART)
            {
               (elements[_loc2_] as MachinationsNode).fire();
            }
            _loc2_++;
         }
      }
      
      public function stop() : void
      {
         var _loc1_:int = int(elements.length);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            if(elements[_loc2_] is MachinationsNode)
            {
               (elements[_loc2_] as MachinationsNode).stop();
            }
            if(elements[_loc2_] is MachinationsConnection)
            {
               (elements[_loc2_] as MachinationsConnection).stop();
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            if(elements[_loc2_] is MachinationsNode)
            {
               (elements[_loc2_] as MachinationsNode).inhibited = false;
            }
            _loc2_++;
         }
      }
      
      public function updateCharts() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = int(elements.length);
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            if(elements[_loc2_] is Chart)
            {
               (elements[_loc2_] as MachinationsNode).fire();
            }
            _loc2_++;
         }
      }
      
      public function update(param1:Number, param2:Boolean) : void
      {
         var _loc4_:* = 0;
         var _loc5_:Boolean = false;
         var _loc3_:int = int(elements.length);
         if(this.ended)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(elements[_loc4_] is EndCondition)
               {
                  (elements[_loc4_] as EndCondition).update(param1);
               }
               _loc4_++;
            }
            return;
         }
         switch(this.timeMode)
         {
            case TIME_MODE_ASYNCHRONOUS:
            case TIME_MODE_SYNCHRONOUS:
               this.fireIntervalCounter += param1;
               _loc5_ = this.fireIntervalCounter > this.fireInterval;
               if(_loc5_)
               {
                  this.fireIntervalCounter -= this.fireInterval;
               }
               break;
            case TIME_MODE_TURN_BASED:
               if(this.actionsThisTurn >= this.actionsPerTurn)
               {
                  this.actionsThisTurn -= this.actionsPerTurn;
                  _loc5_ = true;
               }
               else
               {
                  _loc5_ = false;
               }
         }
         this.up = !this.up;
         if(_loc5_)
         {
            ++this.steps;
            this.fireUp = !this.fireUp;
            if(this.fireUp)
            {
               _loc4_ = 0;
               while(_loc4_ < _loc3_)
               {
                  if(elements[_loc4_] is MachinationsNode && !(elements[_loc4_] is Delay))
                  {
                     (elements[_loc4_] as MachinationsNode).autoFire();
                  }
                  _loc4_++;
               }
            }
            else
            {
               _loc4_ = int(_loc3_ - 1);
               while(_loc4_ >= 0)
               {
                  if(elements[_loc4_] is MachinationsNode && !(elements[_loc4_] is Delay))
                  {
                     (elements[_loc4_] as MachinationsNode).autoFire();
                  }
                  _loc4_--;
               }
            }
            if(this.fireUp)
            {
               _loc4_ = 0;
               while(_loc4_ < _loc3_)
               {
                  if(elements[_loc4_] is Delay)
                  {
                     (elements[_loc4_] as MachinationsNode).autoFire();
                  }
                  _loc4_++;
               }
            }
            else
            {
               _loc4_ = int(_loc3_ - 1);
               while(_loc4_ >= 0)
               {
                  if(elements[_loc4_] is Delay)
                  {
                     (elements[_loc4_] as MachinationsNode).autoFire();
                  }
                  _loc4_--;
               }
            }
         }
         if(this.timeMode == TIME_MODE_SYNCHRONOUS)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(elements[_loc4_] is Pool)
               {
                  (elements[_loc4_] as Pool).resolveOverPull();
               }
               _loc4_++;
            }
         }
         if(this.up)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(elements[_loc4_] is MachinationsNode)
               {
                  (elements[_loc4_] as MachinationsNode).update(param1);
               }
               if(elements[_loc4_] is MachinationsConnection)
               {
                  (elements[_loc4_] as MachinationsConnection).update(param1);
               }
               _loc4_++;
            }
         }
         else
         {
            _loc4_ = int(_loc3_ - 1);
            while(_loc4_ >= 0)
            {
               if(elements[_loc4_] is MachinationsNode)
               {
                  (elements[_loc4_] as MachinationsNode).update(param1);
               }
               if(elements[_loc4_] is MachinationsConnection)
               {
                  (elements[_loc4_] as MachinationsConnection).update(param1);
               }
               _loc4_--;
            }
         }
      }
      
      public function getDiceValue() : Number
      {
         var _loc1_:int = 0;
         if(this.dicePercentage > 0)
         {
            _loc1_ = Math.floor(this.dicePercentage / 100);
            if(Math.random() * 100 < this.dicePercentage % 100)
            {
               _loc1_++;
            }
            return _loc1_;
         }
         if(this.dicePostFix)
         {
            return Math.max(0,MachinationsExpression.evaluatePostFix(this.dicePostFix));
         }
         return 0;
      }
      
      public function getSkillValue() : Number
      {
         var _loc1_:int = 0;
         if(this.skillPercentage > 0)
         {
            _loc1_ = Math.floor(this.skillPercentage / 100);
            if(Math.random() * 100 < this.skillPercentage % 100)
            {
               _loc1_++;
            }
            return _loc1_;
         }
         if(this.skillPostFix)
         {
            return Math.max(0,MachinationsExpression.evaluatePostFix(this.skillPostFix));
         }
         return 0;
      }
      
      public function getStrategyValue() : Number
      {
         var _loc1_:int = 0;
         if(this.strategyPercentage > 0)
         {
            _loc1_ = Math.floor(this.strategyPercentage / 100);
            if(Math.random() * 100 < this.strategyPercentage % 100)
            {
               _loc1_++;
            }
            return _loc1_;
         }
         if(this.strategyPostFix)
         {
            return Math.max(0,MachinationsExpression.evaluatePostFix(this.strategyPostFix));
         }
         return 0;
      }
      
      public function getMultiplayerValue() : Number
      {
         var _loc1_:int = 0;
         if(this.multiplayerPercentage > 0)
         {
            _loc1_ = Math.floor(this.multiplayerPercentage / 100);
            if(Math.random() * 100 < this.multiplayerPercentage % 100)
            {
               _loc1_++;
            }
            return _loc1_;
         }
         if(this.multiplayerPostFix)
         {
            return Math.max(0,MachinationsExpression.evaluatePostFix(this.multiplayerPostFix));
         }
         return 0;
      }
      
      public function findAllNodesByCaptionAndColor(param1:String, param2:uint) : Vector.<MachinationsNode>
      {
         var _loc3_:Vector.<MachinationsNode> = new Vector.<MachinationsNode>();
         if(param1 == "")
         {
            return _loc3_;
         }
         var _loc4_:int = 0;
         while(_loc4_ < elements.length)
         {
            if(elements[_loc4_] is MachinationsNode)
            {
               if(StringUtil.trim((elements[_loc4_] as MachinationsNode).caption) == param1 && (elements[_loc4_] as MachinationsNode).color == param2)
               {
                  _loc3_.push(elements[_loc4_] as MachinationsNode);
               }
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function findNodeByCaptionAndColor(param1:String, param2:uint) : MachinationsNode
      {
         if(param1 == "")
         {
            return null;
         }
         var _loc3_:int = 0;
         while(_loc3_ < elements.length)
         {
            if(elements[_loc3_] is MachinationsNode)
            {
               if(StringUtil.trim((elements[_loc3_] as MachinationsNode).caption) == param1 && (elements[_loc3_] as MachinationsNode).color == param2)
               {
                  return elements[_loc3_] as MachinationsNode;
               }
            }
            _loc3_++;
         }
         return null;
      }
      
      public function findAllNodesByCaption(param1:String) : Vector.<MachinationsNode>
      {
         var _loc2_:Vector.<MachinationsNode> = new Vector.<MachinationsNode>();
         if(param1 == "")
         {
            return _loc2_;
         }
         var _loc3_:int = 0;
         while(_loc3_ < elements.length)
         {
            if(elements[_loc3_] is MachinationsNode)
            {
               if(StringUtil.trim((elements[_loc3_] as MachinationsNode).caption) == param1)
               {
                  _loc2_.push(elements[_loc3_] as MachinationsNode);
               }
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function findNodeByCaption(param1:String) : MachinationsNode
      {
         if(param1 == "")
         {
            return null;
         }
         var _loc2_:int = 0;
         while(_loc2_ < elements.length)
         {
            if(elements[_loc2_] is MachinationsNode)
            {
               if(StringUtil.trim((elements[_loc2_] as MachinationsNode).caption) == param1)
               {
                  return elements[_loc2_] as MachinationsNode;
               }
            }
            _loc2_++;
         }
         return null;
      }
      
      public function pushToTop(param1:GraphElement) : void
      {
         var _loc2_:int = int(elements.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_ - 1)
         {
            if(elements[_loc3_] == param1)
            {
               elements.splice(_loc3_,1);
               elements.push(param1);
               break;
            }
            _loc3_++;
         }
      }
   }
}

