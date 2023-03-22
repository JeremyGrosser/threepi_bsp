--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with Ada.Unchecked_Conversion;

package body LSM6DSO is

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
         raise Program_Error with "LSM6DSO write error";
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
         raise Program_Error with "LSM6DSO read register error";
      end if;
      This.Port.Master_Receive (This.Addr, Data, Status);
      if Status /= Ok then
         raise Program_Error with "LSM6DSO read data error";
      end if;
      return Data (1);
   end Read;

   procedure Initialize
      (This : in out Device)
   is
      WHOAMI : constant UInt8 := 16#0F#;
      CTRL3_C  : constant UInt8 := 16#13#;
      CTRL2_G  : constant UInt8 := 16#11#;
   begin
      if Read (This, WHOAMI) /= 2#0110_1100# then
         raise Program_Error with "LSM6DSO WHOAMI returned incorrect value";
      end if;

      Write (This, CTRL3_C, 2#1000_0000#); --  BOOT
      while (Read (This, CTRL3_C) and 2#1000_0000#) /= 0 loop
         null;
      end loop;

      Write (This, CTRL3_C, 2#0000_0001#); --  SW_RESET
      while (Read (This, CTRL3_C) and 2#0000_0001#) /= 0 loop
         null;
      end loop;

      Write (This, CTRL3_C, 2#0100_0000#); --  BDU

      Write (This, CTRL2_G, 16#60#);
      --  Gyro 417 Hz (High Performance mode)
      --  +/- 250 degrees per second
   end Initialize;

   function Data_Ready
      (This : in out Device)
      return Boolean
   is ((Read (This, 16#1E#) and 2#11#) /= 2#11#); --  STATUS_REG.XLDA & STATUS_REG.GDA

   procedure Read
      (This : in out Device;
       Acc  : out Acceleration;
       Rate : out Angular_Rate)
   is
      use HAL.I2C;

      type Int16 is range -2 ** 15 .. 2 ** 15 - 1
         with Size => 16;
      subtype Int16_Bytes is I2C_Data (1 .. 2);
      function Convert is new Ada.Unchecked_Conversion (Int16_Bytes, Int16);

      Data    : I2C_Data (1 .. 12);
      Status  : I2C_Status;
   begin
      This.Port.Master_Transmit (This.Addr, I2C_Data'(1 => 16#22#), Status);
      if Status /= Ok then
         raise Program_Error with "LSM6DSO OUT_X_L register error";
      end if;
      This.Port.Master_Receive (This.Addr, Data, Status);
      if Status /= Ok then
         raise Program_Error with "LSM6DSO OUT read error";
      end if;

      Rate (X) := Degrees (Convert (Data (1 .. 2)));
      Rate (Y) := Degrees (Convert (Data (3 .. 4)));
      Rate (Z) := Degrees (Convert (Data (5 .. 6)));
      Acc (X) := G (Convert (Data (7 .. 8)));
      Acc (Y) := G (Convert (Data (9 .. 10)));
      Acc (Z) := G (Convert (Data (11 .. 12)));
   end Read;

end LSM6DSO;
