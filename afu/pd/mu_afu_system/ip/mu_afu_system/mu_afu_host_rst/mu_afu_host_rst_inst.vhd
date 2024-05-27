	component mu_afu_host_rst is
		port (
			clk       : in  std_logic := 'X'; -- clk
			in_reset  : in  std_logic := 'X'; -- reset
			out_reset : out std_logic         -- reset
		);
	end component mu_afu_host_rst;

	u0 : component mu_afu_host_rst
		port map (
			clk       => CONNECTED_TO_clk,       --       clk.clk
			in_reset  => CONNECTED_TO_in_reset,  --  in_reset.reset
			out_reset => CONNECTED_TO_out_reset  -- out_reset.reset
		);

