library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Res_1080p_package.all;
use work.test_rom_package.all;

entity video_controller2 is
    port (
        clk : in std_logic;
        rst : in std_logic;
        hsync : out std_logic;
        vsync : out std_logic;
        vga_g : out std_logic_vector(RGB_bits-1 downto 0);
        vga_b : out std_logic_vector(RGB_bits-1 downto 0);
        vga_r : out std_logic_vector(RGB_bits-1 downto 0)
    );
end video_controller2;

architecture rtl of video_controller2 is

    signal x : integer range 0 to total_x := 0;
    signal y : integer range 0 to total_y := 0;
    signal en : std_logic := '1';
    signal vga_rgb : std_logic_vector((RGB_bits*6)-1 downto 0);

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
                    hsync <= '0';
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
                            vsync <= '0';
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

    RGB_PROC: process(en, x)
    begin
        if en = '1' then
            if x < x_active/num_colours then
                vga_rgb <= test_pattern_ROM(0);
            elsif x < 2 * (x_active/num_colours) then
                vga_rgb <= test_pattern_ROM(1);
            elsif x < 3 * (x_active/num_colours) then
                vga_rgb <= test_pattern_ROM(2);
            elsif x < 4 * (x_active/num_colours) then
                vga_rgb <= test_pattern_ROM(3);
            elsif x < 5 * (x_active/num_colours) then
                vga_rgb <= test_pattern_ROM(4);
            elsif x < 6 * (x_active/num_colours) then
                vga_rgb <= test_pattern_ROM(5);
            elsif x < 7 * (x_active/num_colours) then
                vga_rgb <= test_pattern_ROM(6);
            else
                vga_rgb <= test_pattern_ROM(7);
            end if;

            vga_r <= vga_rgb((RGB_bits*6)-1 downto (RGB_bits*5));
            vga_g <= vga_rgb((RGB_bits*4)-1 downto (RGB_bits*3));
            vga_b <= vga_rgb(RGB_bits-1 downto 0);
        else
            vga_g <= (others => '0');
            vga_b <= (others => '0');
            vga_r <= (others => '0');
        end if;
    end process;


end architecture;