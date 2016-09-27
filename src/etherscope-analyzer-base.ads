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
with EtherScope.Analyzer.IGMP;
with EtherScope.Analyzer.TCP;

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

   type Protocol_Stats is record
      Count     : EtherScope.Stats.Protocol_Count := 0;

      --  Global ICMP, IGMP, UDP, TCP statistics.
      Ethernet   : EtherScope.Stats.Statistics;
      ICMP       : EtherScope.Stats.Statistics;
      IGMP       : EtherScope.Stats.Statistics;
      UDP        : EtherScope.Stats.Statistics;
      TCP        : EtherScope.Stats.Statistics;
      Unknown    : EtherScope.Stats.Statistics;
   end record;

   type Group_Stats is record
      Groups     : EtherScope.Analyzer.IGMP.Group_Table_Stats;
      Count      : EtherScope.Stats.Group_Count := 0;

      --  Protocol statistics.
      IGMP       : EtherScope.Stats.Statistics;
      UDP        : EtherScope.Stats.Statistics;
   end record;

   --  TCP/IP analysis results.
   type TCP_Stats is record
      Ports      : EtherScope.Analyzer.TCP.TCP_Table_Stats;
      Count      : EtherScope.Stats.Group_Count := 0;

      --  Protocol global statistics.
      TCP        : EtherScope.Stats.Statistics;
   end record;

   --  Analyze the received packet.
   procedure Analyze (Packet : in out Net.Buffers.Buffer_Type);

   --  Get the device statistics.
   procedure Get_Devices (Into : out Device_Stats);

   --  Get the protocol statistics.
   procedure Get_Protocols (Into : out Protocol_Stats);

   --  Get the multicast group statistics.
   procedure Get_Groups (Into : out Group_Stats);

   --  Get the TCP/IP information statistics.
   procedure Get_TCP (Into : out TCP_Stats);

   procedure Update_Graph_Samples (Samples : out EtherScope.Stats.Graph_Samples;
                                   Clear   : in Boolean);

end EtherScope.Analyzer.Base;
