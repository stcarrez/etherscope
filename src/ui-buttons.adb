-----------------------------------------------------------------------
--  ui -- User Interface Framework
--  Copyright (C) 2016, 2017 Stephane Carrez
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
with Bitmapped_Drawing;
with BMP_Fonts;
package body UI.Buttons is


   --  ------------------------------
   --  Draw the button in its current state on the bitmap.
   --  ------------------------------
   procedure Draw_Button (Buffer : in out HAL.Bitmap.Bitmap_Buffer'Class;
                          Button : in Button_Type) is
      Color : constant HAL.Bitmap.Bitmap_Color
        := (if Button.State = B_RELEASED then Background else Active_Background);
   begin
      Buffer.Set_Source (Color);
      Buffer.Fill_Rect (Area => (Position => (Button.Pos.X + 1, Button.Pos.Y + 1),
                                 Width  => Button.Width - 2,
                                 Height => Button.Height - 2));
      if Button.State = B_PRESSED then
         Buffer.Set_Source (HAL.Bitmap.Grey);
         Buffer.Draw_Rect (Area => (Position => (Button.Pos.X + 3, Button.Pos.Y + 3),
                                    Width  => Button.Width - 5,
                                    Height => Button.Height - 6));
         Buffer.Draw_Horizontal_Line (Pt => (Button.Pos.X + 2, Button.Pos.Y + 2),
                                      Width => Button.Width - 4);
         Buffer.Draw_Vertical_Line (Pt => (Button.Pos.X + 2, Button.Pos.Y + 2),
                                    Height => Button.Height - 4);
      end if;
      Bitmapped_Drawing.Draw_String
        (Buffer,
         Start      => (Button.Pos.X + 4, Button.Pos.Y + 6),
         Msg        => Button.Name,
         Font       => BMP_Fonts.Font16x24,
         Foreground => (if Button.State = B_RELEASED then Foreground else Active_Foreground),
         Background => Color);
   end Draw_Button;

   --  ------------------------------
   --  Layout and draw a list of buttons starting at the given top position.
   --  Each button is assigned the given width and height.
   --  ------------------------------
   procedure Draw_Buttons (Buffer : in out HAL.Bitmap.Bitmap_Buffer'Class;
                           List   : in out Button_Array;
                           X      : in Natural;
                           Y      : in Natural;
                           Width  : in Natural;
                           Height : in Natural) is
      By : Natural := Y;
   begin
      for I in List'Range loop
         List (I).Width  := Width;
         List (I).Height := Height;
         List (I).Pos    := (X, By);
         Draw_Button (Buffer, List (I));
         By := By + Height;
      end loop;
   end Draw_Buttons;

   --  ------------------------------
   --  Set the active button in a list of button.  Update <tt>Change</tt> to indicate whether
   --  some button state was changed and a redraw is necessary.
   --  ------------------------------
   procedure Set_Active (List    : in out Button_Array;
                         Index   : in Button_Event;
                         Changed : out Boolean) is
      State : Button_State;
   begin
      Changed := False;
      for I in List'Range loop
         if List (I).State /= B_DISABLED then
            State := (if I = Index then B_PRESSED else B_RELEASED);
            if State /= List (I).State then
               List (I).State := State;
               Changed := True;
            end if;
         end if;
      end loop;
   end Set_Active;

   --  ------------------------------
   --  Check the touch panel for a button being pressed.
   --  ------------------------------
   procedure Get_Event (Buffer : in HAL.Bitmap.Bitmap_Buffer'Class;
                        Touch  : in out HAL.Touch_Panel.Touch_Panel_Device'Class;
                        List   : in Button_Array;
                        Event  : out Button_Event) is
      pragma Unreferenced (Buffer);
      State : constant HAL.Touch_Panel.TP_State := Touch.Get_All_Touch_Points;
      X     : Natural;
      Y     : Natural;
   begin
      if State'Length > 0 then
         X := State (State'First).X;
         Y := State (State'First).Y;
         for I in List'Range loop
            if X >= List (I).Pos.X and Y >= List (I).Pos.Y
              and X < List (I).Pos.X + List (I).Width
              and Y < List (I).Pos.Y + List (I).Height
            then
               Event := I;
               return;
            end if;
         end loop;
      end if;
      Event := NO_EVENT;
   end Get_Event;

end UI.Buttons;
