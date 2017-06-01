-----------------------------------------------------------------------
--  ui-texts -- Utilities to draw text strings
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
with Bitmap_Color_Conversion;
package body UI.Texts is

   function Char_Width (C : in Character) return Natural;

   function Char_Width (C : in Character) return Natural is
      pragma Unreferenced (C);
      use type BMP_Fonts.BMP_Font;
   begin
      if Current_Font /= BMP_Fonts.Font12x12 then
         return BMP_Fonts.Char_Width (Current_Font);
      end if;
      return BMP_Fonts.Char_Width (Current_Font) - 2;
   end Char_Width;

   --  ------------------------------
   --  Get the width of the string in pixels after rendering with the current font.
   --  ------------------------------
   function Get_Width (S : in String) return Natural is
      W : constant Natural := Char_Width ('a');
   begin
      return W * S'Length;
   end Get_Width;

   --  ------------------------------
   --  Draw the string at the given position and using the justification so that we don't
   --  span more than the width.  The current font, foreground and background are used
   --  to draw the string.
   --  ------------------------------
   procedure Draw_String (Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class;
                          Start   : in HAL.Bitmap.Point;
                          Width   : in Natural;
                          Msg     : in String;
                          Justify : in Justify_Type := LEFT) is
      X    : Natural := Start.X;
      Y    : constant Natural := Start.Y;
      Last : Natural := Start.X + Width;
      FG    : constant HAL.UInt32 := Bitmap_Color_Conversion.Bitmap_Color_To_Word (Buffer.Color_Mode,
                                                                      Foreground);
      BG    : constant HAL.UInt32 := Bitmap_Color_Conversion.Bitmap_Color_To_Word (Buffer.Color_Mode,
                                                                      Background);
   begin
      if Last > Buffer.Width then
         Last := Buffer.Width;
      end if;
      case Justify is
         when LEFT =>
            for C of Msg loop
               exit when X > Last;
               Bitmapped_Drawing.Draw_Char (Buffer     => Buffer,
                                            Start      => (X, Y),
                                            Char       => C,
                                            Font       => Current_Font,
                                            Foreground => FG,
                                            Background => BG);
               X := X + Char_Width (C);
            end loop;

         when RIGHT =>
            X := X + Width;
            for C of reverse Msg loop
               exit when X - Char_Width (C) < Start.X;
               X := X - Char_Width (C);
               Bitmapped_Drawing.Draw_Char (Buffer     => Buffer,
                                            Start      => (X, Y),
                                            Char       => C,
                                            Font       => Current_Font,
                                            Foreground => FG,
                                            Background => BG);
            end loop;

      end case;
   end Draw_String;

end UI.Texts;
