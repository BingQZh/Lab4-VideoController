library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Res_1080p_package.all;

use std.textio.all;
use std.env.finish;

entity video_controller3_tb is
end video_controller3_tb;

architecture sim of video_controller3_tb is

    -- freq for image processing
    constant clk_hz : integer := 1485e5;
    constant clk_period : time := 1 sec / clk_hz;

    signal clk : std_logic := '1';
    signal rst : std_logic := '0';
    signal hsync : std_logic;
    signal vsync : std_logic;
    signal SW6 : std_logic := '0';
    signal SW7 : std_logic := '0';
    signal vga_g : std_logic_vector(RGB_bits-1 downto 0);
    signal vga_b : std_logic_vector(RGB_bits-1 downto 0);
    signal vga_r : std_logic_vector(RGB_bits-1 downto 0);
begin

    clk <= not clk after clk_period / 2;

    DUT : entity work.video_controller3(rtl)
    port map (
        clk => clk,
        rst => rst,
        SW6 => SW6,
        SW7 => SW7,
        hsync => hsync,
        vsync => vsync,
        vga_g => vga_g,
        vga_b => vga_b,
        vga_r => vga_r
    );

    VID_PROC : process
    begin
        wait for clk_period * 3000000;

        SW6 <= '1';

        wait for clk_period * 3000000;

        SW6 <= '0';
        SW7 <= '1'; 

        wait for clk_period * 3000000;

        rst <= '1';

        wait for clk_period * 100000;

        finish;
    end process;

end architecture;