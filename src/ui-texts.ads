-----------------------------------------------------------------------
--  ui-texts -- Utilities to draw text strings
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
with BMP_Fonts;
with Bitmapped_Drawing;
package UI.Texts is

   type Justify_Type is (LEFT, RIGHT);  --  CENTER is left as an exercise to the reader.

   Foreground   : HAL.Bitmap.Bitmap_Color := HAL.Bitmap.White;
   Background   : HAL.Bitmap.Bitmap_Color := HAL.Bitmap.Black;
   Current_Font : BMP_Fonts.BMP_Font := BMP_Fonts.Font12x12;

   --  Get the width of the string in pixels after rendering with the current font.
   function Get_Width (S : in String) return Natural;

   --  Draw the string at the given position and using the justification so that we don't
   --  span more than the width.  The current font, foreground and background are used
   --  to draw the string.
   procedure Draw_String (Buffer  : in HAL.Bitmap.Bitmap_Buffer'Class;
                          Start   : in Bitmapped_Drawing.Point;
                          Width   : in Natural;
                          Msg     : in String;
                          Justify : in Justify_Type := LEFT);

end UI.Texts;
