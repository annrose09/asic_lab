LIBRARY VALUES USED IN EACH LAB (from LIB/teaching_sta.lib)
===========================================================
All tables are constant, so the value Tempus looks up does not depend on the
input slew (0.05 ns) or the load (pin cap 0.002 pF). Time unit = ns.

CELL        LIBERTY ARC / CHECK                         VALUE
----------  ------------------------------------------  ------
DFFPOS_X1   CLK -> Q   (timing_type rising_edge)        0.20
DFFPOS_X1   D setup    (setup_rising, related CLK)      0.20
DFFPOS_X1   D hold     (hold_rising,  related CLK)      0.10
DFFNEG_X1   CLK -> Q   (timing_type falling_edge)       0.20
DFFNEG_X1   D setup / hold (setup_falling/hold_falling) 0.20 / 0.10
BUF_X1      A -> Y                                      0.50
DLY_X1      A -> Y                                      1.00
INV_X1      A -> Y  (not used in the labs)              0.40
ICG_X1      EN setup   (setup_rising, related CLK)      0.50
ICG_X1      EN hold    (hold_rising,  related CLK)      0.20
ICG_X1      CLK -> GCLK                                 0.10
All cells   output transition                           0.05

FORMULAS
  Arrival          = launch edge + launch clock delay + CLK->Q + data-path cells
  Setup required   = capture edge + capture clock delay - library setup - setup uncertainty
  Hold  required   = capture edge + capture clock delay + library hold  + hold uncertainty
  Setup slack      = Required - Arrival
  Hold  slack      = Arrival  - Required
Values marked (SDC) come from the constraint file, not the library.

LAB01_SETUP_HOLD
----------------------------------------------------------------------------------
Exp  Library values used                     Arrival           Required            Slack
01   CLK->Q 0.20, 8xBUF 4.00, setup 0.20     0.20+4.00 = 4.20  4.00-0.20 = 3.80    -0.40
02   same                                    4.20              5.00-0.20 = 4.80    +0.60
03   CLK->Q 0.20, hold 0.10, unc 0.30 (SDC)  0.20              0+0.10+0.30 = 0.40  -0.20
04   CLK->Q 0.20, 1xBUF 0.50, hold 0.10      0.20+0.50 = 0.70  0.40                +0.30

LAB02_CLOCK_SKEW  (propagated clock)
----------------------------------------------------------------------------------
01   launch clock DLY_X1 1.00, CLK->Q 0.20,  1.00+0.20+4.00    5.00+0-0.20 = 4.80  -0.40
     8xBUF 4.00, setup 0.20                  = 5.20
02   launch clock BUF_X1 0.50 (rest same)    0.50+4.20 = 4.70  4.80                +0.10
03   capture clock DLY_X1 1.00, CLK->Q 0.20, 0.20              0+1.00+0.10 = 1.10  -0.90
     hold 0.10
04   same + 2xBUF 1.00 in data path          0.20+1.00 = 1.20  1.10                +0.10

LAB03_MULTICYCLE  (CLK->Q 0.20 + 12xBUF 6.00 = 6.20 arrival in every case)
----------------------------------------------------------------------------------
01   T=4, setup 0.20                         6.20              4.00-0.20 = 3.80    -2.40
02   T=4, MCP2 setup, setup 0.20             6.20              8.00-0.20 = 7.80    +1.60
     hold (edge moved to 4 ns), hold 0.10    6.20              4.00+0.10 = 4.10    +2.10
03   T=4, MCP2 / MCP1 hold                   6.20              setup 7.80          +1.60
                                             6.20              hold 0+0.10 = 0.10  +6.10
04   T=3, MCP2 / MCP1 hold                   6.20              setup 6.00-0.20=5.80 -0.40
                                             6.20              hold 0.10           +6.10
05   T=3, MCP3 / MCP2 hold                   6.20              setup 9.00-0.20=8.80 +2.60
                                             6.20              hold 0.10           +6.10

LAB04_HALF_CYCLE  (DFFNEG_X1 launch on FALLING edge, DFFPOS_X1 capture)
----------------------------------------------------------------------------------
01   T=8: fall edge 4.00, CLK->Q 0.20,       4.00+0.20+4.00    8.00-0.20 = 7.80    -0.40
     8xBUF 4.00, setup 0.20                  = 8.20
02   T=10: fall edge 5.00                    5.00+4.20 = 9.20  10.00-0.20 = 9.80   +0.60
03   T=10: hold 0.10 (capture edge 0)        9.20              0+0.10 = 0.10       +9.10

LAB05_FALSE_PATH  (T = 5)
----------------------------------------------------------------------------------
01   cfg : CLK->Q 0.20 + 12xBUF 6.00         6.20              5.00-0.20 = 4.80    -1.40
     data: CLK->Q 0.20 + 6xBUF 3.00          3.20              4.80                +1.60
02   cfg : false path -> not timed           -                 -                   no path
     data: same as 01                        3.20              4.80                +1.60

