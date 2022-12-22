LIBRARY ieee ; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 

ENTITY rowperm IS
	port( 
	clk : IN STD_LOGIC;
	S : IN STD_LOGIC_VECTOR (31 downto 0);
	B0_pos , B1_pos, B2_pos, B3_pos : IN STD_LOGIC_VECTOR(1 downto 0);
	reset : IN STD_LOGIC ;
	T : OUT STD_LOGIC_VECTOR(31 downto 0);
	finish_rp : OUT STD_LOGIC := '0'
	);
end entity;

ARCHITECTURE babi of rowperm IS
SIGNAL counter1 : INTEGER := 0;
SIGNAL counter2 : INTEGER := 0;
SIGNAL temp : STD_LOGIC_VECTOR (31 downto 0) := X"00000000" ; -- biar awalnya 0
BEGIN 
	process (clk, counter1, B0_pos , B1_pos, B2_pos, B3_pos, S, reset)
		begin
		if reset = '1' then  -- active high
			counter1 <= 0;
			temp <= X"00000000";
			finish_rp <= '0';
		else 	
			if rising_edge(clk) then 
				if counter1 < 8 then
					if counter2 = 0 then 
						temp <= temp OR std_logic_vector(shift_left(unsigned(shift_right(unsigned(S), 4 * counter1 + 0)), counter1 + 8*(to_integer (unsigned(B0_pos)))));
						counter2 <= 1;
					elsif counter2 = 1 then
						temp <= temp OR std_logic_vector(shift_left(unsigned(shift_right(unsigned(S), 4 * counter1 + 1)), counter1 + 8*(to_integer (unsigned(B1_pos)))));
						counter2 <= 2;
					elsif counter2 = 2 then 
						temp <= temp OR std_logic_vector(shift_left(unsigned(shift_right(unsigned(S), 4 * counter1 + 2)), counter1 + 8*(to_integer (unsigned(B2_pos)))));
						counter2 <= 3;
					else
						temp <= temp OR std_logic_vector(shift_left(unsigned(shift_right(unsigned(S), 4 * counter1 + 3)), counter1 + 8*(to_integer (unsigned(B3_pos)))));
						counter2 <= 0;
						counter1 <= counter1 + 1;
					end if;
				else 
					T <= temp;
					finish_rp <= '1';
				end if;
			end if;
		end if;
END PROCESS;
END ARCHITECTURE;