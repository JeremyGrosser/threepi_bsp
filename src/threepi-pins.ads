--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with RP.GPIO; use RP.GPIO;

package ThreePi.Pins is

   package LED is
      --  6x APA102
      RGB_CLK : aliased GPIO_Point := (Pin => 6);
      RGB_DAT : aliased GPIO_Point := (Pin => 3);     --  Shared with Screen.MOSI
      Yellow  : aliased GPIO_Point := (Pin => 25);    --  Shared with Button.A
   end LED;

   package Motor is
      type Point is record
         PH, EN, QA, QB : aliased GPIO_Point;
      end record;

      type Name is (Left, Right);

      Points : array (Name) of Point :=
         (Left =>
            (PH => (Pin => 11),
             EN => (Pin => 15),
             QA => (Pin => 12),
             QB => (Pin => 13)),
          Right =>
            (PH => (Pin => 10),
             EN => (Pin => 14),
             QA => (Pin => 8),
             QB => (Pin => 9)));
   end Motor;

   package Button is
      A : aliased GPIO_Point := (Pin => 25); --  Shared with LED.Yellow
      --  B : IO_BANK0_Periph.GPIO_QSPI_SS_STATUS.INFROMPAD
      --      Reading from QSPI pins is not supported by rp2040_hal yet
      C : aliased GPIO_Point := (Pin => 0);  --  Shared with Screen.DC
   end Button;

   package IR is
      BUMPEMIT : aliased GPIO_Point := (Pin => 23);
      BUMPR    : aliased GPIO_Point := (Pin => 16);
      BUMPL    : aliased GPIO_Point := (Pin => 17);

      DOWNEMIT : aliased GPIO_Point := (Pin => 26);   --  Shared with Battery.BATLEV
      DOWN1    : aliased GPIO_Point := (Pin => 22);
      DOWN2    : aliased GPIO_Point := (Pin => 21);
      DOWN3    : aliased GPIO_Point := (Pin => 20);
      DOWN4    : aliased GPIO_Point := (Pin => 19);
      DOWN5    : aliased GPIO_Point := (Pin => 18);
   end IR;

   package Screen is
      SCK   : aliased GPIO_Point := (Pin => 2);
      MOSI  : aliased GPIO_Point := (Pin => 3);       --  Shared with LED.RGB_DAT
      NRST  : aliased GPIO_Point := (Pin => 1);
      DC    : aliased GPIO_Point := (Pin => 0);       --  Shared with Button.C
   end Screen;

   package IMU is
      SCL : aliased GPIO_Point := (Pin => 5);
      SDA : aliased GPIO_Point := (Pin => 4);
   end IMU;

   package Battery is
      BATLEV : aliased GPIO_Point := (Pin => 26);     --  Shared with IR.DOWNEMIT
   end Battery;

   package Buzzer is
      BZCTRL : aliased GPIO_Point := (Pin => 7);
   end Buzzer;

end ThreePi.Pins;
