--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
package LCH is
   procedure Last_Chance_Handler
      with Export, Convention => C, External_Name => "__gnat_last_chance_handler";
end LCH;
