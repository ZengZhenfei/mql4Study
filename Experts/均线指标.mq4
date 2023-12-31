//+------------------------------------------------------------------+
//|                                                 均线交叉指标.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Silver
#property indicator_color2 DodgerBlue
#property indicator_color3 Red
#property indicator_color4 Lime
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  0
#property indicator_width4  0
//+------------------------------------------------------------------+
input int    短期均线=13;
input int    ShorType=0;
input int    长期均线=55;
input int    LongType=0;
input int    字体大小=8;
input int    预设点差=10;
input bool   显示盈亏=true;
input bool   信号提醒=false;
input bool   显示轨迹=false;
input int    Barsback=2000;
//+------------------------------------------------------------------+
datetime LastTime;
string Names="Trade",Backgroundwidth="ggggg";
color  FontsColor=Chocolate,BackgroundColor=C'35,65,65';
double MA1,MA2,PreMA1,PreMA2,ShortMA[],LongMA[],CrossUp[],CrossDown[];
color  clor,WinClr=Red,LossClr=Lime,BuyColor=FireBrick,SellColor=LimeGreen;
int    StatsCorner=4,Bkgdpara=20,m,cnt,direction,lastcrossBar,MAxconseclosses,MAxconsecwins,conseclosses,consecwins;
double pipgains,TotalPips,TotalLosingPips,TotalWinningPips,TradeCount,LossCounts,WinCounts,WinPercent,MAXWinPips=0,MAXLossPips=0,MaxWins,MaxLoses;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ShortMA);
   SetIndexStyle(0,DRAW_LINE,0);
   SetIndexDrawBegin(0,短期均线);
 
 
   SetIndexBuffer(1,LongMA);
   SetIndexStyle(1,DRAW_LINE,0);
   SetIndexDrawBegin(1,长期均线);
 
 
   SetIndexBuffer(2,CrossUp);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,233);
 
 
   SetIndexBuffer(3,CrossDown);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,234);
//---
   return(INIT_SUCCEEDED);
  }
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteObjects(Names);
   for(int i=ObjectsTotal(); i>=0; i--)
      if(StringFind(ObjectName(i),"JX",0)==0)
         ObjectDelete(ObjectName(i));
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
 
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
 
   ShowMA();
   //DrawTraders();
   //ShowTradeMsg();
   //TimeRemains();
   //TaijiandName();
  }
