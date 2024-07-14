//By Alexander Peacock, undergrad at UCF ECE
//email: alexpeacock56ten@gmail.com

`timescale 1ns/1ns
`include "uButterfly.v"
`include "sobolrng.v"
`define TESTAMOUNT 10

//used to check errors
class errorcheck;
    real uResult_Real0;
    real uResult_Img0;
    real uResult_Real1;
    real uResult_Img1;
    real eResult_Real0;
    real eResult_Img0;
    real eResult_Real1;
    real eResult_Img1;
    real fdenom;
    real cntReal0;
    real cntImg0;
    real cntReal1;
    real cntImg1;
    real cntiwImg;
    real cntiwReal;
    real outReal0;
    real outImg0;
    real outReal1;
    real outImg1;
    real asum_Real0;
    real asum_Img0;
    real asum_Real1;
    real asum_Img1;
    real mse_Real0;
    real mse_Img0;
    real mse_Real1;
    real mse_Img1;
    real rmse_Real0;
    real rmse_Img0;
    real rmse_Real1;
    real rmse_Img1;
    static int j;

    function new();
        asum_Real0 = 0;
        asum_Img0 = 0;
        asum_Real1 = 0;
        asum_Img1 = 0;
        fdenom = 0;
        cntReal0 = 0;
        cntImg0 = 0;
        cntReal1 = 0;
        cntImg1 = 0;
        cntiwReal = 0;
        cntiwImg = 0;
        outReal0 = 0;
        outImg0 = 0;
        outReal1 = 0;
        outImg1 = 0;
        j = 0;
    endfunction

    //accumulates to account for bitstreams
    function count(real a, b, c, d, e, f, oA, oB, oC, oD);
        cntReal0 = cntReal0 + a;
        cntImg0 = cntImg0 + b;
        cntReal1 = cntReal1 + c;
        cntImg1 = cntImg1 + d;
        cntiwReal = cntiwReal + e;
        cntiwImg = cntiwImg + f;
        outReal0 = outReal0 + oA;
        outImg0 = outImg0 + oB;
        outReal1 = outReal1 + oC;
        outImg1 = outImg1 + oD;

        fdenom++;
    endfunction

    //sums the results of a bitstream cycle
    function fSUM();
        real biReal0; 
        real biImg0;
        real biReal1;
        real biImg1;
        real biwReal;
        real biwImg;

        j++; //counts current run

        biReal0 = (2*(cntReal0/fdenom)) - 1;
        biImg0 = (2*(cntImg0/fdenom)) - 1;
        biReal1 = (2*(cntReal1/fdenom)) - 1;
        biImg1 = (2*(cntImg1/fdenom)) - 1;
        biwReal = (2*(cntiwReal/fdenom)) - 1;
        biwImg = (2*(cntiwImg/fdenom)) - 1;

        //bipolar representation
        
        $display("Run <%.0f>: ", j);
        $display("Length of bitstream = %.0f", fdenom);
        $display("Number of 1s in input Real0 = %.0f", cntReal0);
        $display("Number of 1s in input Img0 = %.0f", cntImg0);
        $display("Number of 1s in input Real1 = %.0f", cntReal1);
        $display("Number of 1s in input Img1 = %.0f", cntImg1);
        $display("Number of 1s in input wReal = %.0f", cntiwReal);
        $display("Number of 1s in input wImg = %.0f", cntiwImg);
        $display("Number of 1s in output Real0 = %.0f", outReal0);
        $display("Number of 1s in output Img0 = %.0f", outImg0);
        $display("Number of 1s in output Real1 = %.0f", outReal1);
        $display("Number of 1s in output Img1 = %.0f\n", outImg1);

        $display("Bipolar Real0 value = %.9f", biReal0);
        $display("Bipolar Image0 value = %.9f", biImg0);
        $display("Bipolar Real1 value = %.9f", biReal1);
        $display("Bipolar Image1 value = %.9f", biImg1);
        $display("Bipolar wReal value = %.9f", biwReal);
        $display("Bipolar wImg value = %.9f\n", biwImg);

        //unary result
        uResult_Real0 = (2*(outReal0/fdenom)) - 1;
        uResult_Img0 = (2*(outImg0/fdenom)) - 1;
        uResult_Real1 = (2*(outReal1/fdenom)) - 1;
        uResult_Img1 = (2*(outImg1/fdenom)) - 1;

        //expected results
        eResult_Real0 = (biReal0 + ((biReal1*biwReal) - (biImg1*biwImg)))/4; 
        eResult_Img0 = (biImg0 + ((biReal1*biwImg) + (biImg1*biwReal)))/4;
        eResult_Real1 = (biReal0 - ((biReal1*biwReal) - (biImg1*biwImg)))/4;
        eResult_Img1 = (biImg0 - ((biReal1*biwImg) + (biImg1*biwReal)))/4;

        $display("Unary result 0 = %.9f + %.9fi", uResult_Real0, uResult_Img0);
        $display("Unary result 1 = %.9f + %.9fi\n", uResult_Real1, uResult_Img1);
        
        $display("Expected result 0 = %.9f + %.9fi", eResult_Real0, eResult_Img0);
        $display("Expected result 1 = %.9f + %.9fi\n", eResult_Real1, eResult_Img1);

        asum_Real0 = asum_Real0 + ((uResult_Real0 - eResult_Real0) * (uResult_Real0 - eResult_Real0));
        asum_Img0 = asum_Img0 + ((uResult_Img0 - eResult_Img0) * (uResult_Img0 - eResult_Img0));
        asum_Real1 = asum_Real1 + ((uResult_Real1 - eResult_Real1) * (uResult_Real1 - eResult_Real1));
        asum_Img1 = asum_Img1 + ((uResult_Img1 - eResult_Img1) * (uResult_Img1 - eResult_Img1));
        $display("Real0 cumulated square error = %.9f", asum_Real0);
        $display("Img0 cumulated square error = %.9f", asum_Img0);
        $display("Real1 cumulated square error = %.9f", asum_Real1);
        $display("Img1 cumulated square error = %.9f\n", asum_Img0);

        //resets for next bitstreams

        fdenom = 0;
        cntReal0 = 0;
        cntImg0 = 0;
        cntReal1 = 0;
        cntImg1 = 0;
        cntiwReal = 0;
        cntiwImg = 0;
        outReal0 = 0;
        outImg0 = 0;
        outReal1 = 0;
        outImg1 = 0;
    endfunction

    //mean squared error
    function fMSE();
        $display("Final Results: "); 
        mse_Real0 = asum_Real0 / `TESTAMOUNT;
        mse_Img0 = asum_Img0 / `TESTAMOUNT;
        mse_Real1 = asum_Real1 / `TESTAMOUNT;
        mse_Img1 = asum_Img1 / `TESTAMOUNT;
        $display("Real0 mse: %.9f", mse_Real0);
        $display("Img0 mse: %.9f", mse_Img0);
        $display("Real1 mse: %.9f", mse_Real1);
        $display("Img1 mse: %.9f", mse_Img1);
    endfunction

    //root mean square error
    function fRMSE();
        rmse_Real0 = $sqrt(mse_Real0);
        rmse_Img0 = $sqrt(mse_Img0);
        rmse_Real1 = $sqrt(mse_Real1);
        rmse_Img1 = $sqrt(mse_Img1);
        $display("Real0 rmse: %.9f", rmse_Real0);
        $display("Img0 rmse: %.9f", rmse_Img0);
        $display("Real1 rmse: %.9f", rmse_Real1);
        $display("Img1 rmse: %.9f", rmse_Img1);
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
    logic iClr;
    logic loadW;
    logic oBReal;
    logic oBImg;
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
    logic [BITWIDTH-1:0] rand_iReal0;
    logic [BITWIDTH-1:0] rand_iImg0;
    logic [BITWIDTH-1:0] rand_iReal1;
    logic [BITWIDTH-1:0] rand_iImg1;
    logic [BITWIDTH-1:0] iwReal;
    logic [BITWIDTH-1:0] iwImg;

    
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
        .loadW(loadW),
        .iClr(iClr),
        .iReal0(iReal0),
        .iImg0(iImg0),
        .iReal1(iReal1),
        .iImg1(iImg1),
        .iwReal(iwReal),
        .iwImg(iwImg),
        .oBReal(oBReal),
        .oBImg(oBImg),
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
        rand_iReal0 = 0;
        rand_iImg0 = 0;
        rand_iReal1 = 0;
        rand_iImg1 = 0;
        iClr = 0;
        loadW = 1;
        error = new;

        #10;
        iRstN = 1;

        
        //specified cycles of unary bitstreams
        repeat(`TESTAMOUNT) begin
            rand_iReal0 = $urandom_range(255);
            rand_iImg0 = $urandom_range(255);
            rand_iReal1 = $urandom_range(255);
            rand_iImg1 = $urandom_range(255);
            iwReal = $urandom_range(255);
            iwImg = $urandom_range(255);

            repeat(256) begin
                #10; 
                iReal0 = (rand_iReal0 > sobolseq_tbA);
                iImg0 = (rand_iImg0 > sobolseq_tbB);
                iReal1 = (rand_iReal1 > sobolseq_tbC);
                iImg1 = (rand_iImg1 > sobolseq_tbD);
                error.count(iReal0, iImg0, iReal1, iImg1, oBReal, oBImg, result1[PPCYCLE-1], result2[PPCYCLE-1], 
                result3[PPCYCLE-1], result4[PPCYCLE-1]);
            end

            error.fSUM();
        end

        //gives final error results
        error.fMSE();
        error.fRMSE();

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