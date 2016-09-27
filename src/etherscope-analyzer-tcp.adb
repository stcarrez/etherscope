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
with Net.Headers;

package body EtherScope.Analyzer.TCP is

   use type Net.Ip_Addr;
   use type EtherScope.Stats.Group_Count;

   --  ------------------------------
   --  Analyze the packet and update the analysis.
   --  ------------------------------
   procedure Analyze (Packet   : in Net.Buffers.Buffer_Type;
                      Result   : in out Analysis) is
      TCP  : constant Net.Headers.TCP_Header_Access := Packet.TCP;
      Port : constant Net.Uint16 := (if TCP.Th_Sport < TCP.Th_Dport then TCP.Th_Sport else TCP.Th_Dport);
   begin
      for I in 1 .. Result.Count loop
         if Result.Ports (I).Port = Port then
            EtherScope.Stats.Add (Result.Ports (I).TCP, Net.Uint32 (Packet.Get_Length));
            return;
         end if;
      end loop;
      if Result.Count = Result.Ports'Last or (Port > 1024 and Port /= 8080) then
         return;
      end if;
      Result.Count := Result.Count + 1;
      Result.Ports (Result.Count).Port := Port;
      EtherScope.Stats.Add (Result.Ports (Result.Count).TCP, Net.Uint32 (Packet.Get_Length));
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
            EtherScope.Stats.Update_Rate (Current.Ports (I).TCP, Previous.Ports (I).TCP, Dt);
         else
            Previous.Ports (I).TCP := Current.Ports (I).TCP;
         end if;
      end loop;
      Previous.Count := Current.Count;
   end Update_Rates;

end EtherScope.Analyzer.TCP;
