library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Res_1080p_package is

    -- amt of r g and b bits recieved by VGA cord
    constant RGB_bits : integer := 4;

    constant x_active : integer := 1920;
    constant x_frontp : integer := 88;
    constant x_sync : integer := 44;
    constant x_backp : integer := 148;
    constant total_x : integer := 2200;

    constant y_active : integer := 1080;
    constant y_frontp : integer := 4;
    constant y_sync : integer := 5;
    constant y_backp : integer := 36;
    constant total_y : integer := 1125;

end package;