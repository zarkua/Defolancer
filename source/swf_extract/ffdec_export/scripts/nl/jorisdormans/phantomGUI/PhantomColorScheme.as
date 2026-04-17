package nl.jorisdormans.phantomGUI
{
   public class PhantomColorScheme
   {
      
      public var colorFont:uint = 85;
      
      public var colorWindow:uint = 16777215;
      
      public var colorWindowDisabled:uint = 12303359;
      
      public var colorFace:uint = 12303359;
      
      public var colorFaceHover:uint = 14540287;
      
      public var colorFaceDisabled:uint = 8947899;
      
      public var colorBorder:uint = 85;
      
      public var colorBorderDisabled:uint = 5592456;
      
      public var colorDrawControlOutline:uint = 16777215;
      
      public var colorDrawControl:uint = 0;
      
      public var colorDrawControlHover:uint = 8912896;
      
      public var colorDrawControlSelected:uint = 16711680;
      
      public function PhantomColorScheme()
      {
         super();
         this.setColors();
      }
      
      public function setColors(param1:uint = 12303359, param2:uint = 14540287, param3:uint = 8947899, param4:uint = 85, param5:uint = 5592456, param6:uint = 85, param7:uint = 16777215, param8:uint = 12303359, param9:uint = 0, param10:uint = 16777215, param11:uint = 8912896, param12:uint = 16711680) : void
      {
         this.colorFont = param6;
         this.colorWindow = param7;
         this.colorWindowDisabled = param8;
         this.colorFace = param1;
         this.colorFaceHover = param2;
         this.colorFaceDisabled = param3;
         this.colorBorder = param4;
         this.colorBorderDisabled = param5;
         this.colorDrawControlOutline = param10;
         this.colorDrawControl = param9;
         this.colorDrawControlHover = param11;
         this.colorDrawControlSelected = param12;
      }
   }
}

