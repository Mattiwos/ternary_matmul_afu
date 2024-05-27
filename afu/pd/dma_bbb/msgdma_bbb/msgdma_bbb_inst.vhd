	component msgdma_bbb is
		port (
			clk_clk                       : in  std_logic                      := 'X';             -- clk
			csr_address                   : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- address
			csr_writedata                 : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- writedata
			csr_byteenable                : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- byteenable
			csr_write                     : in  std_logic                      := 'X';             -- write
			csr_read                      : in  std_logic                      := 'X';             -- read
			csr_readdata                  : out std_logic_vector(63 downto 0);                     -- readdata
			csr_readdatavalid             : out std_logic;                                         -- readdatavalid
			csr_waitrequest               : out std_logic;                                         -- waitrequest
			csr_burstcount                : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- burstcount
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
			mem_read_write_address        : out std_logic_vector(47 downto 0);                     -- address
			mem_read_write_writedata      : out std_logic_vector(511 downto 0);                    -- writedata
			mem_read_write_byteenable     : out std_logic_vector(63 downto 0);                     -- byteenable
			mem_read_write_burstcount     : out std_logic_vector(2 downto 0);                      -- burstcount
			mem_read_write_write          : out std_logic;                                         -- write
			mem_read_write_read           : out std_logic;                                         -- read
			mem_read_write_readdata       : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			mem_read_write_readdatavalid  : in  std_logic                      := 'X';             -- readdatavalid
			mem_read_write_waitrequest    : in  std_logic                      := 'X';             -- waitrequest
			reset_reset                   : in  std_logic                      := 'X'              -- reset
		);
	end component msgdma_bbb;

	u0 : component msgdma_bbb
		port map (
			clk_clk                       => CONNECTED_TO_clk_clk,                       --            clk.clk
			csr_address                   => CONNECTED_TO_csr_address,                   --            csr.address
			csr_writedata                 => CONNECTED_TO_csr_writedata,                 --               .writedata
			csr_byteenable                => CONNECTED_TO_csr_byteenable,                --               .byteenable
			csr_write                     => CONNECTED_TO_csr_write,                     --               .write
			csr_read                      => CONNECTED_TO_csr_read,                      --               .read
			csr_readdata                  => CONNECTED_TO_csr_readdata,                  --               .readdata
			csr_readdatavalid             => CONNECTED_TO_csr_readdatavalid,             --               .readdatavalid
			csr_waitrequest               => CONNECTED_TO_csr_waitrequest,               --               .waitrequest
			csr_burstcount                => CONNECTED_TO_csr_burstcount,                --               .burstcount
			host_read_address             => CONNECTED_TO_host_read_address,             --      host_read.address
			host_read_byteenable          => CONNECTED_TO_host_read_byteenable,          --               .byteenable
			host_read_burstcount          => CONNECTED_TO_host_read_burstcount,          --               .burstcount
			host_read_read                => CONNECTED_TO_host_read_read,                --               .read
			host_read_readdata            => CONNECTED_TO_host_read_readdata,            --               .readdata
			host_read_readdatavalid       => CONNECTED_TO_host_read_readdatavalid,       --               .readdatavalid
			host_read_waitrequest         => CONNECTED_TO_host_read_waitrequest,         --               .waitrequest
			host_write_address            => CONNECTED_TO_host_write_address,            --     host_write.address
			host_write_writedata          => CONNECTED_TO_host_write_writedata,          --               .writedata
			host_write_byteenable         => CONNECTED_TO_host_write_byteenable,         --               .byteenable
			host_write_burstcount         => CONNECTED_TO_host_write_burstcount,         --               .burstcount
			host_write_write              => CONNECTED_TO_host_write_write,              --               .write
			host_write_response           => CONNECTED_TO_host_write_response,           --               .response
			host_write_writeresponsevalid => CONNECTED_TO_host_write_writeresponsevalid, --               .writeresponsevalid
			host_write_waitrequest        => CONNECTED_TO_host_write_waitrequest,        --               .waitrequest
			mem_read_write_address        => CONNECTED_TO_mem_read_write_address,        -- mem_read_write.address
			mem_read_write_writedata      => CONNECTED_TO_mem_read_write_writedata,      --               .writedata
			mem_read_write_byteenable     => CONNECTED_TO_mem_read_write_byteenable,     --               .byteenable
			mem_read_write_burstcount     => CONNECTED_TO_mem_read_write_burstcount,     --               .burstcount
			mem_read_write_write          => CONNECTED_TO_mem_read_write_write,          --               .write
			mem_read_write_read           => CONNECTED_TO_mem_read_write_read,           --               .read
			mem_read_write_readdata       => CONNECTED_TO_mem_read_write_readdata,       --               .readdata
			mem_read_write_readdatavalid  => CONNECTED_TO_mem_read_write_readdatavalid,  --               .readdatavalid
			mem_read_write_waitrequest    => CONNECTED_TO_mem_read_write_waitrequest,    --               .waitrequest
			reset_reset                   => CONNECTED_TO_reset_reset                    --          reset.reset
		);

