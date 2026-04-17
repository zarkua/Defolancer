package nl.jorisdormans.utils
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.FileFilter;
   import flash.net.FileReference;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   
   public class FileIO
   {
      
      public var fileName:String = "";
      
      public var data:XML;
      
      public var textData:String;
      
      public var onLoadComplete:Function = null;
      
      public var onSaveComplete:Function = null;
      
      private var _loader:URLLoader;
      
      public var file:FileReference = new FileReference();
      
      public function FileIO()
      {
         super();
      }
      
      public function openFileDialog(param1:String, param2:String = "xml files: (*.xml)|*.xml") : void
      {
         var _loc3_:FileFilter = null;
         this.file.addEventListener(Event.SELECT,this.fileSelectedLoad);
         var _loc4_:int = param2.indexOf("|");
         if(_loc4_ >= 0)
         {
            _loc3_ = new FileFilter(param2.substr(0,_loc4_),param2.substr(_loc4_ + 1));
            this.file.browse([_loc3_]);
         }
         else
         {
            this.file.browse();
         }
      }
      
      private function fileSelectedLoad(param1:Event = null) : void
      {
         this.file.removeEventListener(Event.SELECT,this.fileSelectedLoad);
         this.fileName = this.file.name;
         this.openFile2();
      }
      
      public function saveFileDialog(param1:String) : void
      {
         this.saveFile("");
      }
      
      private function openFile2() : void
      {
         this.fileName = this.fileName;
         this.file.addEventListener(IOErrorEvent.IO_ERROR,this.onFileError);
         this.file.addEventListener(Event.COMPLETE,this.loadFileComplete);
         this.file.load();
      }
      
      private function onFileError(param1:IOErrorEvent) : void
      {
         this.file.removeEventListener(IOErrorEvent.IO_ERROR,this.onFileError);
         this.file.removeEventListener(Event.COMPLETE,this.loadFileComplete);
      }
      
      private function loadFileComplete(param1:Event) : void
      {
         this.file.removeEventListener(IOErrorEvent.IO_ERROR,this.onFileError);
         this.file.removeEventListener(Event.COMPLETE,this.loadFileComplete);
         this.data = XML(this.file.data);
         if(this.onLoadComplete != null)
         {
            this.onLoadComplete();
         }
      }
      
      public function openFile(param1:String) : void
      {
         this.fileName = param1;
         var _loc2_:URLRequest = new URLRequest(param1);
         _loc2_.contentType = "text/xml";
         this._loader = new URLLoader();
         this._loader.addEventListener(IOErrorEvent.IO_ERROR,this.onError);
         this._loader.addEventListener(Event.COMPLETE,this.loadComplete);
         this._loader.dataFormat = URLLoaderDataFormat.TEXT;
         this._loader.load(_loc2_);
      }
      
      private function onError(param1:IOErrorEvent) : void
      {
      }
      
      private function loadComplete(param1:Event) : void
      {
         this.data = XML(this._loader.data);
         if(this.onLoadComplete != null)
         {
            this.onLoadComplete();
         }
      }
      
      public function saveFile(param1:String) : void
      {
         this.fileName = param1;
         if(this.file == null)
         {
            this.file = new FileReference();
         }
         if(this.data != null)
         {
            this.file.save(this.data,param1);
         }
         else
         {
            if(this.textData == null)
            {
               throw new Error("No data specified");
            }
            this.file.save(this.textData,param1);
         }
         this.file.addEventListener(Event.COMPLETE,this.saveComplete);
      }
      
      private function saveComplete(param1:Event) : void
      {
         this.fileName = this.file.name;
         this.file.removeEventListener(Event.COMPLETE,this.saveComplete);
         if(this.onSaveComplete != null)
         {
            this.onSaveComplete();
         }
         this.textData = null;
         this.data = null;
      }
   }
}

