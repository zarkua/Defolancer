package nl.jorisdormans.machinations.model
{
   import nl.jorisdormans.graph.GraphEvent;
   import nl.jorisdormans.utils.StringUtil;
   
   public class ArtificialPlayer extends MachinationsNode
   {
      
      public var script:String;
      
      public var instructions:Vector.<APInstruction>;
      
      public var actionsPerTurn:Number;
      
      private var _autoFire:Number;
      
      private var _timer:Number;
      
      public var actionsExecuted:int;
      
      public var actionsPerStep:int;
      
      private var initialMode:String;
      
      public var pregeneratedRandom:Vector.<Number>;
      
      public function ArtificialPlayer()
      {
         super();
         this.script = "";
         this.actionsPerTurn = 1;
         activationMode = MODE_AUTOMATIC;
         actions = 0;
         this.pregeneratedRandom = new Vector.<Number>();
         var _loc1_:int = 0;
         while(_loc1_ < 10)
         {
            this.pregeneratedRandom.push(0);
            _loc1_++;
         }
      }
      
      override public function generateXML() : XML
      {
         var _loc1_:XML = super.generateXML();
         _loc1_.appendChild(this.script);
         _loc1_.@actionsPerTurn = this.actionsPerTurn;
         return _loc1_;
      }
      
      override public function readXML(param1:XML) : void
      {
         super.readXML(param1);
         this.script = param1.toString();
         this.actionsPerTurn = param1.@actionsPerTurn;
      }
      
      public function readInstructions() : void
      {
         var _loc3_:String = null;
         this.instructions = new Vector.<APInstruction>();
         var _loc1_:String = this.script;
         var _loc2_:int = _loc1_.indexOf("\r");
         if(_loc2_ < 0)
         {
            _loc2_ = _loc1_.indexOf("\n");
         }
         while(_loc2_ > 0)
         {
            _loc3_ = StringUtil.trim(_loc1_.substr(0,_loc2_));
            if(_loc3_.length > 0)
            {
               this.instructions.push(new APInstruction(this,_loc1_));
            }
            _loc1_ = _loc1_.substr(_loc2_ + 1);
            _loc2_ = _loc1_.indexOf("\r");
            if(_loc2_ < 0)
            {
               _loc2_ = _loc1_.indexOf("\n");
            }
         }
         _loc3_ = StringUtil.trim(_loc1_.substr(0,_loc2_));
         if(_loc3_.length > 0)
         {
            this.instructions.push(new APInstruction(this,_loc1_));
         }
      }
      
      override public function prepare(param1:Boolean) : void
      {
         super.prepare(param1);
         this._timer = 0;
         this._autoFire = 0;
         this.actionsExecuted = 0;
         this.actionsPerStep = 0;
         actions = 0;
         this.initialMode = activationMode;
         var _loc2_:int = 0;
         while(_loc2_ < this.pregeneratedRandom.length)
         {
            this.pregeneratedRandom[_loc2_] = Math.random();
            _loc2_++;
         }
      }
      
      override public function stop() : void
      {
         activationMode = this.initialMode;
         super.stop();
      }
      
      override public function autoFire() : void
      {
         this.actionsPerStep = 0;
         if((graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_TURN_BASED)
         {
            if(this.actionsPerTurn >= 1 && activationMode == MODE_AUTOMATIC)
            {
               if(!inhibited)
               {
                  this.fire();
               }
               this._autoFire += Math.floor(this.actionsPerTurn - 1);
            }
         }
         else
         {
            super.autoFire();
         }
      }
      
      override public function update(param1:Number) : void
      {
         if(this.firing > 0)
         {
            this.firing -= param1;
            if(this.firing <= 0)
            {
               this.firing = 0;
               if(doEvents)
               {
                  dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
               }
            }
         }
         if(this._autoFire > 0)
         {
            if(this._autoFire % 1 - param1 * 0.8 <= 0 && this._autoFire % 1 > 0)
            {
               if(!inhibited)
               {
                  this.fire();
               }
            }
            this._autoFire -= param1 * 0.8;
         }
         if((graph as MachinationsGraph).ended || (graph as MachinationsGraph).actionsPerTurn > 0)
         {
            return;
         }
         this._timer += param1;
         if(this._timer >= this.actionsPerTurn)
         {
            this._timer -= this.actionsPerTurn;
            if(activationMode == MODE_AUTOMATIC && !inhibited)
            {
               this.fire();
            }
         }
      }
      
      override public function fire() : void
      {
         if(caption == "F")
         {
            throw new Error("how did I get here");
         }
         ++this.actionsExecuted;
         ++this.actionsPerStep;
         setFiring();
         var _loc1_:int = 0;
         while(_loc1_ < this.instructions.length)
         {
            if(this.instructions[_loc1_].activate())
            {
               break;
            }
            _loc1_++;
         }
      }
      
      public function activate() : void
      {
         if(activationMode == MODE_PASSIVE)
         {
            activationMode = MODE_AUTOMATIC;
            if(doEvents)
            {
               dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
            }
         }
      }
      
      public function deactivate() : void
      {
         if(activationMode == MODE_AUTOMATIC)
         {
            activationMode = MODE_PASSIVE;
            if(doEvents)
            {
               dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
            }
         }
      }
   }
}

