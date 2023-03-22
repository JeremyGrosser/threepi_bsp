--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with ThreePi; use ThreePi;
with ThreePi.Motor;
with ThreePi.LED;
with ThreePi.Timer;

package body LCH is
   procedure Last_Chance_Handler is
   begin
      Motor.Brake (Motor.Left);
      Motor.Brake (Motor.Right);

      loop
         for N in LED.Name'Range loop
            LED.Set_RGB (N, 255, 0, 0);
         end loop;
         LED.Update;
         Timer.Delay_Milliseconds (250);

         for N in LED.Name'Range loop
            LED.Set_RGB (N, 128, 0, 0);
         end loop;
         LED.Update;
         Timer.Delay_Milliseconds (250);
      end loop;
   end Last_Chance_Handler;
end LCH;
