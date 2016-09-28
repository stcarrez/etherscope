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

   use type EtherScope.Stats.Device_Count;

   --  ------------------------------
   --  Analyze the packet and update the analysis.
   --  ------------------------------
   procedure Analyze (Packet   : in Net.Buffers.Buffer_Type;
                      Device   : in Device_Index;
                      Result   : in out Analysis;
                      Groups   : in out EtherScope.Analyzer.IGMP.Analysis;
                      Ports    : in out EtherScope.Analyzer.TCP.Analysis;
                      Samples  : in out EtherScope.Stats.Graph_Samples) is
      use type Net.Ip_Addr;

      Ip_Hdr : constant Net.Headers.IP_Header_Access := Packet.IP;
      Length : constant Net.Uint32 := Net.Uint32 (Packet.Get_Length);
   begin
      if Result.Devices (Device).Ip /= Ip_Hdr.Ip_Src then
         if Device > Result.Count then
            Result.Count := Device;
         end if;
         if Result.Devices (Device).Ip /= (0, 0, 0, 0) then
            Result.Devices (Device).Multihome := True;
         end if;
         Result.Devices (Device).Ip := Ip_Hdr.Ip_Src;
      end if;

      --  Collect per IPv4 protocol statistics.
      case Ip_Hdr.Ip_P is
         when Net.Protos.IPv4.P_UDP =>
            EtherScope.Stats.Add (Samples, EtherScope.Stats.G_UDP, Result.UDP, Length);
            EtherScope.Stats.Add (Result.Devices (Device).UDP, Length);
            if Net.Is_Multicast (Ip_Hdr.Ip_Dst) then
               EtherScope.Analyzer.IGMP.Analyze_Traffic (Packet, Groups);
            end if;

         when Net.Protos.IPv4.P_TCP =>
            EtherScope.Stats.Add (Samples, EtherScope.Stats.G_TCP, Result.TCP, Length);
            EtherScope.Stats.Add (Result.Devices (Device).TCP, Length);
            EtherScope.Analyzer.TCP.Analyze (Packet, Ports);

         when Net.Protos.IPv4.P_ICMP =>
            EtherScope.Stats.Add (Samples, EtherScope.Stats.G_ICMP, Result.ICMP, Length);
            EtherScope.Stats.Add (Result.Devices (Device).ICMP, Length);

         when Net.Protos.IPv4.P_IGMP =>
            EtherScope.Stats.Add (Samples, EtherScope.Stats.G_IGMP, Result.IGMP, Length);
            EtherScope.Stats.Add (Result.Devices (Device).IGMP, Length);
            EtherScope.Analyzer.IGMP.Analyze (Packet, Groups);

         when others =>
            EtherScope.Stats.Add (Result.Unknown, Length);
            EtherScope.Stats.Add (Result.Devices (Device).Unknown, Length);

      end case;
   end Analyze;

   --  ------------------------------
   --  Compute the bandwidth utilization for different devices and protocols.
   --  ------------------------------
   procedure Update_Rates (Current  : in out Analysis;
                           Previous : in out Analysis;
                           Dt       : in Positive) is
   begin
      for I in 1 .. Current.Count loop
         if I <= Previous.Count then
            EtherScope.Stats.Update_Rate (Current.Devices (I).ICMP, Previous.Devices (I).ICMP, Dt);
            EtherScope.Stats.Update_Rate (Current.Devices (I).IGMP, Previous.Devices (I).IGMP, Dt);
            EtherScope.Stats.Update_Rate (Current.Devices (I).UDP, Previous.Devices (I).UDP, Dt);
            EtherScope.Stats.Update_Rate (Current.Devices (I).TCP, Previous.Devices (I).TCP, Dt);
         else
            Previous.Devices (I) := Current.Devices (I);
         end if;
      end loop;
      Previous.Count := Current.Count;

      EtherScope.Stats.Update_Rate (Current.ICMP, Previous.ICMP, Dt);
      EtherScope.Stats.Update_Rate (Current.IGMP, Previous.IGMP, Dt);
      EtherScope.Stats.Update_Rate (Current.UDP, Previous.UDP, Dt);
      EtherScope.Stats.Update_Rate (Current.TCP, Previous.TCP, Dt);
      EtherScope.Stats.Update_Rate (Current.UDP, Previous.Unknown, Dt);
   end Update_Rates;

end EtherScope.Analyzer.IPv4;
