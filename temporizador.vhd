--------------------------------------------------------------------------------
-- Temporizador decimal do cronometro de xadrez
-- Fernando Moraes - 25/out/2023
--------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
library work;

entity temporizador is
    port( clock, reset, load, en : in std_logic;
          init_time : in  std_logic_vector(7 downto 0);
          cont      : out std_logic_vector(15 downto 0)
      );
end temporizador;

architecture a1 of temporizador is
    signal segL, segH, minL, minH, zero, nove, seis : std_logic_vector(3 downto 0);
    signal en1, en2, en3, en4: std_logic;
begin
    zero <= "0000";
    nove <= "1001";
    seis <= "0101";
    en1 <= '1' when ((en = '1') and not(segL = "0000" and segH = "0000" and minL = "0000" and minH = "0000")) else '0';
    en2 <= '1' when ((en = '1' and en1 = '1') and (segL = "0000")) else '0';
    en3 <= '1' when ((en = '1' and en2 = '1') and (segH = "0000") and (segL = "0000")) else '0';
    en4 <= '1' when ((en = '1' and en3 = '1') and (minL = "0000") and (segH = "0000") and (segL = "0000")) else '0';

   sL : entity work.dec_counter port map ( clock => clock, reset => reset, load => load, en => en1,
                                           first_value => zero, limit => nove, cont => segL);

   sH : entity work.dec_counter port map ( clock => clock, reset => reset, load => load, en => en2, 
                                           first_value => zero, limit => seis, cont => segH );

   mL : entity work.dec_counter port map ( clock => clock, reset => reset, load => load, en => en3, 
                                           first_value => init_time(3 downto 0) , limit => nove, cont => minL );

   mH : entity work.dec_counter port map ( clock => clock, reset => reset, load => load, en => en4, 
                                           first_value => init_time(7 downto 4), limit => nove, cont => minH );
   
   cont <= minH & minL & segH & segL;
end a1;


