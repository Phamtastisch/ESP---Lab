//------------------------------------------- 
// designed with -- dec_kernel_int_WS20_EMIL.m -- 
// Fs = 50000.00
// MMmin =   5.33
// fstop = 3350.00
// fpass = 3100.00
// delta_pass =   0.01
// delta_stop_dB =  40.00
// N_FIR = 391, instead two stages with N_FIR_Dec_Int = 20, N_FIR_KERNEL = 116
//------------------------------------------- 
#define N_delays_poly 6

short H_dec_0_delays[N_delays_poly];
short H_int_0_delays[N_delays_poly];
short b_poly_0[6]={
    218,  -1026,   4930,   4930,  -1026,    218,
};

short H_dec_1_delays[N_delays_poly];
short H_int_1_delays[N_delays_poly];
short b_poly_1[6]={
    248,  -1086,   7339,   2101,   -462,      0,
};

short H_dec_2_delays[N_delays_poly];
short H_int_2_delays[N_delays_poly];
short b_poly_2[6]={
     51,    -87,   8286,    -87,     51,      0,
};

short H_dec_3_delays[N_delays_poly];
short H_int_3_delays[N_delays_poly];
short b_poly_3[6]={
   -462,   2101,   7339,  -1086,    248,      0,
};

#define N_delays_kernel 117
short H_kernel_delays[N_delays_kernel];
short b_kernel[117]={
     63,   -104,     -1,     39,    -15,    -55,
     12,     56,    -23,    -64,     32,     69,
    -46,    -74,     62,     77,    -80,    -78,
    101,     77,   -124,    -72,    149,     63,
   -176,    -50,    205,     32,   -235,     -8,
    267,    -22,   -298,     61,    330,   -108,
   -362,    166,    394,   -236,   -424,    323,
    452,   -430,   -478,    565,    502,   -742,
   -523,    986,    541,  -1354,   -555,   1987,
    565,  -3417,   -571,  10410,  16957,  10410,
   -571,  -3417,    565,   1987,   -555,  -1354,
    541,    986,   -523,   -742,    502,    565,
   -478,   -430,    452,    323,   -424,   -236,
    394,    166,   -362,   -108,    330,     61,
   -298,    -22,    267,     -8,   -235,     32,
    205,    -50,   -176,     63,    149,    -72,
   -124,     77,    101,    -78,    -80,     77,
     62,    -74,    -46,     69,     32,    -64,
    -23,     56,     12,    -55,    -15,     39,
     -1,   -104,     63,};

