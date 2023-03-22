--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with Ada.Unchecked_Conversion;
with ThreePi.Pins;
with RP.ADC;
with RP.GPIO;

package body ThreePi.Battery is
   use ThreePi.Pins.Battery;

   Channel : constant RP.ADC.ADC_Channel := RP.ADC.To_ADC_Channel (BATLEV);

   function To_Volts is new Ada.Unchecked_Conversion
      (RP.ADC.Analog_Value, Volts);

   function Voltage
      return Volts
   is (To_Volts (RP.ADC.Read (Channel)));

   function Is_Low
      return Boolean
   is (Voltage <= Low_Threshold);

   procedure Initialize is
      use RP.GPIO;
   begin
      BATLEV.Configure (Analog);
      RP.ADC.Enable;
      RP.ADC.Configure (Channel);
   end Initialize;
end ThreePi.Battery;
