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
with Ada.Real_Time;

with Net.Headers;
with Net.Protos;
package body EtherScope.Analyzer.Base is

   use type Ada.Real_Time.Time;
   use type Ada.Real_Time.Time_Span;
   use type EtherScope.Stats.Device_Count;

   --  Protect the access of the analysis results between the
   --  analyzer's task and the display main task.
   protected DB is
      procedure Get_Devices (Devices : out Device_Stats);
      procedure Get_Protocols (Protocols : out Protocol_Stats);
      procedure Get_Groups (Groups : out Group_Stats);
      procedure Get_TCP (Ports : out TCP_Stats);
      procedure Update_Graph_Samples (Result : out EtherScope.Stats.Graph_Samples;
                                      Clear  : in Boolean);

      procedure Analyze_Ethernet (Packet : in out Net.Buffers.Buffer_Type;
                                  Device : out EtherScope.Stats.Device_Index);

      procedure Analyze_IPv4 (Packet : in out Net.Buffers.Buffer_Type;
                              Device : in EtherScope.Stats.Device_Index);

   private
      Deadline      : Ada.Real_Time.Time := Ada.Real_Time.Clock;
      Prev_Time     : Ada.Real_Time.Time := Ada.Real_Time.Clock;

      --  Ethernet information.
      Ethernet      : EtherScope.Analyzer.Ethernet.Analysis;
      Prev_Ethernet : EtherScope.Analyzer.Ethernet.Analysis;

      --  IPv4 analysis.
      IPv4          : EtherScope.Analyzer.IPv4.Analysis;
      Prev_IPv4     : EtherScope.Analyzer.IPv4.Analysis;

      --  IGMP group analysis.
      IGMP_Groups   : EtherScope.Analyzer.IGMP.Analysis;
      Prev_Groups   : EtherScope.Analyzer.IGMP.Analysis;

      --  TCP/IP analysis.
      TCP_Ports     : EtherScope.Analyzer.TCP.Analysis;
      Prev_TCP      : EtherScope.Analyzer.TCP.Analysis;

      --  Pending samples for the graphs.
      Samples       : EtherScope.Stats.Graph_Samples;
   end DB;

   ONE_MS : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (1);

   protected body DB is

      procedure Update_Rates is
         Now : constant Ada.Real_Time.Time := Ada.Real_Time.Clock;
      begin
         if Deadline < Now then
            declare
               Dt  : constant Ada.Real_Time.Time_Span := Now - Prev_Time;
               MS  : constant Integer := Dt / ONE_MS;
            begin
               EtherScope.Analyzer.Ethernet.Update_Rates (Ethernet, Prev_Ethernet, MS);
               EtherScope.Analyzer.IPv4.Update_Rates (IPv4, Prev_IPv4, MS);
               EtherScope.Analyzer.IGMP.Update_Rates (IGMP_Groups, Prev_Groups, MS);
               EtherScope.Analyzer.TCP.Update_Rates (TCP_Ports, Prev_TCP, MS);
               Prev_Time := Now;
               Deadline := Deadline + Ada.Real_Time.Seconds (1);
            end;
         end if;
      end Update_Rates;

      procedure Get_Devices (Devices : out Device_Stats) is
      begin
         Update_Rates;
         Devices.Ethernet := Ethernet.Devices;
         Devices.IPv4     := IPv4.Devices;
         Devices.Count    := Ethernet.Dev_Count;
      end Get_Devices;

      procedure Get_Protocols (Protocols : out Protocol_Stats) is
      begin
         Update_Rates;
         Protocols.Ethernet := Ethernet.Global;
         Protocols.ICMP := IPv4.ICMP;
         Protocols.IGMP := IPv4.IGMP;
         Protocols.UDP  := IPv4.UDP;
         Protocols.TCP  := IPv4.TCP;
         Protocols.Unknown := IPv4.Unknown;
      end Get_Protocols;

      procedure Get_Groups (Groups : out Group_Stats) is
      begin
         Update_Rates;
         Groups.Groups := IGMP_Groups.Groups;
         Groups.Count  := IGMP_Groups.Count;
         Groups.IGMP   := IPv4.IGMP;
         Groups.UDP    := IPv4.UDP;
      end Get_Groups;

      procedure Get_TCP (Ports : out TCP_Stats) is
      begin
         Update_Rates;
         Ports.Ports := TCP_Ports.Ports;
         Ports.Count := TCP_Ports.Count;
         Ports.TCP   := IPv4.TCP;
      end Get_TCP;

      procedure Update_Graph_Samples (Result : out EtherScope.Stats.Graph_Samples;
                                      Clear  : in Boolean) is
      begin
         Result := Samples;
         for I in Samples'Range loop
            Samples (I) := 0;
         end loop;
      end Update_Graph_Samples;

      procedure Analyze_Ethernet (Packet : in out Net.Buffers.Buffer_Type;
                                  Device : out EtherScope.Stats.Device_Index) is
         Ether   : Net.Headers.Ether_Header_Access;
      begin
         Ether := Packet.Ethernet;
         EtherScope.Analyzer.Ethernet.Analyze (Ether, Net.Uint16 (Packet.Get_Length),
                                               Ethernet, Samples, Device);
      end Analyze_Ethernet;

      procedure Analyze_IPv4 (Packet : in out Net.Buffers.Buffer_Type;
                              Device : in EtherScope.Stats.Device_Index) is
      begin
         EtherScope.Analyzer.IPv4.Analyze (Packet, Device, IPv4, IGMP_Groups, TCP_Ports, Samples);
      end Analyze_IPv4;

   end DB;

   --  ------------------------------
   --  Analyze the received packet.
   --  ------------------------------
   procedure Analyze (Packet : in out Net.Buffers.Buffer_Type) is
      Ether  : Net.Headers.Ether_Header_Access;
      Device : EtherScope.Stats.Device_Index;
   begin
      DB.Analyze_Ethernet (Packet, Device);
      Ether := Packet.Ethernet;
      case Net.Headers.To_Host (Ether.Ether_Type) is
         when Net.Protos.ETHERTYPE_ARP =>
            --  EtherScope.Analyzer.Arp.Analyze (Ether);
            null;

         when Net.Protos.ETHERTYPE_IP =>
            DB.Analyze_IPv4 (Packet, Device);

         when others =>
            --  EtherScope.Analyzer.Analyze (Ether, Packet);
            null;

      end case;
   end Analyze;

   --  ------------------------------
   --  Get the device statistics.
   --  ------------------------------
   procedure Get_Devices (Into : out Device_Stats) is
   begin
      DB.Get_Devices (Into);
   end Get_Devices;

   --  ------------------------------
   --  Get the protocol statistics.
   --  ------------------------------
   procedure Get_Protocols (Into : out Protocol_Stats) is
   begin
      DB.Get_Protocols (Into);
   end Get_Protocols;

   --  ------------------------------
   --  Get the multicast group statistics.
   --  ------------------------------
   procedure Get_Groups (Into : out Group_Stats) is
   begin
      DB.Get_Groups (Into);
   end Get_Groups;

   --  ------------------------------
   --  Get the TCP/IP information statistics.
   --  ------------------------------
   procedure Get_TCP (Into : out TCP_Stats) is
   begin
      DB.Get_TCP (Into);
   end Get_TCP;

   procedure Update_Graph_Samples (Samples : out EtherScope.Stats.Graph_Samples;
                                   Clear   : in Boolean) is
   begin
      DB.Update_Graph_Samples (Samples, Clear);
   end Update_Graph_Samples;

end EtherScope.Analyzer.Base;
