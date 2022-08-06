library ieee;
use ieee.std_logic_1164.all;

-- top
entity top is
	generic (N : integer := 20);
	port 
	( 	-- Inputs 
		clk : in std_logic;
		rst : in std_logic;
		Go : in std_logic;
		We : in std_logic;
		Din : in std_logic_vector(N-1 downto 0);
		RdAddr : in std_logic_vector(N-1 downto 0);
		-- Outputs
		Done : out std_logic;
		Order_Signal : out std_logic_vector(1 downto 0)
    );
end top;

architecture arch of top is
   -- Top signals
   signal S1 : std_logic;
   signal S2 : std_logic;
   signal S3 : std_logic;
   signal S4 : std_logic;
   signal Li : std_logic;
   signal Ei : std_logic;
   signal EA : std_logic;
   signal EB : std_logic;
   signal EC : std_logic;
   signal ED : std_logic;
   signal Zi12 : std_logic;
   signal Zi26 : std_logic;
   signal Zi34 : std_logic;
   signal gt12 : std_logic;
   signal gt26 : std_logic;
   signal gt34 : std_logic;
   signal Csel_1 : std_logic;
   signal Csel_2 : std_logic;
   signal Csel_3 : std_logic;
   signal esum : std_logic;
   signal Zmax : std_logic;

begin 
	-- datapath Instant	
	datapath_inst: entity work.datapath 
    generic map ( N => N)
    port map
    ( 	 
	clk => clk,   
	rst => rst,  
	S1  => S1,   
	S2  => S2,   
	S3  => S3,   
	S4  => S4,   
	Ei  => Ei,    
	Li  => Li,    
	EA  => EA,    
	EB  => EB,    
	EC  => EC,    
	ED  => ED,    
	We  => We,    
	Din  => Din,   
	Zmax => Zmax,
	esum => esum,  
	gt12 => gt12, 
	gt26 => gt26, 
	gt34 => gt34, 
	Zi12  => Zi12,  
	Zi26  => Zi26,  
	Zi34  => Zi34,  
	RdAddr => RdAddr,
	Csel_1 => Csel_1,  
	Csel_2 => Csel_2,
	Csel_3 => Csel_3,
	Order_Signal => Order_Signal
	);
	-- Controller Instant
	controller_inst: entity work.controller 
	port map
	( 	  
	clk	=> clk,	
	rst => rst,  
	Go 	=> Go,	 
	S1 => S1,    
	S2 => S2,    
	S3 => S3,    
	S4 => S4,    
	Li => Li,    
	Ei => Ei,    
	EA => EA,    
	EB => EB,    
	EC => EC,    
	ED => ED,    
	gt12 => gt12,  
	gt26 => gt26,
	gt34 => gt34,
	esum => esum,  
	Zmax => Zmax, 
	Zi12  => Zi12,   
	Zi26  => Zi26,   
	Zi34  => Zi34,   
	Csel_1 => Csel_1,  
	Csel_2 => Csel_2,  
	Csel_3 => Csel_3,  
	Done => Done 
	);
	
end arch;


