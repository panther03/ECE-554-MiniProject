package MiniLab_defs;

    /////////////
    // MEMORY //
    ///////////
    localparam IMEM_DEPTH = 12;
    localparam DMEM_DEPTH = 11;

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