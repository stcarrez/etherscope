-----------------------------------------------------------------------
--  etheroscope -- Ether Oscope main program
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
with System;
with Interfaces;

with STM32.Button;
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

--  The main EtherScope task must run at a lower priority as it takes care
--  of displaying results on the screen while the EtherScope receiver's task
--  waits for packets and analyzes them.  All the hardware initialization must
--  be done here because STM32.SDRAM is not protected against concurrent accesses.
procedure Etheroscope with Priority => System.Priority'First is

   use type Interfaces.Unsigned_32;
   use type UI.Buttons.Button_Index;

   Count  : Natural := 0;
   Mode   : UI.Buttons.Button_Event := EtherScope.Display.B_ETHER;

   --  Reserve 32 network buffers.
   NET_BUFFER_SIZE : constant Interfaces.Unsigned_32 := Net.Buffers.NET_ALLOC_SIZE * 32;
begin
   STM32.RNG.Interrupts.Initialize_RNG;
   STM32.Button.Initialize;

   --  Initialize the display and draw the main/fixed frames in both buffers.
   EtherScope.Display.Initialize;
   EtherScope.Display.Draw_Frame (STM32.Board.Display.Get_Hidden_Buffer (1));
   STM32.Board.Display.Update_Layer (1);
   EtherScope.Display.Draw_Frame (STM32.Board.Display.Get_Hidden_Buffer (1));

   --  Initialize the Ethernet driver.
   STM32.Eth.Initialize_RMII;

   --  Static IP interface, default netmask and no gateway.
   --  (In fact, this is not really necessary for using the receiver in promiscus mode)
   EtherScope.Receiver.Ifnet.Ip := (192, 168, 1, 1);
   EtherScope.Receiver.Ifnet.Mac := (0, 16#81#, 16#E1#, 5, 5, 1); --  STMicroelectronics OUI = 00 81 E1

   Net.Buffers.Add_Region (STM32.SDRAM.Reserve (Amount => NET_BUFFER_SIZE), NET_BUFFER_SIZE);
   EtherScope.Receiver.Ifnet.Initialize;

   --  Loop to retrieve the analysis and display them.
   loop
      declare
         Action : UI.Buttons.Button_Event;
         Buffer : constant HAL.Bitmap.Bitmap_Buffer'Class := STM32.Board.Display.Get_Hidden_Buffer (1);
      begin
         UI.Buttons.Get_Event (Buffer => Buffer,
                               Touch  => STM32.Board.Touch_Panel,
                               List   => EtherScope.Display.Buttons,
                               Event  => Action);
         if Action /= UI.Buttons.NO_EVENT then
            Mode := Action;
         end if;
         case Mode is
            when EtherScope.Display.B_ETHER =>
               EtherScope.Display.Display_Devices (Buffer);

            when EtherScope.Display.B_IPv4 =>
               EtherScope.Display.Display_Protocols (Buffer);

            when others =>
               null;

         end case;
         EtherScope.Display.Print (Buffer => Buffer,
                                   Text   => Natural'Image (Count));
         STM32.Board.Display.Update_Layer (1);
         Count := Count + 1;
      end;
   end loop;

end Etheroscope;
