--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with Ada.Unchecked_Conversion;

package body LIS3MDL is

   procedure Write
      (This : in out Device;
       Reg  : UInt8;
       Val  : UInt8)
   is
      use HAL.I2C;
      Data   : constant I2C_Data (1 .. 2) := (Reg or 1, Val);
      Status : I2C_Status;
   begin
      This.Port.Master_Transmit (This.Addr, Data, Status);
      if Status /= Ok then
         raise Program_Error with "LIS3MDL write error";
      end if;
   end Write;

   function Read
      (This : in out Device;
       Reg  : UInt8)
       return UInt8
   is
      use HAL.I2C;
      Data : I2C_Data (1 .. 1) := (1 => Reg);
      Status : I2C_Status;
   begin
      This.Port.Master_Transmit (This.Addr, Data, Status);
      if Status /= Ok then
         raise Program_Error with "LIS3MDL read register error";
      end if;
      This.Port.Master_Receive (This.Addr, Data, Status);
      if Status /= Ok then
         raise Program_Error with "LIS3MDL read data error";
      end if;
      return Data (1);
   end Read;

   procedure Initialize
      (This : in out Device)
   is
      WHOAMI : constant UInt8 := 16#0F#;
      CTRL2  : constant UInt8 := 16#21#;
      CTRL3  : constant UInt8 := 16#22#;
   begin
      if Read (This, WHOAMI) /= 2#00111101# then
         raise Program_Error with "LIS3MDL WHOAMI returned incorrect value";
      end if;

      Write (This, CTRL2, 2#0000_1000#); --  REBOOT
      while (Read (This, CTRL2) and 2#0000_1000#) /= 0 loop
         null;
      end loop;

      Write (This, CTRL2, 2#0000_0100#); --  SOFT_RST
      while (Read (This, CTRL2) and 2#0000_0100#) /= 0 loop
         null;
      end loop;

      Write (This, CTRL3, 0); --  Power on, continuous conversion mode
   end Initialize;

   function Data_Ready
      (This : in out Device)
      return Boolean
   is ((Read (This, 16#27#) and 2#00001000#) /= 0); --  STATUS_REG.ZYXDA

   function Read_Flux
      (This : in out Device)
      return Flux
   is
      use HAL.I2C;

      type Int16 is range -2 ** 15 .. 2 ** 15 - 1
         with Size => 16;
      subtype Int16_Bytes is I2C_Data (1 .. 2);
      function Convert is new Ada.Unchecked_Conversion (Int16_Bytes, Int16);

      F       : Flux;
      Data    : I2C_Data (1 .. 6);
      Status  : I2C_Status;
   begin
      This.Port.Master_Transmit (This.Addr, I2C_Data'(1 => 16#28#), Status);
      if Status /= Ok then
         raise Program_Error with "LIS3MDL OUT_X_L register error";
      end if;
      This.Port.Master_Receive (This.Addr, Data, Status);
      if Status /= Ok then
         raise Program_Error with "LIS3MDL OUT read error";
      end if;

      F (X) := Gauss (Convert (Data (1 .. 2))) * This.Sensitivity;
      F (Y) := Gauss (Convert (Data (3 .. 4))) * This.Sensitivity;
      F (Z) := Gauss (Convert (Data (5 .. 6))) * This.Sensitivity;
      return F;
   end Read_Flux;

end LIS3MDL;
