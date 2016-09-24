-----------------------------------------------------------------------
--  etherscope-display -- Display manager
--  Copyright (C) 2016 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-----------------------------------------------------------------------
with STM32.Board;
with Bitmapped_Drawing;
with BMP_Fonts;
with Interfaces;
with Net.Utils;
with UI.Texts;

with EtherScope.Stats;
with EtherScope.Analyzer.Ethernet;
with EtherScope.Analyzer.IPv4;
with EtherScope.Analyzer.Base;

package body EtherScope.Display is

   use type Interfaces.Unsigned_32;
   use type Interfaces.Unsigned_64;

   --  Convert the integer to a string without a leading space.
   function Image (Value : in Net.Uint32) return String;
   function Image (Value : in Net.Uint64) return String;
   function Format_Packets (Value : in Net.Uint32) return String;
   function Format_Bytes (Value : in Net.Uint64) return String;
   function Format_Bandwidth (Value : in Net.Uint32) return String;

   --  Kb, Mb, Gb units.
   KB : constant Net.Uint64 := 1024;
   MB : constant Net.Uint64 := KB * KB;
   GB : constant Net.Uint64 := MB * MB;

   --  Convert the integer to a string without a leading space.
   function Image (Value : in Net.Uint32) return String is
      Result : constant String := Net.Uint32'Image (Value);
   begin
      return Result (Result'First + 1 .. Result'Last);
   end Image;

   function Image (Value : in Net.Uint64) return String is
      Result : constant String := Net.Uint64'Image (Value);
   begin
      return Result (Result'First + 1 .. Result'Last);
   end Image;

   function Format_Packets (Value : in Net.Uint32) return String is
   begin
      return Net.Uint32'Image (Value);
   end Format_Packets;

   function Format_Bytes (Value : in Net.Uint64) return String is
   begin
      if Value < 10 * KB then
         return Image (Net.Uint32 (Value));
      elsif Value < 10 * MB then
         return Image (Value / KB) & "." & Image (((Value mod KB) * 10) / KB) & "Kb";
      elsif Value < 10 * GB then
         return Image (Value / MB) & "." & Image (((Value mod MB) * 10) / MB) & "Mb";
      else
         return Image (Value / GB) & "." & Image (((Value mod GB) * 10) / GB) & "Gb";
      end if;
   end Format_Bytes;

   function Format_Bandwidth (Value : in Net.Uint32) return String is
   begin
      return Net.Uint32'Image (Value);
   end Format_Bandwidth;

   --  ------------------------------
   --  Initialize the display.
   --  ------------------------------
   procedure Initialize is
   begin
      STM32.Board.Display.Initialize;
      STM32.Board.Display.Initialize_Layer (1, HAL.Bitmap.ARGB_1555);

      --  Initialize touch panel
      STM32.Board.Touch_Panel.Initialize;
   end Initialize;

   --  ------------------------------
   --  Draw the layout presentation frame.
   --  ------------------------------
   procedure Draw_Frame (Buffer : in HAL.Bitmap.Bitmap_Buffer'Class) is
      Y : constant Natural := 5;
   begin
      Buffer.Fill (Current_Background_Color);
      UI.Buttons.Draw_Buttons (Buffer => Buffer,
                               List   => Buttons,
                               X      => 0,
                               Y      => 0,
                               Width  => 100,
                               Height => 30);
      Buffer.Draw_Vertical_Line (Color  => HAL.Bitmap.White_Smoke,
                                 X      => 100,
                                 Y      => 0,
                                 Height => Y);
      Buffer.Draw_Horizontal_Line (Color => HAL.Bitmap.White_Smoke,
                                   X     => 0,
                                   Y     => Y,
                                   Width => 480);
   end Draw_Frame;

   --  ------------------------------
   --  Display devices found on the network.
   --  ------------------------------
   procedure Display_Devices (Buffer : in HAL.Bitmap.Bitmap_Buffer'Class) is
      use EtherScope.Analyzer.Base;
      use UI.Texts;

      Result : constant Analyzer.Base.Device_Stats := EtherScope.Analyzer.Base.Get_Devices;
      Y      : Natural := 15;
   begin
      Buffer.Fill_Rect (Color  => UI.Texts.Background,
                        X      => 100,
                        Y      => 0,
                        Width  => Buffer.Width - 100,
                        Height => Buffer.Height);
      for I in 1 .. Result.Count loop
         declare
            Ethernet : EtherScope.Analyzer.Ethernet.Device_Stats renames Result.Ethernet (I);
            IP       : EtherScope.Analyzer.IPv4.Device_Stats renames Result.IPv4 (I);
         begin
            UI.Texts.Draw_String (Buffer, (100, Y), 200, Net.Utils.To_String (Ethernet.Mac));
            UI.Texts.Draw_String (Buffer, (300, Y), 150, Net.Utils.To_String (IP.Ip), RIGHT);
            UI.Texts.Draw_String (Buffer, (100, Y + 20), 100, Format_Packets (Ethernet.Stats.Packets), RIGHT);
            UI.Texts.Draw_String (Buffer, (200, Y + 20), 200, Format_Bytes (Ethernet.Stats.Bytes), RIGHT);
            UI.Texts.Draw_String (Buffer, (400, Y + 20), 80, Format_Bandwidth (Ethernet.Stats.Bandwidth));
         end;
         Buffer.Draw_Horizontal_Line (Color => HAL.Bitmap.White_Smoke,
                                      X     => 100,
                                      Y     => Y + 49,
                                      Width => Buffer.Width - 100);
         Y := Y + 50;
      end loop;
   end Display_Devices;

   --  ------------------------------
   --  Display devices found on the network.
   --  ------------------------------
   procedure Display_Protocols (Buffer : in HAL.Bitmap.Bitmap_Buffer'Class) is
      use EtherScope.Analyzer.Base;
      use UI.Texts;

      Result : constant Analyzer.Base.Protocol_Stats := EtherScope.Analyzer.Base.Get_Protocols;
      Y      : Natural := 15;

      procedure Display_Protocol (Name : in String;
                                  Stat : in EtherScope.Stats.Statistics) is
      begin
         UI.Texts.Draw_String (Buffer, (100, Y), 200, Name);
         --  UI.Texts.Draw_String (Buffer, (300, Y), 150, Net.Utils.To_String (IP.Ip), RIGHT);
         UI.Texts.Draw_String (Buffer, (100, Y + 20), 100, Format_Packets (Stat.Packets), RIGHT);
         UI.Texts.Draw_String (Buffer, (200, Y + 20), 200, Format_Bytes (Stat.Bytes), RIGHT);
         UI.Texts.Draw_String (Buffer, (400, Y + 20), 80, Format_Bandwidth (Stat.Bandwidth));
         Buffer.Draw_Horizontal_Line (Color => HAL.Bitmap.White_Smoke,
                                      X     => 100,
                                      Y     => Y + 49,
                                      Width => Buffer.Width - 100);
         Y := Y + 50;
      end Display_Protocol;

   begin
      Buffer.Fill_Rect (Color  => UI.Texts.Background,
                        X      => 100,
                        Y      => 0,
                        Width  => Buffer.Width - 100,
                        Height => Buffer.Height);
      Display_Protocol ("ICMP", Result.ICMP);
      Display_Protocol ("IGMP", Result.IGMP);
      Display_Protocol ("UDP", Result.UDP);
      Display_Protocol ("TCP", Result.TCP);
      Display_Protocol ("Others", Result.Unknown);
   end Display_Protocols;

   procedure Print (Buffer : in HAL.Bitmap.Bitmap_Buffer'Class;
                    Text   : in String) is
   begin
      Bitmapped_Drawing.Draw_String
           (Buffer,
            Start      => (200, 240),
            Msg        => Text,
            Font       => BMP_Fonts.Font16x24,
            Foreground => HAL.Bitmap.White,
            Background => Current_Background_Color);
   end Print;

end EtherScope.Display;
