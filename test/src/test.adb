--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with Ada.Text_IO; use Ada.Text_IO;
with ThreePi; use ThreePi;
with ThreePi.Timer; use ThreePi.Timer;
with ThreePi.Encoder;
with ThreePi.Motor;
with ThreePi.Battery;
with ThreePi.LED;
with ThreePi.IMU;

with LCH;
pragma Unreferenced (LCH);

with RP.Clock;
with RP.GPIO;

procedure Test is
   use type ThreePi.Timer.Time;
   use type ThreePi.Motor.Power;

   ESTOP : aliased RP.GPIO.GPIO_Point := (Pin => 24);

   Rate : constant Time := Milliseconds (100);
   T : Time := Clock;
   Elapsed : Time;

   Limit : constant Motor.Power := 300;
   Step : Motor.Power := +5;
   P : Motor.Power := 0;

   F : IMU.Flux;
begin
   ThreePi.Initialize;

   ESTOP.Configure (RP.GPIO.Input, RP.GPIO.Pull_Up);

   loop
      if ESTOP.Set then
         raise Program_Error with "EMERGENCY STOP";
      end if;

      Put ("BAT");
      Put (Battery.Voltage'Image);
      Put (" V | ");
      exit when Battery.Is_Low;

      if P >= Limit or else P <= (-Limit) then
         Step := (-Step);
      end if;

      --  No motors for the first 5 seconds
      if T > 5_000_000 then
         P := P + Step;
      end if;

      Motor.Set_Power (Motor.Right, P);

      Put ("L");
      Put (Encoder.Left_Count'Image);
      Put (" | ");

      Put ("R");
      Put (Encoder.Right_Count'Image);
      Put (" | ");

      F := IMU.Read_Magnetometer;
      for Axis in F'Range loop
         Put (Axis'Image);
         Put (' ');
         Put (F (Axis)'Image);
         Put (" | ");
      end loop;

      Put ("LOOP");
      Elapsed := Clock - T;
      Put (Elapsed'Image);
      New_Line;

      T := T + Rate;
      Delay_Until (T);
   end loop;

   New_Line;
   Put_Line ("LOW BATTERY SHUTDOWN");

   --  Low battery, minimize power consumption
   Motor.Set_Power (Motor.Left, 0);
   Motor.Set_Power (Motor.Right, 0);

   for N in LED.Name'Range loop
      LED.Set_RGB (N);
   end loop;
   LED.Update;

   --  Disable most clocks, switch clk_sys to ROSC
   declare
      use RP.Clock;
   begin
      Enable (ROSC);
      Set_SYS_Source (ROSC);
      Disable (XOSC);
      Disable (PLL_SYS);
      Disable (ADC);
      Disable (USB);
      Disable (PLL_USB);
      --  REF, SYS, PERI, RTC still running
   end;

   --  Flash LED once every 15 seconds to indicate low battery
   loop
      LED.Set_RGB (LED.B, R => 8);
      LED.Update;
      Delay_Milliseconds (100);

      LED.Set_RGB (LED.B, R => 0);
      LED.Update;
      Delay_Milliseconds (15_000);
   end loop;

end Test;
