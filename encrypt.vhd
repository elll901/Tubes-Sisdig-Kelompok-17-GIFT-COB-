LIBRARY ieee ; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 

ENTITY encrypt IS 
	port (
	clk : in std_logic;
	ad,n,k,m : std_logic_vector(127 downto 0);
	-- ad for asociated data , m for message, n for nonce, k for key
	cip, t : out std_logic_vector(127 downto 0); -- c for cipher, t for tag
	en_encrypt : in std_logic := '1';
	done_encrypt : out std_logic
	);
end entity;

architecture cofb_implementation of encrypt is 
	component giftcob is 
		port(
		clk : in std_logic;
		b,k : in std_logic_vector(127 downto 0);
		C : out std_logic_vector (127 downto 0);
		resetnew : in std_logic;
		done : out std_logic
		);
	end component;

	SIGNAL Y : std_logic_vector(127 downto 0) := (others => '0');
	SIGNAL L : std_logic_vector(63 downto 0);
	SIGNAL tempIn : std_logic_vector(127 downto 0);
	SIGNAL tempOut : std_logic_vector(127 downto 0);
	SIGNAL enable : std_logic;
	SIGNAL tuntas : std_logic;
	SIGNAL tempL : std_logic_vector(127 downto 0) := (others => '0');
	CONSTANT padding : std_logic_vector(63 downto 0) := X"0000000000000000";
	--SIGNAL 	ad,  n, k :  std_logic_vector(127 downto 0) := X"000102030405060708090A0B0C0D0E0F";
	--SIGNAL m : std_logic_vector(127 downto 0) := X"5CC0E36C368F70FF2BE4C076CEB0AEEB";
	
	BEGIN 
	main : giftcob PORT MAP (clk => clk, b => tempIn, k => k, C => tempOut, resetnew => enable, done => tuntas);
	process(clk,Y, L, tempIn, tempOut, enable, ad, m, n, k)
	variable state : std_logic_vector(2 downto 0) := "000";
	variable y1, y2 : std_logic_vector(63 downto 0);
	variable nextState : std_logic_vector(2 downto 0) := "000";
	BEGIN 
	if en_encrypt = '1' then
		state := "000";
		done_encrypt <= '0';
	else 
		if rising_edge(clk) then 
			state := nextState;
		end if; 
	end if;
	CASE state IS
		when  "000" =>
			if tuntas = '0' then 
				tempIn <= n;
				enable <= '1';
			else 
				Y <= tempOut;
				L <= Y(63 downto 0);
				nextState := "001";
			end if;
		when "001"  =>
			tempL <= std_logic_vector(unsigned(L)*3); -- Nampung nilai L sementara
			enable <= '0'; -- Reset gift128
			y2 := Y(63 downto 0);
			y1 := Y(126 downto 64) & Y(127);
			nextState := "010";
		when "010" =>
			L <= tempL(63 downto 0);
			Y <= ad XOR (y1 & y2) XOR (L & padding);
			nextState := "011";
		when  "011" =>
			if tuntas = '0' then
				enable <= '1';
				tempIn <= Y; 
			else 
				Y <= tempOut;
				tempL <= std_logic_vector(unsigned(L)*3);
				nextstate := "100";
			end if;
		when "100" =>
			cip <= m xor Y;
			y2 := Y(63 downto 0);
			y1 := Y(126 downto 64) & Y(127);
			L  <= tempL(63 downto 0);
			nextState := "101";
		when "101" =>
			Y <= m xor (y1 & y2) xor (L & padding);
			
			nextState := "110";
			enable <= '0';
		when "110" =>
			if tuntas = '0' then 
				tempIn <= n;
				enable <= '1';
			else 
				t <= tempOut;
				nextState := "111";
			end if;
		when others => 
			nextState := "111";
			done_encrypt <= '1';
	end case;
	end process;
	end architecture;