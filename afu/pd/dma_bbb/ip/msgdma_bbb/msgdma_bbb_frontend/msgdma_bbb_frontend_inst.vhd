	component msgdma_bbb_frontend is
		port (
			clk                   : in  std_logic                      := 'X';             -- clk
			reset                 : in  std_logic                      := 'X';             -- reset
			s_address             : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- address
			s_read                : in  std_logic                      := 'X';             -- read
			s_readdata            : out std_logic_vector(63 downto 0);                     -- readdata
			s_write               : in  std_logic                      := 'X';             -- write
			s_writedata           : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- writedata
			s_byteenable          : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- byteenable
			m_fetch_address       : out std_logic_vector(48 downto 0);                     -- address
			m_fetch_burst         : out std_logic_vector(2 downto 0);                      -- burstcount
			m_fetch_byteenable    : out std_logic_vector(63 downto 0);                     -- byteenable
			m_fetch_read          : out std_logic;                                         -- read
			m_fetch_readdata      : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			m_fetch_readdatavalid : in  std_logic                      := 'X';             -- readdatavalid
			m_fetch_waitrequest   : in  std_logic                      := 'X';             -- waitrequest
			m_store_address       : out std_logic_vector(48 downto 0);                     -- address
			m_store_burst         : out std_logic_vector(2 downto 0);                      -- burstcount
			m_store_byteenable    : out std_logic_vector(63 downto 0);                     -- byteenable
			m_store_waitrequest   : in  std_logic                      := 'X';             -- waitrequest
			m_store_write         : out std_logic;                                         -- write
			m_store_writedata     : out std_logic_vector(511 downto 0);                    -- writedata
			src_descriptor_data   : out std_logic_vector(255 downto 0);                    -- data
			src_descriptor_ready  : in  std_logic                      := 'X';             -- ready
			src_descriptor_valid  : out std_logic;                                         -- valid
			snk_response_data     : in  std_logic_vector(255 downto 0) := (others => 'X'); -- data
			snk_response_ready    : out std_logic;                                         -- ready
			snk_response_valid    : in  std_logic                      := 'X'              -- valid
		);
	end component msgdma_bbb_frontend;

	u0 : component msgdma_bbb_frontend
		port map (
			clk                   => CONNECTED_TO_clk,                   --                   clock.clk
			reset                 => CONNECTED_TO_reset,                 --                   reset.reset
			s_address             => CONNECTED_TO_s_address,             --               csr_slave.address
			s_read                => CONNECTED_TO_s_read,                --                        .read
			s_readdata            => CONNECTED_TO_s_readdata,            --                        .readdata
			s_write               => CONNECTED_TO_s_write,               --                        .write
			s_writedata           => CONNECTED_TO_s_writedata,           --                        .writedata
			s_byteenable          => CONNECTED_TO_s_byteenable,          --                        .byteenable
			m_fetch_address       => CONNECTED_TO_m_fetch_address,       -- descriptor_fetch_master.address
			m_fetch_burst         => CONNECTED_TO_m_fetch_burst,         --                        .burstcount
			m_fetch_byteenable    => CONNECTED_TO_m_fetch_byteenable,    --                        .byteenable
			m_fetch_read          => CONNECTED_TO_m_fetch_read,          --                        .read
			m_fetch_readdata      => CONNECTED_TO_m_fetch_readdata,      --                        .readdata
			m_fetch_readdatavalid => CONNECTED_TO_m_fetch_readdatavalid, --                        .readdatavalid
			m_fetch_waitrequest   => CONNECTED_TO_m_fetch_waitrequest,   --                        .waitrequest
			m_store_address       => CONNECTED_TO_m_store_address,       -- descriptor_store_master.address
			m_store_burst         => CONNECTED_TO_m_store_burst,         --                        .burstcount
			m_store_byteenable    => CONNECTED_TO_m_store_byteenable,    --                        .byteenable
			m_store_waitrequest   => CONNECTED_TO_m_store_waitrequest,   --                        .waitrequest
			m_store_write         => CONNECTED_TO_m_store_write,         --                        .write
			m_store_writedata     => CONNECTED_TO_m_store_writedata,     --                        .writedata
			src_descriptor_data   => CONNECTED_TO_src_descriptor_data,   --       descriptor_source.data
			src_descriptor_ready  => CONNECTED_TO_src_descriptor_ready,  --                        .ready
			src_descriptor_valid  => CONNECTED_TO_src_descriptor_valid,  --                        .valid
			snk_response_data     => CONNECTED_TO_snk_response_data,     --           response_sink.data
			snk_response_ready    => CONNECTED_TO_snk_response_ready,    --                        .ready
			snk_response_valid    => CONNECTED_TO_snk_response_valid     --                        .valid
		);

