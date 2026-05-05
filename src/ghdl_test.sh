#!/bin/bash

echo "========================================="
echo " LIMPEZA E COMPILAÇÃO GHDL"
echo "========================================="

# Limpa o ambiente
ghdl --clean
rm -f *.cf
rm -rf sim_build

# Compila na ordem correta de dependências (sem o prefixo src/ pois já estamos na pasta)
ghdl -a --std=08 hazard_handlers/hazard_unit.vhd
ghdl -a --std=08 control/main_dec.vhd
ghdl -a --std=08 control/alu_decoder.vhd
ghdl -a --std=08 control/control_unit.vhd

for f in memory/*.vhd; do
  ghdl -a --std=08 "$f"
done
echo ">>> Testes de 'memory/' compilados!"

for f in pipeline_registers/*.vhd; do
  ghdl -a --std=08 "$f"
done
echo ">>> Testes de 'pipeline_registers' compilados!"

for f in architectural_components/*.vhd; do
  ghdl -a --std=08 "$f"
done
echo ">>> Testes de 'architectural_components/' compilados!"

for f in stages/*.vhd; do
  ghdl -a --std=08 "$f"
done
echo ">>> Testes de 'stages/' compilados!"

ghdl -a --std=08 cpu.vhd
echo ">>> CPU compilada com sucesso!"

echo "========================================="
echo " EXECUÇÃO DO TESTBENCH"
echo "========================================="

# Verifica se o utilizador passou um ficheiro como argumento
if [ -z "$1" ]; then
  echo "AVISO: Nenhum Testbench VHDL puro fornecido."
  echo "A executar o Testbench Cocotb (Python) via Makefile..."
  cd cocotb_tests && make SIM_ARGS="--wave=dump_cocotb.ghw"
else
  file="$1"
  # remove o caminho das pastas (deixa só o nome do ficheiro)
  filename=$(basename -- "$file")
  # remove a extensão .vhd
  base="${filename%.vhd}"
  # cria o nome do vcd
  wave="${base}.vcd"

  echo "A executar Testbench Nativo: $base"
  # Compila o ficheiro de testbench passado por argumento
  ghdl -a --std=08 "$file"
  ghdl -e --std=08 "$base"
  ghdl -r --std=08 "$base" --vcd="$wave"
  echo ">>> Sucesso! Onda gerada em $wave"
fi
