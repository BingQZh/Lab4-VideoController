library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Res_1080p_package.all;

entity video_controller is
    port (
        clk : in std_logic;
        rst : in std_logic;
        hsync : out std_logic;
        vsync : out std_logic;
        vga_g : out std_logic_vector(3 downto 0);
        vga_b : out std_logic_vector(3 downto 0);
        vga_r : out std_logic_vector(3 downto 0)
    );
end video_controller;

architecture rtl of video_controller is

    signal x : integer range 0 to total_x := 0;
    signal y : integer range 0 to total_y := 0;
    constant pink_g : std_logic_vector(3 downto 0) := x"9";
    constant pink_b : std_logic_vector(3 downto 0) := x"C";
    constant pink_r : std_logic_vector(3 downto 0) := x"F";

begin

    VIDCONT_PROC: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                hsync <= '1';
                vsync <= '1';
                x <= 0;
                y <= 0;
            else
                if x < x_active then
                    x <= x + 1;
                    hsync <= '1';
                    vsync <= '1';

                    -- output colour
                    vga_g <= pink_g;
                    vga_b <= pink_b;
                    vga_r <= pink_r;
                else 
                    -- begin horizontal blanking process
                    hsync <= '0'
                    if x < total_x-1 then
                        x <= x + 1;

                        -- output blank
                        vga_g <= (other => '0');
                        vga_b <= (other => '0');
                        vga_r <= (other => '0');
                    else -- after this pt x will always = max_x
                        if y < y_active-1 then
                            -- go to the next line
                            y <= y + 1;
                            x <= 0;
                        else
                            -- begin vertical blanking process
                            vsync <= '0'
                            if y < total_y-1 then
                                y <= y + 1;
                            else
                                x <= 0;
                                y <= 0;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture;