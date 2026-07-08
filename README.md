# Hamming-code-encoder-and-decoder
# SEC-DED Extended Hamming (8,4) Codec Core

A hardware-efficient, fully synthesizable **Extended Hamming (8,4) Encoder and Decoder** core implemented in Verilog HDL. This design extends standard single-error correction capabilities by incorporating a global parity bit to support **SEC-DED** (Single Error Correction, Double Error Detection) functionality, making it ideal for low-latency memory protection subsystems (ECC) and reliable bus interfaces.

---

## 🚀 Architecture Overview

The system uses parallel XOR-gate matrix trees to minimize logic depth and maximize throughput. Data bits and parity bits are strategically mapped to allow the decoder to pinpoint single-bit error locations mathematically or flag uncorrectable double-bit errors instantly.

### Bit Alignment Matrix

The 8-bit ECC codeword is structured using the following indexing configuration:

| Bit Position | `code_out[7]` | `code_out[6]` | `code_out[5]` | `code_out[4]` | `code_out[3]` | `code_out[2]` | `code_out[1]` | `code_out[0]` |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Component** | $P_{global}$ | $P_1$ | $P_2$ | $D_1$ | $P_3$ | $D_2$ | $D_3$ | $D_4$ |
| **Type** | Global Parity | Parity ($2^0$) | Parity ($2^1$) | Data 1 | Parity ($2^2$) | Data 2 | Data 3 | Data 4 |

---

## 🧠 Decoding Logic & Truth Table

By evaluating the recalculated 3-bit internal syndrome alongside the overall 8-bit block parity, the decoder determines the precise status of the incoming payload:

| Syndrome Status | Global Parity | Detected State | Decoder Action |
| :--- | :--- | :--- | :--- |
| **All Zeros (`000`)** | Valid (Even) | **No Error** | Passes payload directly. |
| **Non-Zero (` > 0 `)** | Invalid (Odd) | **Single-Bit Error** | **Corrects** the inverted bit using syndrome indexing. |
| **Non-Zero (` > 0 `)** | Valid (Even) | **Double-Bit Error** | **Flags Double Error (`double_err = 1`)**; correction bypassed. |
| **All Zeros (`000`)** | Invalid (Odd) | **Global Bit Error** | Global parity bit itself flipped; payload remains valid. |

---

## 📁 Repository Structure

```text
├── rtl/
│   ├── hamming_encoder_8_4.v  # Combined parity generator logic
│   ├── hamming_decoder_8_4.v  # Syndrome calculation and error-correction matrix
│   └── hamming_top_8_4.v      # Top-level wrapper with integrated error injection
└── bench/
    └── tb_hamming_top_8_4.v   # Self-checking testbench covering verification scenarios



### TCL Console Output Log
The self-checking testbench successfully executed all targeted verification scenarios, proving the functional correctness of the SEC-DED architecture:

```text
Built simulation snapshot tb_hamming_top_8_4_behav
INFO: [Runs 36-26] xelab completed.
INFO: [Vivado 12-1390] *** Running xsim
    with args "tb_hamming_top_8_4_behav -key {Behavioral:sim_1:Functional:tb_hamming_top_8_4} -tclbatch {tb_hamming_top_8_4.tcl} -log {tb_hamming_top_8_4_behav.log}"
Vivado Simulator 2014.1
Time resolution is 1 ps
[PASS] Scenario 1: Clean data transmitted and recovered perfectly.
[PASS] Scenario 2: Single-bit error detected and corrected successfully.
[PASS] Scenario 3: Double-bit error detected reliably (Uncorrectable).
$finish called at time : 50 ns : File "C:/Users/pavan/OneDrive/Documents/xilinx_vivado/Hamingcode_encoder_decoder/Hamingcode_encoder_decoder.srcs/sim_1/new/hamingcode_encoder_decoder_tb.v" Line 82
INFO: [Vivado 12-1395] XSim completed. Design snapshot 'tb_hamming_top_8_4_behav' loaded.
launch_xsim: Time (s): cpu = 00:00:02 ; elapsed = 00:00:07 . Memory (MB): peak = 949.090 ; gain = 0.000
