#property copyright "shiyingpan"
#property link      "https://aijy.github.io"
#property version   "1.00"
#property strict

input double 首单单量 = 1.0;
double 次单单量 = 0;
int cnt;

int OnInit(){
  if (首单单量>1)
  {
    return(INIT_FAILED)
  }
  次单单量 = 首单单量 * 2;
  Print("初始化完成，首单单量是：",首单单量,"次单单量是：",次单单量);
}
