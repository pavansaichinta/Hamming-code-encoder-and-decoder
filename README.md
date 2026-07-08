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
