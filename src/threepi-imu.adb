--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with RP2040_SVD.I2C;
with RP.I2C_Master;
with RP.GPIO;

with ThreePi.Pins;

package body ThreePi.IMU is
   use ThreePi.Pins.IMU;

   I2CM_0   : aliased RP.I2C_Master.I2C_Master_Port (0, RP2040_SVD.I2C.I2C0_Periph'Access);
   Mag      : LIS3MDL.Device (I2CM_0'Access);

   procedure Initialize is
      use RP.GPIO;
   begin
      SDA.Configure (Output, Pull_Up, RP.GPIO.I2C, Schmitt => True);
      SCL.Configure (Output, Pull_Up, RP.GPIO.I2C, Schmitt => True);
      I2CM_0.Configure (400_000);
      Mag.Initialize;
   end Initialize;

   function Read_Magnetometer
      return Flux
   is
   begin
      while not Mag.Data_Ready loop
         null;
      end loop;
      return Mag.Read_Flux;
   end Read_Magnetometer;

end ThreePi.IMU;
