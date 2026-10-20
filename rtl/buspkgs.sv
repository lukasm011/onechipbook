interface axipkg;
    //AW BUS
	logic mem_axi_awvalid;
	logic mem_axi_awready;
	logic [31 : 0] mem_axi_awaddr;
	logic [2 : 0] mem_axi_awprot;
	//W BUS
    logic mem_axi_wvalid;
	logic mem_axi_wready;
	logic [31 : 0] mem_axi_wdata;
	logic [3 : 0] mem_axi_wstrb;
	//B BUS
    logic mem_axi_bvalid;
	logic mem_axi_bready;
	//AR BUS
    logic mem_axi_arvalid;
	logic mem_axi_arready;
	logic [31 : 0] mem_axi_araddr;
	logic [2 : 0] mem_axi_arprot;
	//R BUS
    logic mem_axi_rvalid;
	logic mem_axi_rready;
	logic [31 : 0] mem_axi_rdata;
endinterface : axipkg

interface nativepkg;
	logic [31 : 0] addr;
	logic mvalid;
	logic svalid;
	logic [31 : 0] rdata;
	logic [31 : 0] wdata;
	logic [3 : 0] wstrb; 
endinterface : nativepkg

