import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ReadOnly, RisingEdge, Timer
from cocotb.utils import get_sim_time

# ==============================================================================
# 🛠️ ALTERE AQUI PARA TESTAR NOVOS PROGRAMAS VHDL
# ==============================================================================
# 1. Quantos ciclos de clock a simulação deve rodar para o programa terminar?
MAX_CICLOS = 25

# 2. Quais memórias e registradores deseja exibir no terminal?
MONITOR_RAM = [0, 4, 8]
MONITOR_REGS = [1, 2, 3, 4, 5, 6, 7, 8]

# 3. Estado inicial da RAM (para exibição correta no ciclo 0)
RAM_INICIAL = {0: 15, 4: 10, 8: 0}

# 4. Condição de Sucesso (O que o teste deve validar no final?)
ENDERECO_ALVO = 8
VALOR_ESPERADO = 25
# ==============================================================================


def decodifica_atlas(instr):
    try:
        instr = int(instr)
    except ValueError:
        return "BOLHA (Vazio / 'U')"

    if instr == 0 or instr == 0xFFFFFFFF:
        return "BOLHA (Vazio / NOP)"

    op = instr & 0x7F
    rd = (instr >> 7) & 0x1F
    f3 = (instr >> 12) & 0x7
    rs1 = (instr >> 15) & 0x1F
    rs2 = (instr >> 20) & 0x1F
    f7 = (instr >> 25) & 0x7F

    if op == 0b0110011:
        if f3 == 0b000 and f7 == 0b0000000:
            return f"ADD x{rd}, x{rs1}, x{rs2}"
        if f3 == 0b000 and f7 == 0b0100000:
            return f"SUB/CMP x{rd}, x{rs1}, x{rs2}"
        if f3 == 0b111 and f7 == 0b0000000:
            return f"AND x{rd}, x{rs1}, x{rs2}"
        if f3 == 0b110 and f7 == 0b0000000:
            return f"OR x{rd}, x{rs1}, x{rs2}"
        if f3 == 0b100 and f7 == 0b0000000:
            return f"XOR x{rd}, x{rs1}, x{rs2}"
    elif op == 0b0000011 and f3 == 0b010:
        return f"LD (Load) x{rd}, imm(x{rs1})"
    elif op == 0b0100011 and f3 == 0b010:
        return f"ST (Store) x{rs2}, imm(x{rs1})"
    elif op == 0b0010011 and f3 == 0b100:
        return f"NOT x{rd}, x{rs1}"
    elif op == 0b1101111:
        return f"J (Jump) para x{rd}"
    elif op == 0b1100011:
        if f3 == 0b100:
            return f"JN (Branch Negativo) se x{rs1}"
        if f3 == 0b000:
            return f"JZ (Branch Zero) se x{rs1} == 0"

    return f"Desconhecida (Op={bin(op)})"


def get_signal(dut, path):
    parts = path.split(".")
    current = dut
    try:
        for part in parts:
            if hasattr(current, part):
                current = getattr(current, part)
            elif hasattr(current, part.lower()):
                current = getattr(current, part.lower())
            else:
                return None
        return current
    except Exception:
        return None


@cocotb.test()
async def test_atlas_pipeline(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    estado_ram = RAM_INICIAL.copy()
    estado_regs = {reg: 0 for reg in MONITOR_REGS}

    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await Timer(1, unit="ns")

    dut._log.info("\n>>> PIPELINE MONITOR: ATIVADO <<<\n")

    for ciclo in range(0, MAX_CICLOS):
        if ciclo > 0:
            await RisingEdge(dut.clk)

        await ReadOnly()
        tempo = get_sim_time("ns")

        try:
            we_reg = get_signal(dut, "s_RegWriteW_out")
            rd_reg = get_signal(dut, "s_RdW_out")
            data_reg = get_signal(dut, "s_ResultW")

            we_mem = get_signal(dut, "s_MemWriteM")
            addr_mem = get_signal(dut, "s_ALUResultM")
            data_mem = get_signal(dut, "s_WriteDataM")

            def safe_int(sig):
                if sig is not None:
                    try:
                        return int(sig.value)
                    except ValueError:
                        return 0
                return 0

            if safe_int(we_reg) == 1:
                target_reg = safe_int(rd_reg)
                estado_regs[target_reg] = safe_int(data_reg)

            if safe_int(we_mem) == 1:
                target_addr = safe_int(addr_mem)
                estado_ram[target_addr] = safe_int(data_mem)

            instr_F = get_signal(dut, "s_InstrF")
            instr_D = get_signal(dut, "s_InstrD")
            alu_ctrl_E = get_signal(dut, "s_ALUControlE")
            rd_E = get_signal(dut, "s_RdE")
            alu_res_M = get_signal(dut, "s_ALUResultM")
            rd_M = get_signal(dut, "s_RdM")
            rd_W = get_signal(dut, "s_RdW_out")
            res_W = get_signal(dut, "s_ResultW")

            ram_str = " | ".join(
                [f"[{addr}]=0x{estado_ram.get(addr, 0):02X}" for addr in MONITOR_RAM]
            )
            reg_str = " | ".join(
                [f"x{reg}=0x{estado_regs.get(reg, 0):02X}" for reg in MONITOR_REGS]
            )

            print(f"===========================================================")
            print(f" CICLO {ciclo} ({tempo} ns)")
            print(f"-----------------------------------------------------------")
            print(f" [ESTADO GLOBAL INTERCEPTADO]")
            print(f" RAM:  {ram_str}")
            print(f" Regs: {reg_str}")
            print(f"-----------------------------------------------------------")
            print(f" [PIPELINE STAGES]")
            print(f" IF  (Busca)    : {decodifica_atlas(safe_int(instr_F))}")
            print(f" ID  (Decodif.) : {decodifica_atlas(safe_int(instr_D))}")
            print(
                f" EX  (Execução) : Calculando p/ Destino x{safe_int(rd_E)} (ALU_Ctrl={bin(safe_int(alu_ctrl_E))})"
            )
            print(
                f" MEM (Memória)  : Resultado ALU = 0x{safe_int(alu_res_M):02X} indo p/ x{safe_int(rd_M)}"
            )
            print(
                f" WB  (Escrita)  : Escrevendo 0x{safe_int(res_W):02X} na Gaveta x{safe_int(rd_W)}"
            )
            print(f"===========================================================\n")

        except Exception as e:
            print(f"Ciclo {ciclo} ({tempo} ns) - Erro de monitorização: {e}\n")

    valor_final = estado_ram.get(ENDERECO_ALVO, 0)
    if valor_final == VALOR_ESPERADO:
        dut._log.info(
            f">>>> SUCESSO: O valor {VALOR_ESPERADO} foi guardado na RAM no endereço {ENDERECO_ALVO}! <<<<"
        )
    else:
        dut._log.error(
            f"FALHA: O endereço {ENDERECO_ALVO} da RAM terminou com o valor {valor_final} em vez de {VALOR_ESPERADO}."
        )
