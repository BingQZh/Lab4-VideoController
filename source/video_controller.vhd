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
        vga_g : out std_logic_vector(RGB_bits-1 downto 0);
        vga_b : out std_logic_vector(RGB_bits-1 downto 0);
        vga_r : out std_logic_vector(RGB_bits-1 downto 0)
    );
end video_controller;

architecture rtl of video_controller is

    signal x : integer range 0 to total_x := 0;
    signal y : integer range 0 to total_y := 0;
    signal en : std_logic := '1';
    constant pink_g : std_logic_vector(RGB_bits-1 downto 0) := x"9";
    constant pink_b : std_logic_vector(RGB_bits-1 downto 0) := x"C";
    constant pink_r : std_logic_vector(RGB_bits-1 downto 0) := x"F";

begin

    VIDCONT_PROC: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                hsync <= '1';
                vsync <= '1';
                x <= 0;
                y <= 0;
                en <= '1';
                -- ^ not sure whether i should set to blank or pink?
            else
                if x < x_active-1 then
                    x <= x + 1;
                    hsync <= '1';
                    vsync <= '1';
                    -- en <= '1';
                    -- output colour
                else 
                    -- begin horizontal blanking process
                    if x = (x_active + x_frontp) then
                        hsync <= '0';
                    elsif x = (x_active + x_frontp + x_sync) then
                        hsync <= '1';
                    end if;

                    if x < total_x-1 then
                        x <= x + 1;

                        -- output blank
                        en <= '0';
                    else -- after this pt x will always = max_x
                        if y < y_active-1 then
                            -- go to the next line
                            en <= '1';
                            y <= y + 1;
                            x <= 0;
                        else
                            -- begin vertical blanking process

                            if y = (y_active + y_frontp) then
                                vsync <= '0';
                            elsif y = (y_active + y_frontp + y_sync) then
                                vsync <= '1';
                            end if;

                            if y < total_y-1 then
                                y <= y + 1;
                            else
                                -- brings it back to beginning:
                                x <= 0;
                                y <= 0;
                                en <= '1';   
                                hsync <= '1';
                                vsync <= '1';
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    RGB_PROC: process(en)
    begin
        if en = '1' then
            vga_g <= pink_g;
            vga_b <= pink_b;
            vga_r <= pink_r;
        else
            vga_g <= (others => '0');
            vga_b <= (others => '0');
            vga_r <= (others => '0');
        end if;
    end process;


end architecture;