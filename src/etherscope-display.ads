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
with HAL.Bitmap;
with UI.Buttons;
package EtherScope.Display is

   Default_Text_Color       : constant HAL.Bitmap.Bitmap_Color := HAL.Bitmap.Dark_Blue;
   Default_Background_Color : constant HAL.Bitmap.Bitmap_Color := HAL.Bitmap.Light_Grey;
   Current_Background_Color : HAL.Bitmap.Bitmap_Color := Default_Background_Color;

   B_ETHER : constant UI.Buttons.Button_Index := 1;
   B_IPv4  : constant UI.Buttons.Button_Index := 2;
   B_IGMP  : constant UI.Buttons.Button_Index := 3;
   B_ICMP  : constant UI.Buttons.Button_Index := 4;
   B_UDP   : constant UI.Buttons.Button_Index := 5;
   B_TCP   : constant UI.Buttons.Button_Index := 6;

   Buttons : UI.Buttons.Button_Array (B_ETHER .. B_TCP) :=
     (B_ETHER => (Name => "Ether", others => <>),
      B_IPv4  => (Name => "IPv4 ", others => <>),
      B_ICMP  => (Name => "ICMP ", others => <>),
      B_IGMP  => (Name => "IGMP ", others => <>),
      B_UDP   => (Name => "UDP  ", others => <>),
      B_TCP   => (Name => "TCP  ", others => <>));

   --  Initialize the display.
   procedure Initialize;

   --  Draw the layout presentation frame.
   procedure Draw_Frame (Buffer : in HAL.Bitmap.Bitmap_Buffer'Class);

   --  Display devices found on the network.
   procedure Display_Devices (Buffer : in HAL.Bitmap.Bitmap_Buffer'Class);

   procedure Print (Buffer : in HAL.Bitmap.Bitmap_Buffer'Class;
                    Text   : in String);

end EtherScope.Display;
