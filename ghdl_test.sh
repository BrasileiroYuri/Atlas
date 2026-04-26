ghdl --clean
rm -f *.cf

ghdl -a --std=08 src/control/main_dec.vhd
ghdl -a --std=08 src/control/alu_decoder.vhd
ghdl -a --std=08 src/control/control_unit.vhd

for f in src/memory/*; do
  ghdl -a --std=08 "$f"
done
echo ">>> Testes de 'memory/' feitos!"

for f in src/pipeline_registers/*; do
  ghdl -a --std=08 "$f"
done
echo ">>> Testes de 'pipeline_registers' feitos!"

for f in src/architectural_components/*; do
  ghdl -a --std=08 "$f"
done
echo ">>> Testes de 'architectural_components/' feitos!"

for f in src/stages/*; do
  ghdl -a --std=08 "$f"
done
echo ">>> Testes de 'stages/' feitos!"

ghdl -a --std=08 src/cpu.vhd
ghdl -a --std=08 tb_cpu2.vhd

ghdl -e --std=08 tb_cpu2
ghdl -r --std=08 tb_cpu2 --vcd=wave.vcd
