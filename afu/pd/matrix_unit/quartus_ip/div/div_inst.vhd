	component div is
		port (
			numer    : in  std_logic_vector(7 downto 0) := (others => 'X'); -- numer
			denom    : in  std_logic_vector(7 downto 0) := (others => 'X'); -- denom
			quotient : out std_logic_vector(7 downto 0);                    -- quotient
			remain   : out std_logic_vector(7 downto 0)                     -- remain
		);
	end component div;

	u0 : component div
		port map (
			numer    => CONNECTED_TO_numer,    --  lpm_divide_input.numer
			denom    => CONNECTED_TO_denom,    --                  .denom
			quotient => CONNECTED_TO_quotient, -- lpm_divide_output.quotient
			remain   => CONNECTED_TO_remain    --                  .remain
		);

