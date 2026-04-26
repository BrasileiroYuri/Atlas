#!/bin/bash

# Cores para o terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # Sem cor

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE} ----- INICIANDO BATERIA DE TESTES ----- ${NC}"
echo -e "${BLUE}=========================================${NC}\n"

echo "[0/6] Limpando cache do GHDL..."
rm -f *.cf

echo -e "\n${GREEN}[1/6] Compilando Componentes Arquiteturais...${NC}"
ghdl -a --std=08 src/architectural_components/program_counter.vhd || exit 1
ghdl -a --std=08 src/architectural_components/register_file.vhd || exit 1
ghdl -a --std=08 src/architectural_components/se_unit.vhd || exit 1
ghdl -a --std=08 src/architectural_components/ula.vhd || exit 1

echo -e "\n${GREEN}[2/6] Compilando Memorias...${NC}"
ghdl -a --std=08 src/memory/instruction_memory.vhd || exit 1
ghdl -a --std=08 src/memory/data_memory.vhd || exit 1

echo -e "\n${GREEN}[3/6] Compilando Unidades de Controle...${NC}"
ghdl -a --std=08 src/control/main_dec.vhd || exit 1
ghdl -a --std=08 src/control/alu_decoder.vhd || exit 1
ghdl -a --std=08 src/control/control_unit.vhd || exit 1

echo -e "\n${GREEN}[4/6] Compilando Esteiras (Pipeline Registers) e Bancadas (Stages)...${NC}"
# Compila primeiro os registradores de pipeline
ghdl -a --std=08 src/pipeline_registers/if_id.vhd || exit 1
ghdl -a --std=08 src/pipeline_registers/id_ex.vhd || exit 1
ghdl -a --std=08 src/pipeline_registers/ex_mem.vhd || exit 1
ghdl -a --std=08 src/pipeline_registers/mem_wb.vhd || exit 1
# Compila depois os estágios (que usam as memórias e componentes)
ghdl -a --std=08 src/stages/if_stage.vhd || exit 1
ghdl -a --std=08 src/stages/id_stage.vhd || exit 1
ghdl -a --std=08 src/stages/ex_stage.vhd || exit 1
ghdl -a --std=08 src/stages/mem_stage.vhd || exit 1
ghdl -a --std=08 src/stages/wb_stage.vhd || exit 1

echo -e "\n${GREEN}[5/6] Compilando a Fabrica Final (cpu.vhd)...${NC}"
ghdl -a --std=08 src/cpu.vhd || exit 1
echo "✔️ Top-Level compilado com sucesso! Nao ha fios cortados."

echo -e "\n${GREEN}[6/6] Executando Testbenches Individuais...${NC}"

# Lista de Testbenches para rodar
declare -a testes=(
  "tb_program_counter:src/testbenchs/tb_program_counter.vhd"
  "tb_instruction_memory:src/testbenchs/tb_instruction_memory.vhd"
  "tb_data_memory:src/testbenchs/tb_data_memory.vhd"
  "tb_register_file:src/testbenchs/tb_register_file.vhd"
  "tb_se_unit:src/testbenchs/tb_se_unit.vhd"
  "tb_ula:src/testbenchs/tb_ula.vhd"
  "tb_aludec:src/testbenchs/tb_alu_decoder.vhd"
  "tb_cpu:src/testbenchs/tb_cpu.vhd"
)
for t in "${testes[@]}"; do
    entidade="${t%%:*}"
    ficheiro="${t##*:}"

    echo -e "\n${BLUE}>>> Testando: $entidade <<<${NC}"
    ghdl -a --std=08 "$ficheiro" || exit 1
    ghdl -e --std=08 "$entidade" || exit 1

    # A MÁGICA ESTÁ AQUI: Salva um arquivo .vcd com o nome exato do teste!
    ghdl -r --std=08 "$entidade" --vcd="${entidade}.vcd" || exit 1
done

echo -e "\n${GREEN}====================================================${NC}"
echo -e "${GREEN}-->>===>===>> TODOS OS TESTES PASSARAM<<===<===<<-- ${NC}"
echo -e "${GREEN}====================================================${NC}"
