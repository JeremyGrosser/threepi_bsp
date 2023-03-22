--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL; use HAL;
with HAL.I2C;

package LIS3MDL is

   type Gauss is new Integer;
   type Axis is (X, Y, Z);
   type Flux is array (Axis) of Gauss;

   type Device
      (Port : not null HAL.I2C.Any_I2C_Port)
   is tagged record
      Addr : HAL.I2C.I2C_Address := 2#0011_1100#;
      Sensitivity : Gauss := 6842; -- per LSB (+/- 4g range)
   end record;

   procedure Initialize
      (This : in out Device);

   function Data_Ready
      (This : in out Device)
      return Boolean;

   function Read_Flux
      (This : in out Device)
      return Flux;

private

   procedure Write
      (This : in out Device;
       Reg  : UInt8;
       Val  : UInt8);

   function Read
      (This : in out Device;
       Reg  : UInt8)
       return UInt8;

end LIS3MDL;
