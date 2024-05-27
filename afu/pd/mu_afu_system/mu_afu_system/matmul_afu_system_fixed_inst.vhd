	component matmul_afu_system_fixed is
		port (
			avmm_mmio_address                : in  std_logic_vector(47 downto 0)  := (others => 'X'); -- address
			avmm_mmio_writedata              : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- writedata
			avmm_mmio_byteenable             : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- byteenable
			avmm_mmio_write                  : in  std_logic                      := 'X';             -- write
			avmm_mmio_read                   : in  std_logic                      := 'X';             -- read
			avmm_mmio_readdata               : out std_logic_vector(63 downto 0);                     -- readdata
			avmm_mmio_readdatavalid          : out std_logic;                                         -- readdatavalid
			avmm_mmio_waitrequest            : out std_logic;                                         -- waitrequest
			avmm_mmio_burstcount             : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- burstcount
			ddr4a_master_dma_waitrequest     : in  std_logic                      := 'X';             -- waitrequest
			ddr4a_master_dma_readdata        : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			ddr4a_master_dma_readdatavalid   : in  std_logic                      := 'X';             -- readdatavalid
			ddr4a_master_dma_burstcount      : out std_logic_vector(2 downto 0);                      -- burstcount
			ddr4a_master_dma_writedata       : out std_logic_vector(511 downto 0);                    -- writedata
			ddr4a_master_dma_address         : out std_logic_vector(32 downto 0);                     -- address
			ddr4a_master_dma_write           : out std_logic;                                         -- write
			ddr4a_master_dma_read            : out std_logic;                                         -- read
			ddr4a_master_dma_byteenable      : out std_logic_vector(63 downto 0);                     -- byteenable
			ddr4a_master_dma_debugaccess     : out std_logic;                                         -- debugaccess
			dma_clk_clk                      : in  std_logic                      := 'X';             -- clk
			dma_reset_reset                  : in  std_logic                      := 'X';             -- reset
			host_read_address                : out std_logic_vector(47 downto 0);                     -- address
			host_read_byteenable             : out std_logic_vector(63 downto 0);                     -- byteenable
			host_read_burstcount             : out std_logic_vector(2 downto 0);                      -- burstcount
			host_read_read                   : out std_logic;                                         -- read
			host_read_readdata               : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			host_read_readdatavalid          : in  std_logic                      := 'X';             -- readdatavalid
			host_read_waitrequest            : in  std_logic                      := 'X';             -- waitrequest
			host_write_address               : out std_logic_vector(47 downto 0);                     -- address
			host_write_writedata             : out std_logic_vector(511 downto 0);                    -- writedata
			host_write_byteenable            : out std_logic_vector(63 downto 0);                     -- byteenable
			host_write_burstcount            : out std_logic_vector(2 downto 0);                      -- burstcount
			host_write_write                 : out std_logic;                                         -- write
			host_write_response              : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- response
			host_write_writeresponsevalid    : in  std_logic                      := 'X';             -- writeresponsevalid
			host_write_waitrequest           : in  std_logic                      := 'X';             -- waitrequest
			matmul_clk_clk                   : in  std_logic                      := 'X';             -- clk
			ddr4a_slave_matmul_waitrequest   : out std_logic;                                         -- waitrequest
			ddr4a_slave_matmul_readdata      : out std_logic_vector(7 downto 0);                      -- readdata
			ddr4a_slave_matmul_readdatavalid : out std_logic;                                         -- readdatavalid
			ddr4a_slave_matmul_burstcount    : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- burstcount
			ddr4a_slave_matmul_writedata     : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- writedata
			ddr4a_slave_matmul_address       : in  std_logic_vector(32 downto 0)  := (others => 'X'); -- address
			ddr4a_slave_matmul_write         : in  std_logic                      := 'X';             -- write
			ddr4a_slave_matmul_read          : in  std_logic                      := 'X';             -- read
			ddr4a_slave_matmul_byteenable    : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- byteenable
			ddr4a_slave_matmul_debugaccess   : in  std_logic                      := 'X';             -- debugaccess
			matmul_ready_export              : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- export
			matmul_reset_reset               : out std_logic;                                         -- reset
			matmul_pgm_ram_address           : in  std_logic_vector(5 downto 0)   := (others => 'X'); -- address
			matmul_pgm_ram_chipselect        : in  std_logic                      := 'X';             -- chipselect
			matmul_pgm_ram_clken             : in  std_logic                      := 'X';             -- clken
			matmul_pgm_ram_write             : in  std_logic                      := 'X';             -- write
			matmul_pgm_ram_readdata          : out std_logic_vector(63 downto 0);                     -- readdata
			matmul_pgm_ram_writedata         : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- writedata
			matmul_pgm_ram_byteenable        : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- byteenable
			matmul_start_export              : out std_logic_vector(31 downto 0)                      -- export
		);
	end component matmul_afu_system_fixed;

	u0 : component matmul_afu_system_fixed
		port map (
			avmm_mmio_address                => CONNECTED_TO_avmm_mmio_address,                --          avmm_mmio.address
			avmm_mmio_writedata              => CONNECTED_TO_avmm_mmio_writedata,              --                   .writedata
			avmm_mmio_byteenable             => CONNECTED_TO_avmm_mmio_byteenable,             --                   .byteenable
			avmm_mmio_write                  => CONNECTED_TO_avmm_mmio_write,                  --                   .write
			avmm_mmio_read                   => CONNECTED_TO_avmm_mmio_read,                   --                   .read
			avmm_mmio_readdata               => CONNECTED_TO_avmm_mmio_readdata,               --                   .readdata
			avmm_mmio_readdatavalid          => CONNECTED_TO_avmm_mmio_readdatavalid,          --                   .readdatavalid
			avmm_mmio_waitrequest            => CONNECTED_TO_avmm_mmio_waitrequest,            --                   .waitrequest
			avmm_mmio_burstcount             => CONNECTED_TO_avmm_mmio_burstcount,             --                   .burstcount
			ddr4a_master_dma_waitrequest     => CONNECTED_TO_ddr4a_master_dma_waitrequest,     --   ddr4a_master_dma.waitrequest
			ddr4a_master_dma_readdata        => CONNECTED_TO_ddr4a_master_dma_readdata,        --                   .readdata
			ddr4a_master_dma_readdatavalid   => CONNECTED_TO_ddr4a_master_dma_readdatavalid,   --                   .readdatavalid
			ddr4a_master_dma_burstcount      => CONNECTED_TO_ddr4a_master_dma_burstcount,      --                   .burstcount
			ddr4a_master_dma_writedata       => CONNECTED_TO_ddr4a_master_dma_writedata,       --                   .writedata
			ddr4a_master_dma_address         => CONNECTED_TO_ddr4a_master_dma_address,         --                   .address
			ddr4a_master_dma_write           => CONNECTED_TO_ddr4a_master_dma_write,           --                   .write
			ddr4a_master_dma_read            => CONNECTED_TO_ddr4a_master_dma_read,            --                   .read
			ddr4a_master_dma_byteenable      => CONNECTED_TO_ddr4a_master_dma_byteenable,      --                   .byteenable
			ddr4a_master_dma_debugaccess     => CONNECTED_TO_ddr4a_master_dma_debugaccess,     --                   .debugaccess
			dma_clk_clk                      => CONNECTED_TO_dma_clk_clk,                      --            dma_clk.clk
			dma_reset_reset                  => CONNECTED_TO_dma_reset_reset,                  --          dma_reset.reset
			host_read_address                => CONNECTED_TO_host_read_address,                --          host_read.address
			host_read_byteenable             => CONNECTED_TO_host_read_byteenable,             --                   .byteenable
			host_read_burstcount             => CONNECTED_TO_host_read_burstcount,             --                   .burstcount
			host_read_read                   => CONNECTED_TO_host_read_read,                   --                   .read
			host_read_readdata               => CONNECTED_TO_host_read_readdata,               --                   .readdata
			host_read_readdatavalid          => CONNECTED_TO_host_read_readdatavalid,          --                   .readdatavalid
			host_read_waitrequest            => CONNECTED_TO_host_read_waitrequest,            --                   .waitrequest
			host_write_address               => CONNECTED_TO_host_write_address,               --         host_write.address
			host_write_writedata             => CONNECTED_TO_host_write_writedata,             --                   .writedata
			host_write_byteenable            => CONNECTED_TO_host_write_byteenable,            --                   .byteenable
			host_write_burstcount            => CONNECTED_TO_host_write_burstcount,            --                   .burstcount
			host_write_write                 => CONNECTED_TO_host_write_write,                 --                   .write
			host_write_response              => CONNECTED_TO_host_write_response,              --                   .response
			host_write_writeresponsevalid    => CONNECTED_TO_host_write_writeresponsevalid,    --                   .writeresponsevalid
			host_write_waitrequest           => CONNECTED_TO_host_write_waitrequest,           --                   .waitrequest
			matmul_clk_clk                   => CONNECTED_TO_matmul_clk_clk,                   --         matmul_clk.clk
			ddr4a_slave_matmul_waitrequest   => CONNECTED_TO_ddr4a_slave_matmul_waitrequest,   -- ddr4a_slave_matmul.waitrequest
			ddr4a_slave_matmul_readdata      => CONNECTED_TO_ddr4a_slave_matmul_readdata,      --                   .readdata
			ddr4a_slave_matmul_readdatavalid => CONNECTED_TO_ddr4a_slave_matmul_readdatavalid, --                   .readdatavalid
			ddr4a_slave_matmul_burstcount    => CONNECTED_TO_ddr4a_slave_matmul_burstcount,    --                   .burstcount
			ddr4a_slave_matmul_writedata     => CONNECTED_TO_ddr4a_slave_matmul_writedata,     --                   .writedata
			ddr4a_slave_matmul_address       => CONNECTED_TO_ddr4a_slave_matmul_address,       --                   .address
			ddr4a_slave_matmul_write         => CONNECTED_TO_ddr4a_slave_matmul_write,         --                   .write
			ddr4a_slave_matmul_read          => CONNECTED_TO_ddr4a_slave_matmul_read,          --                   .read
			ddr4a_slave_matmul_byteenable    => CONNECTED_TO_ddr4a_slave_matmul_byteenable,    --                   .byteenable
			ddr4a_slave_matmul_debugaccess   => CONNECTED_TO_ddr4a_slave_matmul_debugaccess,   --                   .debugaccess
			matmul_ready_export              => CONNECTED_TO_matmul_ready_export,              --       matmul_ready.export
			matmul_reset_reset               => CONNECTED_TO_matmul_reset_reset,               --       matmul_reset.reset
			matmul_pgm_ram_address           => CONNECTED_TO_matmul_pgm_ram_address,           --     matmul_pgm_ram.address
			matmul_pgm_ram_chipselect        => CONNECTED_TO_matmul_pgm_ram_chipselect,        --                   .chipselect
			matmul_pgm_ram_clken             => CONNECTED_TO_matmul_pgm_ram_clken,             --                   .clken
			matmul_pgm_ram_write             => CONNECTED_TO_matmul_pgm_ram_write,             --                   .write
			matmul_pgm_ram_readdata          => CONNECTED_TO_matmul_pgm_ram_readdata,          --                   .readdata
			matmul_pgm_ram_writedata         => CONNECTED_TO_matmul_pgm_ram_writedata,         --                   .writedata
			matmul_pgm_ram_byteenable        => CONNECTED_TO_matmul_pgm_ram_byteenable,        --                   .byteenable
			matmul_start_export              => CONNECTED_TO_matmul_start_export               --       matmul_start.export
		);

