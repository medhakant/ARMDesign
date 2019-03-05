----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 01/21/2019 01:34:26 PM
-- Design Name:
-- Module Name: CPU_design - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.All;
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CPU_design is
  Port (clk, reset : IN std_logic;
--        state : in std_logic_vector(1 downto 0);
        led : out std_logic_vector(15 downto 0);
        instruction, data_from_memory: IN std_logic_vector(31 downto 0);
        psc : in std_logic_vector(31 downto 0);
        reg_val : in std_logic_vector(3 downto 0);
        address_progm, address_data, data_to_memory: OUT std_logic_vector(31 downto 0);
        wr_enable:OUT std_logic);
end CPU_design;

architecture Behavioral of CPU_design is

type instr_class_type is (DP, DT, branch, unknown);
type i_decoded_type is (add,sub,cmp,mov,ldr,str,beq,bne,b, halt, unknown);
signal instr_class : instr_class_type;
signal i_decoded : i_decoded_type;
type RegFile is array(15 downto 0) of std_logic_vector(31 downto 0);
type state_type is (init, oneStep, Cont, Done);
--signal state : state_type:= init;
signal next_state : state_type;

signal RF : RegFile;
signal pc, next_pc, check, pc_4, RF_add, RF_sub, RF_mov, address_data_next, extendedAdd : std_logic_vector (31 downto 0);
signal cond : std_logic_vector (3 downto 0);
signal F_field : std_logic_vector (1 downto 0);
signal I_bit, U_bit, Z_flag, next_Z, L_bit : std_logic;
signal shift_spec : std_logic_vector (7 downto 0);
signal bTarget : std_logic_vector (31 downto 0);
signal zero8 : std_logic_vector(7 downto 0) := "00000000";
signal zero24 : std_logic_vector(23 downto 0) := "000000000000000000000000";
signal zero32 : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

Begin
    led <= RF(0)(15 downto 0) when reg_val = "0000" else
           RF(0)(31 downto 16) when reg_val = "1000" else
           RF(1)(15 downto 0) when reg_val = "0001" else
           RF(1)(31 downto 16) when reg_val = "1001" else
           RF(2)(15 downto 0) when reg_val = "0010" else
           RF(2)(31 downto 16) when reg_val = "1010" else
           RF(3)(15 downto 0) when reg_val = "0011" else
           RF(3)(31 downto 16) when reg_val = "1011" else
           pc(15 downto 0) when reg_val = "0100" else
           pc(31 downto 16) when reg_val = "1100" else
           instruction(15 downto 0) when reg_val = "0101" else
           instruction(31 downto 16) when reg_val = "1101" else
           data_from_memory(15 downto 0) when reg_val = "0110" else
           data_from_memory(31 downto 16) when reg_val = "1110" else
           zero8&zero8;
    cond <= instruction(31 downto 28);
    F_field <= instruction(27 downto 26);
    I_bit <= instruction(25);
    shift_spec <= instruction (11 downto 4);
    U_bit <= instruction(23);
    L_bit <= instruction(20);

    with F_field select instr_class <=
        DP when "00",
        DT when "01",
        branch when "10",
        unknown when others;
    i_decoded <= add when instr_class = DP and instruction(24 downto 21) = "0100" else
                 sub when instr_class = DP and instruction(24 downto 21) = "0010" else
                 mov when instr_class = DP and instruction(24 downto 21) = "1101" else
                 cmp when instr_class = DP and instruction(24 downto 21) = "1010" else
                 str when instr_class = DT and instruction(20) = '0' else
                 ldr when instr_class = DT and instruction(20) = '1' else
                 b when instr_class = branch and cond = "1110" else
                 beq when instr_class = branch and cond = "0000" else
                 bne when instr_class = branch and cond = "0001" else
                 halt when instruction = zero32 else
                 unknown;
     
     extendedAdd <= instruction(23)&instruction(23)&instruction(23)&instruction(23)&instruction(23)&instruction(23)&instruction(23 downto 0) & "00";
     bTarget <= std_logic_vector(signed(pc)+8+signed(extendedAdd)) when i_decoded = b else
                std_logic_vector(signed(pc)+8+signed(extendedAdd)) when i_decoded = beq and not Z_flag = '0' else
                std_logic_vector(signed(pc)+8+signed(extendedAdd)) when i_decoded = bne and Z_flag = '0' else
                pc_4;

     pc_4 <= std_logic_vector(signed(pc)+4);

     next_pc <= bTarget when instr_class = branch else
                pc when i_decoded = halt else
                pc_4;

    check <= RF(to_integer(unsigned(instruction(19 downto 16)))) - (zero24 & instruction(7 downto 0));
    next_Z <= '1' when check = zero32 else
              '0';

    RF_add <= RF(to_integer(unsigned(instruction(19 downto 16))))  + (zero24&instruction(7 downto 0)) when I_bit = '1' else
              RF(to_integer(unsigned(instruction(19 downto 16)))) + RF(to_integer(unsigned(instruction(3 downto 0))));

    RF_sub <= RF(to_integer(unsigned(instruction(19 downto 16)))) - (zero24&instruction(7 downto 0)) when I_bit = '1' else
              RF(to_integer(unsigned(instruction(19 downto 16)))) - RF(to_integer(unsigned(instruction(3 downto 0))));

    RF_mov <= zero24&instruction(7 downto 0) when I_bit = '1' else
              RF(to_integer(unsigned(instruction(3 downto 0)))) when I_bit = '0';

    address_data_next <= RF(to_integer(unsigned(instruction(19 downto 16)))) + instruction(11 downto 0) when U_bit = '1' else
                         RF(to_integer(unsigned(instruction(19 downto 16)))) - instruction(11 downto 0) when U_bit ='0';
    address_progm <= pc;
    
    wr_enable <= '0' when (reset = '1') or (not (i_decoded = str)) else
                 '1';
    process(clk, reset)
    begin
    if reset ='1' then
--            wr_enable <= '0';
            pc <= psc;
            Z_flag <= '0';
    elsif rising_edge(clk) then
        case i_decoded is
            when add => RF(to_integer(unsigned(instruction(15 downto 12)))) <= RF_add;
            when sub => RF(to_integer(unsigned(instruction(15 downto 12)))) <= RF_sub;
            when mov => RF(to_integer(unsigned(instruction(15 downto 12)))) <= RF_mov;
            when cmp => Z_flag <= next_Z;
            when str => 
                        data_to_memory <= RF(to_integer(unsigned(instruction(15 downto 12))));
                        address_data <= address_data_next;
            when ldr => address_data <= address_data_next;
                        RF(to_integer(unsigned(instruction(15 downto 12)))) <= data_from_memory;
            when others =>
        end case;
        pc <= next_pc;
    end if;
    end process;
end Behavioral;