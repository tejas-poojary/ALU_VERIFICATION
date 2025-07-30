`include "defines.sv"

class alu_test;

virtual alu_intf.ALU_DRV vif_drv;
virtual alu_intf.ALU_MON vif_mon;
virtual alu_intf.ALU_REF vif_ref;
alu_environment env;

function new(virtual alu_intf.ALU_DRV vif_drv,virtual alu_intf.ALU_MON vif_mon,virtual alu_intf.ALU_REF vif_ref);
 this.vif_drv=vif_drv;
 this.vif_mon=vif_mon;
 this.vif_ref=vif_ref;
endfunction

task run();
env=new(vif_drv,vif_mon,vif_ref);
env.build();
env.start();
endtask

endclass

/****************************************************--------------------------------------------------****************************************************/
 
class test1 extends alu_test;
  alu_transaction1 trans;
   	
function new(virtual alu_intf.ALU_DRV vif_drv,virtual alu_intf.ALU_MON vif_mon,virtual alu_intf.ALU_REF vif_ref);
       	   super.new(vif_drv,vif_mon,vif_ref);
 endfunction
  
   task run();
       	env = new(vif_drv,vif_mon,vif_ref);
      	env.build();
      	begin
           trans=new();
           env.gen.blueprint=trans;
         end
      	env.start();
   endtask
 endclass

class test2 extends alu_test;
   	alu_transaction2 trans;
 function new(virtual alu_intf.ALU_DRV vif_drv,virtual alu_intf.ALU_MON vif_mon,virtual alu_intf.ALU_REF vif_ref);
       	  super.new(vif_drv,vif_mon,vif_ref);
     endfunction
  
   task run();
       	env = new(vif_drv,vif_mon,vif_ref);
       	env.build();
       	begin
           trans = new();
           env.gen.blueprint=trans;
         end
       	env.start();
   endtask
 endclass


 class test3 extends alu_test;
   	alu_transaction3 trans;
  function new(virtual alu_intf.ALU_DRV vif_drv,virtual alu_intf.ALU_MON vif_mon,virtual alu_intf.ALU_REF vif_ref);
       	super.new(vif_drv,vif_mon,vif_ref);
   endfunction
  
   task run();
       	env = new(vif_drv,vif_mon,vif_ref);
       	env.build();
       	begin
           trans = new();
           env.gen.blueprint=trans;
         end
       	env.start();
  endtask
endclass

class test4 extends alu_test;
   	alu_transaction4 trans;
  function new(virtual alu_intf.ALU_DRV vif_drv,virtual alu_intf.ALU_MON vif_mon,virtual alu_intf.ALU_REF vif_ref);
       	super.new(vif_drv,vif_mon,vif_ref);
  endfunction
  
   task run();
       	env = new(vif_drv,vif_mon,vif_ref);
       	env.build();
       	begin
           trans = new();
           env.gen.blueprint=trans;
         end
       	env.start();
  endtask
 endclass
    
 class test_regression extends alu_test;
   	alu_transaction trans0;
   	//alu_transaction1 trans1;
        //alu_transaction2 trans2;
       //alu_transaction3 trans3;
       //alu_transaction4 trans4;
  
  function new(virtual alu_intf.ALU_DRV vif_drv,virtual alu_intf.ALU_MON vif_mon,virtual alu_intf.ALU_REF vif_ref);
       super.new(vif_drv,vif_mon,vif_ref);
  endfunction
  	
   task run();
       	$display("child test");
       	env = new(vif_drv,vif_mon,vif_ref);
       	env.build();
       	begin
           trans0 = new();
           env.gen.blueprint=trans0;
         end
       	env.start();
      	begin
           trans1 = new();
           env.gen.blueprint=trans1;
         end
       	env.start();
        begin
           trans2 = new();
           env.gen.blueprint=trans2;
        end
       	env.start();
       	begin
           trans3 = new();
           env.gen.blueprint=trans3;
         end
       env.start();
        begin
            trans4 = new();
            env.gen.blueprint=trans4;
          end
      env.start();
   	endtask
 endclass
