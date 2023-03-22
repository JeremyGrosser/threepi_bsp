--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL; use HAL;
with HAL.I2C;

package LSM6DSO is

   type G is delta 0.001 range -10.0 .. +10.0; --  1.0 G = 9.81 meters per second ^ 2
   type Degrees is delta 0.1 range -250.0 .. +250.0;
   type Axis is (X, Y, Z);
   type Acceleration is array (Axis) of G;
   type Angular_Rate is array (Axis) of Degrees;

   type Device
      (Port : not null HAL.I2C.Any_I2C_Port)
   is tagged record
      Addr : HAL.I2C.I2C_Address := 2#1101_0110#;
   end record;

   procedure Initialize
      (This : in out Device);

   function Data_Ready
      (This : in out Device)
      return Boolean;

   procedure Read
      (This : in out Device;
       Acc  : out Acceleration;
       Rate : out Angular_Rate);

private

   procedure Write
      (This : in out Device;
       Reg  : UInt8;
       Val  : UInt8);

   function Read
      (This : in out Device;
       Reg  : UInt8)
       return UInt8;

end LSM6DSO;
