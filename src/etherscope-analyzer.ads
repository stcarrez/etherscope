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

--  == EtherScope Analyzer ==
--  The packet analysis is split in different parts depending on the protocol
--  identified on the packet.  Each protocol analyzer collects its own information
--  in some <tt>Analysis</tt> record.  Some protocol analyzer also rely on the
--  analysis of another protocol.
--
--  @include etherscope-analyzer-base.ads
--  @include etherscope-analyzer-ethernet.ads
--  @include etherscope-analyzer-ipv4.ads
--  @include etherscope-analyzer-igmp.ads
--  @include etherscope-analyzer-tcp.ads
package EtherScope.Analyzer is

end EtherScope.Analyzer;
