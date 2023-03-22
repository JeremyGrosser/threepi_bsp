--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with ThreePi.Pins;
with RP.GPIO;
with RP.PWM;
with RP;

package body ThreePi.Motor is
   use ThreePi.Pins.Motor;
   use RP.PWM;

   Drive_Slice     : constant PWM_Slice := To_PWM (Points (Left).EN).Slice;
   --  Both EN pins are connected to the same PWM slice

   Drive_Channel   : constant array (Name) of PWM_Channel :=
      (Left  => To_PWM (Points (Left).EN).Channel,
       Right => To_PWM (Points (Right).EN).Channel);

   Drive_Frequency : constant RP.Hertz := 50_000;
   Drive_Period    : constant := 1_000;

   function To_Name
      (M : Motor)
      return Name
   is
   begin
      case M is
         when Left   => return Left;
         when Right  => return Right;
         when Both   => raise Program_Error;
      end case;
   end To_Name;

   procedure Set_Power
      (M : Motor;
       P : Power)
   is
   begin
      if M = Both then
         Set_Power (Left, P);
         Set_Power (Right, P);
      else
         declare
            N : constant Name := To_Name (M);
         begin
            if P < 0 then
               Points (N).PH.Set;
               Set_Duty_Cycle (Drive_Slice, Drive_Channel (N), RP.PWM.Period (-P));
            else
               Points (N).PH.Clear;
               Set_Duty_Cycle (Drive_Slice, Drive_Channel (N), RP.PWM.Period (P));
            end if;
         end;
      end if;
   end Set_Power;

   procedure Brake
      (M : Motor)
   is
   begin
      if M = Both then
         Set_Duty_Cycle (Drive_Slice, 0, 0);
      else
         Set_Duty_Cycle (Drive_Slice, Drive_Channel (To_Name (M)), 0);
      end if;
   end Brake;

   procedure Initialize is
      use RP.GPIO;
   begin
      --  DRV8838 control pins have internal pulldown resistors
      for M of Points loop
         M.PH.Configure (Output, Floating);
         M.EN.Configure (Output, Floating, RP.GPIO.PWM);
      end loop;

      if not RP.PWM.Initialized then
         RP.PWM.Initialize;
      end if;

      Set_Mode (Drive_Slice, Free_Running);
      Set_Frequency (Drive_Slice, Drive_Frequency * Drive_Period);
      Set_Interval (Drive_Slice, Drive_Period);
      Set_Duty_Cycle (Drive_Slice, 0, 0);
      Enable (Drive_Slice);
   end Initialize;
end ThreePi.Motor;
