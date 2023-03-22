--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
package body ThreePi.Timer is

   function Clock return Time
      renames RP.Timer.Clock;

   function Milliseconds (N : Natural) return Time
      renames RP.Timer.Milliseconds;

   procedure Delay_Milliseconds
      (Ms : Natural)
   is
   begin
      Delays.Delay_Milliseconds (Ms);
   end Delay_Milliseconds;

   procedure Delay_Until
      (T : Time)
   is
   begin
      Delays.Delay_Until (T);
   end Delay_Until;

end ThreePi.Timer;
