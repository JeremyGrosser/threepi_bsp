--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
package ThreePi.Screen is
   Width  : constant := 128;
   Height : constant := 64;

   type Row    is range 0 .. Height - 1;
   type Column is range 0 .. Width - 1;
   type Framebuffer is array (Row, Column) of Boolean
      with Component_Size => 1,
           Size => Width * Height;

   FB : Framebuffer := (others => (others => False));

   procedure Update;
   --  Writes FB data to the screen

   procedure Initialize;

end ThreePi.Screen;
