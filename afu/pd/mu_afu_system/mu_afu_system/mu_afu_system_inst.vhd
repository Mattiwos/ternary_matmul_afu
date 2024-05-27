	component mu_afu_system is
		port (
			avmm_mmio_address             : in  std_logic_vector(47 downto 0)  := (others => 'X'); -- address
			avmm_mmio_writedata           : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- writedata
			avmm_mmio_byteenable          : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- byteenable
			avmm_mmio_write               : in  std_logic                      := 'X';             -- write
			avmm_mmio_read                : in  std_logic                      := 'X';             -- read
			avmm_mmio_readdata            : out std_logic_vector(63 downto 0);                     -- readdata
			avmm_mmio_readdatavalid       : out std_logic;                                         -- readdatavalid
			avmm_mmio_waitrequest         : out std_logic;                                         -- waitrequest
			avmm_mmio_burstcount          : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- burstcount
			ddr4a_host_waitrequest        : in  std_logic                      := 'X';             -- waitrequest
			ddr4a_host_readdata           : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			ddr4a_host_readdatavalid      : in  std_logic                      := 'X';             -- readdatavalid
			ddr4a_host_burstcount         : out std_logic_vector(2 downto 0);                      -- burstcount
			ddr4a_host_writedata          : out std_logic_vector(511 downto 0);                    -- writedata
			ddr4a_host_address            : out std_logic_vector(32 downto 0);                     -- address
			ddr4a_host_write              : out std_logic;                                         -- write
			ddr4a_host_read               : out std_logic;                                         -- read
			ddr4a_host_byteenable         : out std_logic_vector(63 downto 0);                     -- byteenable
			ddr4a_host_debugaccess        : out std_logic;                                         -- debugaccess
			dma_clk_clk                   : in  std_logic                      := 'X';             -- clk
			host_read_address             : out std_logic_vector(47 downto 0);                     -- address
			host_read_byteenable          : out std_logic_vector(63 downto 0);                     -- byteenable
			host_read_burstcount          : out std_logic_vector(2 downto 0);                      -- burstcount
			host_read_read                : out std_logic;                                         -- read
			host_read_readdata            : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			host_read_readdatavalid       : in  std_logic                      := 'X';             -- readdatavalid
			host_read_waitrequest         : in  std_logic                      := 'X';             -- waitrequest
			host_write_address            : out std_logic_vector(47 downto 0);                     -- address
			host_write_writedata          : out std_logic_vector(511 downto 0);                    -- writedata
			host_write_byteenable         : out std_logic_vector(63 downto 0);                     -- byteenable
			host_write_burstcount         : out std_logic_vector(2 downto 0);                      -- burstcount
			host_write_write              : out std_logic;                                         -- write
			host_write_response           : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- response
			host_write_writeresponsevalid : in  std_logic                      := 'X';             -- writeresponsevalid
			host_write_waitrequest        : in  std_logic                      := 'X';             -- waitrequest
			host_reset_reset              : in  std_logic                      := 'X';             -- reset
			mu_clk_clk                    : in  std_logic                      := 'X'              -- clk
		);
	end component mu_afu_system;

	u0 : component mu_afu_system
		port map (
			avmm_mmio_address             => CONNECTED_TO_avmm_mmio_address,             --  avmm_mmio.address
			avmm_mmio_writedata           => CONNECTED_TO_avmm_mmio_writedata,           --           .writedata
			avmm_mmio_byteenable          => CONNECTED_TO_avmm_mmio_byteenable,          --           .byteenable
			avmm_mmio_write               => CONNECTED_TO_avmm_mmio_write,               --           .write
			avmm_mmio_read                => CONNECTED_TO_avmm_mmio_read,                --           .read
			avmm_mmio_readdata            => CONNECTED_TO_avmm_mmio_readdata,            --           .readdata
			avmm_mmio_readdatavalid       => CONNECTED_TO_avmm_mmio_readdatavalid,       --           .readdatavalid
			avmm_mmio_waitrequest         => CONNECTED_TO_avmm_mmio_waitrequest,         --           .waitrequest
			avmm_mmio_burstcount          => CONNECTED_TO_avmm_mmio_burstcount,          --           .burstcount
			ddr4a_host_waitrequest        => CONNECTED_TO_ddr4a_host_waitrequest,        -- ddr4a_host.waitrequest
			ddr4a_host_readdata           => CONNECTED_TO_ddr4a_host_readdata,           --           .readdata
			ddr4a_host_readdatavalid      => CONNECTED_TO_ddr4a_host_readdatavalid,      --           .readdatavalid
			ddr4a_host_burstcount         => CONNECTED_TO_ddr4a_host_burstcount,         --           .burstcount
			ddr4a_host_writedata          => CONNECTED_TO_ddr4a_host_writedata,          --           .writedata
			ddr4a_host_address            => CONNECTED_TO_ddr4a_host_address,            --           .address
			ddr4a_host_write              => CONNECTED_TO_ddr4a_host_write,              --           .write
			ddr4a_host_read               => CONNECTED_TO_ddr4a_host_read,               --           .read
			ddr4a_host_byteenable         => CONNECTED_TO_ddr4a_host_byteenable,         --           .byteenable
			ddr4a_host_debugaccess        => CONNECTED_TO_ddr4a_host_debugaccess,        --           .debugaccess
			dma_clk_clk                   => CONNECTED_TO_dma_clk_clk,                   --    dma_clk.clk
			host_read_address             => CONNECTED_TO_host_read_address,             --  host_read.address
			host_read_byteenable          => CONNECTED_TO_host_read_byteenable,          --           .byteenable
			host_read_burstcount          => CONNECTED_TO_host_read_burstcount,          --           .burstcount
			host_read_read                => CONNECTED_TO_host_read_read,                --           .read
			host_read_readdata            => CONNECTED_TO_host_read_readdata,            --           .readdata
			host_read_readdatavalid       => CONNECTED_TO_host_read_readdatavalid,       --           .readdatavalid
			host_read_waitrequest         => CONNECTED_TO_host_read_waitrequest,         --           .waitrequest
			host_write_address            => CONNECTED_TO_host_write_address,            -- host_write.address
			host_write_writedata          => CONNECTED_TO_host_write_writedata,          --           .writedata
			host_write_byteenable         => CONNECTED_TO_host_write_byteenable,         --           .byteenable
			host_write_burstcount         => CONNECTED_TO_host_write_burstcount,         --           .burstcount
			host_write_write              => CONNECTED_TO_host_write_write,              --           .write
			host_write_response           => CONNECTED_TO_host_write_response,           --           .response
			host_write_writeresponsevalid => CONNECTED_TO_host_write_writeresponsevalid, --           .writeresponsevalid
			host_write_waitrequest        => CONNECTED_TO_host_write_waitrequest,        --           .waitrequest
			host_reset_reset              => CONNECTED_TO_host_reset_reset,              -- host_reset.reset
			mu_clk_clk                    => CONNECTED_TO_mu_clk_clk                     --     mu_clk.clk
		);

