#include <stdio.h>

#define M 2    // downsampling factor
#define L 2    // upsampling factor
#define LEN 30
#define ADC0 0
#define ADC1 1

// Global variable declaration
short int g_PolyW[M]={0,0}; // downsampled polyphase values
short int g_PolyWUpdate=0;   // last polyphase updated
short int g_i16AdcData[2]={0,0};  // 2 x 16 bit data of ADC input channels
short int g_i16DacData[2]={0,0};; // 2 x 16 bit data of DAC output  channels

short int g_SamplesX[30] = {
    1,2,3,4,5,6,7,8,9,10,
    11,12,13,14,15,16,17,18,19,20,
    21,22,23,24,25,26,27,28,29,30
}; // input values
short int g_SampleXIdx = 0; // index input samples

// decimation
void adcInt(void) {
    static short lambda = 0;
    // read values from ADC
    g_i16AdcData[ADC0] = g_SamplesX[g_SampleXIdx]; // next ADC sample
    g_i16AdcData[ADC1] = 0;                        // 2nd channel not used

    // create polyphase signals, low sampling rate 
    switch (lambda) {
    case 0:
        g_PolyW[0] = g_i16AdcData[ADC0];
        g_PolyWUpdate = 0;
        break;
    case 1:
        g_PolyW[1] = g_i16AdcData[ADC0];
        g_PolyWUpdate = 1;
        break;
    default:
        break;
    }

    lambda = (lambda + 1) % M;
}

void dacInt(void) {
    // write values to DAC, high sampling rate
    switch (g_PolyWUpdate) {
    case 0:
        g_i16DacData[0] = g_PolyW[0];
        g_i16DacData[1] = 0;
        break;
    case 1:
        g_i16DacData[0] = 0;
        g_i16DacData[1] = g_PolyW[1];
        break;
    default:
        break;
    }
    // add interpolation filtering here
}

int main(void) {
short int g_SamplesY[2][LEN]; // output values

    for (g_SampleXIdx = 0; g_SampleXIdx < LEN; g_SampleXIdx++) {
        dacInt(); // "call" of interrupt handler
        adcInt(); // "call" of interrupt handler
        
        // output values after ADC + DAC interrupt
        printf("g_PolyW[0]:%2d  g_PolyW[1]:%2d\n", g_PolyW[0], g_PolyW[1]); 
        g_SamplesY[0][g_SampleXIdx] = g_i16DacData[0];
        g_SamplesY[1][g_SampleXIdx] = g_i16DacData[1];
    }

  // assemble polyphase signals y_0[n], y_1[1]
    printf("g_SamplesY[0]: ");
    for (g_SampleXIdx = 0; g_SampleXIdx < LEN; g_SampleXIdx++) {
        printf("%d ", g_SamplesY[0][g_SampleXIdx]);
    }
    printf("\n");

    printf("g_SamplesY[1]: ");
    for (g_SampleXIdx = 0; g_SampleXIdx < LEN; g_SampleXIdx++) {
        printf("%d ", g_SamplesY[1][g_SampleXIdx]);
    }
    printf("\n");

    return 0;
}
