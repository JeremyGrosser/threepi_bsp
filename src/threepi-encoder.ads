--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
package ThreePi.Encoder is

   type Int32 is range -2 ** 31 .. 2 ** 31 - 1
      with Size => 32;

   function Left_Count
      return Int32;

   function Right_Count
      return Int32;

   procedure Initialize;

end ThreePi.Encoder;
