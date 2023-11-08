--------------------------------------------------------------------------------
-- RELOGIO DE XADREZ
-- Author - Fernando Moraes - 25/out/2023
-- Revision - Iaçanã Ianiski Weber - 30/out/2023
--------------------------------------------------------------------------------
library IEEE;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library work;

entity relogio_xadrez is
    port( 
        init_time: in std_logic_vector(7 downto 0);
        contj1, contj2: out std_logic_vector(15 downto 0);
        j1, j2, load, clock, reset: in std_logic;
        winJ1, winJ2: out std_logic := '0'
    );
end relogio_xadrez;

architecture relogio_xadrez of relogio_xadrez is
    -- DECLARACAO DOS ESTADOS
    type states is ( S_IDLE, S_LOAD, START, S_J1, S_J2, S_WINJ1, S_WINJ2);
    signal EA, PE : states;
    -- ADICIONE AQUI OS SINAIS INTERNOS NECESSARIOS
    signal cont1, cont2: std_logic_vector(15 downto 0);
    signal enable_c1, enable_c2 : std_logic;
    
    begin

    -- INSTANCIACAO DOS CONTADORES
    contador1 : entity work.temporizador port map ( clock => clock, reset => reset, load => load, en => enable_c1,
                                                    init_time => init_time, cont => cont1);
    contador2 : entity work.temporizador port map ( clock => clock, reset => reset, load => load, en => enable_c2,
                                                    init_time => init_time, cont => cont2);

    -- PROCESSO DE TROCA DE ESTADOS
    process (clock, reset)
    begin
        
    if (reset = '1') then
        EA <= S_IDLE;
    elsif (rising_edge(clock)) then
        EA <= PE;
    end if;

    end process;

    -- PROCESSO PARA DEFINIR O PROXIMO ESTADO
    process (EA, load, j1, j2, cont1, cont2 ) --<<< Nao esqueca de adicionar os sinais da lista de sensitividade
    begin
        case EA is
            
            when S_IDLE =>
                if (load = '1') then
                    PE <= S_LOAD;
                else PE <= S_IDLE;
                end if;
            
            when S_LOAD => PE <= START;

            when START =>
                if (j1 = '1') then
                    PE <= S_J1;
                elsif (j2 = '1') then
                    PE <= S_J2;
                else PE <= START;
                end if;
            
            when S_J1 =>
                if(cont1 = "00000000000000000000") then
                    PE <= S_WINJ2;
                elsif (j1 = '1') then
                    PE <= S_J2;
                else PE <= S_J1;
                end if;

            when S_J2 =>
                if(cont2 = "00000000000000000000") then
                    PE <= S_WINJ1;
                elsif (j2 = '1') then
                    PE <= S_J1;
                else PE <= S_J2;
                end if;
            when S_WINJ1 => PE <= S_IDLE;
            when S_WINJ2 => PE <= S_IDLE;
            
        end case;
    end process;

    
    -- ATRIBUICAO COMBINACIONAL DOS SINAIS INTERNOS E SAIDAS - Dica: faca uma maquina de Moore, desta forma os sinais dependem apenas do estado atual!!
    contj1 <= cont1;
    contj2 <= cont2;
    enable_c1 <= '1' when EA = S_J1 else '0';
    enable_c2 <= '1' when EA = S_J2 else '0';
    winJ1 <= '1' when EA = S_WINJ1 else '0';
    winJ2 <= '1' when EA = S_WINJ2 else '0';

end relogio_xadrez;


