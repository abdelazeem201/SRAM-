----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2022 11:14:08 AM
-- Design Name: 
-- Module Name: sram_controller - Behavioral
-- Project Name: SRAM memory
-- Target Devices: 
-- Tool Versions: vivado 2021.1
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
entity sram_controller is
	port( clk, reset : in std_logic;
		 -- to/from main system 
		  mem, rw : in std_logic;
		  addr : in std_logic_vector (17 downto 0);
		  data_f2s : in std_logic_vector (15 downto 0);
		  data_s2f_r, data_s2f_ur: out std_logic_vector (15 downto 0);
		  ready : out std_logic;
		  -- to/from chip "controller"
		  ad: out std_logic_vector (17 downto 0);
		  we_n, oe_n : out std_logic;
		  
		  -- SRAM chip
		  dio_a : inout std_logic_vector (15 downto 0);
		  ce_a_n, ub_a_n, lb_a_n : out std_logic 
		  );
end sram_controller;
architecture sram_arch of sram_controller is
type state_type is (idle, rd1, rd2, wr1, wr2);
signal state_reg, state_next: state_type;
signal data_f2s_reg, data_f2s_next : std_logic_vector (15 downto 0);
signal data_s2f_reg, data_s2f_next : std_logic_vector (15 downto 0);
signal addr_reg, addr_next : std_logic_vector (17 downto 0);
-- adds a buffer for each output signal to remove glitches and reduce clock-to-output delay
signal we_buf, oe_buf, tri_buf: std_logic; 
signal we_reg, oe_reg, tri_reg: std_logic;
begin		  
	-- state and data register
	process(reset, clk)
	begin
		if(reset = '1') then
			state_reg <= idle; 
			data_f2s_reg <= (others => '0');
			data_s2f_reg <= (others => '0');
			addr_reg <= (others => '0');
			we_reg <= '1';
			oe_reg <= '1';
			tri_reg <= '1';
		elsif (clk'event and clk = '1') then 	
			state_reg <= state_next; 
			data_f2s_reg <= data_f2s_next;
			data_s2f_reg <= data_s2f_next;
			addr_reg <= addr_next;
			we_reg <= we_buf;
			oe_reg <= oe_buf;
			tri_reg <= tri_buf;
		end if;
	end process;
	
	-- next state logic
	process (state_reg, data_f2s_reg, data_s2f_reg, addr_reg, mem, rw, addr, dio_a, data_f2s)
	begin
			state_next <= state_reg;
			data_f2s_next <= data_f2s_reg;
			data_s2f_next <= data_s2f_reg;
			ready <= '0';
			case state_reg is
				when idle => 
					if mem= '0'then
						state_next <= idle;
					else
						addr_next <= addr;
						if rw = '0' then --write
							state_next <= wr1;
						else
							state_next <= rd1;
						end if;
					end if;
				ready <= '1';
				when wr1 => 
					state_next <= wr2;
				when wr2 => 
					state_next <= idle;
				when rd1 => 
					state_next <= rd2;
				when rd2 => 
					data_s2f_next <= dio_a;
					state_next <= idle;
			end case;
	end process;
	
	--output logic
	process (state_next)
	begin
		we_buf <= '1';
		oe_buf <= '1';
		tri_buf <= '1';
		case state_next is
			when idle =>
				we_buf <= '1';
				oe_buf <= '1';
				tri_buf <= '1';
			when wr1 => 
				we_buf <= '0';
				tri_buf <= '0';
			when wr2 =>
				tri_buf <= '0';	
			when rd1 => 
				oe_buf <= '0';
			when rd2 => 	
				oe_buf <= '0';
		 end case;	
	end process;
	
	-- to main system
	data_s2f_r  <= data_f2s_reg;
	data_s2f_ur <= dio_a;
	-- to sram
	we_n <= we_reg;
	oe_n <= oe_reg;
	ad <= addr_reg;
	-- i/o for sram chip
	ce_a_n <= '0';
	ub_a_n <= '0';
	lb_a_n <= '0';
	dio_a <= data_f2s_reg when tri_reg = '0' else (others => '0');
end sram_arch;	
