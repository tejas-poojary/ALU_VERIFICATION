`include "defines.sv"

class alu_transaction;
rand bit cin,ce,mode;
rand bit [1:0] inp_valid;
rand bit [`n-1:0] opa,opb;
rand bit [`m-1:0] cmd;

bit err,oflow,g,l,e,cout;
bit [`n:0]res;

constraint clk_en { ce dist {0:=10,1:=90}; }
constraint input_valid { inp_valid dist {[1:3]:=90,0:=10};}
constraint command {if(mode)
                       cmd inside {[0:10]};
                    else
                       cmd inside {[0:13]};
                   }
//constraint set{cmd==9;mode==1;inp_valid inside {1,3};}
//constraint set{cmd==9;mode==1;inp_valid==3;}

virtual function alu_transaction copy();
copy=new();
copy.cin=this.cin;
copy.ce=this.ce;
copy.mode=this.mode;
copy.inp_valid=this.inp_valid;
copy.opb=this.opb;
copy.opa=this.opa;
copy.cmd=this.cmd;
copy.g=this.g;
copy.l=this.l;
copy.e=this.e;
copy.res=this.res;
copy.err=this.err;
copy.cout=this.cout;
copy.oflow=this.oflow;
return copy;
endfunction

endclass

/////////////////---------------------------------------------------------------------------------------------------------------------///////////////////

 class alu_transaction1 extends alu_transaction;
   constraint LOGICAL_1{ inp_valid == 2'b11;
                         mode== 0;
                         ce== 1;
                         cin == 1;
                         cmd inside{[6:11]};
                       }
  virtual function alu_transaction copy();
    alu_transaction1 copy1;
        copy1 = new();
        copy1.inp_valid = this.inp_valid;
        copy1.mode = this.mode;
        copy1.cmd = this.cmd;
        copy1.ce = this.ce;
        copy1.opa = this.opa;
        copy1.opb = this.opb;
        copy1.cin = this.cin;
        return copy1;
    endfunction
endclass


class alu_transaction2 extends alu_transaction;
  constraint ARITHMETIC_1{ inp_valid == 2'b11;
                         mode == 1;
                         ce == 1;
                         cin == 1;
                         cmd inside{[0:3],[8:10]};
                       }
  virtual function alu_transaction copy();
    alu_transaction2 copy2;
        copy2 = new();
        copy2.inp_valid = this.inp_valid;
        copy2.mode = this.mode;
        copy2.cmd = this.cmd;
        copy2.ce = this.ce;
        copy2.opa = this.opa;
        copy2.opa = this.opb;
        copy2.cin = this.cin;
        return copy2;
    endfunction
endclass


class alu_transaction3 extends alu_transaction;
  constraint LOGICAL_2{  inp_valid == 2'b11;
                       mode == 0;
                       ce == 1;
                       cin == 1;
                       cmd inside{[0:5],12,13};
                                           }
  virtual function alu_transaction copy();
    alu_transaction3 copy3;
        copy3 = new();
        copy3.inp_valid = this.inp_valid;
        copy3.mode = this.mode;
        copy3.cmd= this.cmd;
        copy3.ce = this.ce;
        copy3.opa = this.opa;
        copy3.opb = this.opb;
        copy3.cin = this.cin;
        return copy3;
    endfunction
endclass

class alu_transaction4 extends alu_transaction;
  constraint ARITHMETIC_2{ inp_valid == 2'b11;
                           mode == 1;
                           ce == 1;
                           cin == 1;
                           cmd inside{[4:7]};
                         }

  virtual function alu_transaction copy();
    alu_transaction4 copy4;
        copy4 = new();
        copy4.inp_valid = this.inp_valid;
        copy4.mode = this.mode;
        copy4.cmd= this.cmd;
        copy4.ce = this.ce;
        copy4.opa = this.opa;
        copy4.opb = this.opb;
        copy4.cin = this.cin;
        return copy4;
    endfunction
endclass
