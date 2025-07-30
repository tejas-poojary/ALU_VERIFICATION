`include "alu_interface.sv"
`include "alu_design.sv"
`include "alu_pkg.sv"

module top();

import alu_pkg::*;
bit clk,reset;

 initial
    begin
     forever #10 clk=~clk;
    end

initial
    begin
      @(posedge clk);
      reset=1;
      repeat(1)@(negedge clk);
      reset=0;
    end

alu_intf intrf(clk,reset);  //interface instantiation

ALU_DESIGN DUT(.OPA(intrf.opa),
.OPB(intrf.opb),
.CIN(intrf.cin),
.CE(intrf.ce),
.MODE(intrf.mode),
.CMD(intrf.cmd),
.INP_VALID(intrf.inp_valid),
.CLK(clk),
.RST(reset),
.RES(intrf.res),
.COUT(intrf.cout),
.OFLOW(intrf.oflow),
.ERR(intrf.err),
.G(intrf.g),
.L(intrf.l),
.E(intrf.e)
);


alu_test tb;  //test class instantiation
test1 t1;
test2 t2;
test3 t3;
test4 t4;
test_regression tr;

initial
   begin
    tb=new(intrf.ALU_DRV,intrf.ALU_MON,intrf.ALU_REF);
    t1=new(intrf.ALU_DRV,intrf.ALU_MON,intrf.ALU_REF);
    t2=new(intrf.ALU_DRV,intrf.ALU_MON,intrf.ALU_REF);
    t3=new(intrf.ALU_DRV,intrf.ALU_MON,intrf.ALU_REF);
    t4=new(intrf.ALU_DRV,intrf.ALU_MON,intrf.ALU_REF);
    tr=new(intrf.ALU_DRV,intrf.ALU_MON,intrf.ALU_REF);

    //tb.run();
    //  t1.run();
    //  t2.run();
    //  t3.run();
    //  t4.run();
      tr.run();
    $finish();
   end

endmodule
