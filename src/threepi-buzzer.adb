--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with ThreePi.Pins;
with ThreePi.Timer;
with RP.GPIO;
with RP.PWM;

package body ThreePi.Buzzer is
   use ThreePi.Pins.Buzzer;
   use ThreePi.Timer;
   use RP.PWM;

   P     : constant PWM_Point := To_PWM (BZCTRL);
   Limit : constant := RP.PWM.Period'Last;
   Half  : constant := Limit / 2;

   procedure Beep
      (Length     : Milliseconds := 50;
       Frequency  : Hertz := 440;
       Count      : Positive := 1)
   is
   begin
      Set_Frequency (P.Slice, Frequency * Hertz (Limit));
      Enable (P.Slice);
      for I in 1 .. Count loop
         Set_Duty_Cycle (P.Slice, P.Channel, Half);
         Delay_Milliseconds (Length);
         Set_Duty_Cycle (P.Slice, P.Channel, 0);
         if I /= Count then
            Delay_Milliseconds (Length);
         end if;
      end loop;
      Disable (P.Slice);
   end Beep;

   procedure Initialize is
   begin
      if not RP.PWM.Initialized then
         RP.PWM.Initialize;
      end if;

      BZCTRL.Configure (RP.GPIO.Output, RP.GPIO.Floating, RP.GPIO.PWM);
      Set_Mode (P.Slice, Free_Running);
      Set_Interval (P.Slice, Limit);
      Set_Duty_Cycle (P.Slice, P.Channel, 0);
   end Initialize;
end ThreePi.Buzzer;
