-----------------------------------------------------------------------
--  etherscope-analyzer -- Packet analyzer
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

package body EtherScope.Analyzer.Ethernet is

   use type EtherScope.Stats.Device_Count;

   --  ------------------------------
   --  Analyze the packet and update the analysis.
   --  ------------------------------
   procedure Analyze (Ether    : in Net.Headers.Ether_Header_Access;
                      Length   : in Net.Uint16;
                      Result   : in out Analysis;
                      Device   : out Device_Index) is
      use type Net.Uint16;
      use type Net.Uint32;
      use type Net.Ether_Addr;
      Found : Boolean := False;
   begin
      --  Collect information by device/Ethernet address.
      for I in 1 .. Result.Dev_Count loop
         if Result.Devices (I).Mac = Ether.Ether_Shost then
            Device := I;
            Found := True;
            exit;
         end if;
      end loop;
      if not Found then
         if Result.Dev_Count < Device_Index'Last then
            Result.Dev_Count := Result.Dev_Count + 1;
            Result.Devices (Result.Dev_Count).Mac := Ether.Ether_Shost;
         end if;
         Device := Result.Dev_Count;
      end if;
      EtherScope.Stats.Add (Result.Devices (Device).Stats, Net.Uint32 (Length));

      --  Collect information by Ethernet protocol.
      for I in Result.Protocols'Range loop
         if Result.Protocols (I).Stats.Packets = 0 then
            Result.Protocols (I).Proto := Ether.Ether_Type;
         end if;
         if Result.Protocols (I).Proto = Ether.Ether_Type or else I = Result.Protocols'Last then
            EtherScope.Stats.Add (Result.Protocols (I).Stats, Net.Uint32 (Length));
            exit;
         end if;
      end loop;
   end Analyze;

end EtherScope.Analyzer.Ethernet;
