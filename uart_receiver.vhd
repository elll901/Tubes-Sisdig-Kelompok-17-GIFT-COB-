library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_receiver is
port ( 	 clk   : in std_logic;
		 din   : in  std_logic;
		 store : out std_logic_vector(7 downto 0);
		 en_re : in std_logic;
		 done_re : out std_logic);
end uart_receiver;

architecture Behavioral of uart_receiver is
type state is (ready,b0);
signal ps : state := ready;
signal start,stop : std_logic;

begin
process(clk)
variable i : integer := 0 ;
begin
if en_re = '1' then
	i := 0;
	done_re <= '0';
	ps <= ready;
else
if clk'event and clk = '1' then
if ps = ready then
start <= din;
end if;
if start = '0' then
ps <= b0;
elsif start = '1' then
ps <= ready;
end if;
------------------------------------------1
if ps = b0 then
i := i + 1;
if i = 2600 then
start <= din;
end if;
if i = 7800 then
store(0) <= din;
end if;
if i = 13000 then
store(1) <= din;
end if;
if i = 18200 then
store(2) <= din;
end if;
if i = 23400 then
store(3) <= din;
end if;
if i = 28600 then
store(4) <= din;
end if;
if i = 33800 then
store(5) <= din;
end if;
if i = 39000 then
store(6) <= din;
end if;
if i = 44200 then
store(7) <= din;
end if;
if i = 49400 then
stop <= din;
end if;
if i = 54600 then
i := 0 ;
ps <= ready ;
done_re <= '1';
-----------------------------------------------------10
end if;
end if;
end if;
end if;
end  process;


end Behavioral;