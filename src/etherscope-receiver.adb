-----------------------------------------------------------------------
--  etherscope-receiver -- Ethernet Packet Receiver
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
with Ada.Real_Time;
with Ada.Synchronous_Task_Control;
with Net.Buffers;
with Net.Interfaces;
with EtherScope.Analyzer.Base;

package body EtherScope.Receiver is

   Ready  : Ada.Synchronous_Task_Control.Suspension_Object;

   --  ------------------------------
   --  Start the receiver loop.
   --  ------------------------------
   procedure Start is
   begin
      Ada.Synchronous_Task_Control.Set_True (Ready);
   end Start;

   --  ------------------------------
   --  The task that waits for packets.
   --  ------------------------------
   task body Controller is
      use type Ada.Real_Time.Time;

      Packet  : Net.Buffers.Buffer_Type;
   begin
      --  Wait until the Ethernet driver is ready.
      Ada.Synchronous_Task_Control.Suspend_Until_True (Ready);

      Net.Buffers.Allocate (Packet);
      loop
         Ifnet.Receive (Packet);
         EtherScope.Analyzer.Base.Analyze (Packet);
      end loop;
   end Controller;

end EtherScope.Receiver;
