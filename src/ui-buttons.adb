-----------------------------------------------------------------------
--  ui -- User Interface Framework
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
with Bitmapped_Drawing;
with Bmp_Fonts;
package body UI.Buttons is

   --  ------------------------------
   --  Draw the button in its current state on the bitmap.
   --  ------------------------------
   procedure Draw_Button (Buffer : in HAL.Bitmap.Bitmap_Buffer'Class;
                          Button : in Button_Type) is
   begin
      Bitmapped_Drawing.Draw_String (Buffer,
                                     Start      => (Button.Pos.X + 2, Button.Pos.Y + 2),
                                     Msg        => Button.Name,
                                     Font       => Bmp_Fonts.Font16x24,
                                     Foreground => HAL.Bitmap.White,
                                     Background => HAL.Bitmap.Transparent);
   end Draw_Button;

   --  ------------------------------
   --  Layout and draw a list of buttons starting at the given top position.
   --  Each button is assigned the given width and height.
   --  ------------------------------
   procedure Draw_Buttons (Buffer : in HAL.Bitmap.Bitmap_Buffer'Class;
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
   --  Check the touch panel for a button being pressed.
   --  ------------------------------
   procedure Get_Event (Buffer : in HAL.Bitmap.Bitmap_Buffer'Class;
                        Touch  : in out HAL.Touch_Panel.Touch_Panel_Device'Class;
                        List   : in out Button_Array;
                        Event  : out Button_Event) is
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
               List (I).State := B_PRESSED;
               Event := I;
               return;
            end if;
         end loop;
      end if;
      Event := NO_EVENT;
   end Get_Event;

end UI.Buttons;
