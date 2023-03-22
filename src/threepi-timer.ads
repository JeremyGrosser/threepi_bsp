--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with RP.Timer.Interrupts;
with RP.Timer;

package ThreePi.Timer is
   Delays : aliased RP.Timer.Interrupts.Delays;

   subtype Time is RP.Timer.Time;

   function Clock
      return Time;

   function Milliseconds
      (N : Natural)
      return Time;

   procedure Delay_Milliseconds
      (Ms : Natural);

   procedure Delay_Until
      (T : Time);

end ThreePi.Timer;
