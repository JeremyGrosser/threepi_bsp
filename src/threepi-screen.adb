--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with RP2040_SVD;
with RP.PIO.Encoding;
with RP.PIO;
with RP.GPIO;
with ThreePi.Pins;
with HAL; use HAL;

package body ThreePi.Screen is
   use ThreePi.Pins.Screen;

   --  SPI_0 is already used for the RGB LEDs, so we'll use PIO to shift out

   PIO0_Periph : aliased RP.PIO.PIO_Peripheral
      with Import, Address => RP2040_SVD.PIO0_Base;
   PIO_0 : aliased RP.PIO.PIO_Device (0, PIO0_Periph'Access);
   SM    : constant RP.PIO.PIO_SM := 0;

   procedure Wait is
   begin
      --  Block until TX complete.
      while not PIO_0.FIFO_Status (SM).TXSTALL loop
         null;
      end loop;
      PIO_0.Clear_FIFO_Status (SM, (TXSTALL => True, others => False));
   end Wait;

   procedure Write
      (Data : UInt8)
   is
   begin
      PIO_0.Put (SM, Shift_Left (UInt32 (Data), 24));
   end Write;

   procedure Init_Display is
      --  Stolen from adafruit_displayio_sh1106.py
      Init_Sequence : constant UInt8_Array :=
         (16#AE#, 16#00#,           --  display off, sleep mode
          16#d5#, 16#01#, 16#80#,   --  divide ratio/oscillator: divide by 2, fOsc (POR)
          16#a8#, 16#01#, 16#3f#,   --  multiplex ratio = 64 (POR)
          16#d3#, 16#01#, 16#00#,   --  set display offset mode = 0x0
          16#40#, 16#00#,           --  set start line
          16#ad#, 16#01#, 16#8b#,   --  turn on DC/DC
          16#a1#, 16#00#,           --  segment remap = 1 (POR=0, down rotation)
          16#c8#, 16#00#,           --  scan decrement
          16#da#, 16#01#, 16#12#,   --  set com pins
          16#81#, 16#01#, 16#ff#,   --  contrast setting = 0xff
          16#d9#, 16#01#, 16#1f#,   --  pre-charge/dis-charge period mode: 2 DCLKs/2 DCLKs (POR)
          16#db#, 16#01#, 16#40#,   --  VCOM deselect level = 0.770 (POR)
          16#20#, 16#01#, 16#20#,
          16#33#, 16#00#,           --  turn on VPP to 9V
          16#a6#, 16#00#,           --  normal (not reversed) display
          16#a4#, 16#00#,           --  entire display off, retain RAM, normal status (POR)
          16#af#, 16#00#);          --  DISPLAY_ON
   begin
      NRST.Set;
      DC.Clear;
      for D of Init_Sequence loop
         Write (D);
      end loop;
      Wait;
   end Init_Display;

   procedure Update is
      LOW_COLUMN_ADDRESS   : constant UInt8 := 16#00#;
      HIGH_COLUMN_ADDRESS  : constant UInt8 := 16#10#;
      SET_PAGE_ADDRESS     : constant UInt8 := 16#B0#;

      Data : UInt8_Array (0 .. (FB'Size / 8) - 1)
         with Address => FB'Address;
      First, Last : Natural;
   begin
      for Page in 0 .. (Height / 8) - 1 loop
         DC.Clear;
         Write (SET_PAGE_ADDRESS or UInt8 (Page));
         Write (LOW_COLUMN_ADDRESS or 2);
         Write (HIGH_COLUMN_ADDRESS or 0);
         Wait;
         DC.Set;

         First := (Width * Page) / 8;
         Last := First + (Width / 8);
         for I in First .. Last loop
            Write (Data (I));
         end loop;
         Wait;
      end loop;
   end Update;

   procedure Initialize is
   begin
      declare
         use RP.GPIO;
      begin
         NRST.Configure (Output, Pull_Up);
         NRST.Clear;

         SCK.Configure (Output, Pull_Up, PIO_0.GPIO_Function);
         MOSI.Configure (Output, Pull_Up, PIO_0.GPIO_Function);
         DC.Configure (Output, Pull_Up);
      end;

      declare
         use RP.PIO.Encoding;
         use RP.PIO;

         --  Sideset is SCK, SH1106 samples on the rising edge.
         Shift_Out_Program : constant RP.PIO.Program :=
            (Encode (SHIFT_OUT'(Destination => RP.PIO.Encoding.PINS, Bit_Count => 1, Delay_Sideset => 0, others => <>)),
             Encode (MOV'(Source => X, Destination => X, Delay_Sideset => 1, others => <>))); --  NOP

         Offset : constant PIO_Address := PIO_Address'Last - Shift_Out_Program'Length;
         Config : PIO_SM_Config := Default_SM_Config;
      begin
         Set_Out_Pins (Config, MOSI.Pin, 1);
         Set_Set_Pins (Config, MOSI.Pin, 1);
         Set_Sideset_Pins (Config, SCK.Pin);
         Set_Sideset (Config,
            Bit_Count   => 1,
            Optional    => False,
            Pindirs     => False);
         Set_Out_Shift (Config,
            Shift_Right    => False,
            Autopull       => True,
            Pull_Threshold => 8);
         Set_Clock_Frequency (Config, 20_000_000);
         Set_Wrap (Config, Offset, Offset + Shift_Out_Program'Length);

         PIO_0.Enable;
         PIO_0.Load (Shift_Out_Program, Offset);
         PIO_0.SM_Initialize (SM, Offset, Config);
         PIO_0.Set_Pin_Direction (SM, SCK.Pin, Output);
         PIO_0.Set_Pin_Direction (SM, MOSI.Pin, Output);
         PIO_0.Set_Enabled (SM, True);
      end;

      Init_Display;
   end Initialize;
end ThreePi.Screen;
