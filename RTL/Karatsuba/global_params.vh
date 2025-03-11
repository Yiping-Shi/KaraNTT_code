// global_params.vh
// Global parameters definition

// Polynomial degree
`define N 16

// Modulus Q
`define Q 998244353

// Barrett constant U = floor(2^60/Q)
`define U 1154949187

// Basic data width (for modulus Q)
`define DATA_WIDTH 30

// Accumulation result maximum width
`define ACC_WIDTH 45

// Elememt-wise multiplication result width
`define MULT_WIDTH 90


`define EVAL_ROWS 81
`define EVAL_COLS 16
`define EVAL_NONZEROS 256

`define POSTPROC_ROWS 16
`define POSTPROC_COLS 81
`define POSTPROC_NONZEROS 625