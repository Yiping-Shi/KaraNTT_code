# KaraNTT_code

- Dev on YipingPC and ISCL404.
- Aim: T-I in JUNE.

## Introduction

## To-Do List

* [ ] PyModel
  * [ ] NTT-65536 (Based on radix-16 unit) (4-step NTT)
  * [ ] INTT-65536 (Based on radix-16 unit) (4-step NTT)
  * [ ] Karatsuba / Winograd (16 $\rightarrow$ 81, 81 $\rightarrow$ 16\)
* [X] Scripts
  * [X] BRAM (coe+mem)
  * [X] WROM (coe+mem) (NTT+INTT)
* [ ] RTL
  * [ ] NTT-65536 (Based on radix-16 unit) (4-step NTT)
  * [ ] INTT-65536 (Based on radix-16 unit) (4-step NTT)
  * [X] Karatsuba / Winograd (16 $\rightarrow$ 81, 81 $\rightarrow$ 16\)

---

* [ ] NTT-based Polynomial Multiplier
  * [ ] Pymodel
    * [ ] NTT/INTT-16:   $INTT(NTT(A))==A$,  $INTT(NTT(A)\odot NTT(B))==C$
    * [ ] 4-stage-NTT
  * [X] RTL
    * [X] NTT/INTT_65536

      * [X] control logic (state machine)
      * [X] addr generator

      * ~~ data reorder (in and out)~~

      * [X] Buffer

        * [X] BRAM
        * [X] WROM
      * [X] IFFT_16

        * ~~ bit_reverse~~

        * [X] butterfly_stage0/1/2/3
        * [X] mod_add
        * [X] mod_sub
        * [X] mod_mul
    * [X] mod_mul x 16

## Tips

- Get the information of utilization by module.
  - `report_utilization -hierarchical -file D:\\IDEA\\NTT_Kara_25\\utilization_by_module.rpt`
- `report_timing -sort_by slack -max_paths 20 -path_type full -file D:\\IDEA\\NTT_Kara_25\\KaraNTT_code\\Reports\\Poly\\critical_paths.rpt`
- `report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 100 -file timing_summary_detailed.rpt`

## Element-wise Multiplication Optimization

- In the first version, 81 Multpliers are used, where each width is from 45-bit to 90-bit.
  - This will occupy 729 DSP48E2 in all
  - 1 Multiplier of 45-bit x 45-bit will occupy 9 DSP48E2
- DSP48E2 is designed to compute 27-bit x 18-bit signed multiplication.
  - It can be cascaded to implement larger multiplication.
