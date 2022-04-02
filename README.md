# SRAM
SRAM is memory cells which are used to store or retrieve the data. Further, FPGA chips have separate SRAM modules which can be used to design memories of different sizes and types, as shown in this repository..

![SRAM](https://user-images.githubusercontent.com/58098260/161374978-e31de7b2-d4bd-42fb-9f06-52db0d0e0364.png)

# memory controller

```
entity sram_controller is
	port( clk, reset : in std_logic;
		 -- to/from main system 
		  mem, rw : in std_logic;
		  addr : in std_logic_vector (17 downto 0);
		  data_f2s : in std_logic_vector (15 downto 0);
		  data_s2f : out std_logic_vector (15 downto 0);
		  ready : out std_logic;
		  -- to/from chip "controller"
		  ad: out std_logic_vector (17 downto 0);
		  we_n, oe_n : out std_logic
		  
		  -- SRAM chip
		  dio_a : inout std_logic_vector (15 downto 0);
		  ce_a_n, ub_a_n, lb_a_n : out std_logic 
		  );
end sram_controller;
```
