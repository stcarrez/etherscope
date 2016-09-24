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
with Net.Headers;
with Net.Protos;
package body EtherScope.Analyzer.Base is

   use type EtherScope.Stats.Device_Count;

   --  Protect the access of the analysis results between the
   --  analyzer's task and the display main task.
   protected DB is
      function Get_Devices return Device_Stats;
      function Get_Protocols return Protocol_Stats;

      procedure Analyze_Ethernet (Packet : in out Net.Buffers.Buffer_Type;
                                  Device : out EtherScope.Stats.Device_Index);

      procedure Analyze_IPv4 (Packet : in out Net.Buffers.Buffer_Type;
                              Device : in EtherScope.Stats.Device_Index);

   private
      --  Ethernet information.
      Ethernet  : EtherScope.Analyzer.Ethernet.Analysis;

      --  IPv4 analysis.
      IPv4      : EtherScope.Analyzer.IPv4.Analysis;
   end DB;

   protected body DB is

      function Get_Devices return Device_Stats is
         Devices   : Device_Stats;
      begin
         Devices.Ethernet := Ethernet.Devices;
         Devices.IPv4     := IPv4.Devices;
         Devices.Count    := Ethernet.Dev_Count;
         return Devices;
      end Get_Devices;

      function Get_Protocols return Protocol_Stats is
         Protocols   : Protocol_Stats;
      begin
         Protocols.ICMP := IPv4.ICMP;
         Protocols.IGMP := IPv4.IGMP;
         Protocols.UDP  := IPv4.UDP;
         Protocols.TCP  := IPv4.TCP;
         Protocols.Unknown := IPv4.Unknown;
         return Protocols;
      end Get_Protocols;

      procedure Analyze_Ethernet (Packet : in out Net.Buffers.Buffer_Type;
                                  Device : out EtherScope.Stats.Device_Index) is
         Ether   : Net.Headers.Ether_Header_Access;
      begin
         Ether := Packet.Ethernet;
         EtherScope.Analyzer.Ethernet.Analyze (Ether, Net.Uint16 (Packet.Get_Length),
                                               Ethernet, Device);
      end Analyze_Ethernet;

      procedure Analyze_IPv4 (Packet : in out Net.Buffers.Buffer_Type;
                              Device : in EtherScope.Stats.Device_Index) is
      begin
         EtherScope.Analyzer.IPv4.Analyze (Packet, Device, IPv4);
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
   function Get_Devices return Device_Stats is
   begin
      return DB.Get_Devices;
   end Get_Devices;

   --  ------------------------------
   --  Get the protocol statistics.
   --  ------------------------------
   function Get_Protocols return Protocol_Stats is
   begin
      return DB.Get_Protocols;
   end Get_Protocols;

end EtherScope.Analyzer.Base;
