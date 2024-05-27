	component msgdma_bbb_mem_bridge is
		port (
			s_clk           : in  std_logic                      := 'X';             -- clk
			reset           : in  std_logic                      := 'X';             -- reset
			s_address       : in  std_logic_vector(47 downto 0)  := (others => 'X'); -- address
			s_writedata     : in  std_logic_vector(511 downto 0) := (others => 'X'); -- writedata
			s_byteenable    : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- byteenable
			s_write         : in  std_logic                      := 'X';             -- write
			s_read          : in  std_logic                      := 'X';             -- read
			s_readdata      : out std_logic_vector(511 downto 0);                    -- readdata
			s_readdatavalid : out std_logic;                                         -- readdatavalid
			s_waitrequest   : out std_logic;                                         -- waitrequest
			s_burst         : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- burstcount
			m_address       : out std_logic_vector(47 downto 0);                     -- address
			m_writedata     : out std_logic_vector(511 downto 0);                    -- writedata
			m_byteenable    : out std_logic_vector(63 downto 0);                     -- byteenable
			m_burst         : out std_logic_vector(2 downto 0);                      -- burstcount
			m_write         : out std_logic;                                         -- write
			m_read          : out std_logic;                                         -- read
			m_readdata      : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			m_readdatavalid : in  std_logic                      := 'X';             -- readdatavalid
			m_waitrequest   : in  std_logic                      := 'X'              -- waitrequest
		);
	end component msgdma_bbb_mem_bridge;

	u0 : component msgdma_bbb_mem_bridge
		port map (
			s_clk           => CONNECTED_TO_s_clk,           --    clk.clk
			reset           => CONNECTED_TO_reset,           --  reset.reset
			s_address       => CONNECTED_TO_s_address,       --  slave.address
			s_writedata     => CONNECTED_TO_s_writedata,     --       .writedata
			s_byteenable    => CONNECTED_TO_s_byteenable,    --       .byteenable
			s_write         => CONNECTED_TO_s_write,         --       .write
			s_read          => CONNECTED_TO_s_read,          --       .read
			s_readdata      => CONNECTED_TO_s_readdata,      --       .readdata
			s_readdatavalid => CONNECTED_TO_s_readdatavalid, --       .readdatavalid
			s_waitrequest   => CONNECTED_TO_s_waitrequest,   --       .waitrequest
			s_burst         => CONNECTED_TO_s_burst,         --       .burstcount
			m_address       => CONNECTED_TO_m_address,       -- master.address
			m_writedata     => CONNECTED_TO_m_writedata,     --       .writedata
			m_byteenable    => CONNECTED_TO_m_byteenable,    --       .byteenable
			m_burst         => CONNECTED_TO_m_burst,         --       .burstcount
			m_write         => CONNECTED_TO_m_write,         --       .write
			m_read          => CONNECTED_TO_m_read,          --       .read
			m_readdata      => CONNECTED_TO_m_readdata,      --       .readdata
			m_readdatavalid => CONNECTED_TO_m_readdatavalid, --       .readdatavalid
			m_waitrequest   => CONNECTED_TO_m_waitrequest    --       .waitrequest
		);

