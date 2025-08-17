`include "defines.sv"

class alu_driver;
  mailbox #(alu_transaction)mbx_gd;
  mailbox #(alu_transaction)mbx_dr;
  alu_transaction trans_drv;
  alu_transaction trans_drv_temp;
  virtual alu_intf vif_drv;

  covergroup cg_drv;
        INPUT_VALID : coverpoint trans_drv.inp_valid { bins valid_opa = {2'b01};
                                                       bins valid_opb = {2'b10};
                                                       bins valid_both = {2'b11};
                                                       bins invalid = {2'b00};
                                                         }
        COMMAND : coverpoint trans_drv.cmd { bins arithmetic[] = {[0:10]};
                                             bins logical[] = {[0:13]};
                                             //bins arithmetic_invalid[] = {[11:15]};
                                             //bins logical_invalid[] = {14,15};
                                            }
        MODE : coverpoint trans_drv.mode { bins arithmetic = {1};
                                           bins logical = {0};
                                             }
        CLOCK_ENABLE : coverpoint trans_drv.ce { bins clock_enable_valid = {1};
                                                 bins clock_enable_invalid = {0};
                                               }
        OPERAND_A : coverpoint trans_drv.opa { bins opa[]={[0:(2**`n)-1]};}
        OPERAND_B : coverpoint trans_drv.opb { bins opb[]={[0:(2**`n)-1]};}
        CARRY_IN : coverpoint trans_drv.cin { bins cin_high = {1};
                                              bins cin_low = {0};
                                            }
        MODE_CMD_: cross MODE,COMMAND;
        endgroup


  function new(mailbox #(alu_transaction)mbx_gd,mailbox #(alu_transaction)mbx_dr,virtual alu_intf vif_drv);
    this.mbx_gd=mbx_gd;
    this.mbx_dr=mbx_dr;
    this.vif_drv=vif_drv;
    cg_drv=new();
  endfunction

  task start();
    repeat(3)@(vif_drv.drv_cb);
    for(int i=0;i<`no_transactions;i++)
      begin
        trans_drv=new();
        mbx_gd.get(trans_drv);
        $display("Driver got values from generator at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d",$time,trans_drv.opa,trans_drv.opb,trans_drv.cin,trans_drv.ce,trans_drv.mode,trans_drv.cmd,trans_drv.inp_valid);

       @(vif_drv.drv_cb);
        begin
         if(trans_drv.inp_valid==2'b01 || trans_drv.inp_valid==2'b10)
            begin
               if(((trans_drv.mode==1)&& (trans_drv.cmd inside {0,1,2,3,8,9,10})) || ((trans_drv.mode==0)&& (trans_drv.cmd inside {0,1,2,3,4,5,12,13})))
                 begin
                    //$display("DRIVING CORRECTLY @%T",$time);
                    vif_drv.drv_cb.opa<=trans_drv.opa;
                    vif_drv.drv_cb.opb<=trans_drv.opb;
                    vif_drv.drv_cb.cin<=trans_drv.cin;
                    vif_drv.drv_cb.ce<=trans_drv.ce;
                    vif_drv.drv_cb.cmd<=trans_drv.cmd;
                    vif_drv.drv_cb.mode<=trans_drv.mode;
                    vif_drv.drv_cb.inp_valid<=trans_drv.inp_valid;
                    mbx_dr.put(trans_drv);
                    $display("Mailbox put happened at %0t before entering 16 clock cycle normal sending at first edge for transaction %0d",$time,i+1);

                    $display("Driver drived values normally at first edge of 16 cycle at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d",$time,trans_drv.opa,trans_drv.opb,trans_drv.cin,trans_drv.ce,trans_drv.mode,trans_drv.cmd,trans_drv.inp_valid);

                for(int j=0;j<16;j++)
                begin
                 @(vif_drv.drv_cb);
                  begin
                  if(trans_drv.inp_valid==2'b11)
                   begin
                      //$display("Driver entered the if part of repeat 16 loop and got 11 at %0t",$time);
                      vif_drv.drv_cb.opa<=trans_drv.opa;
                      vif_drv.drv_cb.opb<=trans_drv.opb;
                      vif_drv.drv_cb.cin<=trans_drv.cin;
                      vif_drv.drv_cb.ce<=trans_drv.ce;
                      vif_drv.drv_cb.cmd<=trans_drv.cmd;
                      vif_drv.drv_cb.mode<=trans_drv.mode;
                      vif_drv.drv_cb.inp_valid<=trans_drv.inp_valid;
                      $display("Driver driving values because it got 11 at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d",$time,trans_drv.opa,trans_drv.opb,trans_drv.cin,trans_drv.ce,trans_drv.mode,trans_drv.cmd,trans_drv.inp_valid);
                      cg_drv.sample();
                      $display("INPUT FUNCTIONAL COVERAGE =%.2f ",cg_drv.get_coverage());
                      mbx_dr.put(trans_drv);
                      $display("Mailbox put happened at %0t inside 16 loop when i got 11 for transaction %0d",$time,i+1);
                     break;
                   end
                  else
                    begin
                      $display("Driver inside the else part repeat 16 loop but didnt get 11 at %0t",$time);
                      trans_drv.mode.rand_mode(0);
                      trans_drv.cmd.rand_mode(0);
                      trans_drv.ce.rand_mode(0);   //optional to prevent the non existence of 2'b11 within 16 cycles.
                      trans_drv.randomize();  //randomize with mode 0 for mode and cmd

                      $display("Driver driving constrained values because it didnt get 11 at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d",$time,trans_drv.opa,trans_drv.opb,trans_drv.cin,trans_drv.ce,trans_drv.mode,trans_drv.cmd,trans_drv.inp_valid);
                      cg_drv.sample();
                      $display("INPUT FUNCTIONAL COVERAGE =%.2f ",cg_drv.get_coverage());
                    end
                 end //end of second clocking block
                end  //end of 16 for loop
              end  //two input check
           else    //else part for one input
            begin
              vif_drv.drv_cb.opa<=trans_drv.opa;
              vif_drv.drv_cb.opb<=trans_drv.opb;
              vif_drv.drv_cb.cin<=trans_drv.cin;
              vif_drv.drv_cb.ce<=trans_drv.ce;
              vif_drv.drv_cb.cmd<=trans_drv.cmd;
              vif_drv.drv_cb.mode<=trans_drv.mode;
              vif_drv.drv_cb.inp_valid<=trans_drv.inp_valid;
              mbx_dr.put(trans_drv);
              $display("Mailbox put happened at %0t outside the 16 logic for direct single operand for transaction %0d",$time,i+1);
              $display("Driver driving values because it got single operand operation at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d",$time,trans_drv.opa,trans_drv.opb,trans_drv.cin,trans_drv.ce,trans_drv.mode,trans_drv.cmd,trans_drv.inp_valid);
              cg_drv.sample();
              $display("INPUT FUNCTIONAL COVERAGE =%.2f ",cg_drv.get_coverage());
            end
         end   //end of 01 or 10
     else    //else part for inp_valid is 11 or 00 directly in the 2 operand case
            begin
              vif_drv.drv_cb.opa<=trans_drv.opa;
              vif_drv.drv_cb.opb<=trans_drv.opb;
              vif_drv.drv_cb.cin<=trans_drv.cin;
              vif_drv.drv_cb.ce<=trans_drv.ce;
              vif_drv.drv_cb.cmd<=trans_drv.cmd;
              vif_drv.drv_cb.mode<=trans_drv.mode;
              vif_drv.drv_cb.inp_valid<=trans_drv.inp_valid;
              mbx_dr.put(trans_drv);
              $display("Mailbox put happened at %0t for direct 11 for transaction %0d",$time,i+1);
              $display("Driver driving values because it got 11 directly at first edge without waiting for 16 cycles at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d",$time,trans_drv.opa,trans_drv.opb,trans_drv.cin,trans_drv.ce,trans_drv.mode,trans_drv.cmd,trans_drv.inp_valid);
              cg_drv.sample();
              $display("INPUT FUNCTIONAL COVERAGE =%.2f ",cg_drv.get_coverage());
            end
        end   //end of clocking block

//Logic to delay the next driving value

       if(trans_drv.inp_valid inside {0,1,2,3} && ((trans_drv.mode==1 &&trans_drv.cmd inside {0,1,2,3,4,5,6,7,8})|| (trans_drv.mode==0 &&trans_drv.cmd inside {0,1,2,3,4,5,6,7,8,9,10,11,12,13})))
         repeat (1) @(vif_drv.drv_cb);
       else if(trans_drv.inp_valid==3 && (trans_drv.mode==1 && trans_drv.cmd inside {9,10}))
         repeat(2)@(vif_drv.drv_cb);

  end   //end of for loop
endtask

endclass
