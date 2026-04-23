library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity wb_stage is
  port (
    RdW_in : in std_logic_vector(4 downto 0);
    RegWriteW_in : in std_logic;
    ResultSrcW : in std_logic_vector(1 downto 0);

    ReadDataW : in std_logic_vector(31 downto 0);
    PCPlus4W : in std_logic_vector(31 downto 0);
    ALUResultM : in std_logic_vector(31 downto 0);

    RdW_out : out std_logic_vector(4 downto 0);
    RegWriteW_out : out std_logic;
    ResultW : out std_logic_vector(31 downto 0)
  );
end entity wb_stage;

architecture rtl of wb_stage is

begin

process(ResultSrcW, ALUResultM, ReadDataW, PCPlus4W)
begin
  case ResultSrcW is
    when "00" =>
      ResultW <= ALUResultM;

    when "01" =>
      ResultW <= ReadDataW;

    when "10" =>
      ResultW <= PCPlus4W;

    when others =>
      ResultW <= (others => '0');
  end case;
end process;
  -- Apenas conectando entrada com saida.
  RdW_out <= RdW_in;
  RegWriteW_out <= RegWriteW_in;

end architecture rtl;
