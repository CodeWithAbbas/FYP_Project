library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Datapath
entity datapath is
generic (N : integer := 20; M : integer := 20);
port 
( 	
	-- Inputs
	clk : in std_logic;
	rst : in std_logic;
	S1  : in std_logic; 
	S2  : in std_logic;
	S3  : in std_logic; 
	S4  : in std_logic; 
	Ei  : in std_logic; 
	Li  : in std_logic; 
	EA  : in std_logic; 
	EB  : in std_logic; 
	EC  : in std_logic; 
	ED  : in std_logic; 
	We  : in std_logic; 
	esum: in std_logic;  
	Csel_1: in std_logic; 
	Csel_2: in std_logic; 
	Csel_3: in std_logic; 
	Din : in std_logic_vector(N-1 downto 0); 
	RdAddr : in std_logic_vector(N-1 downto 0); 
	
	-- Outputs
	Zi12  : out std_logic; 
	Zi26  : inout std_logic; 
	Zi34  : inout std_logic; 
	gt12 : out std_logic;
	gt26 : inout std_logic;
	gt34 : inout std_logic;
	Zmax : out std_logic; 
	Order_Signal : out std_logic_vector(1 downto 0)
);
end datapath;

architecture arch of datapath is

	signal buy : std_logic;
	signal sell : std_logic;
	signal Buy_Flag : std_logic;
	signal Sell_Flag : std_logic;
	signal MACD : std_logic_vector(N-1 downto 0); 
	signal EMA9 : std_logic_vector(N-1 downto 0); 
	signal EMA26 : std_logic_vector(N-1 downto 0); 
	signal avg_1 : std_logic_vector(N+M-1 downto 0);  
	signal avg_9 : std_logic_vector(N-1 downto 0); 
	signal avg_2 : std_logic_vector(N+M-1 downto 0);  
	signal avg_3 : std_logic_vector(N+M-1 downto 0);  
	signal EMA12 : std_logic_vector(N-1 downto 0); 
	signal avg_12 : std_logic_vector(N-1 downto 0); 
	signal EC_out : std_logic_vector(N+M-1 downto 0);  
	signal avg_26 : std_logic_vector(N-1 downto 0); 
	signal EA_out : std_logic_vector(N-1 downto 0); 
	signal EB_out : std_logic_vector(N-1 downto 0); 
	signal ED_out : std_logic_vector(N-1 downto 0); 
	signal ram_out : std_logic_vector(N-1 downto 0); 
	signal i_count : std_logic_vector(N-1 downto 0);  
	signal cntr_in : std_logic_vector(N-1 downto 0);
	signal mux0_out : std_logic_vector(N-1 downto 0); 
	signal mux1_out : std_logic_vector(N-1 downto 0); 
	signal mux2_out : std_logic_vector(N-1 downto 0); 
	signal mux3_out : std_logic_vector(N-1 downto 0); 
	signal mux4_out : std_logic_vector(N-1 downto 0); 
	signal mux5_out : std_logic_vector(N-1 downto 0); 
	signal mux6_out : std_logic_vector(N-1 downto 0); 
	signal Adder_out: std_logic_vector(N+M-1 downto 0); 
	signal esum_out : std_logic_vector(N+M-1 downto 0);  
	signal Adder_MACD: std_logic_vector(N+M-1 downto 0); 
	signal EMA12_out : std_logic_vector(N-1 downto 0); 
	signal EMA26_out : std_logic_vector(N-1 downto 0);
	signal sel_order : std_logic_vector(1 downto 0);
    signal order_buy : std_logic_vector(1 downto 0);
	signal order_sell : std_logic_vector(1 downto 0);
	signal MACD_signal : std_logic_vector(N-1 downto 0); 
	signal EMA9_calc_1 : std_logic_vector(N+M-1 downto 0); 
	signal EMA9_calc_2 : std_logic_vector(N+M-1 downto 0); 
	signal EMA12_calc_1 : std_logic_vector(N+M-1 downto 0); 
	signal EMA26_calc_1 : std_logic_vector(N+M-1 downto 0); 
	signal EMA12_calc_2 : std_logic_vector(N+M-1 downto 0); 
	signal EMA26_calc_2 : std_logic_vector(N+M-1 downto 0); 

	constant CNTR_MAX : std_logic_vector(N-1 downto 0) := x"000c7";   -- X"00C8" = 200

