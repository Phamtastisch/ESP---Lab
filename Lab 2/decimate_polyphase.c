interrupt void intser_McBSP0()     //interrupt service routine McBSP0
{     
    sample_McBSP0.both    = MCBSP_read(hMcbsp0); 	// read from ADC
    inL = sample_McBSP0.channel[LEFT];				// use left channel only	

    // reset input counter for McBSP1 INT
    if (count_McBSP0_INT >= MM)
        count_McBSP0_INT = 0;

    // Note, we have a decimator : 
    // ==> The SWITCH rotates anti-Clockwise, sequence 0, 4, 3, 2, 1
    //
    // distribute computations across 5 output McBSP0 INTs
    //----------------------------------  sample 0 ---------------------------------
    if (count_McBSP0_INT == 0) {
        // for INT handler
        count_McBSP0_INT++;
        y1_part1 = FIR_filter_sc( H_filt_50_delays, // compute polyphase FIR out and save
                                 b_filt_b0_b5_usw, N_delays_H_filt_50_delays, inL, 15);
    }

    //----------------------------------  sample 1 ---------------------------------
    else if (count_McBSP0_INT == 1) {
        // for INT handler
        count_McBSP0_INT++;
        y1_part2 = FIR_filter_sc ( H_filt_54_delays, // compute polyphase FIR out and save
                                  b_filt_b4_b9_usw, N_delays_H_filt_54_delays, delay4, 15);
        delay4 = inL; 						// now update delay
    }

    //----------------------------------  sample 2 ---------------------------------
    else if (count_McBSP0_INT == 2) {
        // for INT handler
        count_McBSP0_INT++;
        y1_part3 = FIR_filter_sc ( H_filt_53_delays, // compute polyphase FIR out and save 
                                  b_filt_b3_b8_usw, N_delays_H_filt_53_delays, delay3, 15);
        delay3 = inL; 						// now update delay
    }

    //----------------------------------  sample 3 ---------------------------------
    else if (count_McBSP0_INT == 3) {
        // for INT handler
        count_McBSP0_INT++;
        y1_part4 = FIR_filter_sc ( H_filt_52_delays, // compute polyphase FIR out and save 
                                  b_filt_b2_b7_usw, N_delays_H_filt_52_delays,delay2, 15);
        delay2 = inL; 						// now update delay
    }

    //----------------------------------  sample 4 ---------------------------------
    else if (count_McBSP0_INT == 4) {
        // for INT handler
        count_McBSP0_INT++;
        y1_part5 = FIR_filter_sc ( H_filt_51_delays, // compute polyphase FIR out and save 
                                  b_filt_b1_b6_usw, N_delays_H_filt_51_delays,delay1, 15);
        delay1 = inL; 						// now update delay

        // add all partial results up
        y1 = y1_part1 + y1_part2 + y1_part3 + y1_part4 + y1_part5;
    }

    MCBSP_write(hMcbsp0, sample_McBSP0.both );
    return;
}

