--
--  Copyright (C) 2023 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
--------------------------------------------------------
-- This file is autogenerated by pioasm; do not edit! --
--------------------------------------------------------

pragma Style_Checks (Off);

with RP.PIO;

package ThreePi.Encoder_PIO is

   ------------------------
   -- Quadrature_Encoder --
   ------------------------

   Quadrature_Encoder_Wrap_Target : constant := 15;
   Quadrature_Encoder_Wrap        : constant := 28;

   Quadrature_Encoder_Program_Instructions : RP.PIO.Program := (
         16#000f#,  --   0: jmp    15                         
         16#000e#,  --   1: jmp    14                         
         16#001a#,  --   2: jmp    26                         
         16#000f#,  --   3: jmp    15                         
         16#001a#,  --   4: jmp    26                         
         16#000f#,  --   5: jmp    15                         
         16#000f#,  --   6: jmp    15                         
         16#000e#,  --   7: jmp    14                         
         16#000e#,  --   8: jmp    14                         
         16#000f#,  --   9: jmp    15                         
         16#000f#,  --  10: jmp    15                         
         16#001a#,  --  11: jmp    26                         
         16#000f#,  --  12: jmp    15                         
         16#001a#,  --  13: jmp    26                         
         16#008f#,  --  14: jmp    y--, 15                    
                    --  .wrap_target
         16#e020#,  --  15: set    x, 0                       
         16#8080#,  --  16: pull   noblock                    
         16#a027#,  --  17: mov    x, osr                     
         16#a0e6#,  --  18: mov    osr, isr                   
         16#0036#,  --  19: jmp    !x, 22                     
         16#a0c2#,  --  20: mov    isr, y                     
         16#8020#,  --  21: push   block                      
         16#a0c3#,  --  22: mov    isr, null                  
         16#40e2#,  --  23: in     osr, 2                     
         16#4002#,  --  24: in     pins, 2                    
         16#a0a6#,  --  25: mov    pc, isr                    
         16#a02a#,  --  26: mov    x, !y                      
         16#005c#,  --  27: jmp    x--, 28                    
         16#a049#); --  28: mov    y, !x                      
                    --  .wrap

end ThreePi.Encoder_PIO;