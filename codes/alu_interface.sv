`include "defines.sv"

interface alu_intf(input bit clk,reset);
 logic [1:0] inp_valid;
 logic mode;
 logic [`m-1:0]cmd;
 logic ce;
 logic [`n-1:0]opa,opb;
 logic cin;
 logic err,oflow,g,l,e,cout;
 logic [`n+1:0]res;

clocking drv_cb@(posedge clk);
 default input #0 output #0;
 input reset;    //optional
 output opa,opb,inp_valid,mode,cmd,ce,cin;
endclocking


clocking mon_cb@(posedge clk);
default input #0 output #0;
input res,err,oflow,g,l,e,cout,opa,opb,cin,ce,mode,cmd,inp_valid;
//can also add other signals like cmd,mode etc
endclocking

clocking ref_cb@(posedge clk);
default input #0 output #0;
input opa,opb,cin,ce,mode,inp_valid,cmd,reset;
output res,oflow,err,g,l,cout;
endclocking

modport ALU_DRV(clocking drv_cb);
modport ALU_MON(clocking mon_cb);
modport ALU_REF(clocking ref_cb);

//Reset assertion
property ppt_reset;
  @(posedge clk) reset |=> ##1 (res == 9'bzzzzzzzz && err == 1'bz && e == 1'bz && g == 1'bz && l == 1'bz && cout == 1'bz && oflow == 1'bz)
 endproperty
assert property(ppt_reset)
    $display("RST assertion PASSED at time %0t", $time);
  else
    $info("RST assertion FAILED @ time %0t", $time);


// 16- cycle arithmetic TIMEOUT assertion
property ppt_timeout_arithmetic;
  @(posedge clk) disable iff(reset) (ce && (cmd == `ADD || cmd == `SUB || cmd == `ADD_CIN || cmd == `SUB_CIN || cmd == `MUL_SHIFT || cmd == `MUL_INC) && (inp_valid == 2'b01 || inp_valid == 2'b10)) |-> ##16 (err == 1'b1);
endproperty
    assert property(ppt_timeout_arithmetic)
       else $error("Timeout assertion failed at time %0t", $time);
      

//16- cycle logical TIMEOUT assertion
property ppt_timeout_logical;
   @(posedge clk) disable iff(reset) (ce && (cmd == `AND || cmd == `OR || cmd == `NAND || cmd == `XOR || cmd == `XNOR || cmd == `NOR || cmd == `SHR1_A || cmd == `SHR1_B || cmd == `SHL1_A || cmd == `SHL1_B || cmd == `ROR_A_B  || cmd == `ROL_A_B) && (inp_valid == 2'b01 || inp_valid == 2'b10)) |-> ##16 (err == 1'b1);
endproperty
   assert property(ppt_timeout_logical)
      else $error("Timeout assertion failed at time %0t", $time);


//ROR/ROL error
  assert property (@(posedge clk) disable iff(reset) (ce && mode && (cmd == `ROR_A_B || cmd == `ROL_A_B) && $countones(opb) > `ROR_WIDTH + 1) |=> ##[1:3] err )
        else $info(" ERROR FLAG IS NOT RAISED");

//CMD out of range
  assert property (@(posedge clk) (mode && cmd > 10) |=> err)
        else $info("CMD INVALID FOR ARITHMETIC BUT ERR NOT RAISED");

//CMD out of range logical
  assert property (@(posedge clk) (!mode && cmd > 13) |=> err)
  else $info("CMD INVALID FOR LOGICAL BUT ERR NOT RAISED");


//INP_VALID  assertion
property ppt_valid_inp_valid;
   @(posedge clk) disable iff(reset) inp_valid inside {2'b00, 2'b01, 2'b10, 2'b11};
endproperty
  assert property(ppt_valid_inp_valid)
      else $info("Invalid INP_VALID value: %b at time %0t", INP_VALID, $time);

// INP_VALID 00 case
 assert property (@(posedge CLK) (INP_VALID == 2'b00) |=> ERR )
      else $info("ERROR NOT raised");

//CE assertion
 property ppt_clock_enable;
   @(posedge clk) disable iff(reset) !ce |-> ##1 ($stable(res) && $stable(cout) && $stable(oflow) && $stable(g) && $stable(l) && $stable(e) && $stable(err));
 endproperty
  assert property(ppt_clock_enable)
    else $info("Clock enable assertion failed at time %0t", $time);

endinterface
