-- Testbench for hardcoded AES-128 encryption (Artix-7 FPGA testing)
-- Key       : 3c4fcf098815f7aba6d2ae2816157e2b
-- Plaintext : 340737e0a29831318d305a88a8f64332
-- Expected  : 320b6a19978511dcfb09dc021d842539

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity enc_tb is
end enc_tb;

architecture behavior of enc_tb is

	component aes_enc
		port (
			clk        : in  std_logic;
			rst        : in  std_logic;
			ciphertext : out std_logic_vector(127 downto 0);
			done       : out std_logic
		);
	end component aes_enc;

	signal clk        : std_logic := '0';
	signal rst        : std_logic := '0';
	signal done       : std_logic;
	signal ciphertext : std_logic_vector(127 downto 0);

	constant clk_period : time := 10 ns;

	-- Convert std_logic_vector to hex string (Vivado VHDL-93 safe)
	function slv_to_hstring(slv : std_logic_vector) return string is
		constant hex_chars : string(1 to 16) := "0123456789abcdef";
		variable result    : string(1 to slv'length / 4);
		variable nibble    : std_logic_vector(3 downto 0);
	begin
		for i in result'range loop
			nibble := slv(slv'length - (i-1)*4 - 1 downto slv'length - i*4);
			result(i) := hex_chars(to_integer(unsigned(nibble)) + 1);
		end loop;
		return result;
	end function;

begin

	uut : aes_enc
		port map (
			clk        => clk,
			rst        => rst,
			ciphertext => ciphertext,
			done       => done
		);

	clk_process : process is
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process clk_process;

	sim_proc : process is
	begin
		report "=== AES-128 Hardcoded Encryption Test Starting ===";
		report "Key       : 3c4fcf098815f7aba6d2ae2816157e2b";
		report "Plaintext : 340737e0a29831318d305a88a8f64332";
		report "Expected  : 320b6a19978511dcfb09dc021d842539";

		rst <= '0';
		wait for clk_period * 1;
		rst <= '1';

		wait until done = '1';
		wait for clk_period / 2;

		if ciphertext = x"320b6a19978511dcfb09dc021d842539" then
			report "=== PASSED: Ciphertext matches expected output ===" severity note;
		else
			report "=== FAILED: Ciphertext does NOT match ===" severity error;
			report "  Got      : " & slv_to_hstring(ciphertext) severity error;
			report "  Expected : 320b6a19978511dcfb09dc021d842539" severity error;
		end if;

		report "=== Simulation complete ===";
		wait;
	end process sim_proc;

end architecture behavior;