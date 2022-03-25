----------------------------------------------------------------------------------
-- Course: ENSC462
-- Group #: 9 
-- Engineer: Valeriya Svichkar and Bing Qiu Zhang

-- Module Name: video_controller3 - rtl
-- Project Name: Lab4
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Res_1080p_package.all;
use work.test_rom_package.all;

entity video_controller3 is
    port (
        clk : in std_logic;
        rst : in std_logic;
        SW6 : in std_logic;
        SW7 : in std_logic;
        hsync : out std_logic;
        vsync : out std_logic;
        vga_g : out std_logic_vector(RGB_bits-1 downto 0);
        vga_b : out std_logic_vector(RGB_bits-1 downto 0);
        vga_r : out std_logic_vector(RGB_bits-1 downto 0)
    );
end video_controller3;

architecture rtl of video_controller3 is

    signal x : integer range 0 to total_x := 0;
    signal y : integer range 0 to total_y := 0;
    signal en : std_logic := '1';

    -- take 24 bits from ROM
    signal vga_rgb : std_logic_vector((RGB_bits*6)-1 downto 0);

    -- this signal controls the displaying colours
    signal changed_bits : integer range 0 to x_active := 0;
    -- this signal is the amt of shift occuring
    signal base_bits : integer range 0 to x_active := 0;

begin

    VIDCONT_PROC: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- rst all values!
                hsync <= '1';
                vsync <= '1';
                x <= 0;
                y <= 0;
                base_bits <= 0;
                changed_bits <= 0;
                en <= '1';
            else
                -- start at active region (0,0)
                if x < x_active-1 then
                    -- output colour
                    x <= x + 1;

                    if changed_bits = x_active-1 then
                        changed_bits <= 0;
                    else
                        changed_bits <= changed_bits + 1;
                    end if;

                    hsync <= '1';

                    -- en is already set to 1
                    -- check for vertical blanking period:
                    if en = '1' then
                        vsync <= '1';
                    end if;
                else 
                    -- begin horizontal blanking process

                    -- set hsync to only x sync region:
                    if x >= (x_active + x_frontp + x_sync) - 1 then 
                        hsync <= '1';
                    elsif x >= (x_active + x_frontp) - 1 then
                        hsync <= '0';
                    end if;

                    if x < total_x-1 then
                        x <= x + 1;
                        -- output blank
                        en <= '0';
                    else -- check y index
                        if y < y_active-1 then
                            -- go to the next line without beginning vertical blanking process
                            en <= '1';
                            y <= y + 1;
                            x <= 0;
                            changed_bits <= base_bits;
                        else
                            -- begin vertical blanking process

                            -- set vsync to only y sync region:
                            if y >= (y_active + y_frontp + y_sync) - 1 then
                                -- this is back porch
                                vsync <= '1';
                            elsif y >= (y_active + y_frontp) - 1 then
                                -- this is y sync
                                vsync <= '0';
                            elsif y >= y_active - 1 then
                                -- this is front porch

                                -- shift bits here:
                                if SW6 = '0' and SW7 = '1' then
                                    -- shift right
                                    if base_bits = 0 then
                                        base_bits <= x_active-1;
                                    else
                                        base_bits <= base_bits - 1;
                                    end if;

                                elsif SW6 = '1' and SW7 = '0' then
                                    -- shift left
                                    if base_bits = x_active-1 then
                                        base_bits <= 0;
                                    else
                                        base_bits <= base_bits + 1;
                                    end if;

                                -- else stay same
                                end if;

                            end if;
                            
                            if y < total_y-1 then
                                -- continue the lines
                                y <= y + 1;
                                x <= 0;
                            else
                                -- brings it back to beginning:
                                x <= 0;
                                y <= 0;
                                en <= '1';   
                                changed_bits <= base_bits;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    RGB_PROC: process(en, x)
    begin
        -- check enable button:
        if en = '1' and rst = '0' then
            if changed_bits < x_active/num_colours then -- 1st segment colours of the test card (1920/8)
                vga_rgb <= test_pattern_ROM(0); -- white
            elsif changed_bits < 2 * (x_active/num_colours) then -- 2nd segment 2*(1920/8)
                vga_rgb <= test_pattern_ROM(1); -- yellow
            elsif changed_bits < 3 * (x_active/num_colours) then -- 3rd segment 3*(1920/8)
                vga_rgb <= test_pattern_ROM(2); -- cyan
            elsif changed_bits < 4 * (x_active/num_colours) then -- 4th segment 4*(1920/8)
                vga_rgb <= test_pattern_ROM(3); -- green
            elsif changed_bits < 5 * (x_active/num_colours) then -- 5th segment 5*(1920/8)
                vga_rgb <= test_pattern_ROM(4); -- pink
            elsif changed_bits < 6 * (x_active/num_colours) then -- 6th segment 6*(1920/8)
                vga_rgb <= test_pattern_ROM(5); -- red 
            elsif changed_bits < 7 * (x_active/num_colours) then -- 7th segment 7*(1920/8)
                vga_rgb <= test_pattern_ROM(6); -- blue
            else -- 8th segment 8*(1920/8)
                vga_rgb <= test_pattern_ROM(7); -- black
            end if;

            -- seperate the rgb value into r, g, and b
            vga_r <= vga_rgb((RGB_bits*6)-1 downto (RGB_bits*5));
            vga_g <= vga_rgb((RGB_bits*4)-1 downto (RGB_bits*3));
            vga_b <= vga_rgb(RGB_bits-1 downto 0);
        else -- en = 0 or rst = 1
            -- output blank
            vga_g <= (others => '0');
            vga_b <= (others => '0');
            vga_r <= (others => '0');
        end if;
    end process;

end architecture;