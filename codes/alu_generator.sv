`include "defines.sv"

class alu_generator;
alu_transaction blueprint;
mailbox #(alu_transaction) mbx_gd;

function new(mailbox #(alu_transaction) mbx_gd);
this.mbx_gd=mbx_gd;
blueprint=new();
endfunction

task start();
for(int i=0;i<`no_transactions;i++)
 begin
  blueprint.randomize();
  mbx_gd.put(blueprint.copy());
  $display("Generator randomized data values @ %0t :OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d",$time,blueprint.opa,blueprint.opb,blueprint.cin,blueprint.ce,blueprint.mode,blueprint.cmd,blueprint.inp_valid);
$display("********************************************************************************************************");
end
endtask
endclass
