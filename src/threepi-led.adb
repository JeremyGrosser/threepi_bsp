--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with ThreePi.Pins;
with RP2040_SVD.SPI;
with RP.GPIO;
with RP.SPI;
with HAL.SPI;

package body ThreePi.LED is
   use ThreePi.Pins.LED;
   use RP.GPIO;

   RGB_SPI : aliased RP.SPI.SPI_Port (0, RP2040_SVD.SPI.SPI0_Periph'Access);

   subtype Color is HAL.SPI.SPI_Data_8b (1 .. 4);
   type Color_Array is array (Name) of Color
      with Component_Size => 32;
   Colors : Color_Array := (others => (0, 0, 0, 0));

   procedure Set_RGB
      (N          : Name;
       R, G, B    : UInt8 := 0;
       Brightness : UInt5 := 15)
   is
   begin
      Colors (N) := (UInt8 (Brightness) or 2#1110_0000#, B, G, R);
   end Set_RGB;

   procedure Set_HSV
      (N          : Name;
       H, S, V    : UInt8 := 0;
       Brightness : UInt5 := 15)
   is
      R, G, B : UInt8;
      Region, Remainder : UInt32;
      A, Q, T : UInt8;
   begin
      if S = 0 then
         R := V;
         G := V;
         B := V;
      else
         Region := UInt32 (H / 43);
         Remainder := (UInt32 (H) - (Region * 43)) * 6;

         A := UInt8 (Shift_Right (UInt32 (V) * (255 - UInt32 (S)), 8));

         Q := UInt8 (Shift_Right (UInt32 (V) *
                     (255 - Shift_Right (UInt32 (S) * Remainder, 8)), 8));

         T := UInt8 (Shift_Right (UInt32 (V) *
                     (255 - Shift_Right (UInt32 (S) *
                        (255 - Remainder), 8)), 8));

         case (Region) is
            when      0 => R := V; G := T; B := A;
            when      1 => R := Q; G := V; B := A;
            when      2 => R := A; G := V; B := T;
            when      3 => R := A; G := Q; B := V;
            when      4 => R := T; G := A; B := V;
            when others => R := V; G := A; B := Q;
         end case;
      end if;

      Set_RGB (N, R, G, B, Brightness);
   end Set_HSV;

   procedure Update is
      use HAL.SPI;
      Status : SPI_Status;
   begin
      RGB_SPI.Transmit (SPI_Data_8b'(0, 0, 0, 0), Status, Timeout => 0);
      for Value of Colors loop
         RGB_SPI.Transmit (Value, Status, Timeout => 0);
      end loop;
      RGB_SPI.Transmit (SPI_Data_8b'(16#FF#, 16#FF#, 16#FF#, 16#FF#), Status, Timeout => 0);
   end Update;

   procedure Initialize is
   begin
      RGB_CLK.Configure (Output, Floating, RP.GPIO.SPI);
      RGB_DAT.Configure (Output, Floating, RP.GPIO.SPI);
      RGB_SPI.Configure ((Baud => 1_200_000, others => <>));
      for N in Name'Range loop
         Set_RGB (N, 0, 0, 0);
      end loop;
      Update;
   end Initialize;
end ThreePi.LED;
