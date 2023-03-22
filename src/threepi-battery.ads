--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
pragma Warnings (Off, "static fixed-point value is not a multiple of Small");
package ThreePi.Battery is

   VREF        : constant := 3.3;
   VDIV        : constant := 10.0;
   ADC_Bits    : constant := 12;
   ADC_Max     : constant := 2 ** ADC_Bits - 1;
   Volts_Small : constant := (VREF * VDIV) / ADC_Max;

   type Volts is delta Volts_Small range 0.0 .. (VREF * VDIV)
      with Small => Volts_Small,
           Size  => ADC_Bits;

   function Voltage
      return Volts;

   Num_Cells     : constant := 4;
   Low_Threshold : constant Volts := Num_Cells * 0.9;

   function Is_Low
      return Boolean;

   procedure Initialize;
end ThreePi.Battery;
