library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart is
	port(
		clock: in std_logic;
		din : in std_logic;
		txd: out std_logic
		);
end uart;

architecture uart_processing of uart is
	signal storein : std_logic_vector(7 downto 0);
	signal out_pc : std_logic_vector(127 downto 0);
	signal clkbaud : std_logic;
	signal counterclkbaud : integer := 1;
	signal en_te, done_te, en_re, done_re, done_encrypt : std_logic;
	signal en_encrypt : std_logic := '0';
	signal storeall : std_logic_vector(127 downto 0);
	signal ad, n, k, m : std_logic_vector(127 downto 0);
	signal cip, t : std_logic_vector(127 downto 0);

	component encrypt is
		port (
		clk : in std_logic;
		ad,n,k,m : std_logic_vector(127 downto 0);
		-- ad for asociated data , m for message, n for nonce, k for key
		cip, t : out std_logic_vector(127 downto 0); -- c for cipher, t for tag
		en_encrypt : in std_logic ;
		done_encrypt : out std_logic
		);
	end component;
	
	-- Komponen transmitter
	component uart_transmitter is
	port(
		clock: in std_logic;
		out_pc : in std_logic_vector (127 downto 0);
		txd: out std_logic;
		baudrate_clock : buffer std_logic;
		en_te : in std_logic;
		done_te : out std_logic);
	end component;
	
	-- Komponen receiver
	component uart_receiver is
	port ( 	 
		clk   : in std_logic;
		din   : in  std_logic;
		store : out std_logic_vector(7 downto 0);
		en_re : in std_logic;
		done_re : out std_logic);
	end component;
	begin
	rx : uart_receiver port map(clock, din, storein, en_re, done_re);
	tx : uart_transmitter port map(clock, out_pc, txd, clkbaud, en_te, done_te);
	enkripsi : encrypt port map(clock, ad,n,k,m,cip,t, en_encrypt, done_encrypt);
	
	process(clock, storein, en_encrypt)
	variable i : integer := 0;
	variable counterChange : integer := 0;
	variable counterTransmisi : integer := 0;
	begin
	if rising_edge(clkbaud) then 
		if counterclkbaud = 9601 then
			counterclkbaud <= 1;
		else 
			counterclkbaud <= counterclkbaud + 1;
		end if;
	end if;
	if i <= 120 then
		en_te <= '1';
		if counterclkbaud = 9600 then
			storeall((127-i) downto (120-i)) <= storein;
			i := i + 8;
		end if;
	else
		-- key, nonce, ad, message
		if rising_edge(clock) then
			if (counterChange < 4) then 
				if (counterChange = 0) then 
					k <= storeall;
					counterChange := counterChange + 1;
					i := 0;
				elsif (counterChange = 1) then
					n <= storeall;
					i := 0;
					counterChange := counterChange + 1;
				elsif (counterChange = 2) then
					ad <= storeall;
					i := 0;
					counterChange := counterChange + 1;
				elsif (counterChange = 3) then
					m <= storeall;
					counterChange := counterChange + 1;
				end if;
			else 
				en_encrypt <= '1';
		end if;
	end if;
	if done_encrypt = '1' then
		if rising_edge(clock) then 
			if (counterTransmisi = 0) then
				if done_te = '0' then 
					en_te <= '0';
					out_pc <= cip;
				elsif done_te = '1' then 
					en_te <= '1';
					counterTransmisi := counterTransmisi +1 ;
				end if;
			elsif(counterTransmisi = 1) then 
				if done_te = '0' then 
					en_te <= '0';
					out_pc <= t;
				elsif done_te = '1' then 
					en_te <= '1';
					counterTransmisi := counterTransmisi +1 ;
				end if;
			end if;
		end if;
	end if;
	end if;
	end process;
	end architecture;
				
		
		
	
	
	
		
		
		
		
		