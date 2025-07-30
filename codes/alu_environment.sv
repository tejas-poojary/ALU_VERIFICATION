`include "defines.sv"

class alu_environment;

virtual alu_intf.ALU_DRV vif_drv;
virtual alu_intf.ALU_MON vif_mon;
virtual alu_intf.ALU_REF vif_ref;

mailbox #(alu_transaction) mbx_gd;
mailbox #(alu_transaction) mbx_dr;
mailbox #(alu_transaction) mbx_ms;
mailbox #(alu_transaction) mbx_rs;

alu_generator gen;
alu_monitor mon;
alu_driver drv;
alu_reference_model refr;
alu_scoreboard scb;


function new(virtual alu_intf.ALU_DRV vif_drv,virtual alu_intf.ALU_MON vif_mon,virtual alu_intf.ALU_REF vif_ref);
 this.vif_drv=vif_drv;
 this.vif_mon=vif_mon;
 this.vif_ref=vif_ref;
endfunction

task build();
 begin
  mbx_gd=new();
  mbx_dr=new();
  mbx_ms=new();
  mbx_rs=new();

  gen=new(mbx_gd);
  drv=new(mbx_gd,mbx_dr,vif_drv);
  mon=new(mbx_ms,vif_mon);
  scb=new(mbx_ms,mbx_rs);
  refr=new(mbx_dr,mbx_rs,vif_ref);
 end
endtask

task start();
    fork
    gen.start();
    drv.start();
    mon.start();
    scb.start();
    refr.start();
    join
 endtask

endclass
