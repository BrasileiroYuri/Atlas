# ==============================================================================
# MAKEFILE - TESTE MESTRE ATLAS RISC-V (PIPELINE DE 5 ESTÁGIOS)
# ==============================================================================

# 1. Definir o simulador (GHDL) e a linguagem
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

# 2. Caminho base para os códigos-fonte VHDL (Assumindo que estamos na pasta cocotb_tests)
SRC_DIR = $(PWD)/..

# 3. Ordem rigorosa de compilação (Bottom-Up: Tijolos -> Paredes -> Telhado)
VHDL_SOURCES += \
    $(SRC_DIR)/hazard_handlers/hazard_unit.vhd \
    $(SRC_DIR)/control/main_dec.vhd \
    $(SRC_DIR)/control/alu_decoder.vhd \
    $(SRC_DIR)/control/control_unit.vhd \
    $(SRC_DIR)/memory/instruction_memory.vhd \
    $(SRC_DIR)/memory/data_memory.vhd \
    $(SRC_DIR)/architectural_components/program_counter.vhd \
    $(SRC_DIR)/architectural_components/register_file.vhd \
    $(SRC_DIR)/architectural_components/se_unit.vhd \
    $(SRC_DIR)/architectural_components/ula.vhd \
    $(SRC_DIR)/pipeline_registers/if_id.vhd \
    $(SRC_DIR)/pipeline_registers/id_ex.vhd \
    $(SRC_DIR)/pipeline_registers/ex_mem.vhd \
    $(SRC_DIR)/pipeline_registers/mem_wb.vhd \
    $(SRC_DIR)/stages/if_stage.vhd \
    $(SRC_DIR)/stages/id_stage.vhd \
    $(SRC_DIR)/stages/ex_stage.vhd \
    $(SRC_DIR)/stages/mem_stage.vhd \
    $(SRC_DIR)/stages/wb_stage.vhd \
    $(SRC_DIR)/cpu.vhd

# 4. A Entidade principal do hardware que vamos testar
TOPLEVEL = cpu

# 5. O nome do nosso script Python Mestre (sem a extensão .py)
MODULE = tb_atlas

# 6. Forçar a geração das ondas para abrir no GTKWave
SIM_ARGS += --vcd=atlas.vcd

# 7. Incluir os scripts base do Cocotb para compilar tudo magicamente
include $(shell cocotb-config --makefiles)/Makefile.sim
