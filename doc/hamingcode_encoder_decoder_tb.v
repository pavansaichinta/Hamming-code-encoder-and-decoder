`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 23:37:41
// Design Name: 
// Module Name: hamingcode_encoder_decoder_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module tb_hamming_top_8_4;

    reg  [3:0] data_in;
    reg  [7:0] error_mask;
    wire [3:0] data_out;
    wire       single_err;
    wire       double_err;

    // Instantiate UUT
    hamming_top_8_4 uut (
        .data_in(data_in),
        .error_mask(error_mask),
        .data_out(data_out),
        .single_err(single_err),
        .double_err(double_err)
    );

    initial begin
        // Initialize Inputs
        data_in = 4'b0000;
        error_mask = 8'b0000_0000;
        #20;

        // --- Scenario 1: Clean Transmission (No Errors) ---
        data_in = 4'b1011; 
        error_mask = 8'b0000_0000; 
        #10;
        if (data_out == 4'b1011 && !single_err && !double_err)
            $display("[PASS] Scenario 1: Clean data transmitted and recovered perfectly.");
        else
            $display("[FAIL] Scenario 1: Unexpected behavior on clean data.");

        
        
        
        
        // --- Scenario 2: Single Bit Error Injection (Correctable) ---
        data_in = 4'b1011;
        error_mask = 8'b0000_0100; // Inject single bit flip at Position 5 (D2)
        #10;
        if (data_out == 4'b1011 && single_err && !double_err)
            $display("[PASS] Scenario 2: Single-bit error detected and corrected successfully.");
        else
            $display("[FAIL] Scenario 2: Failed to correct single-bit error.");

        
        
        
        
        // --- Scenario 3: Double Bit Error Injection (Detect-Only) ---
        data_in = 4'b1011;
        error_mask = 8'b0001_0100; // Inject two bit flips (Position 4 and Position 5)
        #10;
        if (double_err && !single_err)
            $display("[PASS] Scenario 3: Double-bit error detected reliably (Uncorrectable).");
        else
            $display("[FAIL] Scenario 3: Failed to flag double-bit error.");

        $finish;
    end
      
endmodule
