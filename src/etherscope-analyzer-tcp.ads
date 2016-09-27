-----------------------------------------------------------------------
--  etherscope-analyzer-tcp -- TCP/IP packet analyzer
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

--  === TCP/IP Analysis ===
--  The TCP/IP analysis inspects the TCP header and collects information about source
--  and destination ports to classify the traffic in higher level protocols such
--  as ''http'', ''https'' or ''ssh''.
--
package EtherScope.Analyzer.TCP is

   subtype Group_Index is EtherScope.Stats.Group_Index;

   --  Collect per source IGMP group statistics.
   type TCP_Stats is record
      --  The server's TCP/IP port.
      Port         : Net.Uint16 := 0;

      --  TCP flow statistics associated with the port.
      TCP          : EtherScope.Stats.Statistics;
   end record;

   type TCP_Table_Stats is array (Group_Index) of TCP_Stats;

   --  TCP/IP packet and associated traffic analysis.
   type Analysis is record
      Ports      : TCP_Table_Stats;
      Count      : EtherScope.Stats.Group_Count := 0;
   end record;

   --  Analyze the TCP packet and update the analysis.
   procedure Analyze (Packet   : in Net.Buffers.Buffer_Type;
                      Result   : in out Analysis);

   --  Compute the bandwidth utilization for different TCP/IP protocols.
   procedure Update_Rates (Current  : in out Analysis;
                           Previous : in out Analysis;
                           Dt       : in Positive);

end EtherScope.Analyzer.TCP;
