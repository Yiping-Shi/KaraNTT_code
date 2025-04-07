`ifndef GLOBAL_PARAMS_VH
`define GLOBAL_PARAMS_VH

`define Q 998244353
`define U 1154949187
`define N 65536

`define PHI     629671588
`define PHI_INV 283043518
`define PSI     24514907
`define PSI_INV 3707709
`define N_INV   998229121

`define PHI_16     929031873
`define PSI_16     452798380
`define PSI_16_INV 87557064
`define N_16_INV   935854081

`define DATA_WIDTH 30
`define BRAM_ADDR_WIDTH 12
`define WROM_ADDR_WIDTH 13

// Accumulation result maximum width
`define ACC_WIDTH 34

// Elememt-wise multiplication result width
`define MULT_WIDTH 68

`define EVAL_ROWS 81
`define EVAL_COLS 16
`define EVAL_NONZEROS 256

`define POSTPROC_ROWS 16
`define POSTPROC_COLS 81
`define POSTPROC_NONZEROS 625


`endif // GLOBAL_PARAMS_VH