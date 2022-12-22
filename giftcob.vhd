LIBRARY iEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY giftcob IS 
PORT(
	clk : in std_logic;
	b, k : in STD_LOGIC_VECTOR(127 downto 0);
	C : out std_logic_vector (127 downto 0);
	resetnew : in std_logic := '1';
	done : out std_logic := '0'
);
END giftcob;

ARCHITECTURE implementasi of giftcob is
	type S_type is array (0 to 3) of STD_LOGIC_VECTOR (31 DOWNTO 0);
	type W_type is array (0 to 7) of STD_LOGIC_VECTOR (15 DOWNTO 0);
	signal S : S_type;
	signal W : W_type;
	SIGNAL T : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL Temp1 : STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL Temp2 : STD_LOGIC_VECTOR(15 downto 0);
	--SIGNAL b : STD_LOGIC_VECTOR(127 downto 0) := X"000102030405060708090A0B0C0D0E0F"; -- nonce  
	--SIGNAL k : STD_LOGIC_VECTOR (127 downto 0):= X"000102030405060708090A0B0C0D0E0F"; -- key
	SIGNAL enable : STD_LOGIC := '1';
	type konstanta is array (0 to 39) of STD_LOGIC_VECTOR(7 downto 0);
	CONSTANT konstanta_kodeC : konstanta :=
		(X"01", X"03", X"07", X"0F", X"1F", X"3E", X"3D", X"3B", X"37", X"2F", X"1E", X"3C", X"39", X"33", X"27", X"0E",
		X"1D", X"3A", X"35", X"2B", X"16", X"2C", X"18", X"30", X"21", X"02", X"05", X"0B", 
		X"17", X"2E", X"1C", X"38", X"31", X"23", X"06", X"0D", X"1B", X"36", X"2D", X"1A");
	SIGNAL gantiState : STD_LOGIC_VECTOR(1 downto 0) := "00" ;
	
	
	
	
	signal parsingState, bs : STD_LOGIC_VECTOR (4 downto 0) := "00000";
	SIGNAL tempS : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL B0, B1 , B2 , B3 : STD_LOGIC_VECTOR (1 downto 0);
	SIGNAL enableR : STD_LOGIC := '1';
	SIGNAL outR : STD_LOGIC_VECTOR (31 downto 0);
	SIGNAL finished : STD_LOGIC;
	SIGNAL ns : STD_LOGIC_VECTOR (1 downto 0) := "00";
	BEGIN 
	process(clk, gantiState, parsingState)
	BEGIN
		if (clk'event) and (clk = '1') then 
			gantiState <= ns;
			parsingState <= bs;
		end if;
	end process;
	
	process(clk, S, W, T, Temp1, Temp2, b, k, enable, tempS, B0, B1, B2, B3, enableR, outR, ns, bs)
	variable state, changeState : INTEGER := 0;
	variable halfstate : INTEGER := 0;
	BEGIN
	if resetnew = '0' then
		halfstate := 0;
		ns <= "00";
		bs <= "00000";
		done <= '0';
	else
		
		CASE gantiState IS 
		when "00" =>
				S(0)(31 downto 24) <= b(127 downto 120); 
				S(0)(23 downto 16) <= b(119 downto 112);
				S(0)(15 downto 8) <= b(111 downto 104);
				S(0)(7 downto 0) <= b(103 downto 96);  
				S(1)(31 downto 24) <= b(95 downto 88);
				S(1)(23 downto 16) <= b(87 downto 80);
				S(1)(15 downto 8) <= b(79 downto 72);
				S(1)(7 downto 0) <= b(71 downto 64);
				S(2)(31 downto 24) <= b(63 downto 56);
				S(2)(23 downto 16) <= b(55 downto 48);
				S(2)(15 downto 8) <= b(47 downto 40);
				S(2)(7 downto 0) <= b(39 downto 32);
				S(3)(31 downto 24) <= b(31 downto 24);
				S(3)(23 downto 16) <= b(23 downto 16);
				S(3)(15 downto 8) <= b(15 downto 8);
				S(3)(7 downto 0) <= b(7 downto 0);
				
				
				W(0)(15 downto 8) <= k(127 downto 120);
				W(0)(7 downto 0) <= k(119 downto 112);
				W(1)(15 downto 8) <= k(111 downto 104);
				W(1)(7 downto 0) <= k (103 downto 96);
				W(2)(15 downto 8) <= k(95 downto 88);
				W(2)(7 downto 0) <= k(87 downto 80);
				W(3)(15 downto 8) <= k(79 downto 72);
				W(3)(7 downto 0) <= k(71 downto 64);
				W(4)(15 downto 8) <= k(63 downto 56);
				W(4)(7 downto 0) <= k(55 downto 48);
				W(5)(15 downto 8) <= k(47 downto 40 );
				W(5)(7 downto 0) <= k(39 downto 32);
				W(6)(15 downto 8) <= k(31 downto 24);
				W(6)(7 downto 0) <= k(23 downto 16);
				W(7)(15 downto 8) <= k(15 downto 8);
				W(7)(7 downto 0) <= k(7 downto 0);
				
				ns <= "01";
		when "01" =>
			if halfstate < 40 then
					if rising_edge(clk) then
					CASE parsingState IS 
					
						when "00000" =>
							--if rising_edge(clk) then
								S(1) <= S(1) XOR (S(0) AND S(2));
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
						when  "00001" => 
							--if rising_edge(clk) then
								S(0) <= S(0) XOR (S(1) AND S(3));
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
						when  "00010" =>
							--if rising_edge(clk) then
								S(2) <= S(2) XOR (S(0) OR S(1));
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
						when  "00011" =>
							--if rising_edge(clk) then
								S(3) <= S(3) XOR S(2);
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
						when  "00100" =>
							--if rising_edge(clk) then
								S(1) <= S(1) XOR S(3);
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
						when "00101" => 
							--if rising_edge(clk) then
								S(3) <= NOT S(3); 
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
						when "00110" =>
							--if rising_edge(clk) then
								S(2) <= S(2) XOR (S(0) AND S(1));
							--end if;
							T <= S(0);
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
						when  "00111" =>
							--if rising_edge(clk) then
								S(0) <= S(3);
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
						when  "01000" => 
							--if rising_edge(clk) then
								S(3) <= T;
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
							
						when  "01001" =>
							--if rising_edge(clk) then
								S(0) <= S(0)(29)&S(0)(25)&S(0)(21)&S(0)(17)&S(0)(13)&S(0)(9)&S(0)(5)&S(0)(1)&S(0)(30)&S(0)(26)&S(0)(22)&S(0)(18)&S(0)(14)&S(0)(10)&S(0)(6)&S(0)(2)&S(0)(31)&S(0)(27)&S(0)(23)&S(0)(19)&S(0)(15)&S(0)(11)&S(0)(7)&S(0)(3)&S(0)(28)&S(0)(24)&S(0)(20)&S(0)(16)&S(0)(12)&S(0)(8)&S(0)(4)&S(0)(0);
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
							
							
						when  "01010" => 
							--if rising_edge(clk) then
								S(1) <= S(1)(30)&S(1)(26)&S(1)(22)&S(1)(18)&S(1)(14)&S(1)(10)&S(1)(6)&S(1)(2)&S(1)(31)&S(1)(27)&S(1)(23)&S(1)(19)&S(1)(15)&S(1)(11)&S(1)(7)&S(1)(3)&S(1)(28)&S(1)(24)&S(1)(20)&S(1)(16)&S(1)(12)&S(1)(8)&S(1)(4)&S(1)(0)&S(1)(29)&S(1)(25)&S(1)(21)&S(1)(17)&S(1)(13)&S(1)(9)&S(1)(5)&S(1)(1);
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
						when  "01011" => 
							--if rising_edge(clk) then
								S(2) <= S(2)(31)&S(2)(27)&S(2)(23)&S(2)(19)&S(2)(15)&S(2)(11)&S(2)(7)&S(2)(3)&S(2)(28)&S(2)(24)&S(2)(20)&S(2)(16)&S(2)(12)&S(2)(8)&S(2)(4)&S(2)(0)&S(2)(29)&S(2)(25)&S(2)(21)&S(2)(17)&S(2)(13)&S(2)(9)&S(2)(5)&S(2)(1)&S(2)(30)&S(2)(26)&S(2)(22)&S(2)(18)&S(2)(14)&S(2)(10)&S(2)(6)&S(2)(2);
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
						when  "01100" => 
							--if rising_edge(clk) then
								S(3) <= S(3)(28)&S(3)(24)&S(3)(20)&S(3)(16)&S(3)(12)&S(3)(8)&S(3)(4)&S(3)(0)&S(3)(29)&S(3)(25)&S(3)(21)&S(3)(17)&S(3)(13)&S(3)(9)&S(3)(5)&S(3)(1)&S(3)(30)&S(3)(26)&S(3)(22)&S(3)(18)&S(3)(14)&S(3)(10)&S(3)(6)&S(3)(2)&S(3)(31)&S(3)(27)&S(3)(23)&S(3)(19)&S(3)(15)&S(3)(11)&S(3)(7)&S(3)(3);
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
							
							
						when  "01101" =>
							--if rising_edge(clk) then
								S(2) <= S(2) XOR (W(2) & W(3));	
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
						when  "01110" =>
							--if rising_edge(clk) then
								S(1) <= S(1) XOR (W(6)& W(7));
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
						when  "01111" =>
							--if rising_edge(clk) then
								S(3) <= S(3) XOR (X"800000" & konstanta_kodeC (halfstate));
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
						when  "10000" =>
							--if rising_edge(clk) then
								Temp1 <= std_logic_vector((shift_right(unsigned(W(6)),2)) OR (shift_left(unsigned(W(6)),14)));
								Temp2 <= std_logic_vector((shift_right(unsigned(W(7)),12)) OR (shift_left(unsigned(W(7)),4)));
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
						when  "10001" =>
							--if rising_edge(clk) then
								W(7) <= W(5);
								W(6) <= W(4);
								W(5) <= W(3);
								W(4) <= W(2);
								W(3) <= W(1);
								W(2) <= W(0);
								W(1) <= Temp2;
								W(0) <= Temp1;
							--end if;
							bs <= STD_LOGIC_VECTOR(unsigned(parsingState) + 1);
						when others =>
								bs <= "00000";
								--if rising_edge(clk) then
									halfstate := halfstate + 1;
								--end if;
					
					end case;
					end if;
			elsif halfstate = 40 then	
				halfstate := halfstate + 1;			
				ns <= "10";
			end if;
					
		when "10" =>
				
				c <= S(0) & S(1) & S(2) & S(3);
				
				ns <= "11"; 
		when others => 
			ns <= "11";
			done <= '1';
		END CASE;
		
	end if;
	end process;
	end architecture;