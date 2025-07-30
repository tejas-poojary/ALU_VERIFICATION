`include "defines.sv"

class alu_scoreboard;

alu_transaction ref2sb;
alu_transaction mon2sb;
mailbox #(alu_transaction) mbx_ms;
mailbox #(alu_transaction) mbx_rs;

function new(mailbox #(alu_transaction) mbx_ms,mailbox #(alu_transaction) mbx_rs);
this.mbx_ms=mbx_ms;
this.mbx_rs=mbx_rs;
endfunction


int res_match,res_mismatch,err_match,err_mismatch,cout_match,cout_mismatch,oflow_match,oflow_mismatch,g_match,g_mismatch,l_match,l_mismatch,e_match, e_mismatch,overall_match,overall_mismatch;      //declare all count flags

task start();
for(int i=0;i<`no_transactions;i++)
 begin
  $display("SCOREBOARD RESULTS FOR TRANSACTION %0d",i+1);
  ref2sb=new();
  mon2sb=new();
  fork
    begin
     mbx_ms.get(mon2sb);
     $display("Monitor values at scoreboard @ %0t for transaction %0d:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d,RES=%0d,ERR=%0d,OFLOW=%0d,G=%0d,L=%0d,E=%0d",$time,i+1,mon2sb.opa,mon2sb.opb,mon2sb.cin,mon2sb.ce,mon2sb.mode,mon2sb.cmd,mon2sb.inp_valid,mon2sb.res,mon2sb.err,mon2sb.oflow,mon2sb.g,mon2sb.l,mon2sb.e);
     $display("---------------------------------------------------------------------------------");
    end
    begin
     mbx_rs.get(ref2sb);
     $display("---------------------------------------------------------------------------------");
     $display("Reference model values at scoreboard @ %0t for transaction %0d:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d,RES=%0d,ERR=%0d,OFLOW=%0d,G=%0d,L=%0d,E=%0d",$time,i+1,ref2sb.opa,ref2sb.opb,ref2sb.cin,ref2sb.ce,ref2sb.mode,ref2sb.cmd,ref2sb.inp_valid,ref2sb.res,ref2sb.err,ref2sb.oflow,ref2sb.g,ref2sb.l,ref2sb.e);
    end
  join
   compare_report();
end
endtask

task compare_report();
begin
  fork
   begin
     if(mon2sb.res==ref2sb.res)
      begin
       res_match++;
        $display("Result Match Successful: Monitor RES=%0d,Reference model RES=%0d",mon2sb.res,ref2sb.res);
      end
     else
       begin
        res_mismatch++;
        $display("Result Match Unsuccessful: Monitor RES=%0d,Reference model RES=%0d",mon2sb.res,ref2sb.res);
       end
   end

   begin
     if(mon2sb.err==ref2sb.err)
      begin
       err_match++;
        $display("Error Match Successful: Monitor ERR=%0d,Reference model ERR=%0d",mon2sb.err,ref2sb.err);
      end
     else
       begin
        err_mismatch++;
        $display("Error Match Unsuccessful: Monitor ERR=%0d,Reference model ERR=%0d",mon2sb.err,ref2sb.err);
       end
   end

   begin
     if(mon2sb.cout==ref2sb.cout)
      begin
       cout_match++;
        $display("Carry out Match Successful: Monitor COUT=%0d,Reference model COUT=%0d",mon2sb.cout,ref2sb.cout);
      end
     else
       begin
        cout_mismatch++;
        $display("Carry out Match Unsuccessful: Monitor COUT=%0d,Reference model COUT=%0d",mon2sb.cout,ref2sb.cout);
       end
   end

   begin
     if(mon2sb.oflow==ref2sb.oflow)
      begin
       oflow_match++;
        $display("Overflow Match Successful: Monitor OFLOW=%0d,Reference model OFLOW=%0d",mon2sb.oflow,ref2sb.oflow);
      end
     else
       begin
        oflow_mismatch++;
        $display("Overflow Match Unsuccessful: Monitor OFLOW=%0d,Reference model OFLOW=%0d",mon2sb.oflow,ref2sb.oflow);
       end
   end

   begin
     if(mon2sb.g==ref2sb.g)
      begin
       g_match++;
        $display("Greater Match Successful: Monitor G=%0d,Reference model G=%0d",mon2sb.g,ref2sb.g);
      end
     else
       begin
        g_mismatch++;
        $display("Greater Match Unsuccessful: Monitor G=%0d,Reference model G=%0d",mon2sb.g,ref2sb.g);
       end
   end

   begin
     if(mon2sb.l==ref2sb.l)
      begin
       l_match++;
        $display("Lesser Match Successful: Monitor L=%0d,Reference model L=%0d",mon2sb.l,ref2sb.l);
      end
     else
       begin
        l_mismatch++;
        $display("Lesser Match Unsuccessful: Monitor L=%0d,Reference model L=%0d",mon2sb.l,ref2sb.l);
       end
   end

   begin
     if(mon2sb.e==ref2sb.e)
      begin
       e_match++;
        $display("Equal Match Successful: Monitor E=%0d,Reference model E=%0d",mon2sb.e,ref2sb.e);
      end
     else
       begin
        e_mismatch++;
        $display("Equal Match Unsuccessful: Monitor E=%0d,Reference model E=%0d",mon2sb.e,ref2sb.e);
       end
   end
join

if((mon2sb.res==ref2sb.res)&&(mon2sb.err==ref2sb.err)&&(mon2sb.cout==ref2sb.cout)&&(mon2sb.oflow==ref2sb.oflow)&&(mon2sb.g==ref2sb.g)&&(mon2sb.l==ref2sb.l)&&(mon2sb.e==ref2sb.e))
 begin
  overall_match++;
  $display("Overall Match Sucessfull %0d",overall_match);
 end
else
 begin
  overall_mismatch++;
  $display("Overall Match Unsucessfull %0d",overall_mismatch);
 end

end
$display("*************************************************************************************************************");

endtask

endclass
