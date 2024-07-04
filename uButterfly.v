//By Alexander Peacock, undergrad at UCF ECE
//email: alexpeacock56ten@gmail.com

`ifndef uButterfly
`define uButterfly

`include "uMUL_bi.v"
`include "uSADD.v"
`include "uSSUB.v"


module uButterfly #(
    parameter BITWIDTH = 8,
              BINPUT = 2
) (
    input wire iClk,
    input wire iRstN,
    input wire loadB,
    input wire iClr,
    input wire iReal0,
    input wire iImg0,
    input wire iReal1,
    input wire iImg1,
    input wire [BITWIDTH-1:0] iwReal,
    input wire [BITWIDTH-1:0] iwImg,
    output wire oReal0,
    output wire oImg0,
    output wire oReal1,
    output wire oImg1
);

    wire eq_1;
    wire eq_2;
    wire eq_3;
    wire eq_4;
    wire real_eq;
    wire img_eq;

    //these account for the multiplication of input 0 with w
    uMUL_bi #(
        .BITWIDTH(BITWIDTH)
    )u_uMUL_bi_1 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(iReal1),
        .iB(iwReal),
        .loadB(loadB),
        .iClr(iClr),
        .oMult(eq_1)
    );

    uMUL_bi #(
        .BITWIDTH(BITWIDTH)
    ) u_uMUL_bi_2 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(iReal1),
        .iB(iwImg),
        .loadB(loadB),
        .iClr(iClr),
        .oMult(eq_2)
    );

    uMUL_bi #(
        .BITWIDTH(BITWIDTH)
    ) u_uMUL_bi_3 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(iImg1),
        .iB(iwReal),
        .loadB(loadB),
        .iClr(iClr),
        .oMult(eq_3)
    );

    uMUL_bi #(
        .BITWIDTH(BITWIDTH)
    ) u_uMUL_bi_4 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(iImg1),
        .iB(iwImg),
        .loadB(loadB),
        .iClr(iClr),
        .oMult(eq_4)
    );

    //creates parts to be added and subtracted in butterfly

    uSSUB #(
        .BINPUT(BINPUT)
    ) u_uSSUB_realeq (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(eq_1),
        .iB(eq_4),
        .oC(real_eq)
    );

    uSADD #(
        .BINPUT(BINPUT)
    ) u_uSADD_imgeq (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(eq_2),
        .iB(eq_3),
        .oC(img_eq) 
    );

    //used to find final outputs

    uSADD #(
        .BINPUT(BINPUT)
    ) u_uSADD_oReal0 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(iReal0),
        .iB(real_eq),
        .oC(oReal0) 
    );

    uSADD #(
        .BINPUT(BINPUT)
    ) u_uSADD_oImg0 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(iImg0),
        .iB(img_eq),
        .oC(oReal0) 
    );

    uSSUB #(
        .BINPUT(BINPUT)
    ) u_uSSUB_oReal1 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(iReal0),
        .iB(real_eq),
        .oC(oReal1) 
    );

    uSSUB #(
        .BINPUT(BINPUT)
    ) u_uSSUB_oImg1 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(iImg0),
        .iB(img_eq),
        .oC(oImg1) 
    );
    
endmodule

`endif