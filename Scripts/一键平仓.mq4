//+------------------------------------------------------------------+
//|                                                     一键平仓.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                          http://www.study-ea.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "http://www.study-ea.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   while(total())
     {
      for(int i=0; i<OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderType()==OP_BUY || OrderType()==OP_SELL)
              {
               RefreshRates();
               bool res=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0);
               if(res)
                 {
                  Print("平仓成功。#"+IntegerToString(OrderTicket()));
                 }
               else
                 {
                  Print("平仓失败。#"+IntegerToString(OrderTicket())+",出错："+IntegerToString(GetLastError()));
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
int total()
  {
   int result=0,cmd=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         cmd=OrderType();
         if(cmd<=1)
            result++;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+