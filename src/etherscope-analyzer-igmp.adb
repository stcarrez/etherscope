-----------------------------------------------------------------------
--  etherscope-analyzer-igmp -- IGMP packet analyzer
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

package body EtherScope.Analyzer.IGMP is

   use type Net.Ip_Addr;
   use type EtherScope.Stats.Group_Count;

   --  ------------------------------
   --  Analyze the packet and update the analysis.
   --  ------------------------------
   procedure Analyze (Packet   : in Net.Buffers.Buffer_Type;
                      Result   : in out Analysis) is
      IGMP : constant Net.Headers.IGMP_Header_Access := Packet.IGMP;
   begin
      case IGMP.Igmp_Type is
         when Net.Headers.IGMP_V2_MEMBERSHIP_REPORT
            | Net.Headers.IGMP_V3_MEMBERSHIP_REPORT =>
            for I in 1 .. Result.Count loop
               if Result.Groups (I).Ip = IGMP.Igmp_Group then
                  Result.Groups (I).Report_Count := Result.Groups (I).Report_Count + 1;
                  Result.Groups (I).Last_Report := Ada.Real_Time.Clock;
                  return;
               end if;
            end loop;
            if Result.Count = Result.Groups'Last then
               return;
            end if;
            Result.Count := Result.Count + 1;
            Result.Groups (Result.Count).Ip := IGMP.Igmp_Group;
            Result.Groups (Result.Count).Report_Count := 1;
            Result.Groups (Result.Count).Last_Report := Ada.Real_Time.Clock;

         when Net.Headers.IGMP_V2_LEAVE_GROUP =>
            --  Look for the group and remove the entry.  We (incorrectly) assume that
            --  there is only one subscriber.
            for I in 1 .. Result.Count loop
               if Result.Groups (I).Ip = IGMP.Igmp_Group then
                  if I < Result.Count then
                     Result.Groups (I .. Result.Count - 1) := Result.Groups (I + 1 .. Result.Count);
                  end if;
                  Result.Count := Result.Count - 1;
                  return;
               end if;
            end loop;

         when others =>
            null;

      end case;
   end Analyze;

   --  ------------------------------
   --  Analyze the UDP multicast packet and update the analysis.
   --  ------------------------------
   procedure Analyze_Traffic (Packet   : in Net.Buffers.Buffer_Type;
                              Result   : in out Analysis) is
      Ip_Hdr : constant Net.Headers.IP_Header_Access := Packet.IP;
   begin
      --  Find the multicast group based on the multicast address and update the UDP flow.
      for I in 1 .. Result.Count loop
         if Result.Groups (I).Ip = Ip_Hdr.Ip_Dst then
            EtherScope.Stats.Add (Result.Groups (I).UDP, Net.Uint32 (Packet.Get_Length));
            return;
         end if;
      end loop;
   end Analyze_Traffic;

   --  ------------------------------
   --  Compute the bandwidth utilization for different devices and protocols.
   --  ------------------------------
   procedure Update_Rates (Current  : in out Analysis;
                           Previous : in out Analysis;
                           Dt       : in Positive) is
   begin
      for I in 1 .. Current.Count loop
         if I <= Previous.Count then
            EtherScope.Stats.Update_Rate (Current.Groups (I).UDP, Previous.Groups (I).UDP, Dt);
         else
            Previous.Groups (I).UDP := Current.Groups (I).UDP;
         end if;
      end loop;
      Previous.Count := Current.Count;
   end Update_Rates;

end EtherScope.Analyzer.IGMP;
