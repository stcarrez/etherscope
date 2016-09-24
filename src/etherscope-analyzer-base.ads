-----------------------------------------------------------------------
--  etherscope-analyzer-base -- Packet analyzer
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
with Net.Buffers;
with EtherScope.Stats;
with EtherScope.Analyzer.Ethernet;
with EtherScope.Analyzer.IPv4;

--  === Package Analyzer ===
--  The packet analyzer looks at the received Ethernet packet and applies protocol
--  specific analysis to gather all the information.  It provides entry points for
--  the display task to retrieve the collected data.
--
--  The analysis is internally protected from concurrency between the receiver's task
--  that uses the <tt>Analyze</tt> procedure and the display task that uses other
--  operations.
package EtherScope.Analyzer.Base is

   type Device_Stats is record
      Count     : EtherScope.Stats.Device_Count := 0;
      Ethernet  : EtherScope.Analyzer.Ethernet.Device_Table_Stats;
      IPv4      : EtherScope.Analyzer.IPv4.Device_Table_Stats;
   end record;

   --  Analyze the received packet.
   procedure Analyze (Packet : in out Net.Buffers.Buffer_Type);

   --  Get the device statistics.
   function Get_Devices return Device_Stats;

end EtherScope.Analyzer.Base;
