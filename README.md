# 📟 Atlas - our RV32I implementation

## 📖 A quick context

In our homework, we have to implement a Pipelined RISC processor with Hazard handling (Data and Control) with the following instruction set:

```ADD, SUB, CMP, NOT, XOR, AND, OR, LD, ST, J, JN and JZ.```

Therefore, as RISC lovers, we choose RISC-V RV32I as our RISC processor.

However, the RISC-V doesn't have instructions like NOT, CMP, J, J, JN and JZ with the same name or meaning. So, we made some ISA decisions to fulfill our homework requirements while still implementing RV32I in the same project.
