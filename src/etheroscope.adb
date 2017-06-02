-----------------------------------------------------------------------
--  etheroscope -- Ether Oscope main program
--  Copyright (C) 2016, 2017 Stephane Carrez
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
with System;
with Interfaces;

with Ada.Real_Time;

with STM32.Board;
with STM32.RNG.Interrupts;
with STM32.Eth;
with STM32.SDRAM;
with HAL.Bitmap;

with Net;
with Net.Buffers;
with UI.Buttons;
with EtherScope.Display;
with EtherScope.Receiver;
with EtherScope.Stats;

--  The main EtherScope task must run at a lower priority as it takes care
--  of displaying results on the screen while the EtherScope receiver's task
--  waits for packets and analyzes them.  All the hardware initialization must
--  be done here because STM32.SDRAM is not protected against concurrent accesses.
procedure Etheroscope with Priority => System.Priority'First is

   use type Interfaces.Unsigned_32;
   use type UI.Buttons.Button_Index;
   use type Ada.Real_Time.Time;
   use type Ada.Real_Time.Time_Span;

   --  Reserve 32 network buffers.
   NET_BUFFER_SIZE  : constant Interfaces.Unsigned_32 := Net.Buffers.NET_ALLOC_SIZE * 32;

   --  Display refresh period.
   REFRESH_PERIOD   : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (500);

   --  Display refresh deadline.
   Refresh_Deadline : Ada.Real_Time.Time;

   --  Current display mode.
   Mode             : UI.Buttons.Button_Event := EtherScope.Display.B_ETHER;
   Button_Changed   : Boolean := False;

   --  Display the Ethernet graph (all traffic).
   Graph_Mode       : EtherScope.Stats.Graph_Kind := EtherScope.Stats.G_ETHERNET;
begin
   STM32.RNG.Interrupts.Initialize_RNG;

   --  Initialize the display and draw the main/fixed frames in both buffers.
   EtherScope.Display.Initialize;
   EtherScope.Display.Draw_Frame (STM32.Board.Display.Hidden_Buffer (1).all);
   STM32.Board.Display.Update_Layer (1);
   EtherScope.Display.Draw_Frame (STM32.Board.Display.Hidden_Buffer (1).all);

   --  Initialize the Ethernet driver.
   STM32.Eth.Initialize_RMII;

   --  Static IP interface, default netmask and no gateway.
   --  (In fact, this is not really necessary for using the receiver in promiscus mode)
   EtherScope.Receiver.Ifnet.Ip := (192, 168, 1, 1);

   --  STMicroelectronics OUI = 00 81 E1
   EtherScope.Receiver.Ifnet.Mac := (0, 16#81#, 16#E1#, 5, 5, 1);

   --  Setup some receive buffers and initialize the Ethernet driver.
   Net.Buffers.Add_Region (STM32.SDRAM.Reserve (Amount => HAL.UInt32 (NET_BUFFER_SIZE)), NET_BUFFER_SIZE);
   EtherScope.Receiver.Ifnet.Initialize;
   EtherScope.Receiver.Start;

   Refresh_Deadline := Ada.Real_Time.Clock + REFRESH_PERIOD;

   --  Loop to retrieve the analysis and display them.
   loop
      declare
         Action  : UI.Buttons.Button_Event;
         Now     : constant Ada.Real_Time.Time := Ada.Real_Time.Clock;
         Buffer  : constant HAL.Bitmap.Any_Bitmap_Buffer := STM32.Board.Display.Hidden_Buffer (1);
      begin
         --  We updated the buttons in the previous layer and
         --  we must update them in the second one.
         if Button_Changed then
            EtherScope.Display.Draw_Buttons (Buffer.all);
            Button_Changed := False;
         end if;

         --  Check for a button being pressed.
         UI.Buttons.Get_Event (Buffer => Buffer.all,
                               Touch  => STM32.Board.Touch_Panel,
                               List   => EtherScope.Display.Buttons,
                               Event  => Action);
         if Action /= UI.Buttons.NO_EVENT then
            Mode := Action;
            UI.Buttons.Set_Active (EtherScope.Display.Buttons, Action, Button_Changed);

            --  Update the buttons in the first layer.
            if Button_Changed then
               EtherScope.Display.Draw_Buttons (Buffer.all);
            end if;
         end if;

         --  Refresh the display only every 500 ms or when the display state is changed.
         if Refresh_Deadline <= Now or Button_Changed then
            case Mode is
               when EtherScope.Display.B_ETHER =>
                  EtherScope.Display.Display_Devices (Buffer.all);
                  Graph_Mode := EtherScope.Stats.G_ETHERNET;

               when EtherScope.Display.B_IPv4 =>
                  EtherScope.Display.Display_Protocols (Buffer.all);
                  Graph_Mode := EtherScope.Stats.G_ETHERNET;

               when EtherScope.Display.B_IGMP =>
                  EtherScope.Display.Display_Groups (Buffer.all);
                  Graph_Mode := EtherScope.Stats.G_UDP;

               when EtherScope.Display.B_TCP =>
                  EtherScope.Display.Display_TCP (Buffer.all);
                  Graph_Mode := EtherScope.Stats.G_TCP;

               when others =>
                  null;

            end case;
            EtherScope.Display.Refresh_Graphs (Buffer.all, Graph_Mode);
            EtherScope.Display.Display_Summary (Buffer.all);
            STM32.Board.Display.Update_Layer (1);
            Refresh_Deadline := Refresh_Deadline + REFRESH_PERIOD;
         end if;
         delay until Now + Ada.Real_Time.Milliseconds (100);
      end;
   end loop;

end Etheroscope;
