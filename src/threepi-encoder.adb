--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with Ada.Unchecked_Conversion;
with ThreePi.Encoder_PIO;
with ThreePi.Pins;
with RP2040_SVD;
with RP.GPIO;
with RP.PIO;
with HAL; use HAL;

package body ThreePi.Encoder is
   use ThreePi.Pins.Motor;
   use RP.PIO;

   PIO1_Periph : aliased PIO_Peripheral
      with Import, Address => RP2040_SVD.PIO1_Base;
   PIO_1 : aliased PIO_Device (1, PIO1_Periph'Access);

   package Prog renames ThreePi.Encoder_PIO;
   Offset : constant PIO_Address := 0;

   Left_SM  : constant PIO_SM := 0;
   Right_SM : constant PIO_SM := 1;

   function Get_Count
      (SM : PIO_SM)
      return Int32
   is
      function To_Int32 is new Ada.Unchecked_Conversion (UInt32, Int32);
      Count : UInt32;
   begin
      PIO_1.Put (SM, 1);
      PIO_1.Get (SM, Count);
      return To_Int32 (Count);
   end Get_Count;

   function Left_Count
      return Int32
   is (Get_Count (Left_SM));

   function Right_Count
      return Int32
   is (Get_Count (Right_SM));

   procedure Init_Counter
      (SM   : RP.PIO.PIO_SM;
       A, B : in out RP.GPIO.GPIO_Point)
   is
      use RP.GPIO;
      Config : PIO_SM_Config := Default_SM_Config;
   begin
      A.Configure (Input, Pull_Up, PIO_1.GPIO_Function);
      B.Configure (Input, Pull_Up, PIO_1.GPIO_Function);

      Set_In_Pins (Config, A.Pin);
      Set_Jmp_Pin (Config, A.Pin);
      Set_In_Shift (Config,
         Shift_Right    => False,
         Autopush       => False,
         Push_Threshold => 32);
      Set_FIFO_Join (Config, False, False);
      Set_Clock_Divider (Config, 1.0);
      --  TODO: figure out our max motor speed and use a slower clock to save power
      Set_Wrap (Config,
         Wrap_Target => Prog.Quadrature_Encoder_Wrap_Target + Offset,
         Wrap        => Prog.Quadrature_Encoder_Wrap + Offset);

      PIO_1.SM_Initialize (SM, Offset, Config);
      PIO_1.Set_Pin_Direction (SM, A.Pin, RP.PIO.Input);
      PIO_1.Set_Pin_Direction (SM, B.Pin, RP.PIO.Input);
      PIO_1.Set_Enabled (SM, True);
   end Init_Counter;

   procedure Initialize is
   begin
      PIO_1.Enable;
      PIO_1.Load (Prog.Quadrature_Encoder_Program_Instructions, Offset);
      Init_Counter (Left_SM, Points (Left).QA, Points (Left).QB);
      Init_Counter (Right_SM, Points (Right).QA, Points (Right).QB);
   end Initialize;

end ThreePi.Encoder;