//+------------------------------------------------------------------+
void ShowMA()
  {
   int tempBars=Bars-长期均线-1;
   if(tempBars>Barsback) tempBars=Barsback;
  
   for(int i=0; i<tempBars; i++)
     {
      MA1=iMA(NULL,0,短期均线,0,ShorType,PRICE_CLOSE,i);
      MA2=iMA(NULL,0,长期均线,0,LongType,PRICE_CLOSE,i);
      PreMA1=iMA(NULL,0,短期均线,0,ShorType,PRICE_CLOSE,i+1);
      PreMA2=iMA(NULL,0,长期均线,0,LongType,PRICE_CLOSE,i+1);
 
 
      ShortMA[i]=iMA(NULL,0,短期均线,0,ShorType,PRICE_CLOSE,i);
      LongMA[i]=iMA(NULL,0,长期均线,0,LongType,PRICE_CLOSE,i);
 
 
      //+--------------------多---------------------------+
      if(MA1>MA2 && PreMA1<PreMA2)
        {
         CrossUp[i]=Close[i];
 
 
         if(信号提醒==true && i<=1 && Time[i]!=LastTime)
           {
            LastTime=Time[i];
            Alert("均线多 ",Symbol()," , ",Period()," 分钟");
           }
        }
      else
         CrossUp[i]=-1;
      //+--------------------空---------------------------+
      if(MA1<MA2 && PreMA1>PreMA2)
        {
         CrossDown[i]=Close[i];
 
 
         if(信号提醒==true && i<=1 && Time[i]!=LastTime)
           {
            LastTime=Time[i];
            Alert("均线空 ",Symbol()," , ",Period()," 分钟");
           }
        }
      else
         CrossDown[i]=-1;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTraders()
  {
   cnt=0;
   lastcrossBar=0;
   TotalPips=0;
   TotalLosingPips=0;
 
 
   TotalWinningPips=0;
   TradeCount=0;
   LossCounts=0;
   WinCounts=0;
   WinPercent=0;
 
 
   double Range=(iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,25,1))-iLow(NULL,0,iLowest(NULL,0,MODE_LOW,25,1)))/10;
 
 
   for(int i=0; i<Barsback-200; i++)
     {
      pipgains=0;
      direction=0;
 
 
      MA1=iMA(NULL,0,短期均线,0,ShorType,PRICE_CLOSE,i);
      MA2=iMA(NULL,0,长期均线,0,LongType,PRICE_CLOSE,i);
      PreMA1=iMA(NULL,0,短期均线,0,ShorType,PRICE_CLOSE,i+1);
      PreMA2=iMA(NULL,0,长期均线,0,LongType,PRICE_CLOSE,i+1);
 
      //+--------------------多---------------------------+
      if(PreMA1<=PreMA2 && MA1>MA2)
        {
         pipgains=Close[lastcrossBar]-Close[i]-预设点差*Point;
 
 
         if(显示轨迹)
           {
            DrawOrderLine(GetUniqueName(Names+"trade"),Time[i],Close[i]+预设点差*Point,Time[lastcrossBar],Close[lastcrossBar],BuyColor,DoubleToStr(pipgains,1),STYLE_DOT);
           }
         direction=1;
        }
      //+--------------------空---------------------------+
      if(PreMA1>=PreMA2 && MA1<MA2)
        {
         pipgains=Close[i]-Close[lastcrossBar]-预设点差*Point;
 
 
         if(显示轨迹)
           {
            DrawOrderLine(GetUniqueName(Names+"trade"),Time[i],Close[i],Time[lastcrossBar],Close[lastcrossBar]+预设点差*Point,SellColor,DoubleToStr(pipgains,1),STYLE_DOT);
           }
         direction=-1;
        }
 
 
      TotalPips+=pipgains;
 
 
      if(pipgains<0)
        {
         TradeCount++;
         LossCounts++;
         consecwins=0;
         conseclosses+=1;
         TotalLosingPips+=pipgains;
         MaxLoses=pipgains/Point;
 
 
         if(显示盈亏)
           {
            DrawLabel(GetUniqueName(Names+"trade"),DoubleToStr(pipgains/Point,0),int(Time[lastcrossBar]),Close[lastcrossBar]-Range,字体大小,"Calibri",LossClr,3);
           }
        }
      if(pipgains>0)
        {
         TradeCount++;
         WinCounts++;
         consecwins+=1;
         conseclosses=0;
         TotalWinningPips+=pipgains;
         MaxWins=pipgains/Point;
 
 
         if(显示盈亏)
           {
            DrawLabel(GetUniqueName(Names+"trade"),DoubleToStr(pipgains/Point,0),int(Time[lastcrossBar]),Close[lastcrossBar]-Range,字体大小,"Calibri",WinClr,3);
           }
        }
      if(MAXLossPips>=MaxLoses)
        {
         MAXLossPips=MaxLoses;
        }
      if(MAXWinPips<=MaxWins)
        {
         MAXWinPips=MaxWins;
        }
      if(MAxconseclosses<conseclosses)
        {
         MAxconseclosses=conseclosses;
        }
      if(MAxconsecwins<consecwins)
        {
         MAxconsecwins=consecwins;
        }
      if(direction!=0)
        {
         lastcrossBar=i;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowTradeMsg()
  {
   string bg=Backgroundwidth;
 
 
   color colorr=FontsColor;
 
 
   if(TotalPips<0)
      colorr=Lime;
 
 
   if(TotalPips>0)
      colorr=Red;
 
 
   int x=10,y=0,dy=Bkgdpara;
 
 
   double PipslossPer=TotalLosingPips/(LossCounts*Point);
 
 
   double PipswinPer=TotalWinningPips/(WinCounts*Point);
 
 
   double WinLoseRate=-TotalWinningPips/TotalLosingPips;
 
 
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"Barsback ："+DoubleToStr(Barsback,0),StatsCorner,x,y,字体大小,"Arial",FontsColor,false);
 
 
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"短期均线 ："+DoubleToStr(短期均线,0),StatsCorner,x,y,字体大小,"Arial",Silver,false);
 
 
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"长期均线 ："+DoubleToStr(长期均线,0),StatsCorner,x,y,字体大小,"Arial",DodgerBlue,false);
 
 
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"预设点差 ："+DoubleToStr(预设点差,0),StatsCorner,x,y,字体大小,"Arial",FontsColor,false);
 
 
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"交易单量 ："+DoubleToStr(TradeCount,0),StatsCorner,x,y,字体大小,"Arial",FontsColor,false);
 
 
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"盈利单数 ："+DoubleToStr(WinCounts,0),StatsCorner,x,y,字体大小,"Arial",FontsColor,false);
 
 
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"亏损单数 ："+DoubleToStr(LossCounts,0),StatsCorner,x,y,字体大小,"Arial",FontsColor,false);
 
 
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"最大连胜 ："+DoubleToStr(MAxconsecwins,0),StatsCorner,x,y,字体大小,"Arial",FontsColor,false);
 
 
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"最大连亏 ："+DoubleToStr(MAxconseclosses,0),StatsCorner,x,y,字体大小,"Arial",Lime,false);
 
 
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"盈利点数 ："+DoubleToStr(TotalWinningPips/Point,0),StatsCorner,x,y,字体大小,"Arial",FontsColor,false);
 
 
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"亏损点数 ："+DoubleToStr(TotalLosingPips/Point,0),StatsCorner,x,y,字体大小,"Arial",FontsColor,false);
 
 
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"总计点数 ："+DoubleToStr(TotalPips/Point,0),StatsCorner,x,y,字体大小,"Arial",colorr,false);
 
 
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"每笔均亏 ："+DoubleToStr(PipslossPer,0),StatsCorner,x,y,字体大小,"Arial",FontsColor,false);
 
 
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"每笔均赢 ："+DoubleToStr(PipswinPer,0),StatsCorner,x,y,字体大小,"Arial",FontsColor,false);
 
 
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"单笔最亏 ："+DoubleToStr(MAXLossPips,0),StatsCorner,x,y,字体大小,"Arial",Lime,false);
 
 
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"单笔最赢 ："+DoubleToStr(MAXWinPips,0),StatsCorner,x,y,字体大小,"Arial",FontsColor,false);
 
 
   if(TotalLosingPips!=0)
     {
      y+=dy;
      DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
      DrawFixedLabel(GetUniqueName(Names),"盈亏比值 ："+DoubleToStr(WinLoseRate,2),StatsCorner,x,y,字体大小,"Arial",FontsColor,false);
     }
   y+=dy;
   DrawFixedLabel(GetUniqueName(Names),bg,StatsCorner,x-5,y-5,16,"Webdings",BackgroundColor,false);
   DrawFixedLabel(GetUniqueName(Names),"策略胜率 ："+DoubleToStr(100*WinCounts/TradeCount,2)+"%",StatsCorner,x,y,字体大小,"Arial",FontsColor,false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TimeRemains()
  {
   int minute=int(Time[0]+60*Period()-TimeCurrent());
   int second=minute%60;
   minute=(minute-minute%60)/60;
   ObjectCreate("JX-time",OBJ_TEXT,0,Time[0],Close[0]);
   ObjectSetText("JX-time","               "+string(minute)+":"+string(second),10,"Verdana",Yellow);
   ObjectMove("JX-time",0,Time[0],Close[0]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TaijiandName()
  {
   m++;
   if(m>8)
      m=0;
 
 
   if(m>=0 && m<=2)
      clor=LossClr;
   if(m>=3 && m<=5)
      clor=White;
   if(m>=6 && m<=8)
      clor=WinClr;
 
 
   ObjectCreate("JX-taiji",OBJ_LABEL,0,0,0);
   ObjectSet("JX-taiji",OBJPROP_CORNER,2);
   ObjectSet("JX-taiji",OBJPROP_YDISTANCE,5);
   ObjectSet("JX-taiji",OBJPROP_XDISTANCE,5);
   ObjectSetText("JX-taiji",CharToStr(91),18,"WingDings",clor);
 
 
   ObjectCreate("JX-nm",OBJ_LABEL,0,0,0);
   ObjectSetText("JX-nm",AccountName()+" : "+DoubleToStr(AccountNumber(),0),10,"Arial",FontsColor);
   ObjectSet("JX-nm",OBJPROP_CORNER,2);
   ObjectSet("JX-nm",OBJPROP_XDISTANCE,33);
   ObjectSet("JX-nm",OBJPROP_YDISTANCE,10);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawOrderLine(string name,datetime starts,double startPrice,datetime ends,double endPrice,color c,string label,int style)
  {
   ObjectCreate(name,OBJ_TREND,0,starts,startPrice,ends,endPrice);
   ObjectSet(name,OBJPROP_RAY,0);
   ObjectSet(name,OBJPROP_COLOR,c);
   ObjectSet(name,OBJPROP_STYLE,style);
   ObjectSetText(name,label,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLabel(string objname,string s,int LTime,double LPrice,int FSize,string Font,color c,int width)
  {
   if(ObjectFind(objname)<0)
     {
      ObjectCreate(objname,OBJ_TEXT,0,LTime,LPrice);
     }
   else
     {
      if(ObjectType(objname)==OBJ_TEXT)
        {
         ObjectSet(objname,OBJPROP_TIME1,LTime);
         ObjectSet(objname,OBJPROP_PRICE1,LPrice);
        }
     }
   ObjectSet(objname,OBJPROP_FONTSIZE,FSize);
   ObjectSetText(objname,s,FSize,Font,c);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawFixedLabel(string objname,string s,int Corner,int DX,int DY,int FSize,string Font,color c,bool sbg)
  {
   ObjectCreate(objname,OBJ_LABEL,0,0,0);
   ObjectSet(objname,OBJPROP_CORNER,Corner);
   ObjectSet(objname,OBJPROP_XDISTANCE,DX);
   ObjectSet(objname,OBJPROP_YDISTANCE,DY);
   ObjectSet(objname,OBJPROP_BACK,sbg);
   ObjectSetText(objname,s,FSize,Font,c);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetUniqueName(string px)
  {
   cnt++;
   return (px+" "+DoubleToStr(cnt,0));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteObjects(string px)
  {
   int L = StringLen(px);
   int i = 0;
   while(i<ObjectsTotal())
     {
      string ObjName=ObjectName(i);
      if(StringSubstr(ObjName,0,L)!=px)
        {
         i++;
         continue;
        }
      ObjectDelete(ObjName);
     }
  }
//+------------------------------------------------------------------+
//| 程序结束                                                         |
//+------------------------------------------------------------------+