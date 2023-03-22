--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with RP.Clock;
with ThreePi.Timer;
with ThreePi.LED;
with ThreePi.Motor;
--  with ThreePi.Screen;
with ThreePi.Buzzer;
with ThreePi.Encoder;
with ThreePi.Battery;
with ThreePi.IMU;

package body ThreePi is
   procedure Initialize is
   begin
      RP.Clock.Initialize (12_000_000, 100_000);
      ThreePi.Timer.Delays.Enable;
      ThreePi.LED.Initialize;
      ThreePi.Battery.Initialize;
      ThreePi.Buzzer.Initialize;
      ThreePi.Motor.Initialize;
      --  ThreePi.Screen.Initialize;
      ThreePi.Encoder.Initialize;
      ThreePi.IMU.Initialize;
   end Initialize;
end ThreePi;
