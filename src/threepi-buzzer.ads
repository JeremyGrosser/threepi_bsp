--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
package ThreePi.Buzzer is

   subtype Milliseconds is Natural;
   subtype Hertz is Natural;

   procedure Beep
      (Length     : Milliseconds := 50;
       Frequency  : Hertz := 440;
       Count      : Positive := 1);

   procedure Initialize;

end ThreePi.Buzzer;
