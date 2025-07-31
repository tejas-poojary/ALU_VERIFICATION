`include "defines.sv"
`define ADD 0
`define SUB 1
`define ADD_CIN 2
`define SUB_CIN 3
`define INC_A 4
`define DEC_A 5
`define INC_B 6
`define DEC_B 7
`define CMP 8
`define INC_MUL 9
`define SHIFT_MUL 10
`define AND 0
`define NAND 1
`define OR 2
`define NOR 3
`define XOR 4
`define XNOR 5
`define NOT_A 6
`define NOT_B 7
`define SHR1_A 8
`define SHL1_A 9
`define SHR1_B 10
`define SHL1_B 11
`define ROL_A_B 12
`define ROR_A_B 13

class alu_reference_model;

mailbox #(alu_transaction) mbx_dr;
mailbox #(alu_transaction) mbx_rs;
alu_transaction ref_trans;
virtual alu_intf.ALU_REF vif_ref;

function new(mailbox #(alu_transaction) mbx_dr,
               mailbox #(alu_transaction) mbx_rs,
               virtual alu_intf.ALU_REF vif_ref);
    this.mbx_dr=mbx_dr;
    this.mbx_rs=mbx_rs;
    this.vif_ref=vif_ref;
  endfunction

  int shift_value,got,inside_16;
  localparam int required_bits = $clog2(`n);


task start();
  repeat(1)@(vif_ref.ref_cb);
    begin
  for(int i=0;i<`no_transactions;i++)
    begin
      got=0;  //make got zero initially foreach transaction
      ref_trans=new();
      if(inside_16==1)
        mbx_dr.get(ref_trans);
      else
        begin
          @(vif_ref.ref_cb);
          mbx_dr.get(ref_trans);
        end
        inside_16=0;
     $display("Reference model got values from first get for transaction %0d at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,INP_VALID=%0d,CMD=%0d",i+1,$time,ref_trans.opa,ref_trans.opb,ref_trans.cin,ref_trans.ce,ref_trans.mode,ref_trans.inp_valid,ref_trans.cmd);
         if(vif_ref.ref_cb.reset==1)
           begin
             ref_trans.res=9'bz;
             ref_trans.oflow=1'bz;
             ref_trans.cout=1'bz;
             ref_trans.g=1'bz;
             ref_trans.l=1'bz;
             ref_trans.e=1'bz;
             ref_trans.err=1'bz;
           end
         else   //else if reset is not 1
           begin
             if(ref_trans.ce==1)    //check for clock enable
              begin
                 if(ref_trans.inp_valid == 2'b01 || ref_trans.inp_valid == 2'b10)     //16 cycle delay logic
                     begin
                       if(((ref_trans.mode==1)&& (ref_trans.cmd inside {0,1,2,3,8,9,10})) || ((ref_trans.mode==0)&& (ref_trans.cmd inside {0,1,2,3,4,5,12,13})))   //inp_valid is 01 or 10 at first clock but cmd is 2 operand operation
                         begin

                           mbx_dr.get(ref_trans);  // removed get hereeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee

                           $display("Inside the 16 cycle logic and");
                           $display("Reference model got values from second get for transaction %0d at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,INP_VALID=%0d,CMD=%0d",i+1,$time,ref_trans.opa,ref_trans.opb,ref_trans.cin,ref_trans.ce,ref_trans.mode,ref_trans.inp_valid,ref_trans.cmd);

                           repeat(16)@(vif_ref.ref_cb)      //or for loop
                           begin
                             inside_16=1;
                           if(ref_trans.inp_valid==2'b11)  //perform all operations also
                            begin
                              got=1;
                             if(ref_trans.mode==1)
                               begin
                                case(ref_trans.cmd)
                                  `ADD:begin
                                            ref_trans.res=(ref_trans.opa+ref_trans.opb);
                                            ref_trans.cout=ref_trans.res[`n+1]?1:0;
                                              end
                                      `SUB:begin
                                           ref_trans.res=(ref_trans.opa-ref_trans.opb);
                                           ref_trans.oflow=(ref_trans.opa<ref_trans.opb)?1:0;
                                              end
                                      `ADD_CIN:begin
                                                 ref_trans.res=(ref_trans.opa+ref_trans.opb+ref_trans.cin);
                                                 ref_trans.cout=ref_trans.res[`n+1]?1:0;
                                              end
                                      `SUB_CIN:begin
                                                 ref_trans.res=(ref_trans.opa-ref_trans.opb-ref_trans.cin);
                                                 ref_trans.oflow=((ref_trans.opa<ref_trans.opb)||((ref_trans.opa==ref_trans.opb)&&ref_trans.cin))?1:0;
                                               end
                                  `CMP:begin
                                          ref_trans.e=(ref_trans.opa==ref_trans.opb)? 1'b1:1'b0;
                                          ref_trans.g=(ref_trans.opa>ref_trans.opb)? 1'b1:1'b0;
                                          ref_trans.l=(ref_trans.opa<ref_trans.opb)? 1'b1:1'b0;
                                      end
                                  `INC_MUL:begin
                                              ref_trans.res=(ref_trans.opa+1)*(ref_trans.opb+1);
                                          end
                                  `SHIFT_MUL:begin
                                               ref_trans.res=(ref_trans.opa<<1)*(ref_trans.opb);
                                            end
                                  default:begin
                                               ref_trans.res=9'bz;
                                               ref_trans.oflow=1'bz;
                                               ref_trans.cout=1'bz;
                                               ref_trans.err=1'bz;
                                               ref_trans.g=1'bz;
                                               ref_trans.l=1'bz;
                                               ref_trans.e=1'bz;
                                          end
                                endcase
                               end     //end of if mode==1
                  else              //else part for mode=0
                    begin
                      case(ref_trans.cmd)
                        `AND:begin
                                ref_trans.res={1'b0,(ref_trans.opa & ref_trans.opb)};
                            end
                        `NAND:begin
                               ref_trans.res={1'b0,~(ref_trans.opa & ref_trans.opb)};
                            end
                        `OR:begin
                               ref_trans.res={1'b0,(ref_trans.opa | ref_trans.opb)};
                            end
                        `NOR:begin
                               ref_trans.res={1'b0,~(ref_trans.opa | ref_trans.opb)};
                            end
                        `XOR:begin
                               ref_trans.res={1'b0,(ref_trans.opa ^ ref_trans.opb)};
                            end
                        `XNOR:begin
                                ref_trans.res={1'b0,~(ref_trans.opa ^ ref_trans.opb)};
                            end
                        `ROL_A_B:begin
                                 shift_value=ref_trans.opb[required_bits-1:0];
                                 ref_trans.res={1'b0,((ref_trans.opa<<shift_value)|(ref_trans.opa>>`n-shift_value))};
                                 if(ref_trans.opb>`n-1)
                                  ref_trans.err=1;
                                 else
                                  ref_trans.err=0;
                                end
                        `ROR_A_B:begin
                                 shift_value=ref_trans.opb[required_bits-1:0];
                                 ref_trans.res={1'b0,((ref_trans.opa>>shift_value)|(ref_trans.opa<<`n-shift_value))};
                                if(ref_trans.opb>`n-1)
                                  ref_trans.err=1;
                                 else
                                  ref_trans.err=0;
                                end
                        default:begin
                               ref_trans.res=9'bz;
                               ref_trans.oflow=1'bz;
                               ref_trans.cout=1'bz;
                               ref_trans.g=1'bz;
                               ref_trans.l=1'bz;
                               ref_trans.e=1'bz;
                              ref_trans.err=1'bz;
                              end
                      endcase
                  end // end of mode==0
                if(got==1)
                   break;         //to break once after we get 11 within any of the 16 cycles
             end              //end of if inp_valid becomes 11 within 16 cycle
           end    //end of repeat(16)
              if(got==1 && ref_trans.err==1)
                  ref_trans.err=1;    //raising error based on got flag
              else if(got==1 && ref_trans.err==0)
                  ref_trans.err=0;
              else
                  ref_trans.err=1;
         end   //end for 2 input mode and cmd check
    else if((ref_trans.mode==1 && ref_trans.cmd inside {4,5,6,7}) || (ref_trans.mode==0 && ref_trans.cmd inside {6,7,8,9,10,11}))      //else loop for single operand operatons
      begin

       if(ref_trans.mode==1)
          begin
            if(ref_trans.inp_valid==01)
              begin
               case(ref_trans.cmd)
                `INC_A:begin
                        ref_trans.res=ref_trans.opa+1;
                    end
                `DEC_A:begin
                        ref_trans.res=ref_trans.opa-1;
                    end
                 default:begin
                        ref_trans.res=9'bz;
                        ref_trans.oflow=1'bz;
                        ref_trans.cout=1'bz;
                        ref_trans.g=1'bz;
                        ref_trans.l=1'bz;
                        ref_trans.e=1'bz;
                        ref_trans.err=1'bz;
                      end
               endcase //endcase for 01
            end //end for 01
         else  //for 10
           begin
             case(ref_trans.cmd)
               `INC_B:begin
                        ref_trans.res=ref_trans.opb+1;
                      end
                `DEC_B:begin
                        ref_trans.res=ref_trans.opb-1;
                      end
                 default:begin
                        ref_trans.res=9'bz;
                        ref_trans.oflow=1'bz;
                        ref_trans.cout=1'bz;
                        ref_trans.g=1'bz;
                        ref_trans.l=1'bz;
                        ref_trans.e=1'bz;
                        ref_trans.err=1'bz;
                      end
              endcase
            end
          end //end of mode 1
        else   //for mode=0
          begin
          if(ref_trans.inp_valid==2'b01)
            begin
            case(ref_trans.cmd)
              `NOT_A:begin
                        ref_trans.res={1'b0,~(ref_trans.opa)};
                    end
              `SHR1_A:begin
                       ref_trans.res={1'b0,(ref_trans.opa>>1)};
                    end
              `SHL1_A:begin
                        ref_trans.res={1'b0,(ref_trans.opa<<1)};
                    end
              default:begin
                        ref_trans.res=9'bz;
                        ref_trans.oflow=1'bz;
                        ref_trans.cout=1'bz;
                        ref_trans.g=1'bz;
                        ref_trans.l=1'bz;
                        ref_trans.e=1'bz;
                        ref_trans.err=1'bz;
                      end
             endcase
            end  //end for if 01
          else
             begin
               case(ref_trans.cmd)
               `NOT_B:begin
                       ref_trans.res={1'b0,~(ref_trans.opb)};
                      end
                `SHR1_B:begin
                         ref_trans.res={1'b0,(ref_trans.opb>>1)};
                        end
                `SHL1_B:begin
                         ref_trans.res={1'b0,(ref_trans.opb<<1)};
                        end
                  default:begin
                        ref_trans.res=9'bz;
                        ref_trans.oflow=1'bz;
                        ref_trans.cout=1'bz;
                        ref_trans.g=1'bz;
                        ref_trans.l=1'bz;
                        ref_trans.e=1'bz;
                        ref_trans.err=1'bz;
                      end
                endcase
             end
           end //end of else mode=0
      end     //end of single input operands
  end      // end of check for input valid 01 or 10
else if (ref_trans.inp_valid==2'b11)    //else if 11 directly
  begin
      if(ref_trans.mode==1)
        begin
            case(ref_trans.cmd)
                             `ADD:begin
                                    ref_trans.res=(ref_trans.opa+ref_trans.opb);
                                    ref_trans.cout=ref_trans.res[`n+1]?1:0;
                                  end
                                 `SUB:begin
                                        ref_trans.res=(ref_trans.opa-ref_trans.opb);
                                        ref_trans.oflow=(ref_trans.opa<ref_trans.opb)?1:0;
                                         end
                                 `ADD_CIN:begin
                                            ref_trans.res=(ref_trans.opa+ref_trans.opb+ref_trans.cin);
                                            ref_trans.cout=ref_trans.res[`n+1]?1:0;
                                         end
                                `SUB_CIN:begin
                                             ref_trans.res=(ref_trans.opa-ref_trans.opb-ref_trans.cin);
                                             ref_trans.oflow=((ref_trans.opa<ref_trans.opb)||((ref_trans.opa==ref_trans.opb)&&ref_trans.cin))?1:0;
                                         end
                                `CMP:begin
                                        ref_trans.e=(ref_trans.opa==ref_trans.opb)? 1'b1:1'b0;
                                        ref_trans.g=(ref_trans.opa>ref_trans.opb)? 1'b1:1'b0;
                                        ref_trans.l=(ref_trans.opa<ref_trans.opb)? 1'b1:1'b0;
                                      end
                           `INC_MUL:begin
                                     ref_trans.res=(ref_trans.opa+1)*(ref_trans.opb+1);
                                   end
                           `SHIFT_MUL:begin
                                       ref_trans.res=(ref_trans.opa<<1)*(ref_trans.opb);
                                     end
                           `INC_A:begin
                                   ref_trans.res=ref_trans.opa+1;
                                  end
                           `DEC_A:begin
                                  ref_trans.res=ref_trans.opa-1;
                                  end
                          `INC_B:begin
                                  ref_trans.res=ref_trans.opb+1;
                                 end
                         `DEC_B:begin
                                 ref_trans.res=ref_trans.opb-1;
                                end
                           default:begin
                                        ref_trans.res=9'bz;
                                        ref_trans.oflow=1'bz;
                                        ref_trans.cout=1'bz;
                                        ref_trans.g=1'bz;
                                        ref_trans.l=1'bz;
                                        ref_trans.e=1'bz;
                                        ref_trans.err=1'bz;
                                   end
                        endcase
                    end  //end of if mode==1
                  else               //else part for mode=0
                    begin
                      case(ref_trans.cmd)
                        `AND:begin
                                ref_trans.res={1'b0,(ref_trans.opa & ref_trans.opb)};
                            end
                        `NAND:begin
                               ref_trans.res={1'b0,~(ref_trans.opa & ref_trans.opb)};
                            end
                        `OR:begin
                               ref_trans.res={1'b0,(ref_trans.opa | ref_trans.opb)};
                            end
                        `NOR:begin
                               ref_trans.res={1'b0,~(ref_trans.opa | ref_trans.opb)};
                            end
                        `XOR:begin;
                               ref_trans.res={1'b0,(ref_trans.opa ^ ref_trans.opb)};
                            end
                        `XNOR:begin
                                ref_trans.res={1'b0,~(ref_trans.opa ^ ref_trans.opb)};
                            end
                        `ROL_A_B:begin
                                 shift_value=ref_trans.opb[required_bits-1:0];
                                 ref_trans.res={1'b0,((ref_trans.opa<<shift_value)|(ref_trans.opa>>`n-shift_value))};
                                 if(ref_trans.opb>`n-1)
                                  ref_trans.err=1;
                                 else
                                  ref_trans.err=0;
                                end
                        `ROR_A_B:begin
                                 shift_value=ref_trans.opb[required_bits-1:0];
                                 ref_trans.res={1'b0,((ref_trans.opa>>shift_value)|(ref_trans.opa<<`n-shift_value))};
                                if(ref_trans.opb>`n-1)
                                  ref_trans.err=1;
                                 else
                                  ref_trans.err=0;
                                end
                         `NOT_A:begin
                                 ref_trans.res={1'b0,~(ref_trans.opa)};
                                end
                         `NOT_B:begin
                                ref_trans.res={1'b0,~(ref_trans.opb)};
                                end
                         `SHR1_A:begin
                                 ref_trans.res={1'b0,(ref_trans.opa>>1)};
                                 end
                        `SHL1_A:begin
                                ref_trans.res={1'b0,(ref_trans.opa<<1)};
                                end
                        `SHR1_B:begin
                                 ref_trans.res={1'b0,(ref_trans.opb>>1)};
                                end
                        `SHL1_B:begin
                                 ref_trans.res={1'b0,(ref_trans.opb<<1)};
                                end

                        default:begin
                                 ref_trans.res=9'bz;
                                 ref_trans.oflow=1'bz;
                                 ref_trans.cout=1'bz;
                                 ref_trans.g=1'bz;
                                 ref_trans.l=1'bz;
                                 ref_trans.e=1'bz;
                                 ref_trans.err=1'bz;
                              end
                      endcase
                  end       //end of else mode==0
            end        //end of inp_valid=11 directly case
   else   //input valid is 00
     begin
       ref_trans.res=ref_trans.res;
       ref_trans.oflow=ref_trans.oflow;
       ref_trans.cout=ref_trans.cout;
       ref_trans.g=ref_trans.g;
       ref_trans.l=ref_trans.l;
       ref_trans.e=ref_trans.e;
       ref_trans.err=ref_trans.err;
     end  //end of 00
  end    //end of ce=1
else   //if ce=0
    begin
       ref_trans.res=ref_trans.res;
       ref_trans.oflow=ref_trans.oflow;
       ref_trans.cout=ref_trans.cout;
       ref_trans.g=ref_trans.g;
       ref_trans.l=ref_trans.l;
       ref_trans.e=ref_trans.e;
       ref_trans.err=ref_trans.err;
     end
  end   //end of else loop for reset!=1

if( ref_trans.inp_valid inside {0,1,2,3} && ((ref_trans.mode==1 && ref_trans.cmd inside {0,1,2,3,4,5,6,7,8})|| (ref_trans.mode==0 && ref_trans.cmd inside {0,1,2,3,4,5,6,7,8,9,10,11,12,13})))
 repeat(1)@(vif_ref.ref_cb);
else if(ref_trans.inp_valid==3 && ref_trans.mode==1 && ref_trans.cmd inside {9,10})
 repeat(2)@(vif_ref.ref_cb);

mbx_rs.put(ref_trans);    //put to the mailbox

$display("Reference model putting values to the mailbox of scoreboard for transaction %0d at %0t :OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d,RES=%0d,ERR=%0d,COUT=%0d,OFLOW=%0d,G=%0d,L=%0d,E=%0d",i+1,$time,ref_trans.opa,ref_trans.opb,ref_trans.cin,ref_trans.ce,ref_trans.mode,ref_trans.cmd,ref_trans.inp_valid,ref_trans.res,ref_trans.err,ref_trans.cout,ref_trans.oflow,ref_trans.g,ref_trans.l,ref_trans.e);

end   //end of transaction for loop

end
endtask


endclass

