`include "defines.sv"

class alu_monitor;

alu_transaction mon_trans;
mailbox #(alu_transaction) mbx_ms;
virtual alu_intf vif_mon;

covergroup cg_mon;
                coverpoint mon_trans.res { bins result[]={[0:(2**`n)-1]};}
                coverpoint mon_trans.cout{ bins cout_active = {1};
                                           bins cout_inactive = {0};
                                         }
                coverpoint mon_trans.oflow { bins oflow_active = {1};
                                             bins oflow_inactive = {0};
                                           }
                coverpoint mon_trans.err { bins error_active = {1};
                                           bins error_inactive = {0};
                                         }
                coverpoint mon_trans.g { bins greater_active = {1};
                                         bins greater_inactive = {0};
                                       }
                coverpoint mon_trans.e { bins equal_active = {1};
                                         bins equal_inactive = {0};
                                       }
                coverpoint mon_trans.l { bins lesser_active = {1};
                                         bins lesser_inactive = {0};
                                       }
endgroup


function new(mailbox #(alu_transaction) mbx_ms,virtual alu_intf vif_mon);
 this.mbx_ms=mbx_ms;
 this.vif_mon=vif_mon;
 cg_mon=new();
endfunction

task start();
repeat(4)@(vif_mon.mon_cb);
for(int i=0;i<`no_transactions;i++)
 begin
  mon_trans=new();
  @(vif_mon.mon_cb);

  if(vif_mon.mon_cb.inp_valid inside{0,1,2,3} && ((vif_mon.mon_cb.mode==1 && vif_mon.mon_cb.cmd inside {0,1,2,3,4,5,6,7,8})||(vif_mon.mon_cb.mode==0 && vif_mon.mon_cb.cmd inside {0,1,2,3,4,5,6,7,8,9,10,11,12,13})))
    repeat(1) @(vif_mon.mon_cb);
else if(vif_mon.mon_cb.inp_valid==3 && (vif_mon.mon_cb.mode==1 && vif_mon.mon_cb.cmd inside {9,10}))
    repeat(2) @(vif_mon.mon_cb);

   begin
     if((vif_mon.mon_cb.inp_valid==2'b01) ||(vif_mon.mon_cb.inp_valid==2'b10))
      begin
        if(((vif_mon.mon_cb.mode==1)&& (vif_mon.mon_cb.cmd inside {0,1,2,3,8,9,10})) || ((vif_mon.mon_cb.mode==0)&& (vif_mon.mon_cb.cmd inside {0,1,2,3,4,5,12,13})))
          begin
            for(int j=0;j<16;j++)
              begin
                @(vif_mon.mon_cb);
                 begin
                  if(vif_mon.mon_cb.inp_valid==2'b11)
                    begin
                     if(vif_mon.mon_cb.mode==1 && vif_mon.mon_cb.cmd inside {9,10})
                      begin
                       repeat(2)@(vif_mon.mon_cb);
                       mon_trans.res=vif_mon.mon_cb.res;
                       mon_trans.err=vif_mon.mon_cb.err;
                       mon_trans.g=vif_mon.mon_cb.g;
                       mon_trans.l=vif_mon.mon_cb.l;
                       mon_trans.e=vif_mon.mon_cb.e;
                       mon_trans.oflow=vif_mon.mon_cb.oflow;
 //put inputs so that to compare at the output
                       mon_trans.opa=vif_mon.mon_cb.opa;
                       mon_trans.opb=vif_mon.mon_cb.opb;
                       mon_trans.cin=vif_mon.mon_cb.cin;
                       mon_trans.ce=vif_mon.mon_cb.ce;
                       mon_trans.mode=vif_mon.mon_cb.mode;
                       mon_trans.cmd=vif_mon.mon_cb.cmd;
                       mon_trans.inp_valid=vif_mon.mon_cb.inp_valid;

                       mbx_ms.put(mon_trans.copy());
                      $display("Monitor put  values from the DUT to mailbox @ %0t for transaction %0d:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d,RES=%0d,ERR=%0d,OFLOW=%0d,G=%0d,L=%0d,E=%0d",$time,i+1,vif_mon.mon_cb.opa,vif_mon.mon_cb.opb,vif_mon.mon_cb.cin,vif_mon.mon_cb.ce,vif_mon.mon_cb.mode,vif_mon.mon_cb.cmd,vif_mon.mon_cb.inp_valid,vif_mon.mon_cb.res,vif_mon.mon_cb.err,vif_mon.mon_cb.oflow,vif_mon.mon_cb.g,vif_mon.mon_cb.l,vif_mon.mon_cb.e);
                    cg_mon.sample();
                    $display("The outputcoverage %.2f",cg_mon.get_coverage());
                   end   // if cmd is of multiplication
                    else  //else if it is any other operation
                     begin
                      repeat(1)@(vif_mon.mon_cb);
                      mon_trans.res=vif_mon.mon_cb.res;
                      mon_trans.err=vif_mon.mon_cb.err;
                      mon_trans.g=vif_mon.mon_cb.g;
                      mon_trans.l=vif_mon.mon_cb.l;
                      mon_trans.e=vif_mon.mon_cb.e;
                      mon_trans.oflow=vif_mon.mon_cb.oflow;
 //put inputs so that to compare at the output
                      mon_trans.opa=vif_mon.mon_cb.opa;
                      mon_trans.opb=vif_mon.mon_cb.opb;
                      mon_trans.cin=vif_mon.mon_cb.cin;
                      mon_trans.ce=vif_mon.mon_cb.ce;
                      mon_trans.mode=vif_mon.mon_cb.mode;
                      mon_trans.cmd=vif_mon.mon_cb.cmd;
                      mon_trans.inp_valid=vif_mon.mon_cb.inp_valid;

                      mbx_ms.put(mon_trans.copy());
                      $display("Monitor put  values from the DUT to mailbox @ %0t for transaction %0d:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d,RES=%0d,ERR=%0d,OFLOW=%0d,G=%0d,L=%0d,E=%0d",$time,i+1,vif_mon.mon_cb.opa,vif_mon.mon_cb.opb,vif_mon.mon_cb.cin,vif_mon.mon_cb.ce,vif_mon.mon_cb.mode,vif_mon.mon_cb.cmd,vif_mon.mon_cb.inp_valid,vif_mon.mon_cb.res,vif_mon.mon_cb.err,vif_mon.mon_cb.oflow,vif_mon.mon_cb.g,vif_mon.mon_cb.l,vif_mon.mon_cb.e);
                    cg_mon.sample();
                    $display("The outputcoverage %.2f",cg_mon.get_coverage());
                    end   //end of else
                     break;
                   end  // end of inp_valid 11
                 else
                    begin
                      continue;
                    end
                 end   //end of clocking
                end    //end of for loop
              end      //end of if for two inputs
        else if((vif_mon.mon_cb.mode==1 && vif_mon.mon_cb.cmd inside {4,5,6,7})||(vif_mon.mon_cb.mode==0 && vif_mon.mon_cb.cmd inside {6,7,8,9,10,11}))
              begin
                     mon_trans.res=vif_mon.mon_cb.res;
                     mon_trans.err=vif_mon.mon_cb.err;
                     mon_trans.g=vif_mon.mon_cb.g;
                     mon_trans.l=vif_mon.mon_cb.l;
                     mon_trans.e=vif_mon.mon_cb.e;
                     mon_trans.oflow=vif_mon.mon_cb.oflow;
 //put inputs so that to compare at the output
                     mon_trans.opa=vif_mon.mon_cb.opa;
                     mon_trans.opb=vif_mon.mon_cb.opb;
                     mon_trans.cin=vif_mon.mon_cb.cin;
                     mon_trans.ce=vif_mon.mon_cb.ce;
                     mon_trans.mode=vif_mon.mon_cb.mode;
                     mon_trans.cmd=vif_mon.mon_cb.cmd;
                     mon_trans.inp_valid=vif_mon.mon_cb.inp_valid;

                     mbx_ms.put(mon_trans.copy());
                      $display("Monitor put values from the DUT to mailbox for direct single operand operation @ %0t for transaction %0d:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d,RES=%0d,ERR=%0d,OFLOW=%0d,G=%0d,L=%0d,E=%0d",$time,i+1,vif_mon.mon_cb.opa,vif_mon.mon_cb.opb,vif_mon.mon_cb.cin,vif_mon.mon_cb.ce,vif_mon.mon_cb.mode,vif_mon.mon_cb.cmd,vif_mon.mon_cb.inp_valid,vif_mon.mon_cb.res,vif_mon.mon_cb.err,vif_mon.mon_cb.oflow,vif_mon.mon_cb.g,vif_mon.mon_cb.l,vif_mon.mon_cb.e);
                     cg_mon.sample();
                     $display("The outputcoverage %.2f",cg_mon.get_coverage());

               end  // end for one input
           end  //end for 01 0r 10 at first edge
        else     // else for direct 11 or 00
           begin
             mon_trans.res=vif_mon.mon_cb.res;
             mon_trans.err=vif_mon.mon_cb.err;
             mon_trans.g=vif_mon.mon_cb.g;
             mon_trans.l=vif_mon.mon_cb.l;
             mon_trans.e=vif_mon.mon_cb.e;
             mon_trans.oflow=vif_mon.mon_cb.oflow;
 //put inputs so that to compare at the output
             mon_trans.opa=vif_mon.mon_cb.opa;
             mon_trans.opb=vif_mon.mon_cb.opb;
             mon_trans.cin=vif_mon.mon_cb.cin;
             mon_trans.ce=vif_mon.mon_cb.ce;
             mon_trans.mode=vif_mon.mon_cb.mode;
             mon_trans.cmd=vif_mon.mon_cb.cmd;
             mon_trans.inp_valid=vif_mon.mon_cb.inp_valid;

              mbx_ms.put(mon_trans.copy());
              cg_mon.sample();
              $display("The outputcoverage %.2f",cg_mon.get_coverage());

            $display("Monitor put values from the DUT to mailbox @ %0t for transaction %0d:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d,RES=%0d,ERR=%0d,OFLOW=%0d,G=%0d,L=%0d,E=%0d",$time,i+1,vif_mon.mon_cb.opa,vif_mon.mon_cb.opb,vif_mon.mon_cb.cin,vif_mon.mon_cb.ce,vif_mon.mon_cb.mode,vif_mon.mon_cb.cmd,vif_mon.mon_cb.inp_valid,vif_mon.mon_cb.res,vif_mon.mon_cb.err,vif_mon.mon_cb.oflow,vif_mon.mon_cb.g,vif_mon.mon_cb.l,vif_mon.mon_cb.e);
   end  //end of direct 11
  end
end
endtask

endclass
