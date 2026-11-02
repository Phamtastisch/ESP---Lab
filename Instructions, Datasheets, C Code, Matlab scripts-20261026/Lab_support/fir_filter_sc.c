//------------------------------------------------------
// File: fir_filter_sc.c
// =====
//
// US 17-Jun-06, 05-Aug-2013
// 
// Description:
// ============
// programm to do FIR filter computation in a subroutine
//
// Note : 
// This has been tested with decimate_by_5_1_stage.c
// and decimatinterpolate_by_5_1_stage.c
//
// The number of delays and coeffs are the same.
// Therefore, FIR_delays[0] will contain x(n).
// 
// Changes:
// US 29-Jul-06 update of T[0] now done OUTSIDE of this function
// US 30-Jul-06 update of T[0] again now done INSIDE of this function
//              but x_n is AT THE END of the parameter list
//              also : version sued where the delays run BACKWARDS
//
// Profiling:
// 31-Jul-06, filter 1000/1100 Hz 40 dB, N = 713
// whole INT routine uses with -o3 optimization
// code count incl. tot  incl. max   Min    Avg   excl.tot
//  492  8     12594       1933      1513   1574    12594
//
// Changes;
// US 15-Aug-06 only backwards delay storage remains in code
// update of delay[0] done INSIDE this code
//
//---------------------------------------------------------------------
short FIR_filter_sc(short FIR_delays[], short FIR_coe[], short int N_delays, short x_n, int shift){
	short i, y;
	int FIR_accu32=0;

// delays BACKWARDS, coefficients in FORWARD direction
	FIR_delays[N_delays-1] = x_n;	// read input sample from ADC 
// accumulate in 32 bit variable
	FIR_accu32	= 0;				// clear accu
	for(i=0; i < N_delays; i++)		// FIR filter routine
		FIR_accu32 += FIR_delays[N_delays-1-i] * FIR_coe[i];
	
// loop to shift the delays
	for(i=1; i < N_delays; i++)				
		FIR_delays[i-1] = FIR_delays[i];

// shift back by 15 bit to obtain short int 16 bit output 
	y = (short) (FIR_accu32 >>shift);
	return y;
}

