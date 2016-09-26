-----------------------------------------------------------------------
--  etherscope-analyzer-ipv4 -- IPv4 packet analyzer
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
with Ada.Real_Time;
with Net.Buffers;
with EtherScope.Stats;

--  === IGMP Analysis ===
--  The IGMP analysis looks at multicast group submissions and remember which multicast
--  group was subscribed.  It also identifies the multicast traffic and associate it to
--  the IGMP group.  The analyzer identifies when a host subscribes to a multicast group
--  and when the group is left.
--
--  The implementation is able to remember only one subscriber.
package EtherScope.Analyzer.IGMP is

   subtype Group_Index is EtherScope.Stats.Group_Index;

   --  Collect per source IGMP group statistics.
   type Group_Stats is record
      --  The IPv4 group address.
      Ip           : Net.Ip_Addr := (0, 0, 0, 0);

      --  Time of the last report.
      Last_Report  : Ada.Real_Time.Time;

      --  Number of membership reports seen so far.
      Report_Count : Natural := 0;

      --  UDP flow statistics associated with the group.
      UDP          : EtherScope.Stats.Statistics;
   end record;

   type Group_Table_Stats is array (Group_Index) of Group_Stats;

   --  IGMP packet and associated traffic analysis.
   type Analysis is record
      Groups     : Group_Table_Stats;
      Count      : EtherScope.Stats.Group_Count := 0;
   end record;

   --  Analyze the IGMP packet and update the analysis.
   procedure Analyze (Packet   : in Net.Buffers.Buffer_Type;
                      Result   : in out Analysis);

   --  Analyze the UDP multicast packet and update the analysis.
   procedure Analyze_Traffic (Packet   : in Net.Buffers.Buffer_Type;
                              Result   : in out Analysis);

   --  Compute the bandwidth utilization for different devices and protocols.
   procedure Update_Rates (Current  : in out Analysis;
                           Previous : in out Analysis;
                           Dt       : in Positive);

end EtherScope.Analyzer.IGMP;
