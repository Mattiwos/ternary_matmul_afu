	component msgdma_bbb_dispatcher is
		port (
			clk                    : in  std_logic                      := 'X';             -- clk
			reset                  : in  std_logic                      := 'X';             -- reset
			csr_writedata          : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- writedata
			csr_write              : in  std_logic                      := 'X';             -- write
			csr_byteenable         : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- byteenable
			csr_readdata           : out std_logic_vector(31 downto 0);                     -- readdata
			csr_read               : in  std_logic                      := 'X';             -- read
			csr_address            : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- address
			src_response_data      : out std_logic_vector(255 downto 0);                    -- data
			src_response_valid     : out std_logic;                                         -- valid
			src_response_ready     : in  std_logic                      := 'X';             -- ready
			snk_descriptor_data    : in  std_logic_vector(255 downto 0) := (others => 'X'); -- data
			snk_descriptor_valid   : in  std_logic                      := 'X';             -- valid
			snk_descriptor_ready   : out std_logic;                                         -- ready
			src_write_master_data  : out std_logic_vector(255 downto 0);                    -- data
			src_write_master_valid : out std_logic;                                         -- valid
			src_write_master_ready : in  std_logic                      := 'X';             -- ready
			snk_write_master_data  : in  std_logic_vector(255 downto 0) := (others => 'X'); -- data
			snk_write_master_valid : in  std_logic                      := 'X';             -- valid
			snk_write_master_ready : out std_logic;                                         -- ready
			src_read_master_data   : out std_logic_vector(255 downto 0);                    -- data
			src_read_master_valid  : out std_logic;                                         -- valid
			src_read_master_ready  : in  std_logic                      := 'X';             -- ready
			snk_read_master_data   : in  std_logic_vector(255 downto 0) := (others => 'X'); -- data
			snk_read_master_valid  : in  std_logic                      := 'X';             -- valid
			snk_read_master_ready  : out std_logic                                          -- ready
		);
	end component msgdma_bbb_dispatcher;

	u0 : component msgdma_bbb_dispatcher
		port map (
			clk                    => CONNECTED_TO_clk,                    --                clock.clk
			reset                  => CONNECTED_TO_reset,                  --          clock_reset.reset
			csr_writedata          => CONNECTED_TO_csr_writedata,          --                  CSR.writedata
			csr_write              => CONNECTED_TO_csr_write,              --                     .write
			csr_byteenable         => CONNECTED_TO_csr_byteenable,         --                     .byteenable
			csr_readdata           => CONNECTED_TO_csr_readdata,           --                     .readdata
			csr_read               => CONNECTED_TO_csr_read,               --                     .read
			csr_address            => CONNECTED_TO_csr_address,            --                     .address
			src_response_data      => CONNECTED_TO_src_response_data,      --      Response_Source.data
			src_response_valid     => CONNECTED_TO_src_response_valid,     --                     .valid
			src_response_ready     => CONNECTED_TO_src_response_ready,     --                     .ready
			snk_descriptor_data    => CONNECTED_TO_snk_descriptor_data,    --      Descriptor_Sink.data
			snk_descriptor_valid   => CONNECTED_TO_snk_descriptor_valid,   --                     .valid
			snk_descriptor_ready   => CONNECTED_TO_snk_descriptor_ready,   --                     .ready
			src_write_master_data  => CONNECTED_TO_src_write_master_data,  -- Write_Command_Source.data
			src_write_master_valid => CONNECTED_TO_src_write_master_valid, --                     .valid
			src_write_master_ready => CONNECTED_TO_src_write_master_ready, --                     .ready
			snk_write_master_data  => CONNECTED_TO_snk_write_master_data,  --  Write_Response_Sink.data
			snk_write_master_valid => CONNECTED_TO_snk_write_master_valid, --                     .valid
			snk_write_master_ready => CONNECTED_TO_snk_write_master_ready, --                     .ready
			src_read_master_data   => CONNECTED_TO_src_read_master_data,   --  Read_Command_Source.data
			src_read_master_valid  => CONNECTED_TO_src_read_master_valid,  --                     .valid
			src_read_master_ready  => CONNECTED_TO_src_read_master_ready,  --                     .ready
			snk_read_master_data   => CONNECTED_TO_snk_read_master_data,   --   Read_Response_Sink.data
			snk_read_master_valid  => CONNECTED_TO_snk_read_master_valid,  --                     .valid
			snk_read_master_ready  => CONNECTED_TO_snk_read_master_ready   --                     .ready
		);

