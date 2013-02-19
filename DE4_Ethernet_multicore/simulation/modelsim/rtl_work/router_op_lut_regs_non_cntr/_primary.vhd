library verilog;
use verilog.vl_types.all;
entity router_op_lut_regs_non_cntr is
    generic(
        NUM_QUEUES      : integer := 5;
        ARP_LUT_DEPTH_BITS: integer := 4;
        LPM_LUT_DEPTH_BITS: integer := 4;
        FILTER_DEPTH_BITS: integer := 4;
        UDP_REG_SRC_WIDTH: integer := 2
    );
    port(
        reg_req_in      : in     vl_logic;
        reg_ack_in      : in     vl_logic;
        reg_rd_wr_L_in  : in     vl_logic;
        reg_addr_in     : in     vl_logic_vector(22 downto 0);
        reg_data_in     : in     vl_logic_vector(31 downto 0);
        reg_src_in      : in     vl_logic_vector;
        reg_req_out     : out    vl_logic;
        reg_ack_out     : out    vl_logic;
        reg_rd_wr_L_out : out    vl_logic;
        reg_addr_out    : out    vl_logic_vector(22 downto 0);
        reg_data_out    : out    vl_logic_vector(31 downto 0);
        reg_src_out     : out    vl_logic_vector;
        lpm_rd_addr     : out    vl_logic_vector;
        lpm_rd_req      : out    vl_logic;
        lpm_rd_ip       : in     vl_logic_vector(31 downto 0);
        lpm_rd_mask     : in     vl_logic_vector(31 downto 0);
        lpm_rd_oq       : in     vl_logic_vector;
        lpm_rd_next_hop_ip: in     vl_logic_vector(31 downto 0);
        lpm_rd_ack      : in     vl_logic;
        lpm_wr_addr     : out    vl_logic_vector;
        lpm_wr_req      : out    vl_logic;
        lpm_wr_oq       : out    vl_logic_vector;
        lpm_wr_next_hop_ip: out    vl_logic_vector(31 downto 0);
        lpm_wr_ip       : out    vl_logic_vector(31 downto 0);
        lpm_wr_mask     : out    vl_logic_vector(31 downto 0);
        lpm_wr_ack      : in     vl_logic;
        arp_rd_addr     : out    vl_logic_vector;
        arp_rd_req      : out    vl_logic;
        arp_rd_mac      : in     vl_logic_vector(47 downto 0);
        arp_rd_ip       : in     vl_logic_vector(31 downto 0);
        arp_rd_ack      : in     vl_logic;
        arp_wr_addr     : out    vl_logic_vector;
        arp_wr_req      : out    vl_logic;
        arp_wr_mac      : out    vl_logic_vector(47 downto 0);
        arp_wr_ip       : out    vl_logic_vector(31 downto 0);
        arp_wr_ack      : in     vl_logic;
        dest_ip_filter_rd_addr: out    vl_logic_vector;
        dest_ip_filter_rd_req: out    vl_logic;
        dest_ip_filter_rd_ip: in     vl_logic_vector(31 downto 0);
        dest_ip_filter_rd_ack: in     vl_logic;
        dest_ip_filter_wr_addr: out    vl_logic_vector;
        dest_ip_filter_wr_req: out    vl_logic;
        dest_ip_filter_wr_ip: out    vl_logic_vector(31 downto 0);
        dest_ip_filter_wr_ack: in     vl_logic;
        mac_0           : out    vl_logic_vector(47 downto 0);
        mac_1           : out    vl_logic_vector(47 downto 0);
        mac_2           : out    vl_logic_vector(47 downto 0);
        mac_3           : out    vl_logic_vector(47 downto 0);
        clk             : in     vl_logic;
        reset           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of NUM_QUEUES : constant is 1;
    attribute mti_svvh_generic_type of ARP_LUT_DEPTH_BITS : constant is 1;
    attribute mti_svvh_generic_type of LPM_LUT_DEPTH_BITS : constant is 1;
    attribute mti_svvh_generic_type of FILTER_DEPTH_BITS : constant is 1;
    attribute mti_svvh_generic_type of UDP_REG_SRC_WIDTH : constant is 1;
end router_op_lut_regs_non_cntr;