begin
	
	cntr_in <=  x"00000"; 	-- Initialize counter value with '1'

	-- Counter i
	couter_i : entity work.countern generic map (N => N) port map (clk => clk, rst => rst, ld => Li, en => Ei, input => cntr_in, output => i_count);
	
	-- RAM 
	RAM_A : entity work.RAM generic map (addr_width => M, data_width => N) port map(clk => clk, WE => We, ADDR => mux0_out, DIN => Din, Dout => ram_out);
    
 
	-- Register
	reg_esum_out : entity work.reg generic map (N => N+M) port map (clk => clk, rst => rst, en => esum, D => Adder_out, Q => esum_out); 
    reg_EA : entity work.reg generic map (N => N) port map (clk => clk, rst => rst, en => EA, D => mux1_out, Q => EA_out); 
    reg_EB : entity work.reg generic map (N => N) port map (clk => clk, rst => rst, en => EB, D => mux3_out, Q => EB_out); 
    
	reg_EC : entity work.reg generic map (N => N+M) port map (clk => clk, rst => rst, en => EC, D => Adder_MACD, Q => EC_out); 
    reg_ED : entity work.reg generic map (N => N) port map (clk => clk, rst => rst, en => ED, D => mux5_out, Q => ED_out); 
	
	--Status signal
	Zi12 <= '1' when (i_count = x"0000C") else '0';
	Zi26 <= '1' when (i_count = x"0001A") else '0';
	Zi34 <= '1' when (i_count = x"00022") else '0';
	gt12 <= '1' when (i_count > x"0000C") else '0';
	gt26 <= '1' when (i_count > x"0001A") else '0';
	gt34 <= '1' when (i_count > x"00022") else '0';
	Zmax <= '1' when (i_count >= CNTR_MAX) else '0';
	
	-- Multiplexers
    mux0_out <= i_count when (S1 = '1') else RdAddr;
    mux1_out <= avg_12 when (S2 = '1') else EMA12_out;
    mux2_out <= ram_out when (Csel_1 = '1') else (others=>'0');
    mux3_out <= avg_26 when (S3 = '1') else EMA26_out;
    mux5_out <= avg_9 when (S4 = '1') else MACD_signal; 
    mux4_out <= ram_out when (Csel_2 = '1') else (others=>'0');
    mux6_out <= MACD when (Csel_3 = '1') else (others=>'0');
	
	-- Accumulator
	Adder_out <= ram_out + esum_out;
	Adder_MACD <= MACD+ EC_out;
	
	-- Calculating Averages of EMA12, EMA26 and EMA9
	avg_1 <= std_logic_vector(unsigned(esum_out) / 12);
	avg_12 <=avg_1(N-1 downto 0);
	avg_2 <= std_logic_vector(unsigned(esum_out) / 26);
	avg_26 <=avg_2(N-1 downto 0);
	avg_3 <= std_logic_vector(unsigned(EC_out) / 9);
	avg_9 <=avg_3(N-1 downto 0);
	
	-- Calculation of EMA12
	EMA12_calc_1 <= std_logic_vector((unsigned(mux2_out)*(2))+ (unsigned(EA_out)*(11)));
    EMA12_calc_2 <= std_logic_vector(unsigned(EMA12_calc_1) / 13);
    EMA12_out <= EMA12_calc_2(N-1 downto 0);
	EMA12 <= mux1_out;
	
	-- Calculation of EMA26
	EMA26_calc_1 <= std_logic_vector((unsigned(mux4_out)*(2))+ (unsigned(EB_out)*(25)));
    EMA26_calc_2 <= std_logic_vector(unsigned(EMA26_calc_1) / 27);
    EMA26_out <= EMA26_calc_2(N-1 downto 0);
	EMA26 <= mux3_out;
	
	-- Calculation of EMA9 of MACD
	EMA9_calc_1 <= std_logic_vector((unsigned(mux6_out)*(2))+ (unsigned(ED_out)*(8)));
    EMA9_calc_2 <= std_logic_vector(unsigned(EMA9_calc_1) / 10);
    MACD_signal <= EMA9_calc_2(N-1 downto 0) when (gt34='1') else (others=>'0');
    EMA9 <= mux5_out;
    
	-- Calculation of MACD
	MACD <= (EMA12-EMA26+250) when (gt26='1' or Zi26='1')  else (others=>'0');
	
    -- Comparator 
    Buy_Flag <= '1' when (MACD > MACD_signal and gt34='1') else '0';
	Sell_Flag <= '1' when (MACD < MACD_signal and gt34='1') else '0';
	buy  <= not Buy_Flag after 10 ns when (gt34='1') else '1';
	sell <= not Sell_Flag after 10 ns when (gt34='1') else '1';
	
	order_buy <= '0' & buy when (buy='1' and Buy_Flag='1') else (others=>'0'); 
	order_sell <= sell & '0' when (sell='1' and Sell_Flag='1') else (others=>'0'); 
    
	sel_order <= Sell_Flag & Buy_Flag   when (gt34='1') else "00";
	
	with sel_order select 
		Order_Signal <=	order_buy when "01",
						order_sell when "10",
						(others => '0') when others;
	
end arch;
