library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Res_1080p_package.all;
use work.test_rom_package.all;

entity video_controller2 is
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
end video_controller2;

architecture rtl of video_controller2 is

    signal x : integer range 0 to total_x := 0;
    signal y : integer range 0 to total_y := 0;
    signal en : std_logic := '1';
    signal vga_rgb : std_logic_vector((RGB_bits*6)-1 downto 0);

    -- with this signal i will 
    signal changed_bits : integer range 0 to x_active := 0;
    signal base_bits : integer range 0 to x_active := 0;

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
            else
                -- start at active region (0,0)
                if x < x_active-1 then
                    x <= x + 1;

                    if changed_bits = x_active then
                        base_bits <= 0;
                    else
                        base_bits <= base_bits + 1;
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
                        else
                            -- begin vertical blanking process

                            -- set vsync to only y sync region:
                            if y >= (y_active + y_frontp + y_sync) - 1 then
                                vsync <= '1';
                            elsif y >= (y_active + y_frontp) - 1 then
                                if SW6 = 0 and SW7 = 1 then
                                    -- shift right
                                    if base_bits = 0 then
                                        base_bits <= x_active;
                                    else
                                        base_bits <= base_bits - 1;
                                    end if;

                                elsif SW6 = 1 and SW7 = 0 then
                                    -- shift left
                                    if base_bits = x_active then
                                        base_bits <= 0;
                                    else
                                        base_bits <= base_bits + 1;
                                    end if;
                                    -- else stay same
                                end if;

                                vsync <= '0';
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
                                -- hsync <= '1';
                                -- vsync <= '1';
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    RGB_PROC: process(en, x)
    begin
        if en = '1' and rst = '0' then
            if changed_bits < x_active/num_colours then
                vga_rgb <= test_pattern_ROM(0);
            elsif changed_bits < 2 * (x_active/num_colours) then
                vga_rgb <= test_pattern_ROM(1);
            elsif changed_bits < 3 * (x_active/num_colours) then
                vga_rgb <= test_pattern_ROM(2);
            elsif changed_bits < 4 * (x_active/num_colours) then
                vga_rgb <= test_pattern_ROM(3);
            elsif changed_bits < 5 * (x_active/num_colours) then
                vga_rgb <= test_pattern_ROM(4);
            elsif changed_bits < 6 * (x_active/num_colours) then
                vga_rgb <= test_pattern_ROM(5);
            elsif changed_bits < 7 * (x_active/num_colours) then
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