----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 09/06/2018 02:22:20 PM
-- Design Name:
-- Module Name: freq_div - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity freq_div_2_14 is
    Port(IN_CLK: in std_logic;
         OUT_CLK: out std_logic
        );
end freq_div_2_14;

architecture Behavioral of freq_div_2_14 is
    SIGNAL qtmp: std_logic_vector(13 DOWNTO 0) := "00000000000000";
begin
    PROCESS(IN_CLK)
    begin
        if (rising_edge(IN_CLK)) then
            if (qtmp = "11111111111111") then
                qtmp <= "00000000000000";
            else 
                qtmp <= qtmp + 1;
            end if;
        end if;
    end process;
    OUT_CLK <= '0' WHEN qtmp < "10000000000000" ELSE '1';
end Behavioral;
