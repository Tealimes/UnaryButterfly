//By Alexander Peacock, undergrad at UCF ECE
//email: alexpeacock56ten@gmail.com

`timescale 1ns/1ns
`include "uButterfly.v"
`include "sobolrng.v"
`define TESTAMOUNT 10


//used to check errors
class errorcheck;
    real uResult;
    real eResult;
    real fnum;
    real fdenom;
    real cntReal0;
    real cntImg0;
    real cntReal1;
    real cntImg1;
    real cntiwImg;
    real cntiwReal;
    real asum;
    real mse;
    real rmse;
    static int j;

    function new();
        asum = 0;
        fnum = 0;
        fdenom = 0;
        cntReal0 = 0;
        cntImg0 = 0;
        cntReal1 = 0;
        cntImg1 = 0;
        cntiwReal = 0;
        cntiwImg = 0;
        j = 0;
    endfunction

    //accumulates to account for bitstreams
    function count(real a, b, c, d, e, f);
        cntReal0 = cntReal0 + a;
        cntImg0 = cntImg0 + b;
        cntReal1 = cntReal1 + c;
        cntImg1 = cntImg1 + d;
        cntiwReal = cntiwReal + e;
        cntiwImg = cntiwImg + f;
        fdenom++;
    endfunction

    //sums the results of a bitstream cycle
    function fSUM();

        j++; //counts current run

        //bipolar representation
        
        $display("Run <%.0f>: ", j);
        $display("Length of bitstream = %.0f", fdenom);
        $display("Number of 1s in output = %.0f", fnum);

        //uResult = ; //unary result
        //eResult = ; //expected result

        $display("Unary result = %.9f", uResult);
        $display("Expected result = %.9f", eResult); 

        asum = asum + ((uResult - eResult) * (uResult - eResult));
        $display("Cumulated square error = %.9f", asum);
        $display("");

        //resets for next bitstreams

        fdenom = 0;
    endfunction

    //mean squared error
    function fMSE();
        $display("Final Results: "); 
        mse = asum / `TESTAMOUNT;
        $display("mse: %.9f", mse);
    endfunction

    //root mean square error
    function fRMSE();
        rmse = $sqrt(mse);
        $display("rmse: %.9f", rmse);
    endfunction

endclass


module uButterfly_tb();

    parameter BITWIDTH = 8;
    parameter BINPUT = 2;
    logic iClk;
    logic iRstN;
    logic iReal0;
    logic iImg0;
    logic iReal1;
    logic iImg1;
    logic [BITWIDTH-1:0] iwReal;
    logic [BITWIDTH-1:0] iwImg;
    logic iClr;
    logic loadB;
    logic oReal0;
    logic oImg0;
    logic oReal1;
    logic oImg1;

    
    errorcheck error; //class for error checking

    //used for bitstream generation
    logic [BITWIDTH-1:0] sobolseq_tbA;
    logic [BITWIDTH-1:0] sobolseq_tbB;
    logic [BITWIDTH-1:0] sobolseq_tbC;
    logic [BITWIDTH-1:0] sobolseq_tbD;
    logic [BITWIDTH-1:0] rand_a;
    logic [BITWIDTH-1:0] rand_b;
    logic [BITWIDTH-1:0] rand_c;
    logic [BITWIDTH-1:0] rand_d;

    
    // This code is used to delay the expected output
    parameter PPCYCLE = 1;

    // dont change code below
    logic result1 [PPCYCLE-1:0];
    logic result_expected1;
    assign result_expected1 = oReal0;
    logic result2 [PPCYCLE-1:0];
    logic result_expected2;
    assign result_expected2 = oImg0;
    logic result3 [PPCYCLE-1:0];
    logic result_expected3;
    assign result_expected3 = oReal1;
    logic result4 [PPCYCLE-1:0];
    logic result_expected4;
    assign result_expected4 = oImg1;

    genvar i;
    generate
        for (i = 1; i < PPCYCLE; i = i + 1) begin
            always@(posedge iClk or negedge iRstN) begin
                if (~iRstN) begin
                    result1[i] <= 0;
                    result2[i] <= 0;
                    result3[i] <= 0;
                    result4[i] <= 0;
                end else begin
                    result1[i] <= result1[i-1];
                    result2[i] <= result2[i-1];
                    result3[i] <= result3[i-1];
                    result4[i] <= result4[i-1];
                end
            end
        end
    endgenerate

    always@(posedge iClk or negedge iRstN) begin
        if (~iRstN) begin
            result1[0] <= 0;
            result2[0] <= 0;
            result3[0] <= 0;
            result4[0] <= 0;
        end else begin
            result1[0] <= result_expected1;
            result2[0] <= result_expected2;
            result3[0] <= result_expected3;
            result4[0] <= result_expected4;
        end
    end
    // end here
    

    //generates two stochastic bitstreams
    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrng_tbA (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(1),
        .iClr(iClr),
        .sobolseq(sobolseq_tbA)
    );

    
    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrng_tbB (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(1),
        .iClr(iClr),
        .sobolseq(sobolseq_tbB)
    );

    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrng_tbC (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(1),
        .iClr(iClr),
        .sobolseq(sobolseq_tbC)
    );

    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrng_tbD (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(1),
        .iClr(iClr),
        .sobolseq(sobolseq_tbD)
    );

    
    uButterfly #(
        .BITWIDTH(BITWIDTH),
        .BINPUT(BINPUT)
    ) u_uButterfly (
        .iClk(iClk),
        .iRstN(iRstN),
        .loadB(loadB),
        .iClr(iClr),
        .iReal0(iReal0),
        .iImg0(iImg0),
        .iReal1(iReal1),
        .iImg1(iImg1),
        .iwReal(iwReal),
        .iwImg(iwImg),
        .oReal0(oReal0),
        .oImg0(oImg0),
        .oReal1(oReal1),
        .oImg1(oImg1)
    );

    always #5 iClk = ~iClk;

    initial begin 
        $dumpfile("uButterfly_tb.vcd"); $dumpvars;

        
        iClk = 1;
        iReal0 = 0;
        iImg0 = 0;
        iReal1 = 0;
        iImg1 = 0;
        iRstN = 0;
        iwReal = 0;
        iwImg = 0;
        rand_a = 0;
        rand_b = 0;
        iClr = 0;
        loadB = 1;

        #10;
        iRstN = 1;

        
        //specified cycles of unary bitstreams

        rand_a = $urandom_range(255);
        rand_b = $urandom_range(255);
        rand_c = $urandom_range(255);
        rand_d = $urandom_range(255);
        iwReal = $urandom_range(255);
        iwImg = $urandom_range(255);

        repeat(256) begin
            #10; 
            iReal0 = (rand_a > sobolseq_tbA);
            iImg0 = (rand_b > sobolseq_tbB);
            iReal1 = (rand_c > sobolseq_tbC);
            iImg1 = (rand_d > sobolseq_tbD);
        end

        iClr = 1;
        iReal0 = 0;
        iImg0 = 0;
        iReal1 = 0;
        iImg1 = 0;
        iwReal = 0;
        iwImg = 0;
        #400;
        

        #10;
        #100;

        $finish;

    end
    
    
endmodule