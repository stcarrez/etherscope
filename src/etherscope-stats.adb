-----------------------------------------------------------------------
--  etherscope-stats -- Ethernet Packet Statistics
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
package body EtherScope.Stats is

   use type Net.Uint32;
   use type Net.Uint64;

   --  ------------------------------
   --  Update the statistics after reception of a packet of the given length.
   --  ------------------------------
   procedure Add (Stats  : in out Statistics;
                  Length : in Net.Uint32) is
   begin
      Stats.Packets := Stats.Packets + 1;
      Stats.Bytes   := Stats.Bytes + Net.Uint64 (Length);
   end Add;

   --  ------------------------------
   --  Update the statistics after reception of a packet of the given length.
   --  ------------------------------
   procedure Add (Samples : in out Graph_Samples;
                  Kind    : in Graph_Kind;
                  Stats   : in out Statistics;
                  Length  : in Net.Uint32) is
   begin
      Stats.Packets := Stats.Packets + 1;
      Stats.Bytes   := Stats.Bytes + Net.Uint64 (Length);
      Samples (Kind) := Samples (Kind) + Net.Uint64 (Length);
   end Add;

   --  ------------------------------
   --  Compute the bandwidth utilization in bits per second.  The <tt>Dt</tt> is the
   --  delta time in milliseconds that ellapsed between the two samples.  After the
   --  call, <tt>Previous</tt> contains the same value as <tt>Current</tt>.
   --  ------------------------------
   procedure Update_Rate (Current  : in out Statistics;
                          Previous : in out Statistics;
                          Dt       : in Positive) is
      D : constant Net.Uint32 := Net.Uint32 (Current.Bytes - Previous.Bytes);
   begin
      if D /= 0 then
         Current.Bandwidth := (8_000 * D) / Net.Uint32 (Dt);
      else
         Current.Bandwidth := 0;
      end if;
      Previous := Current;
   end Update_Rate;

end EtherScope.Stats;
