	component mu_afu_matrix_unit is
		port (
			avmm_a_csr_address_i       : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- address
			avmm_a_csr_chipselect_i    : in  std_logic                     := 'X';             -- chipselect
			avmm_a_csr_write_i         : in  std_logic                     := 'X';             -- write
			avmm_a_csr_writedata_i     : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			avmm_a_csr_readdata_o      : out std_logic_vector(31 downto 0);                    -- readdata
			clk_i                      : in  std_logic                     := 'X';             -- clk
			rst_n_i                    : in  std_logic                     := 'X';             -- reset_n
			avmm_h_ddr_readdata_i      : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- readdata
			avmm_h_ddr_readdatavalid_i : in  std_logic                     := 'X';             -- readdatavalid
			avmm_h_ddr_waitreq_i       : in  std_logic                     := 'X';             -- waitrequest
			avmm_h_ddr_writedata_o     : out std_logic_vector(7 downto 0);                     -- writedata
			avmm_h_ddr_address_o       : out std_logic_vector(32 downto 0);                    -- address
			avmm_h_ddr_write_o         : out std_logic;                                        -- write
			avmm_h_ddr_read_o          : out std_logic;                                        -- read
			avmm_h_imem_address_o      : out std_logic_vector(5 downto 0);                     -- address
			avmm_h_imem_chipselect_o   : out std_logic;                                        -- chipselect
			avmm_h_imem_write_o        : out std_logic;                                        -- write
			avmm_h_imem_writedata_o    : out std_logic_vector(63 downto 0);                    -- writedata
			avmm_h_imem_readdata_i     : in  std_logic_vector(63 downto 0) := (others => 'X')  -- readdata
		);
	end component mu_afu_matrix_unit;

	u0 : component mu_afu_matrix_unit
		port map (
			avmm_a_csr_address_i       => CONNECTED_TO_avmm_a_csr_address_i,       --    avmm_a_csr.address
			avmm_a_csr_chipselect_i    => CONNECTED_TO_avmm_a_csr_chipselect_i,    --              .chipselect
			avmm_a_csr_write_i         => CONNECTED_TO_avmm_a_csr_write_i,         --              .write
			avmm_a_csr_writedata_i     => CONNECTED_TO_avmm_a_csr_writedata_i,     --              .writedata
			avmm_a_csr_readdata_o      => CONNECTED_TO_avmm_a_csr_readdata_o,      --              .readdata
			clk_i                      => CONNECTED_TO_clk_i,                      --    user_clock.clk
			rst_n_i                    => CONNECTED_TO_rst_n_i,                    --       reset_n.reset_n
			avmm_h_ddr_readdata_i      => CONNECTED_TO_avmm_h_ddr_readdata_i,      --    avmm_h_ddr.readdata
			avmm_h_ddr_readdatavalid_i => CONNECTED_TO_avmm_h_ddr_readdatavalid_i, --              .readdatavalid
			avmm_h_ddr_waitreq_i       => CONNECTED_TO_avmm_h_ddr_waitreq_i,       --              .waitrequest
			avmm_h_ddr_writedata_o     => CONNECTED_TO_avmm_h_ddr_writedata_o,     --              .writedata
			avmm_h_ddr_address_o       => CONNECTED_TO_avmm_h_ddr_address_o,       --              .address
			avmm_h_ddr_write_o         => CONNECTED_TO_avmm_h_ddr_write_o,         --              .write
			avmm_h_ddr_read_o          => CONNECTED_TO_avmm_h_ddr_read_o,          --              .read
			avmm_h_imem_address_o      => CONNECTED_TO_avmm_h_imem_address_o,      -- avalon_a_imem.address
			avmm_h_imem_chipselect_o   => CONNECTED_TO_avmm_h_imem_chipselect_o,   --              .chipselect
			avmm_h_imem_write_o        => CONNECTED_TO_avmm_h_imem_write_o,        --              .write
			avmm_h_imem_writedata_o    => CONNECTED_TO_avmm_h_imem_writedata_o,    --              .writedata
			avmm_h_imem_readdata_i     => CONNECTED_TO_avmm_h_imem_readdata_i      --              .readdata
		);

