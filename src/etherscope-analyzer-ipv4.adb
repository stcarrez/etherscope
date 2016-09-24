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
with Net.Headers;
with Net.Protos.IPv4;

package body EtherScope.Analyzer.IPv4 is

   --  ------------------------------
   --  Analyze the packet and update the analysis.
   --  ------------------------------
   procedure Analyze (Packet   : in Net.Buffers.Buffer_Type;
                      Device   : in Device_Index;
                      Result   : in out Analysis) is
      use type Net.Ip_Addr;

      Ip_Hdr : constant Net.Headers.IP_Header_Access := Packet.IP;
      Length : constant Net.Uint32 := Net.Uint32 (Packet.Get_Length);
   begin
      if Result.Devices (Device).Ip /= Ip_Hdr.Ip_Src then
         if Result.Devices (Device).Ip /= (0, 0, 0, 0) then
            Result.Devices (Device).Multihome := True;
         end if;
         Result.Devices (Device).Ip := Ip_Hdr.Ip_Src;
      end if;

      --  Collect per IPv4 protocol statistics.
      case Ip_Hdr.Ip_P is
         when Net.Protos.IPv4.P_UDP =>
            EtherScope.Stats.Add (Result.UDP, Length);
            EtherScope.Stats.Add (Result.Devices (Device).UDP, Length);

         when Net.Protos.IPv4.P_TCP =>
            EtherScope.Stats.Add (Result.TCP, Length);
            EtherScope.Stats.Add (Result.Devices (Device).TCP, Length);

         when Net.Protos.IPv4.P_ICMP =>
            EtherScope.Stats.Add (Result.ICMP, Length);
            EtherScope.Stats.Add (Result.Devices (Device).ICMP, Length);

         when Net.Protos.IPv4.P_IGMP =>
            EtherScope.Stats.Add (Result.IGMP, Length);
            EtherScope.Stats.Add (Result.Devices (Device).IGMP, Length);

         when others =>
            EtherScope.Stats.Add (Result.Unknown, Length);
            EtherScope.Stats.Add (Result.Devices (Device).Unknown, Length);

      end case;
   end Analyze;

end EtherScope.Analyzer.IPv4;
