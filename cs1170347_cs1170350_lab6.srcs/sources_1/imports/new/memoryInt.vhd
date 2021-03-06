----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/28/2019 03:09:52 PM
-- Design Name: 
-- Module Name: memoryInt - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memoryInt is
  Port ( clk, step, go, reset : IN std_logic;
         reg_val : in std_logic_vector(3 downto 0);
         psc : in std_logic_vector(2 downto 0);
         led: out std_logic_vector(15 downto 0));
end memoryInt;

architecture Behavioral of memoryInt is
type state_type is (initI, init, oneStep, Cont, Done);
signal zero32 : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
signal zero16 : std_logic_vector(15 downto 0) := "0000000000000000";
signal state : state_type;
SIGNAL  instruction_M, instruction_FSM, data_from, address_to_data, data_to, psc_E: std_logic_vector(31 downto 0);
signal address_to_program : std_logic_vector(31 downto 0) := zero32;
SIGNAL wr_enable, slow_clk, resetD, stepD, goD : std_logic;
signal led_O : std_logic_vector(15 downto 0);
--signal state_En : std_logic_vector(1 downto 0);
COMPONENT CPU_design PORT (clk, reset: IN std_logic;
        psc : in std_logic_vector(31 downto 0);
        led : out std_logic_vector(15 downto 0);
        reg_val : in std_logic_vector(3 downto 0);
        instruction, data_from_memory: IN std_logic_vector(31 downto 0);
        address_progm, address_data, data_to_memory: OUT std_logic_vector(31 downto 0);
        wr_enable:OUT std_logic );END COMPONENT;
COMPONENT dist_mem_gen_0 PORT (a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
          ); END COMPONENT;
COMPONENT dist_mem_gen_1 IS
            PORT (
              a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
              d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
              clk : IN STD_LOGIC;
              we : IN STD_LOGIC;
              spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
            );  END COMPONENT;
begin

    freq_div:
        ENTITY WORK.freq_div_2_14(Behavioral)
        PORT MAP(
                IN_CLK => clk,
                OUT_CLK => slow_clk
        );
        
    debounceR:
        ENTITY WORK.debounce(Behavioral)
        PORT MAP(
                clk => slow_clk,
                debbtn => resetD,
                btn => reset
        );
     debounceG:
        ENTITY WORK.debounce(Behavioral)
        PORT MAP(
                clk => slow_clk,
                debbtn => goD,
                btn => go
        );
     debounceS:
        ENTITY WORK.debounce(Behavioral)
        PORT MAP(
                clk => slow_clk,
                debbtn => stepD,
                btn => step
        );

process(clk, resetD)
begin
if resetD = '1' then
    state <= initI;
elsif rising_edge(clk) then
    if state = initI then
        if stepD = '1' then
            state <= oneStep;
        elsif goD = '1' then
            state <= Cont;
        end if;
    elsif state = init then
        if stepD = '1' then
            state <= oneStep;
        elsif goD = '1' then
            state <= Cont;
        end if;
    elsif state = oneStep then
        state <= Done;
    elsif state = Cont then
        if instruction_M = zero32 then
            state <= Done;
        end if;
    elsif state = done then
        if stepD = '0' and goD = '0' then
            state <= init;
        end if;
    end if;
end if;
end process;
with state select instruction_FSM <=
                instruction_M when oneStep,
                instruction_M when Cont,
                zero32 when others;
                     
with state select led <=
                led_O when done,
                led_O when init,
                zero16 when others;

psc_E <= "0000000000000000000000"&psc&"0000000";
       
CPU_D : CPU_design PORT MAP(clk => clk,
                            reset => resetD,
                            instruction => instruction_FSM,
                            data_from_memory => data_from,
                            psc => psc_E,
                            reg_val => reg_val,
                            led => led_O,
                            address_progm => address_to_program,
                            address_data => address_to_data,
                            data_to_memory => data_to,
                            wr_enable => wr_enable
                            );
                            
Program_Mem : dist_mem_gen_0 PORT MAP( a => address_to_program(9 downto 2),
                                       spo => instruction_M);
                                       
Data_Memory : dist_mem_gen_1 PORT MAP( a => address_to_data(9 downto 2),
                                       d => data_to,
                                       we => wr_enable,
                                       clk => clk,
                                       spo => data_from);

end Behavioral;
