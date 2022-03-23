library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Res_1080p_package.all;

package test_rom_package is

    constant num_colours : integer := 8;

    constant white : std_logic_vector((RGB_bits*6)-1 downto 0) := x"FFFFFF";
    constant yellow : std_logic_vector((RGB_bits*6)-1 downto 0) := x"FFFF00";
    constant cyan : std_logic_vector((RGB_bits*6)-1 downto 0) := x"00FFFF";
    constant green : std_logic_vector((RGB_bits*6)-1 downto 0) := x"00FF00";
    constant pink : std_logic_vector((RGB_bits*6)-1 downto 0) := x"FF00FF";
    constant red : std_logic_vector((RGB_bits*6)-1 downto 0) := x"FF0000";
    constant blue : std_logic_vector((RGB_bits*6)-1 downto 0) := x"0000FF";
    constant black : std_logic_vector((RGB_bits*6)-1 downto 0) := x"000000";

    type rgb_array is array (0 to num_colours-1) of std_logic_vector((RGB_bits*6)-1 downto 0);
    
    function test_pattern_ROM return rgb_array;
    -- function test_pattern_ROM(index : in integer) return std_logic_vector;

end package;

package body test_rom_package is

    function test_pattern_ROM return rgb_array is
        variable rgb_vals : rgb_array;
    begin
        rgb_vals := (white, yellow, cyan, green, pink, red, blue, black);
        return rgb_vals;
    end function;

    -- function test_pattern_ROM(index : in integer) return std_logic_vector is
    --     variable rgb_vals : std_logic_vector((RGB_bits*6)-1 downto 0);
    -- begin
    --     if index < x_active/num_colours then
    --         rgb_vals <= white;
    --         -- rgb_vals <= colours(0);
    --     elsif index < 2 * (x_active/num_colours) then
    --         rgb_vals <= colours(1);
    --     elsif index < 3 * (x_active/num_colours) then
    --         rgb_vals <= colours(2);
    --     elsif index < 4 * (x_active/num_colours) then
    --         rgb_vals <= colours(3);
    --     elsif index < 5 * (x_active/num_colours) then
    --         rgb_vals <= colours(4);
    --     elsif index < 6 * (x_active/num_colours) then
    --         rgb_vals <= colours(5);
    --     elsif index < 7 * (x_active/num_colours) then
    --         rgb_vals <= colours(6);
    --     else
    --         rgb_vals <= colours(7);
    --     end if;

    --     return rgb_vals;
    -- end function;

end package body;