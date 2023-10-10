//+------------------------------------------------------------------+
//|                                                   testScript.mq4 |
//|                                                            Aiden |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Aiden"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

#include <JAson.mqh>

void OnStart()
  {
//---
    //---
    CJAVal service_sf;
    service_sf["AccountCompany"]=AccountCompany();
    string json_str = "Hello" + service_sf.Serialize();
    SendNotification(json_str);
    
    //while(true){
        //if(Bars<100 || IsTradeAllowed()==false) return;
        //if(iMACD(NULL,0,6,9,5,PRICE_CLOSE,MODE_MAIN,0)>iMACD(NULL,0,6,9,5,PRICE_CLOSE,MODE_SIGNAL,0)){
           // SendNotification("macd notification");
          //}
        //Sleep(1000);
    //}
    
    
  }
//+------------------------------------------------------------------+
