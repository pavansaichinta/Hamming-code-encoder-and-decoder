`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 23:30:50
// Design Name: 
// Module Name: hamingcode_encoder_decoder
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




//--------------Encoder Module--------------------

module hamming_encoder_8_4 (
    input [3:0] data_in,   // [D1, D2, D3, D4]
    output [7:0] code_out   // [P_global, P1, P2, D1, P3, D2, D3, D4]
);

    wire p1, p2, p3, p_global;

    // Hamming(7,4) parity bit generation
    assign p1 = data_in[3] ^ data_in[2] ^ data_in[0];
    assign p2 = data_in[3] ^ data_in[1] ^ data_in[0];
    assign p3 = data_in[2] ^ data_in[1] ^ data_in[0];

    // Global parity for SEC-DED functionality
    assign p_global = p1 ^ p2 ^ data_in[3] ^ p3 ^ data_in[2] ^ data_in[1] ^ data_in[0];

    assign code_out = {p_global, p1, p2, data_in[3], p3, data_in[2], data_in[1], data_in[0]};

endmodule


//----------Decoder Module-----------------

module hamming_decoder_8_4 (
    input [7:0] code_in,      
    output reg  [3:0] data_out,     
    output single_err,   // Single Error Corrected
    output double_err    // Double Error Detected
);

    wire [2:0] syndrome;
    wire       global_parity_calc;
    wire       syndrome_active;
    wire       global_parity_match;
    
    reg  [7:0] corrected_code;

    // Calculate syndrome and global parity
    assign syndrome[0] = code_in[6] ^ code_in[4] ^ code_in[2] ^ code_in[0];
    assign syndrome[1] = code_in[5] ^ code_in[4] ^ code_in[1] ^ code_in[0];
    assign syndrome[2] = code_in[3] ^ code_in[2] ^ code_in[1] ^ code_in[0];
    assign global_parity_calc = ^code_in; 
    
    assign syndrome_active     = (|syndrome);
    assign global_parity_match = (global_parity_calc == 1'b0);

    // SEC-DED Status Flag Decoding
    assign single_err = syndrome_active && !global_parity_match;
    assign double_err = syndrome_active && global_parity_match;

    // Error Correction Logic
    always @(*) begin
        corrected_code = code_in;
        
        if (single_err) begin
            case (syndrome)
                3'b001: corrected_code[6] = ~code_in[6]; // Error at P1
                3'b010: corrected_code[5] = ~code_in[5]; // Error at P2
                3'b011: corrected_code[4] = ~code_in[4]; // Error at D1
                3'b100: corrected_code[3] = ~code_in[3]; // Error at P3
                3'b101: corrected_code[2] = ~code_in[2]; // Error at D2
                3'b110: corrected_code[1] = ~code_in[1]; // Error at D3
                3'b111: corrected_code[0] = ~code_in[0]; // Error at D4
                default: corrected_code = code_in;
            endcase
        end
        
        data_out = {corrected_code[4], corrected_code[2], corrected_code[1], corrected_code[0]};
    end

endmodule



//--------------------Hamingcode Top Module--------------------------


module hamming_top_8_4 (
    input [3:0] data_in,      // Original data payload
    input [7:0] error_mask,   // Bitmask to inject errors (XORed with codeword)
    output [3:0] data_out,     // Recovered data payload
    output single_err,   // Status flag: Single error corrected
    output double_err    // Status flag: Double error detected
);

    wire [7:0] encoded_stream;
    wire [7:0] corrupted_stream;

    // Instantiate Encoder
    hamming_encoder_8_4 encoder_inst (
        .data_in(data_in),
        .code_out(encoded_stream)
    );

    // Inject errors using XOR mask (a ^ 0 = a     and     a ^ 1 = ~a)
    assign corrupted_stream = encoded_stream ^ error_mask;

    // Instantiate Decoder
    hamming_decoder_8_4 decoder_inst (
        .code_in(corrupted_stream),
        .data_out(data_out),
        .single_err(single_err),
        .double_err(double_err)
    );

endmodule
