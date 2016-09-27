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
with HAL.Bitmap;
with HAL.Touch_Panel;
with Bitmapped_Drawing;
package UI.Buttons is

   --  Button colors (inactive).
   Foreground        : HAL.Bitmap.Bitmap_Color := HAL.Bitmap.Black;
   Background        : HAL.Bitmap.Bitmap_Color := (255, 227, 227, 227);

   --  Button colors (active).
   Active_Foreground : HAL.Bitmap.Bitmap_Color := HAL.Bitmap.Black;
   Active_Background : HAL.Bitmap.Bitmap_Color := (255, 201, 195, 190);

   type Button_State is (B_PRESSED, B_RELEASED, B_DISABLED);

   type Button_Type is record
      Name   : String (1 .. 5);
      Pos    : Bitmapped_Drawing.Point := (0, 0);
      Width  : Positive;
      Height : Positive;
      State  : Button_State := B_RELEASED;
   end record;

   type Button_Event is new Natural;

   subtype Button_Index is Button_Event range 1 .. Button_Event'Last;

   type Button_Array is array (Button_Index range <>) of Button_Type;

   NO_EVENT : constant Button_Event := 0;

   --  Draw the button in its current state on the bitmap.
   procedure Draw_Button (Buffer : in HAL.Bitmap.Bitmap_Buffer'Class;
                          Button : in Button_Type);

   --  Layout and draw a list of buttons starting at the given top position.
   --  Each button is assigned the given width and height.
   procedure Draw_Buttons (Buffer : in HAL.Bitmap.Bitmap_Buffer'Class;
                           List   : in out Button_Array;
                           X      : in Natural;
                           Y      : in Natural;
                           Width  : in Natural;
                           Height : in Natural);

   --  Set the active button in a list of button.  Update <tt>Change</tt> to indicate whether
   --  some button state was changed and a redraw is necessary.
   procedure Set_Active (List    : in out Button_Array;
                         Index   : in Button_Event;
                         Changed : out Boolean);

   --  Check the touch panel for a button being pressed.
   procedure Get_Event (Buffer : in HAL.Bitmap.Bitmap_Buffer'Class;
                        Touch  : in out HAL.Touch_Panel.Touch_Panel_Device'Class;
                        List   : in Button_Array;
                        Event  : out Button_Event);

end UI.Buttons;
