library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_transmitter is
port(
clock: in std_logic;
out_pc : in std_logic_vector (127 downto 0);
txd: out std_logic;
baudrate_clock : buffer std_logic;
en_te : in std_logic;
done_te : out std_logic);
end uart_transmitter;

architecture Behavioral of uart_transmitter is
constant system_speed: natural := 50e6;

signal second_clock, old_second_clock: std_logic;
signal bit_counter: unsigned(3 downto 0) := x"9";
signal shift_register: unsigned(9 downto 0) := (others => '0');
signal char_index: natural range 0 to 17;

component clock_generator 
generic(clock_in_speed, clock_out_speed: integer);
port(
clock_in: in std_logic;
clock_out: out std_logic);
end component;

begin
baudrate_generator: clock_generator
    generic map(clock_in_speed => system_speed, clock_out_speed => 9600)
    port map(
    clock_in => clock,
    clock_out => baudrate_clock);

second_generator: clock_generator
    generic map(clock_in_speed => system_speed, clock_out_speed => 1)
    port map(
    clock_in => clock,
    clock_out => second_clock);

send: process(baudrate_clock)
begin
if en_te = '1' then
	done_te <= '0';
	char_index <= 0;
	bit_counter <= x"9";
else
if baudrate_clock'event and baudrate_clock = '1' then
    txd <= '1';
    if bit_counter = 9 then
        if second_clock /= old_second_clock then
            old_second_clock <= second_clock;
            if second_clock = '1' then
                bit_counter <= x"0";
                char_index <= char_index + 1;
                case char_index is
                    when 0 =>
                        shift_register <= b"1" & unsigned(out_pc(127 downto 120)) & b"0";---P
                    when 1 =>
                        shift_register <= b"1" & unsigned(out_pc(119 downto 112)) & b"0";---A
                    when 2 =>
                        shift_register <= b"1" & unsigned(out_pc(111 downto 104)) & b"0";---N
                    when 3 =>
                        shift_register <= b"1" & unsigned(out_pc(103 downto 96)) & b"0";---T
                    when 4 =>
                        shift_register <= b"1" & unsigned(out_pc(95 downto 88)) & b"0";---E
                    when 5 =>
                        shift_register <= b"1" & unsigned(out_pc(87 downto 80)) & b"0";---C
                    when 6 =>
                        shift_register <= b"1" & unsigned(out_pc(79 downto 72)) & b"0";---H
                    when 7 =>
                        shift_register <= b"1" & unsigned(out_pc(71 downto 64)) & b"0";
                    when 8 =>
                        shift_register <= b"1" & unsigned(out_pc(63 downto 56)) & b"0";---S
                    when 9 =>
                        shift_register <= b"1" & unsigned(out_pc(55 downto 48)) & b"0";---O
                    when 10 =>
                        shift_register <= b"1" & unsigned(out_pc(47 downto 40)) & b"0";---L
                    when 11 =>
                        shift_register <= b"1" & unsigned(out_pc(39 downto 32)) & b"0";---U
                    when 12 =>
                        shift_register <= b"1" & unsigned(out_pc(31 downto 24)) & b"0";---T
                    when 13 =>
                        shift_register <= b"1" & unsigned(out_pc(23 downto 16)) & b"0";---I
                    when 14 =>
                        shift_register <= b"1" & unsigned(out_pc(15 downto 8)) & b"0";---O
                    when 15 =>
                        shift_register <= b"1" & unsigned(out_pc(7 downto 0)) & b"0";---N
                    when 16 =>
                        shift_register <= b"1" & x"0A" & b"0";--- \n line feed
                    when 17 =>
                        shift_register <= b"1" & x"0D" & b"0";--- \r carriage return
                        char_index <= 0;
                    when others =>
                        char_index <= 0;
                end case;
            end if;
        end if;
    else
        txd <= shift_register(0);
        bit_counter <= bit_counter + 1;
        shift_register <= shift_register ror 1;
		if bit_counter = x"8" then
			done_te <= '1';
		end if;
    end if;
end if;
end if;
end process;

end Behavioral;