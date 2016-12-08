#include <cstdio>
#include <cstring>
#define PERIOD 20
#define ASCII
#define FILEIN
unsigned int carryimm16(unsigned int &inst, int imm){
  imm &= 0xFFFF;
  inst |= imm;
}
unsigned int put3reg(unsigned int &inst, int reg1, int reg2, int reg3){
  inst |= (reg1&31) << 21;
  inst |= (reg2&31) << 16;
  inst |= (reg3&31) << 11;
}
unsigned int put2reg(unsigned int &inst, int reg1, int reg2){
  inst |= (reg1&31) << 21;
  inst |= (reg2&31) << 16;
}
unsigned int specialinst(unsigned int &inst, unsigned int func){
  inst |= func;
}
unsigned int MIPS_trans(unsigned int x){
  return ((x&0x000000FF) << 24) | ((x&0x0000FF00) << 8) | ((x&0x00FF0000) >> 8) | ((x&0xFF000000) >> 24);
}
int main(){
  char type[10];
  int arg0, arg1, arg2;
  unsigned int inst;
  #ifdef FILEIN
  FILE *fin = fopen("inst.s", "r");
  #else
  FILE *fin = stdin;
  #endif
  #ifndef BINARY
  FILE *fout = fopen("inst.txt", "w");
  #else
  FILE *fout = fopen("inst.mem", "wb");
  #endif
  int inst_count = 0;
  #ifdef ADDR
  const unsigned int ADDRBASE = 0x80000000;
  #endif
  while(1){
    inst = 0;
    fscanf(fin, "%s", type);
    if(strcmp(type, "ori") == 0){
      fscanf(fin, "%d%d%x", &arg0, &arg1, &arg2);
      carryimm16(inst, arg2);
      inst |= 0x34000000;
      put2reg(inst, arg1, arg0);
    }
    else if(strcmp(type, "or") == 0){
      fscanf(fin, "%d%d%d", &arg0, &arg1, &arg2);
      specialinst(inst, 0x25);
      put3reg(inst, arg1, arg2, arg0);
    }
    else if(strcmp(type, "xor") == 0){
      fscanf(fin, "%d%d%d", &arg0, &arg1, &arg2);
      specialinst(inst, 0x26);
      put3reg(inst, arg1, arg2, arg0);
    }
    else if(strcmp(type, "nor") == 0){
      fscanf(fin, "%d%d%d", &arg0, &arg1, &arg2);
      specialinst(inst, 0x27);
      put3reg(inst, arg1, arg2, arg0);
    }
    else if(strcmp(type, "xori") == 0){
      fscanf(fin, "%d%d%x", &arg0, &arg1, &arg2);
      carryimm16(inst, arg2);
      inst |= 0x38000000;
      put2reg(inst, arg1, arg0);
    }
    else if(strcmp(type, "andi") == 0){
      fscanf(fin, "%d%d%x", &arg0, &arg1, &arg2);
      carryimm16(inst, arg2);
      inst |= 0x30000000;
      put2reg(inst, arg1, arg0);
    }
    else if(strcmp(type, "and") == 0){
      fscanf(fin, "%d%d%d", &arg0, &arg1, &arg2);
      specialinst(inst, 0x24);
      put3reg(inst, arg1, arg2, arg0);
    }
    else if(strcmp(type, "addiu") == 0){
      fscanf(fin, "%d%d%x", &arg0, &arg1, &arg2);
      carryimm16(inst, arg2);
      inst |= 0x24000000;
      put2reg(inst, arg1, arg0);
    }
    else if(strcmp(type, "lui") == 0){
      fscanf(fin, "%d%x", &arg0, &arg1);
      carryimm16(inst, arg1);
      inst |= 0x3C000000;
      put2reg(inst, 0, arg0);
    }
    else if(strcmp(type, "addu") == 0){
      fscanf(fin, "%d%d%d", &arg0, &arg1, &arg2);
      specialinst(inst, 0x21);
      put3reg(inst, arg1, arg2, arg0);
    }
    else if(strcmp(type, "subu") == 0){
      fscanf(fin, "%d%d%d", &arg0, &arg1, &arg2);
      specialinst(inst, 0x23);
      put3reg(inst, arg1, arg2, arg0);
    }
    else if(strcmp(type, "slt") == 0){
      fscanf(fin, "%d%d%d", &arg0, &arg1, &arg2);
      specialinst(inst, 0x2A);
      put3reg(inst, arg1, arg2, arg0);
    }
    else if(strcmp(type, "sltu") == 0){
      fscanf(fin, "%d%d%d", &arg0, &arg1, &arg2);
      specialinst(inst, 0x2B);
      put3reg(inst, arg1, arg2, arg0);
    }
    else if(strcmp(type, "slti") == 0){
      fscanf(fin, "%d%d%x", &arg0, &arg1, &arg2);
      carryimm16(inst, arg2);
      inst |= 0x28000000;
      put2reg(inst, arg1, arg0);
    }
    else if(strcmp(type, "sltiu") == 0){
      fscanf(fin, "%d%d%x", &arg0, &arg1, &arg2);
      carryimm16(inst, arg2);
      inst |= 0x2C000000;
      put2reg(inst, arg1, arg0);
    }
    else if(strcmp(type, "mult") == 0){
      fscanf(fin, "%d%d", &arg0, &arg1);
      carryimm16(inst, 0x18);
      put2reg(inst, arg0, arg1);
    }
    else if(strcmp(type, "lw") == 0){
      fscanf(fin, "%d%d%x", &arg0, &arg1, &arg2);
      carryimm16(inst, arg2);
      inst |= 0x8C000000;
      put2reg(inst, arg1, arg0);
    }
    else if(strcmp(type, "sw") == 0){
      fscanf(fin, "%d%d%x", &arg0, &arg1, &arg2);
      carryimm16(inst, arg2);
      inst |= 0xAC000000;
      put2reg(inst, arg1, arg0);
    }
    else if(strcmp(type, "lb") == 0){
      fscanf(fin, "%d%d%x", &arg0, &arg1, &arg2);
      carryimm16(inst, arg2);
      inst |= 0x80000000;
      put2reg(inst, arg1, arg0);
    }
    else if(strcmp(type, "lbu") == 0){
      fscanf(fin, "%d%d%x", &arg0, &arg1, &arg2);
      carryimm16(inst, arg2);
      inst |= 0x90000000;
      put2reg(inst, arg1, arg0);
    }
    else if(strcmp(type, "sb") == 0){
      fscanf(fin, "%d%d%x", &arg0, &arg1, &arg2);
      carryimm16(inst, arg2);
      inst |= 0xA0000000;
      put2reg(inst, arg1, arg0);
    }
    else if(strcmp(type, "lhu") == 0){
      fscanf(fin, "%d%d%x", &arg0, &arg1, &arg2);
      carryimm16(inst, arg2);
      inst |= 0x94000000;
      put2reg(inst, arg1, arg0);
    }
    else if(strcmp(type, "sll") == 0){
      fscanf(fin, "%d%d%d", &arg0, &arg1, &arg2);
      put3reg(inst,0x0, arg1, arg0);
      inst |= (arg2 & 31)<<6;
    }
    else if(strcmp(type, "srl") == 0){
      fscanf(fin, "%d%d%d", &arg0, &arg1, &arg2);
      put3reg(inst,0x0, arg1, arg0);
      inst |= (arg2 & 31)<<6;
      inst |= 0x2;
    }
    else if(strcmp(type, "sra") == 0){
      fscanf(fin, "%d%d%d", &arg0, &arg1, &arg2);
      put3reg(inst,0x0, arg1, arg0);
      inst |= (arg2 & 31)<<6;
      inst |= 0x3;
    }
    else if(strcmp(type, "sllv") == 0){
      fscanf(fin, "%d%d%d", &arg0, &arg1, &arg2);
      put3reg(inst, arg2, arg1, arg0);
      inst |= 0x4;
    }
    else if(strcmp(type, "srlv") == 0){
      fscanf(fin, "%d%d%d", &arg0, &arg1, &arg2);
      put3reg(inst, arg2, arg1, arg0);
      inst |= 0x6;
    }
    else if(strcmp(type, "srav") == 0){
      fscanf(fin, "%d%d%d", &arg0, &arg1, &arg2);
      put3reg(inst, arg2, arg1, arg0);
      inst |= 0x7;
    }
    else if(strcmp(type, "mfhi") == 0){
      fscanf(fin, "%d", &arg0);
      inst |= 0x10;
      inst |= (arg0 & 31) << 11;
    }
    else if(strcmp(type, "mflo") == 0){
      fscanf(fin, "%d", &arg0);
      inst |= 0x12;
      inst |= (arg0 & 31) << 11;
    }
    else if(strcmp(type, "mthi") == 0){
      fscanf(fin, "%d", &arg0);
      inst |= 0x11;
      inst |= (arg0 & 31) << 21;
    }
    else if(strcmp(type, "mtlo") == 0){
      fscanf(fin, "%d", &arg0);
      inst |= 0x13;
      inst |= (arg0 & 31) << 21;
    }
    else if(strcmp(type, "beq") == 0){
      fscanf(fin, "%d%d%x", &arg0, &arg1, &arg2);
      inst |= 0x10000000;
      carryimm16(inst, arg2);
      put2reg(inst, arg0, arg1);
    }
    else if(strcmp(type, "bgez") == 0){
      fscanf(fin, "%d%x", &arg0, &arg1);
      inst |= 0x4000000;
      carryimm16(inst, arg1);
      put2reg(inst, arg0, 0x1);
    }
    else if(strcmp(type, "bgtz") == 0){
      fscanf(fin, "%d%x", &arg0, &arg1);
      inst |= 0x1C000000;
      carryimm16(inst, arg1);
      put2reg(inst, arg0, 0x0);
    }
    else if(strcmp(type, "blez") == 0){
      fscanf(fin, "%d%x", &arg0, &arg1);
      inst |= 0x18000000;
      carryimm16(inst, arg1);
      put2reg(inst, arg0, 0x0);
    }
    else if(strcmp(type, "bltz") == 0){
      fscanf(fin, "%d%x", &arg0, &arg1);
      inst |= 0x4000000;
      carryimm16(inst, arg1);
      put2reg(inst, arg0, 0x0);
    }
    else if(strcmp(type, "bne") == 0){
      fscanf(fin, "%d%d%x", &arg0, &arg1, &arg2);
      inst |= 0x14000000;
      carryimm16(inst, arg2);
      put2reg(inst, arg0, arg1);
    }
    else if(strcmp(type, "j") == 0){
      fscanf(fin, "%x", &arg0);
      inst |= 0x8000000;
      inst |= (arg0 & 0x3FFFFFF);
    }
    else if(strcmp(type, "jal") == 0){
      fscanf(fin, "%x", &arg0);
      inst |= 0xC000000;
      inst |= (arg0 & 0x3FFFFFF);
    }
    else if(strcmp(type, "jalr") == 0){
      fscanf(fin, "%d%d", &arg0, &arg1);
      inst |= 0x9;
      inst |= (arg0 & 31)<<21;
      inst |= (arg1 & 31)<<11;
    }
    else if(strcmp(type, "jr") == 0){
      fscanf(fin, "%d", &arg0);
      inst |= 0x8;
      inst |= (arg0 & 31)<<21;
    }
    else if(strcmp(type, "mfc0") == 0){
      fscanf(fin, "%d%d", &arg0, &arg1);
      inst |= 0x40000000;
      put3reg(inst, 0, arg0, arg1);
    }
    else if(strcmp(type, "mtc0") == 0){
      fscanf(fin, "%d%d", &arg0, &arg1);
      inst |= 0x40000000;
      put3reg(inst, 4, arg1, arg0);
    }
    else if(strcmp(type, "syscall") == 0){
      inst = 0x0000000C;
    }
    else if(strcmp(type, "tlbwi") == 0){
      inst = 0x42000002;
    }
    else if(strcmp(type, "eret") == 0){
      inst = 0x42000018;
    }
    else if(strcmp(type, "nop") == 0){
    }
    else if(strcmp(type, "exit") == 0){
      break;
    }
    else{
      printf("Bad instruction %s\n", type);
      continue;
    }
    #ifdef SIGNAL_INPUT
    fprintf(fout, "x\"%08X\"", inst);
    if(inst_count > 0){
      fprintf(fout, " after %dns,\n", inst_count*PERIOD);
    }
    else{
      fprintf(fout, ",\n");
    }
    #else
    #ifdef ASCII
    #ifdef ADDR
    #ifdef BASE2
    fprintf(fout, "%08X ", ADDRBASE+4*inst_count);
    for(int i = 31; i >= 0; --i){
      fprintf(fout, "%1d", ((inst&(1<<i))==0)?0:1);
    }
    fprintf(fout, "\n");
    #else
    fprintf(fout, "%08X %08X\n", ADDRBASE+4*inst_count, inst);
    #endif  //BASE2
    #else
    #ifdef BASE2
    for(int i = 31; i >= 0; --i){
      fprintf(fout, "%1d", ((inst&(1<<i))==0)?0:1);
    }
    fprintf(fout, "\n");
    #else
    #ifdef ROM
    fprintf(fout, "x\"%08X\",\n", inst);
    #else
    fprintf(fout, "%08X\n", inst);
    #endif  //ROM
    #endif  //BASE2
    #endif  //ADDR
    #else
    #ifdef BINARY
    inst = MIPS_trans(inst);
    fwrite((void *)&inst, sizeof(inst), 1, fout);
    #endif  //BINARY
    #endif  //ASCII
    #endif  //SIGNAL_INPUT
    ++inst_count;
  }
  fclose(fout);
  fclose(fin);
  return 0;
}