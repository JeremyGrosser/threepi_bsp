--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL; use HAL;

package ThreePi.LED is

   type Name is (A, B, C, D, E, F);

   procedure Set_RGB
      (N          : Name;
       R, G, B    : UInt8 := 0;
       Brightness : UInt5 := 15);

   procedure Set_HSV
      (N          : Name;
       H, S, V    : UInt8 := 0;
       Brightness : UInt5 := 15);

   procedure Update;
   --  Write out color values to all LEDs. Must be called after Set_RGB/Set_HSV
   --  for changes to take effect.

   procedure Initialize;

end ThreePi.LED;
