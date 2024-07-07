//By Alexander Peacock, undergrad at UCF ECE
//email: alexpeacock56ten@gmail.com

`timescale 1ns/1ns
`include "uButterfly.v"
`include "sobolrng.v"
`define TESTAMOUNT 10


//used to check errors
class errorcheck;
    real uResult1;
    real uResult2;
    real uResult3;
    real uResult4;
    real eResult1;
    real eResult2;
    real eResult3;
    real eResult4;
    real fnum;
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
        outReal0 = 0;
        outImg0 = 0;
        outReal1 = 0;
        outReal0 = 0;
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
        $display("Number of 1s in output Img1 = %.0f", outImg1);

        $display("Bipolar Real0 value = %.9f", biReal0);
        $display("Bipolar Image0 value = %.9f", biImg0);
        $display("Bipolar Real1 value = %.9f", biReal1);
        $display("Bipolar Image1 value = %.9f", biImg0);
        $display("Bipolar wReal value = %.9f", biwReal);
        $display("Bipolar wImg value = %.9f", biwImg);

        //unary result
        uResult1 = (2*(outReal0/fdenom)) - 1;
        uResult2 = (2*(outImg0/fdenom)) - 1;
        uResult3 = (2*(outReal1/fdenom)) - 1;
        uResult4 = (2*(outImg1/fdenom)) - 1;

        //expected results
        eResult1 = (biReal0 + ((biReal1*biwReal) - (biImg1*biwImg)))/4; 
        eResult2 = (biImg0 + ((biReal1*biwImg) + (biImg1*biwReal)))/4;
        eResult3 = (biReal0 - ((biReal1*biwReal) - (biImg1*biwImg)))/4;
        eResult4 = (biImg0 - ((biReal1*biwImg) + (biImg1*biwReal)))/4;

        $display("Unary result 0 = %.9f + %.9fi", uResult1, uResult2);
        $display("Unary result 1 = %.9f + %.9fi\n", uResult3, uResult4);
        
        $display("Expected result 0 = %.9f + %.9fi", eResult1, eResult2);
        $display("Expected result 1 = %.9f + %.9fi\n", eResult3, eResult4);

        //asum = asum + ((uResult - eResult) * (uResult - eResult));
        //$display("Cumulated square error = %.9f", asum);
        //$display("");

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
    logic resultwReal [PPCYCLE-1:0];
    logic result_expectedwReal;
    assign result_expectedwReal = oBReal;
    logic resultwImg [PPCYCLE-1:0];
    logic result_expectedwImg;
    assign result_expectedwImg = oBImg;

    genvar i;
    generate
        for (i = 1; i < PPCYCLE; i = i + 1) begin
            always@(posedge iClk or negedge iRstN) begin
                if (~iRstN) begin
                    result1[i] <= 0;
                    result2[i] <= 0;
                    result3[i] <= 0;
                    result4[i] <= 0;
                    resultwReal[i] <= 0;
                    resultwImg[i] <= 0;
                end else begin
                    result1[i] <= result1[i-1];
                    result2[i] <= result2[i-1];
                    result3[i] <= result3[i-1];
                    result4[i] <= result4[i-1];
                    resultwReal[i] <= resultwReal[i-1];
                    resultwImg[i] <= resultwImg[i-1];
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
            resultwReal[0] <= 0;
            resultwImg[0] <= 0;
        end else begin
            result1[0] <= result_expected1;
            result2[0] <= result_expected2;
            result3[0] <= result_expected3;
            result4[0] <= result_expected4;
            resultwReal[0] <= result_expectedwReal;
            resultwImg[0] <= result_expectedwImg;
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
        rand_a = 0;
        rand_b = 0;
        rand_c = 0;
        rand_d = 0;
        iClr = 0;
        loadB = 1;
        error = new;

        #10;
        iRstN = 1;

        
        //specified cycles of unary bitstreams
        repeat(`TESTAMOUNT) begin
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
                error.count(iReal0, iImg0, iReal1, iImg1, resultwReal[PPCYCLE-1], resultwImg[PPCYCLE-1], result1[PPCYCLE-1], result2[PPCYCLE-1], result3[PPCYCLE-1], result4[PPCYCLE-1]);
            end

            error.fSUM();
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
