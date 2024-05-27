	component matmul_afu_pgm_ram is
		port (
			address     : in  std_logic_vector(5 downto 0)  := (others => 'X'); -- address
			clken       : in  std_logic                     := 'X';             -- clken
			chipselect  : in  std_logic                     := 'X';             -- chipselect
			write       : in  std_logic                     := 'X';             -- write
			readdata    : out std_logic_vector(63 downto 0);                    -- readdata
			writedata   : in  std_logic_vector(63 downto 0) := (others => 'X'); -- writedata
			byteenable  : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- byteenable
			address2    : in  std_logic_vector(5 downto 0)  := (others => 'X'); -- address
			chipselect2 : in  std_logic                     := 'X';             -- chipselect
			clken2      : in  std_logic                     := 'X';             -- clken
			write2      : in  std_logic                     := 'X';             -- write
			readdata2   : out std_logic_vector(63 downto 0);                    -- readdata
			writedata2  : in  std_logic_vector(63 downto 0) := (others => 'X'); -- writedata
			byteenable2 : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- byteenable
			clk         : in  std_logic                     := 'X';             -- clk
			reset       : in  std_logic                     := 'X'              -- reset
		);
	end component matmul_afu_pgm_ram;

	u0 : component matmul_afu_pgm_ram
		port map (
			address     => CONNECTED_TO_address,     --     s1.address
			clken       => CONNECTED_TO_clken,       --       .clken
			chipselect  => CONNECTED_TO_chipselect,  --       .chipselect
			write       => CONNECTED_TO_write,       --       .write
			readdata    => CONNECTED_TO_readdata,    --       .readdata
			writedata   => CONNECTED_TO_writedata,   --       .writedata
			byteenable  => CONNECTED_TO_byteenable,  --       .byteenable
			address2    => CONNECTED_TO_address2,    --     s2.address
			chipselect2 => CONNECTED_TO_chipselect2, --       .chipselect
			clken2      => CONNECTED_TO_clken2,      --       .clken
			write2      => CONNECTED_TO_write2,      --       .write
			readdata2   => CONNECTED_TO_readdata2,   --       .readdata
			writedata2  => CONNECTED_TO_writedata2,  --       .writedata
			byteenable2 => CONNECTED_TO_byteenable2, --       .byteenable
			clk         => CONNECTED_TO_clk,         --   clk1.clk
			reset       => CONNECTED_TO_reset        -- reset1.reset
		);

