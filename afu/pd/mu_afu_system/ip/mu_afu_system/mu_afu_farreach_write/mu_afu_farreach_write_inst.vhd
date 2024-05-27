	component mu_afu_farreach_write is
		port (
			s_clk                : in  std_logic                      := 'X';             -- clk
			reset                : in  std_logic                      := 'X';             -- reset
			s_address            : in  std_logic_vector(47 downto 0)  := (others => 'X'); -- address
			s_writedata          : in  std_logic_vector(511 downto 0) := (others => 'X'); -- writedata
			s_byteenable         : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- byteenable
			s_write              : in  std_logic                      := 'X';             -- write
			s_response           : out std_logic_vector(1 downto 0);                      -- response
			s_writeresponsevalid : out std_logic;                                         -- writeresponsevalid
			s_waitrequest        : out std_logic;                                         -- waitrequest
			s_burst              : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- burstcount
			m_address            : out std_logic_vector(47 downto 0);                     -- address
			m_writedata          : out std_logic_vector(511 downto 0);                    -- writedata
			m_byteenable         : out std_logic_vector(63 downto 0);                     -- byteenable
			m_burst              : out std_logic_vector(2 downto 0);                      -- burstcount
			m_write              : out std_logic;                                         -- write
			m_response           : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- response
			m_writeresponsevalid : in  std_logic                      := 'X';             -- writeresponsevalid
			m_waitrequest        : in  std_logic                      := 'X'              -- waitrequest
		);
	end component mu_afu_farreach_write;

	u0 : component mu_afu_farreach_write
		port map (
			s_clk                => CONNECTED_TO_s_clk,                --    clk.clk
			reset                => CONNECTED_TO_reset,                --  reset.reset
			s_address            => CONNECTED_TO_s_address,            --  slave.address
			s_writedata          => CONNECTED_TO_s_writedata,          --       .writedata
			s_byteenable         => CONNECTED_TO_s_byteenable,         --       .byteenable
			s_write              => CONNECTED_TO_s_write,              --       .write
			s_response           => CONNECTED_TO_s_response,           --       .response
			s_writeresponsevalid => CONNECTED_TO_s_writeresponsevalid, --       .writeresponsevalid
			s_waitrequest        => CONNECTED_TO_s_waitrequest,        --       .waitrequest
			s_burst              => CONNECTED_TO_s_burst,              --       .burstcount
			m_address            => CONNECTED_TO_m_address,            -- master.address
			m_writedata          => CONNECTED_TO_m_writedata,          --       .writedata
			m_byteenable         => CONNECTED_TO_m_byteenable,         --       .byteenable
			m_burst              => CONNECTED_TO_m_burst,              --       .burstcount
			m_write              => CONNECTED_TO_m_write,              --       .write
			m_response           => CONNECTED_TO_m_response,           --       .response
			m_writeresponsevalid => CONNECTED_TO_m_writeresponsevalid, --       .writeresponsevalid
			m_waitrequest        => CONNECTED_TO_m_waitrequest         --       .waitrequest
		);

