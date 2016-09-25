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
with Net.Buffers;
with EtherScope.Stats;

--  === IPv4 Packet Analyzer ===
--  The IPv4 packet analyzer collects the different IPv4 addresses seen on the
--  network.  It maintains a table of per-device statistics, the device index is
--  computed by the Ethernet analyzer based on the source Ethernet address.
--  When we detect several IP addresses for the same device, the Multihome flag
--  is set.
--
--  We also collect global IPv4 protocol statistics.
package EtherScope.Analyzer.IPv4 is

   subtype Device_Index is EtherScope.Stats.Device_Index;

   --  Collect per source IP statistics.
   type Device_Stats is record
      --  The device IPv4 address.
      Ip         : Net.Ip_Addr := (0, 0, 0, 0);

      --  Whether we detected several IPv4 addresses for the device.
      Multihome  : Boolean := False;

      --  ICMP, IGMP, UDP, TCP statistics from packets comming from the device.
      ICMP       : EtherScope.Stats.Statistics;
      IGMP       : EtherScope.Stats.Statistics;
      UDP        : EtherScope.Stats.Statistics;
      TCP        : EtherScope.Stats.Statistics;
      Unknown    : EtherScope.Stats.Statistics;
   end record;

   type Device_Table_Stats is array (Device_Index) of Device_Stats;

   --  IPv4 packet analysis.
   type Analysis is record
      Devices    : Device_Table_Stats;
      Count      : EtherScope.Stats.Device_Count := 0;

      --  Global ICMP, IGMP, UDP, TCP statistics.
      ICMP       : EtherScope.Stats.Statistics;
      IGMP       : EtherScope.Stats.Statistics;
      UDP        : EtherScope.Stats.Statistics;
      TCP        : EtherScope.Stats.Statistics;
      Unknown    : EtherScope.Stats.Statistics;
   end record;

   --  Analyze the packet and update the analysis.
   procedure Analyze (Packet   : in Net.Buffers.Buffer_Type;
                      Device   : in Device_Index;
                      Result   : in out Analysis;
                      Samples  : in out EtherScope.Stats.Graph_Samples);

   --  Compute the bandwidth utilization for different devices and protocols.
   procedure Update_Rates (Current  : in out Analysis;
                           Previous : in out Analysis;
                           Dt       : in Positive);

end EtherScope.Analyzer.IPv4;
