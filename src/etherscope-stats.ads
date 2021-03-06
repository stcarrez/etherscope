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
with Net;
package EtherScope.Stats is

   --  Device count and index types.
   type Device_Count is new Natural range 0 .. 5;
   subtype Device_Index is Device_Count range 1 .. Device_Count'Last;

   --  Protocol count and index types.
   type Protocol_Count is new Natural range 0 .. 10;
   subtype Protocol_Index is Protocol_Count range 1 .. Protocol_Count'Last;

   --  IGMP group count and index types.
   type Group_Count is new Natural range 0 .. 5;
   subtype Group_Index is Group_Count range 1 .. Group_Count'Last;

   type Graph_Kind is (G_ETHERNET,
                       G_IPv4,
                       G_ICMP,
                       G_IGMP,
                       G_UDP,
                       G_TCP);

   type Graph_Samples is array (Graph_Kind) of Net.Uint64;

   type Statistics is record
      --  Number of packets seen.
      Packets   : Net.Uint32 := 0;

      --  Number of bytes seen.
      Bytes     : Net.Uint64 := 0;

      --  Bandwidth utilization in bits/sec.
      Bandwidth : Net.Uint32 := 0;
   end record;

   --  Update the statistics after reception of a packet of the given length.
   procedure Add (Stats  : in out Statistics;
                  Length : in Net.Uint32);

   --  Update the statistics after reception of a packet of the given length.
   procedure Add (Samples : in out Graph_Samples;
                  Kind    : in Graph_Kind;
                  Stats   : in out Statistics;
                  Length  : in Net.Uint32);

   --  Compute the bandwidth utilization in bits per second.  The <tt>Dt</tt> is the
   --  delta time in milliseconds that ellapsed between the two samples.  After the
   --  call, <tt>Previous</tt> contains the same value as <tt>Current</tt>.
   procedure Update_Rate (Current  : in out Statistics;
                          Previous : in out Statistics;
                          Dt       : in Positive);

end EtherScope.Stats;
