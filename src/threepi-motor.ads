--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
package ThreePi.Motor is

   type Motor is (Left, Right, Both);
   type Power is range -1_000 .. +1_000;

   procedure Set_Power
      (M : Motor;
       P : Power);

   procedure Brake
      (M : Motor);

   procedure Initialize;

end ThreePi.Motor;
