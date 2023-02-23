package MiniLab_defs;

    /////////////
    // MEMORY //
    ///////////
    localparam IMEM_DEPTH = 14;
    localparam DMEM_DEPTH = 13;

    ////////////
    // SPART //
    //////////
    typedef enum logic [1:0] {
        ADDR_DBUF = 2'b00,
        ADDR_SREG = 2'b01,
        ADDR_DBL  = 2'b10,
        ADDR_DBH  = 2'b11
    } spart_ioaddr_t;

endpackage