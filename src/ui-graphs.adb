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

package body UI.Graphs is

   --  ------------------------------
   --  Initialize the graph.
   --  ------------------------------
   procedure Initialize (Graph  : in out Graph_Type;
                         X      : in Natural;
                         Y      : in Natural;
                         Width  : in Natural;
                         Height : in Natural;
                         Rate   : in Ada.Real_Time.Time_Span) is
      use type Ada.Real_Time.Time;
   begin
      Graph.Pos.X := X;
      Graph.Pos.Y := Y;
      Graph.Width := Width;
      Graph.Height := Height;
      Graph.Rate   := Rate;
      Graph.Current_Sample := Value_Type'First;
      Graph.Deadline := Ada.Real_Time.Clock + Rate;
      Graph.Sample_Count := 0;
      Graph.Last_Pos := 1;
      Graph.Samples := (others => Value_Type'First);
   end Initialize;

   --  ------------------------------
   --  Add the sample value to the current graph sample.
   --  ------------------------------
   procedure Add_Sample (Graph : in out Graph_Type;
                         Value : in Value_Type;
                         Now   : in Ada.Real_Time.Time) is
      use type Ada.Real_Time.Time;
   begin
      --  Deadline has passed, update the graph values, filling with zero empty slots.
      if Graph.Deadline < Now then
         loop
            Graph.Samples (Graph.Last_Pos) := Graph.Current_Sample;
            Graph.Current_Sample := Value_Type'First;
            if Graph.Last_Pos = Graph.Samples'Last then
               Graph.Last_Pos := Graph.Samples'First;
            else
               Graph.Last_Pos := Graph.Last_Pos + 1;
            end if;
            if Graph.Sample_Count < Graph.Samples'Length then
               Graph.Sample_Count := Graph.Sample_Count + 1;
            end if;
            Graph.Deadline := Graph.Deadline + Graph.Rate;

            --  Check if next deadline has passed.
            exit when Now < Graph.Deadline;
         end loop;
      end if;
      Graph.Current_Sample := Graph.Current_Sample + Value;
   end Add_Sample;

   --  ------------------------------
   --  Compute the maximum value seen as a sample in the graph data.
   --  ------------------------------
   function Compute_Max_Value (Graph : in Graph_Type) return Value_Type is
      Value : Value_Type := Value_Type'First;
   begin
      for V of Graph.Samples loop
         if V > Value then
            Value := V;
         end if;
      end loop;
      return Value;
   end Compute_Max_Value;

   --  ------------------------------
   --  Draw the graph.
   --  ------------------------------
   procedure Draw (Buffer : in HAL.Bitmap.Bitmap_Buffer'Class;
                   Graph  : in out Graph_Type) is
      Pos : Positive := 1;
      X   : Natural := Graph.Pos.X;
      H   : Natural;
      V   : Value_Type;
      Last_X : Natural := Graph.Pos.X + Graph.Width;
   begin
      if Graph.Max_Value = 0 then
         Graph.Max_Value := Compute_Max_Value (Graph);
      end if;
      Buffer.Fill_Rect (Color  => Graph.Background,
                        X      => Graph.Pos.X,
                        Y      => Graph.Pos.Y,
                        Width  => Graph.Width,
                        Height => Graph.Height);
      if Graph.Max_Value = Value_Type'First then
         return;
      end if;
      if Pos + Graph.Sample_Count - 1 > Graph.Width then
         Pos := Graph.Sample_Count - Graph.Width;
      end if;
      while X < Last_X loop
         V := Graph.Samples (Pos);
         if V /= Value_Type'First then
            H := Natural ((V * Value_Type (Graph.Height)) / Graph.Max_Value);
            if H > Graph.Height then
               H := Graph.Height;
            end if;

--              Buffer.Draw_Vertical_Line (Color  => Graph.Foreground,
--                                         X      => X,
--                                         Y      => Graph.Pos.Y + Graph.Height - H,
--                                         Height => H);
         else
            H := 1;
         end if;
         Buffer.Set_Pixel (X     => X,
                           Y     => Graph.Pos.Y + Graph.Height - H,
                           Value => Graph.Foreground);
         if Pos = Graph.Samples'Last then
            Pos := Graph.Samples'First;
         else
            Pos := Pos + 1;
         end if;
         X := X + 1;
      end loop;
   end Draw;

end UI.Graphs;
