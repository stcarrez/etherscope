-----------------------------------------------------------------------
--  ui-graphs -- Generic package to draw graphs
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
with HAL.Bitmap;
with Bitmapped_Drawing;
with Ada.Real_Time;
generic
   type Value_Type is mod <>;
   Graph_Size : Positive;
package UI.Graphs is

   type Value_Data_Type is array (1 .. Graph_Size) of Value_Type;

   type Graph_Type is limited record
      Rate             : Ada.Real_Time.Time_Span;
      Pos              : Bitmapped_Drawing.Point;
      Width            : Natural;
      Height           : Natural;
      Current_Sample   : Value_Type;
      Max_Value        : Value_Type;
      Samples          : Value_Data_Type;
      Deadline         : Ada.Real_Time.Time;
      Last_Pos         : Positive := 1;
      Display_Pos      : Positive := 1;
      Sample_Count     : Natural := 0;
      Foreground       : HAL.Bitmap.Bitmap_Color := HAL.Bitmap.Green;
      Background       : HAL.Bitmap.Bitmap_Color := HAL.Bitmap.Black;
   end record;

   --  Initialize the graph.
   procedure Initialize (Graph  : in out Graph_Type;
                         X      : in Natural;
                         Y      : in Natural;
                         Width  : in Natural;
                         Height : in Natural;
                         Rate   : in Ada.Real_Time.Time_Span);

   --  Add the sample value to the current graph sample.
   procedure Add_Sample (Graph : in out Graph_Type;
                         Value : in Value_Type;
                         Now   : in Ada.Real_Time.Time);

   --  Compute the maximum value seen as a sample in the graph data.
   function Compute_Max_Value (Graph : in Graph_Type) return Value_Type;

   --  Draw the graph.
   procedure Draw (Buffer : in HAL.Bitmap.Bitmap_Buffer'Class;
                   Graph  : in out Graph_Type);

end UI.Graphs;
