--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with LIS3MDL;
with LSM6DSO;

package ThreePi.IMU is

   subtype Axis is LIS3MDL.Axis;
   subtype Flux is LIS3MDL.Flux;

   function Read_Magnetometer
      return Flux;

   procedure Initialize;

end ThreePi.IMU;
