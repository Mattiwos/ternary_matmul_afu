	component msgdma_bbb_read_master is
		generic (
			DATA_WIDTH                : integer := 32;
			LENGTH_WIDTH              : integer := 32;
			FIFO_DEPTH                : integer := 32;
			STRIDE_ENABLE             : integer := 0;
			BURST_ENABLE              : integer := 0;
			PACKET_ENABLE             : integer := 0;
			ERROR_ENABLE              : integer := 0;
			ERROR_WIDTH               : integer := 8;
			CHANNEL_ENABLE            : integer := 0;
			CHANNEL_WIDTH             : integer := 8;
			BYTE_ENABLE_WIDTH         : integer := 4;
			BYTE_ENABLE_WIDTH_LOG2    : integer := 2;
			ADDRESS_WIDTH             : integer := 32;
			FIFO_DEPTH_LOG2           : integer := 5;
			SYMBOL_WIDTH              : integer := 8;
			NUMBER_OF_SYMBOLS         : integer := 4;
			NUMBER_OF_SYMBOLS_LOG2    : integer := 2;
			MAX_BURST_COUNT_WIDTH     : integer := 2;
			UNALIGNED_ACCESSES_ENABLE : integer := 0;
			ONLY_FULL_ACCESS_ENABLE   : integer := 0;
			BURST_WRAPPING_SUPPORT    : integer := 1;
			PROGRAMMABLE_BURST_ENABLE : integer := 0;
			MAX_BURST_COUNT           : integer := 2;
			FIFO_SPEED_OPTIMIZATION   : integer := 1;
			STRIDE_WIDTH              : integer := 1
		);
		port (
			clk                  : in  std_logic                      := 'X';             -- clk
			reset                : in  std_logic                      := 'X';             -- reset
			master_address       : out std_logic_vector(48 downto 0);                     -- address
			master_read          : out std_logic;                                         -- read
			master_byteenable    : out std_logic_vector(63 downto 0);                     -- byteenable
			master_readdata      : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			master_waitrequest   : in  std_logic                      := 'X';             -- waitrequest
			master_readdatavalid : in  std_logic                      := 'X';             -- readdatavalid
			master_burstcount    : out std_logic_vector(2 downto 0);                      -- burstcount
			src_data             : out std_logic_vector(511 downto 0);                    -- data
			src_valid            : out std_logic;                                         -- valid
			src_ready            : in  std_logic                      := 'X';             -- ready
			snk_command_data     : in  std_logic_vector(255 downto 0) := (others => 'X'); -- data
			snk_command_valid    : in  std_logic                      := 'X';             -- valid
			snk_command_ready    : out std_logic;                                         -- ready
			src_response_data    : out std_logic_vector(255 downto 0);                    -- data
			src_response_valid   : out std_logic;                                         -- valid
			src_response_ready   : in  std_logic                      := 'X'              -- ready
		);
	end component msgdma_bbb_read_master;

	u0 : component msgdma_bbb_read_master
		generic map (
			DATA_WIDTH                => INTEGER_VALUE_FOR_DATA_WIDTH,
			LENGTH_WIDTH              => INTEGER_VALUE_FOR_LENGTH_WIDTH,
			FIFO_DEPTH                => INTEGER_VALUE_FOR_FIFO_DEPTH,
			STRIDE_ENABLE             => INTEGER_VALUE_FOR_STRIDE_ENABLE,
			BURST_ENABLE              => INTEGER_VALUE_FOR_BURST_ENABLE,
			PACKET_ENABLE             => INTEGER_VALUE_FOR_PACKET_ENABLE,
			ERROR_ENABLE              => INTEGER_VALUE_FOR_ERROR_ENABLE,
			ERROR_WIDTH               => INTEGER_VALUE_FOR_ERROR_WIDTH,
			CHANNEL_ENABLE            => INTEGER_VALUE_FOR_CHANNEL_ENABLE,
			CHANNEL_WIDTH             => INTEGER_VALUE_FOR_CHANNEL_WIDTH,
			BYTE_ENABLE_WIDTH         => INTEGER_VALUE_FOR_BYTE_ENABLE_WIDTH,
			BYTE_ENABLE_WIDTH_LOG2    => INTEGER_VALUE_FOR_BYTE_ENABLE_WIDTH_LOG2,
			ADDRESS_WIDTH             => INTEGER_VALUE_FOR_ADDRESS_WIDTH,
			FIFO_DEPTH_LOG2           => INTEGER_VALUE_FOR_FIFO_DEPTH_LOG2,
			SYMBOL_WIDTH              => INTEGER_VALUE_FOR_SYMBOL_WIDTH,
			NUMBER_OF_SYMBOLS         => INTEGER_VALUE_FOR_NUMBER_OF_SYMBOLS,
			NUMBER_OF_SYMBOLS_LOG2    => INTEGER_VALUE_FOR_NUMBER_OF_SYMBOLS_LOG2,
			MAX_BURST_COUNT_WIDTH     => INTEGER_VALUE_FOR_MAX_BURST_COUNT_WIDTH,
			UNALIGNED_ACCESSES_ENABLE => INTEGER_VALUE_FOR_UNALIGNED_ACCESSES_ENABLE,
			ONLY_FULL_ACCESS_ENABLE   => INTEGER_VALUE_FOR_ONLY_FULL_ACCESS_ENABLE,
			BURST_WRAPPING_SUPPORT    => INTEGER_VALUE_FOR_BURST_WRAPPING_SUPPORT,
			PROGRAMMABLE_BURST_ENABLE => INTEGER_VALUE_FOR_PROGRAMMABLE_BURST_ENABLE,
			MAX_BURST_COUNT           => INTEGER_VALUE_FOR_MAX_BURST_COUNT,
			FIFO_SPEED_OPTIMIZATION   => INTEGER_VALUE_FOR_FIFO_SPEED_OPTIMIZATION,
			STRIDE_WIDTH              => INTEGER_VALUE_FOR_STRIDE_WIDTH
		)
		port map (
			clk                  => CONNECTED_TO_clk,                  --            Clock.clk
			reset                => CONNECTED_TO_reset,                --      Clock_reset.reset
			master_address       => CONNECTED_TO_master_address,       -- Data_Read_Master.address
			master_read          => CONNECTED_TO_master_read,          --                 .read
			master_byteenable    => CONNECTED_TO_master_byteenable,    --                 .byteenable
			master_readdata      => CONNECTED_TO_master_readdata,      --                 .readdata
			master_waitrequest   => CONNECTED_TO_master_waitrequest,   --                 .waitrequest
			master_readdatavalid => CONNECTED_TO_master_readdatavalid, --                 .readdatavalid
			master_burstcount    => CONNECTED_TO_master_burstcount,    --                 .burstcount
			src_data             => CONNECTED_TO_src_data,             --      Data_Source.data
			src_valid            => CONNECTED_TO_src_valid,            --                 .valid
			src_ready            => CONNECTED_TO_src_ready,            --                 .ready
			snk_command_data     => CONNECTED_TO_snk_command_data,     --     Command_Sink.data
			snk_command_valid    => CONNECTED_TO_snk_command_valid,    --                 .valid
			snk_command_ready    => CONNECTED_TO_snk_command_ready,    --                 .ready
			src_response_data    => CONNECTED_TO_src_response_data,    --  Response_Source.data
			src_response_valid   => CONNECTED_TO_src_response_valid,   --                 .valid
			src_response_ready   => CONNECTED_TO_src_response_ready    --                 .ready
		);

