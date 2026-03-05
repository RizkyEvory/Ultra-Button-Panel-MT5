//+------------------------------------------------------------------+
//|                              M4DI_UciH4_Panel_v2_PATCHED.mq5    |
//|                                    Copyright 2024, M4DI~UciH4    |
//|                                    github.com/RizkyEvory         |
//+------------------------------------------------------------------+
// PATCH LOG:
// [PATCH #1] ExecuteBuy/ExecuteSell: Ganti ResultPrice() dengan
//            PositionGetDouble(POSITION_PRICE_OPEN) agar entry price
//            tidak pernah 0 -> mencegah TP trigger instan setelah open
// [PATCH #2] AddToTPTracker: Tambah validasi entry > 0 sebelum
//            menyimpan ke tracker
// [PATCH #3] OnTradeTransaction: Tambah HistoryDealSelect() sebelum
//            membaca data deal agar statistik P/L akurat
// [PATCH #4] ProcessTrailing BUY: Tambah cek sl==0 sama seperti SELL
//            agar trailing BUY konsisten
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, M4DI~UciH4"
#property link      "https://github.com/RizkyEvory"
#property version   "2.02"
#property description "═══════════════════════════════════════════════"
#property description "   M4DI~UciH4 ULTRA BUTTON PANEL v2.0 PATCHED"
#property description "   Premium Semi-Manual Trading Panel for MT5"
#property description "═══════════════════════════════════════════════"
#property description "Features: One-Click Trading, Smart Risk Calculator,"
#property description "Multi-TP Levels, Trailing Stop, Break Even, Session Filter"
#property strict

//+------------------------------------------------------------------+
//| INCLUDES                                                          |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>

//+------------------------------------------------------------------+
//| INPUT PARAMETERS                                                  |
//+------------------------------------------------------------------+
input group "═══════════ 📌 PANEL SETTINGS ═══════════"
input int         InpPanelX              = 20;          // Panel X Position
input int         InpPanelY              = 50;          // Panel Y Position
input bool        InpPanelDraggable      = true;        // Enable Panel Dragging
input ENUM_BASE_CORNER InpPanelCorner    = CORNER_LEFT_UPPER; // Panel Corner

input group "═══════════ 💰 MONEY MANAGEMENT ═══════════"
input double      InpDefaultLot          = 0.01;        // Default Lot Size
input double      InpRiskPercent         = 1.0;         // Risk Percent (%)
input int         InpDefaultSL           = 500;         // Default SL (points)
input int         InpMaxSpread           = 30;          // Max Spread (points)
input int         InpSlippage            = 30;          // Slippage (points)
input ulong       InpMagicNumber         = 20240301;    // Magic Number

input group "═══════════ 🎯 TP LEVELS ═══════════"
input bool        InpTP1_Enabled         = true;        // Enable TP1
input int         InpTP1_Points          = 300;         // TP1 Distance (points)
input int         InpTP1_Percent         = 50;          // TP1 Close Percent
input bool        InpTP2_Enabled         = true;        // Enable TP2
input int         InpTP2_Points          = 600;         // TP2 Distance (points)
input int         InpTP2_Percent         = 30;          // TP2 Close Percent
input bool        InpTP3_Enabled         = true;        // Enable TP3
input int         InpTP3_Points          = 1000;        // TP3 Distance (points)
input int         InpTP3_Percent         = 20;          // TP3 Close Percent
input bool        InpMoveSLToBE_OnTP1    = true;        // Move SL to BE on TP1

input group "═══════════ 🔄 BREAK EVEN & TRAILING ═══════════"
input int         InpBE_Offset           = 10;          // Break Even Offset (points)
input int         InpTrailingStart       = 200;         // Trailing Start (points)
input int         InpTrailingStep        = 100;         // Trailing Step (points)
input int         InpTrailingDistance    = 150;         // Trailing Distance (points)

input group "═══════════ ⏰ SESSION SETTINGS ═══════════"
input int         InpGMT_Offset          = 3;           // Broker GMT Offset
input bool        InpBlockOutsideSession = false;       // Block Trading Outside Session
input bool        InpShowSessionFilter   = true;        // Show Session Indicator

input group "═══════════ 📊 DISPLAY OPTIONS ═══════════"
input bool        InpShowDailyStats      = true;        // Show Daily Statistics
input bool        InpShowChartLines      = true;        // Show SL/TP Lines on Chart
input bool        InpShowSpreadWarning   = true;        // Show Spread Warning
input bool        InpEnableSounds        = true;        // Enable Sound Alerts
input bool        InpConfirmTrades       = false;       // Confirm Before Trading

//+------------------------------------------------------------------+
//| GLOBAL CONSTANTS - COLORS                                         |
//+------------------------------------------------------------------+
#define CLR_PANEL_BG              C'15,15,25'
#define CLR_PANEL_BG_LIGHT        C'25,25,40'
#define CLR_PANEL_BORDER          C'75,0,130'
#define CLR_HEADER_BG             C'30,30,50'
#define CLR_HEADER_ACCENT         C'138,43,226'
#define CLR_ACCENT_PURPLE         C'147,112,219'
#define CLR_ACCENT_GOLD           C'255,215,0'

#define CLR_TEXT_WHITE            C'255,255,255'
#define CLR_TEXT_LIGHT            C'200,200,200'
#define CLR_TEXT_DIM              C'120,120,140'
#define CLR_TEXT_DARK             C'80,80,100'

#define CLR_BUY_BG                C'0,60,30'
#define CLR_BUY_BG_HOVER          C'0,80,40'
#define CLR_BUY_TEXT              C'0,255,127'
#define CLR_BUY_BORDER            C'0,200,100'

#define CLR_SELL_BG               C'60,0,0'
#define CLR_SELL_BG_HOVER         C'80,0,0'
#define CLR_SELL_TEXT             C'255,69,58'
#define CLR_SELL_BORDER           C'200,50,50'

#define CLR_PROFIT                C'0,255,127'
#define CLR_LOSS                  C'255,69,58'
#define CLR_NEUTRAL               C'150,150,170'

#define CLR_TP_LINE               C'255,215,0'
#define CLR_SL_LINE               C'255,69,58'
#define CLR_BE_LINE               C'138,43,226'
#define CLR_ENTRY_LINE            C'100,149,237'

#define CLR_BTN_NORMAL            C'40,40,60'
#define CLR_BTN_HOVER             C'55,55,80'
#define CLR_BTN_ACTIVE            C'75,0,130'

#define CLR_SESSION_ACTIVE        C'138,43,226'
#define CLR_SESSION_INACTIVE      C'35,35,50'

#define CLR_WARNING               C'255,165,0'
#define CLR_ERROR                 C'255,0,0'
#define CLR_SUCCESS               C'0,255,127'

//+------------------------------------------------------------------+
//| GLOBAL CONSTANTS - OBJECT PREFIX                                  |
//+------------------------------------------------------------------+
#define PREFIX                    "M4DI_"
#define PANEL_WIDTH               280
#define BUTTON_HEIGHT             32
#define ROW_HEIGHT                24
#define PADDING                   10
#define SECTION_GAP               8

//+------------------------------------------------------------------+
//| OBJECT NAMES                                                      |
//+------------------------------------------------------------------+
#define OBJ_MAIN_BG               PREFIX+"MainBG"
#define OBJ_HEADER_BG             PREFIX+"HeaderBG"
#define OBJ_HEADER_LINE           PREFIX+"HeaderLine"
#define OBJ_TITLE                 PREFIX+"Title"
#define OBJ_SUBTITLE              PREFIX+"Subtitle"
#define OBJ_VERSION               PREFIX+"Version"
#define OBJ_DRAGAREA              PREFIX+"DragArea"

#define OBJ_SYMBOL_BG             PREFIX+"SymbolBG"
#define OBJ_SYMBOL_NAME           PREFIX+"SymbolName"
#define OBJ_SPREAD_LBL            PREFIX+"SpreadLbl"
#define OBJ_SPREAD_VAL            PREFIX+"SpreadVal"
#define OBJ_SWAP_LONG             PREFIX+"SwapLong"
#define OBJ_SWAP_SHORT            PREFIX+"SwapShort"
#define OBJ_SPREAD_WARN           PREFIX+"SpreadWarn"

#define OBJ_BUY_BTN               PREFIX+"BuyBtn"
#define OBJ_BUY_LBL               PREFIX+"BuyLbl"
#define OBJ_BUY_PRICE             PREFIX+"BuyPrice"
#define OBJ_SELL_BTN              PREFIX+"SellBtn"
#define OBJ_SELL_LBL              PREFIX+"SellLbl"
#define OBJ_SELL_PRICE            PREFIX+"SellPrice"

#define OBJ_LOT_BG                PREFIX+"LotBG"
#define OBJ_LOT_LBL               PREFIX+"LotLbl"
#define OBJ_LOT_VAL               PREFIX+"LotVal"
#define OBJ_LOT_MINUS             PREFIX+"LotMinus"
#define OBJ_LOT_PLUS              PREFIX+"LotPlus"
#define OBJ_LOT_AUTO              PREFIX+"LotAuto"
#define OBJ_RISK_LBL              PREFIX+"RiskLbl"
#define OBJ_SL_LBL                PREFIX+"SLLbl"
#define OBJ_SL_VAL                PREFIX+"SLVal"
#define OBJ_SL_MINUS              PREFIX+"SLMinus"
#define OBJ_SL_PLUS               PREFIX+"SLPlus"
#define OBJ_RISK_MONEY            PREFIX+"RiskMoney"
#define OBJ_CALC_LOT              PREFIX+"CalcLot"

#define OBJ_TP_HEADER             PREFIX+"TPHeader"
#define OBJ_TP1_BTN               PREFIX+"TP1Btn"
#define OBJ_TP1_INFO              PREFIX+"TP1Info"
#define OBJ_TP2_BTN               PREFIX+"TP2Btn"
#define OBJ_TP2_INFO              PREFIX+"TP2Info"
#define OBJ_TP3_BTN               PREFIX+"TP3Btn"
#define OBJ_TP3_INFO              PREFIX+"TP3Info"

#define OBJ_MGMT_HEADER           PREFIX+"MgmtHeader"
#define OBJ_BE_BTN                PREFIX+"BEBtn"
#define OBJ_TRAIL_BTN             PREFIX+"TrailBtn"

#define OBJ_PARTIAL_HEADER        PREFIX+"PartialHeader"
#define OBJ_CLOSE_25              PREFIX+"Close25"
#define OBJ_CLOSE_50              PREFIX+"Close50"
#define OBJ_CLOSE_75              PREFIX+"Close75"

#define OBJ_CLOSE_ALL             PREFIX+"CloseAll"
#define OBJ_CLOSE_BUY             PREFIX+"CloseBuy"
#define OBJ_CLOSE_SELL            PREFIX+"CloseSell"
#define OBJ_CLOSE_PROFIT          PREFIX+"CloseProfit"
#define OBJ_CLOSE_LOSS            PREFIX+"CloseLoss"

#define OBJ_SESSION_HEADER        PREFIX+"SessionHeader"
#define OBJ_SESSION_ASIA          PREFIX+"SessionAsia"
#define OBJ_SESSION_LONDON        PREFIX+"SessionLondon"
#define OBJ_SESSION_NY            PREFIX+"SessionNY"

#define OBJ_STATS_HEADER          PREFIX+"StatsHeader"
#define OBJ_STATS_DAILY           PREFIX+"StatsDaily"
#define OBJ_STATS_FLOATING        PREFIX+"StatsFloating"
#define OBJ_STATS_TRADES          PREFIX+"StatsTrades"
#define OBJ_STATS_WINRATE         PREFIX+"StatsWinrate"

#define OBJ_FOOTER_LINE           PREFIX+"FooterLine"
#define OBJ_FOOTER                PREFIX+"Footer"

//+------------------------------------------------------------------+
//| TRADING OBJECTS                                                   |
//+------------------------------------------------------------------+
CTrade         m_trade;
CPositionInfo  m_position;
CSymbolInfo    m_symbol;
CAccountInfo   m_account;
CDealInfo      m_deal;

//+------------------------------------------------------------------+
//| PANEL STATE VARIABLES                                             |
//+------------------------------------------------------------------+
int            g_panelX;
int            g_panelY;
int            g_panelHeight;
bool           g_isDragging       = false;
int            g_dragOffsetX      = 0;
int            g_dragOffsetY      = 0;
datetime       g_lastMouseTime    = 0;
int            g_deltaMoveX       = 0;
int            g_deltaMoveY       = 0;

//+------------------------------------------------------------------+
//| TRADING STATE VARIABLES                                           |
//+------------------------------------------------------------------+
double         g_lotSize;
int            g_slPoints;
bool           g_trailingOn       = false;
bool           g_tp1Active;
bool           g_tp2Active;
bool           g_tp3Active;

datetime       g_lastOrderTime    = 0;
int            g_orderCooldownSec = 2;

//+------------------------------------------------------------------+
//| DAILY STATISTICS                                                  |
//+------------------------------------------------------------------+
struct DailyStats
{
   datetime    date;
   double      realizedPnL;
   int         wins;
   int         losses;
   int         totalTrades;
   double      totalLots;
};
DailyStats     g_stats;

//+------------------------------------------------------------------+
//| TP TRACKER STRUCTURE                                              |
//+------------------------------------------------------------------+
struct PositionTPInfo
{
   ulong       ticket;
   double      entryPrice;
   double      initialLot;
   double      tp1Price;
   double      tp2Price;
   double      tp3Price;
   bool        tp1Closed;
   bool        tp2Closed;
   bool        tp3Closed;
   bool        movedToBE;
   ENUM_POSITION_TYPE posType;
};
PositionTPInfo g_tpInfo[];

//+------------------------------------------------------------------+
//| EXPERT INITIALIZATION                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   if(!m_symbol.Name(_Symbol))
   {
      Print("❌ Error: Cannot initialize symbol ", _Symbol);
      return INIT_FAILED;
   }
   m_symbol.Refresh();
   m_symbol.RefreshRates();

   m_trade.SetExpertMagicNumber(InpMagicNumber);
   m_trade.SetDeviationInPoints(InpSlippage);
   m_trade.SetMarginMode();

   ENUM_ORDER_TYPE_FILLING fillType = GetFillingMode();
   m_trade.SetTypeFilling(fillType);

   g_panelX   = InpPanelX;
   g_panelY   = InpPanelY;
   g_lotSize  = NormalizeLot(InpDefaultLot);
   g_slPoints = InpDefaultSL;
   g_tp1Active = InpTP1_Enabled;
   g_tp2Active = InpTP2_Enabled;
   g_tp3Active = InpTP3_Enabled;

   LoadDailyStats();
   RebuildTPTracker();
   CreatePanel();

   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, false);

   EventSetMillisecondTimer(200);
   RefreshPanel();

   Print("═══════════════════════════════════════════════════════");
   Print("   M4DI~UciH4 ULTRA BUTTON PANEL v2.02 PATCHED");
   Print("   Symbol: ", _Symbol, " | Digits: ", _Digits);
   Print("   Point: ", _Point, " | Lot Step: ", m_symbol.LotsStep());
   Print("═══════════════════════════════════════════════════════");

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| GET PROPER FILLING MODE                                           |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING GetFillingMode()
{
   uint filling = (uint)SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
   if((filling & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK)
      return ORDER_FILLING_FOK;
   if((filling & SYMBOL_FILLING_IOC) == SYMBOL_FILLING_IOC)
      return ORDER_FILLING_IOC;
   return ORDER_FILLING_RETURN;
}

//+------------------------------------------------------------------+
//| EXPERT DEINITIALIZATION                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   SaveDailyStats();
   DeleteAllObjects();
   ChartRedraw(0);
   Print("═══════════════════════════════════════════════════════");
   Print("   M4DI~UciH4 ULTRA BUTTON PANEL REMOVED");
   Print("   Reason Code: ", reason);
   Print("═══════════════════════════════════════════════════════");
}

//+------------------------------------------------------------------+
//| DELETE ALL PANEL OBJECTS                                          |
//+------------------------------------------------------------------+
void DeleteAllObjects()
{
   ObjectsDeleteAll(0, PREFIX, 0, -1);
}

//+------------------------------------------------------------------+
//| ONTICK                                                            |
//+------------------------------------------------------------------+
void OnTick()
{
   m_symbol.Refresh();
   m_symbol.RefreshRates();

   UpdatePriceDisplay();

   if(g_trailingOn)
      ProcessTrailing();

   CheckTPLevels();

   if(InpShowChartLines)
      UpdateChartLines();
}

//+------------------------------------------------------------------+
//| ONTIMER                                                           |
//+------------------------------------------------------------------+
void OnTimer()
{
   m_symbol.Refresh();
   m_symbol.RefreshRates();
   RefreshPanel();
   CheckNewDay();
}

//+------------------------------------------------------------------+
//| [PATCH #3] ONTRADE TRANSACTION - FIXED: HistoryDealSelect added  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD) return;

   // [PATCH #3] Harus select deal dari history dulu sebelum baca propertinya
   if(!HistoryDealSelect(trans.deal)) return;

   if(HistoryDealGetInteger(trans.deal, DEAL_MAGIC) != (long)InpMagicNumber) return;
   if(HistoryDealGetString(trans.deal, DEAL_SYMBOL) != _Symbol) return;

   ENUM_DEAL_ENTRY dealEntry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
   if(dealEntry != DEAL_ENTRY_OUT && dealEntry != DEAL_ENTRY_OUT_BY) return;

   double profit     = HistoryDealGetDouble(trans.deal, DEAL_PROFIT);
   double swap       = HistoryDealGetDouble(trans.deal, DEAL_SWAP);
   double commission = HistoryDealGetDouble(trans.deal, DEAL_COMMISSION);
   double total      = profit + swap + commission;

   g_stats.realizedPnL += total;
   if(total >= 0)
      g_stats.wins++;
   else
      g_stats.losses++;

   SaveDailyStats();

   Print("📊 Deal closed. P/L: $", DoubleToString(total, 2),
         " | Daily: $", DoubleToString(g_stats.realizedPnL, 2));
}

//+------------------------------------------------------------------+
//| ONCHART EVENT                                                     |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_KEYDOWN)
   {
      ProcessKeyboard((int)lparam);
      return;
   }

   if(id == CHARTEVENT_CLICK)
   {
      int mouseX = (int)lparam;
      int mouseY = (int)dparam;
      if(InpPanelDraggable && IsInDragArea(mouseX, mouseY))
      {
         g_isDragging   = true;
         g_dragOffsetX  = mouseX - g_panelX;
         g_dragOffsetY  = mouseY - g_panelY;
         g_lastMouseTime = TimeCurrent();
      }
      return;
   }

   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int mouseX  = (int)lparam;
      int mouseY  = (int)dparam;
      uint state  = (uint)sparam;

      if((state & 1) != 1)
      {
         if(g_isDragging)
         {
            g_isDragging = false;
            ChartRedraw(0);
         }
         return;
      }

      if(g_isDragging)
      {
         int newX = mouseX - g_dragOffsetX;
         int newY = mouseY - g_dragOffsetY;

         int chartWidth  = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
         int chartHeight = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

         newX = MathMax(0, MathMin(newX, chartWidth  - PANEL_WIDTH - 10));
         newY = MathMax(0, MathMin(newY, chartHeight - g_panelHeight - 10));

         if(newX != g_panelX || newY != g_panelY)
         {
            g_deltaMoveX = newX - g_panelX;
            g_deltaMoveY = newY - g_panelY;
            g_panelX = newX;
            g_panelY = newY;
            MoveAllObjects();
         }
      }
      return;
   }

   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      ProcessButtonClick(sparam);
      if(ObjectGetInteger(0, sparam, OBJPROP_TYPE) == OBJ_BUTTON)
      {
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
         ChartRedraw(0);
      }
      return;
   }
}

//+------------------------------------------------------------------+
//| PROCESS BUTTON CLICK                                              |
//+------------------------------------------------------------------+
void ProcessButtonClick(string objName)
{
   if(objName == OBJ_BUY_BTN)   { OnBuyClick();  return; }
   if(objName == OBJ_SELL_BTN)  { OnSellClick(); return; }

   if(objName == OBJ_LOT_MINUS) { AdjustLot(-1); return; }
   if(objName == OBJ_LOT_PLUS)  { AdjustLot(1);  return; }
   if(objName == OBJ_LOT_AUTO)  { AutoCalculateLot(); return; }

   if(objName == OBJ_SL_MINUS)  { AdjustSL(-10); return; }
   if(objName == OBJ_SL_PLUS)   { AdjustSL(10);  return; }

   if(objName == OBJ_TP1_BTN)   { g_tp1Active = !g_tp1Active; UpdateTPButtons(); return; }
   if(objName == OBJ_TP2_BTN)   { g_tp2Active = !g_tp2Active; UpdateTPButtons(); return; }
   if(objName == OBJ_TP3_BTN)   { g_tp3Active = !g_tp3Active; UpdateTPButtons(); return; }

   if(objName == OBJ_BE_BTN)    { OnBreakEvenClick(); return; }

   if(objName == OBJ_TRAIL_BTN)
   {
      g_trailingOn = !g_trailingOn;
      UpdateTrailingButton();
      PlayAlertSound(g_trailingOn ? "tick.wav" : "news.wav");
      Print("🔄 Trailing Stop: ", g_trailingOn ? "ENABLED" : "DISABLED");
      return;
   }

   if(objName == OBJ_CLOSE_25)     { PartialCloseAll(25); return; }
   if(objName == OBJ_CLOSE_50)     { PartialCloseAll(50); return; }
   if(objName == OBJ_CLOSE_75)     { PartialCloseAll(75); return; }

   if(objName == OBJ_CLOSE_ALL)    { CloseAllPositions(); return; }
   if(objName == OBJ_CLOSE_BUY)    { ClosePositionsByType(POSITION_TYPE_BUY);  return; }
   if(objName == OBJ_CLOSE_SELL)   { ClosePositionsByType(POSITION_TYPE_SELL); return; }
   if(objName == OBJ_CLOSE_PROFIT) { ClosePositionsByProfit(true);  return; }
   if(objName == OBJ_CLOSE_LOSS)   { ClosePositionsByProfit(false); return; }
}

//+------------------------------------------------------------------+
//| PROCESS KEYBOARD                                                  |
//+------------------------------------------------------------------+
void ProcessKeyboard(int key)
{
   if(key == 'B' || key == 'b') { OnBuyClick();        return; }
   if(key == 'S' || key == 's') { OnSellClick();       return; }
   if(key == 'Q' || key == 'q') { CloseAllPositions(); return; }
   if(key == 'E' || key == 'e') { OnBreakEvenClick();  return; }
   if(key == 'T' || key == 't')
   {
      g_trailingOn = !g_trailingOn;
      UpdateTrailingButton();
      return;
   }
}

//+------------------------------------------------------------------+
//| CHECK IF MOUSE IS IN DRAG AREA                                    |
//+------------------------------------------------------------------+
bool IsInDragArea(int x, int y)
{
   return (x >= g_panelX && x <= g_panelX + PANEL_WIDTH &&
           y >= g_panelY && y <= g_panelY + 65);
}

//+------------------------------------------------------------------+
//| BUY CLICK HANDLER                                                 |
//+------------------------------------------------------------------+
void OnBuyClick()
{
   if(TimeCurrent() - g_lastOrderTime < g_orderCooldownSec)
   {
      Print("⚠️ Order cooldown active - please wait");
      return;
   }
   if(!CanTrade())
   {
      Print("⚠️ Trading blocked: Check spread or session");
      PlayAlertSound("alert.wav");
      return;
   }
   if(InpConfirmTrades)
   {
      int res = MessageBox("Execute BUY order?\n\nLot: " + DoubleToString(g_lotSize, 2) +
                          "\nSL: " + IntegerToString(g_slPoints) + " points",
                          "Confirm BUY", MB_YESNO | MB_ICONQUESTION);
      if(res != IDYES) return;
   }
   ExecuteBuy();
}

//+------------------------------------------------------------------+
//| SELL CLICK HANDLER                                                |
//+------------------------------------------------------------------+
void OnSellClick()
{
   if(TimeCurrent() - g_lastOrderTime < g_orderCooldownSec)
   {
      Print("⚠️ Order cooldown active - please wait");
      return;
   }
   if(!CanTrade())
   {
      Print("⚠️ Trading blocked: Check spread or session");
      PlayAlertSound("alert.wav");
      return;
   }
   if(InpConfirmTrades)
   {
      int res = MessageBox("Execute SELL order?\n\nLot: " + DoubleToString(g_lotSize, 2) +
                          "\nSL: " + IntegerToString(g_slPoints) + " points",
                          "Confirm SELL", MB_YESNO | MB_ICONQUESTION);
      if(res != IDYES) return;
   }
   ExecuteSell();
}

//+------------------------------------------------------------------+
//| CAN TRADE CHECK                                                   |
//+------------------------------------------------------------------+
bool CanTrade()
{
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
   {
      Print("❌ Trading not allowed in terminal");
      return false;
   }
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
   {
      Print("❌ EA trading not allowed");
      return false;
   }
   m_symbol.Refresh();
   int currentSpread = (int)m_symbol.Spread();
   if(currentSpread > InpMaxSpread)
   {
      Print("❌ Spread too high: ", currentSpread, " > ", InpMaxSpread);
      return false;
   }
   if(InpBlockOutsideSession && !IsSessionActive())
   {
      Print("❌ Outside trading session");
      return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| EXECUTE BUY ORDER - [PATCH #1] FIXED entry price                 |
//+------------------------------------------------------------------+
void ExecuteBuy()
{
   m_symbol.Refresh();
   m_symbol.RefreshRates();

   double ask = m_symbol.Ask();
   double bid = m_symbol.Bid();

   if(ask <= 0 || bid <= 0)
   {
      Print("❌ Invalid prices - Ask: ", ask, " Bid: ", bid);
      return;
   }

   double sl = NormalizeDouble(ask - g_slPoints * _Point, _Digits);

   double tp = 0;
   if(g_tp3Active)
      tp = NormalizeDouble(ask + InpTP3_Points * _Point, _Digits);
   else if(g_tp2Active)
      tp = NormalizeDouble(ask + InpTP2_Points * _Point, _Digits);
   else if(g_tp1Active)
      tp = NormalizeDouble(ask + InpTP1_Points * _Point, _Digits);

   double minStopLevel = m_symbol.StopsLevel() * _Point;
   if(minStopLevel > 0)
   {
      if(ask - sl < minStopLevel)
         sl = NormalizeDouble(ask - minStopLevel - 10 * _Point, _Digits);
      if(tp > 0 && tp - ask < minStopLevel)
         tp = NormalizeDouble(ask + minStopLevel + 10 * _Point, _Digits);
   }

   string comment = "M4DI Panel BUY";
   Print("📤 Sending BUY order: Lot=", g_lotSize, " Price=", ask, " SL=", sl, " TP=", tp);

   if(m_trade.Buy(g_lotSize, _Symbol, ask, sl, tp, comment))
   {
      ulong ticket = m_trade.ResultOrder();

      if(ticket > 0)
      {
         // [PATCH #1] Ambil harga entry dari posisi aktual, BUKAN dari ResultPrice()
         // ResultPrice() bisa mengembalikan 0 dan menyebabkan TP trigger instan
         double price = 0;
         if(PositionSelectByTicket(ticket))
            price = PositionGetDouble(POSITION_PRICE_OPEN);

         // Fallback jika posisi belum tersedia (sangat jarang)
         if(price <= 0)
         {
            price = ask;
            Print("⚠️ Fallback: menggunakan Ask sebagai entry price");
         }

         Print("✅ BUY Order SUCCESS! Ticket: #", ticket, " Entry Price: ", price);
         PlayAlertSound("ok.wav");

         g_lastOrderTime = TimeCurrent();

         // [PATCH #2] AddToTPTracker sekarang validasi entry > 0
         AddToTPTracker(ticket, price, g_lotSize, POSITION_TYPE_BUY);

         if(InpShowChartLines)
            CreatePositionLines(ticket, price, sl, POSITION_TYPE_BUY);

         g_stats.totalTrades++;
         g_stats.totalLots += g_lotSize;
      }
      else
      {
         Print("⚠️ BUY Order sent but no ticket returned. RetCode: ", m_trade.ResultRetcode());
      }
   }
   else
   {
      uint retcode = m_trade.ResultRetcode();
      Print("❌ BUY Order FAILED! Error: ", retcode, " - ", GetRetcodeDescription(retcode));
      PlayAlertSound("alert2.wav");
   }

   RefreshPanel();
}

//+------------------------------------------------------------------+
//| EXECUTE SELL ORDER - [PATCH #1] FIXED entry price                |
//+------------------------------------------------------------------+
void ExecuteSell()
{
   m_symbol.Refresh();
   m_symbol.RefreshRates();

   double ask = m_symbol.Ask();
   double bid = m_symbol.Bid();

   if(ask <= 0 || bid <= 0)
   {
      Print("❌ Invalid prices - Ask: ", ask, " Bid: ", bid);
      return;
   }

   double sl = NormalizeDouble(bid + g_slPoints * _Point, _Digits);

   double tp = 0;
   if(g_tp3Active)
      tp = NormalizeDouble(bid - InpTP3_Points * _Point, _Digits);
   else if(g_tp2Active)
      tp = NormalizeDouble(bid - InpTP2_Points * _Point, _Digits);
   else if(g_tp1Active)
      tp = NormalizeDouble(bid - InpTP1_Points * _Point, _Digits);

   double minStopLevel = m_symbol.StopsLevel() * _Point;
   if(minStopLevel > 0)
   {
      if(sl - bid < minStopLevel)
         sl = NormalizeDouble(bid + minStopLevel + 10 * _Point, _Digits);
      if(tp > 0 && bid - tp < minStopLevel)
         tp = NormalizeDouble(bid - minStopLevel - 10 * _Point, _Digits);
   }

   string comment = "M4DI Panel SELL";
   Print("📤 Sending SELL order: Lot=", g_lotSize, " Price=", bid, " SL=", sl, " TP=", tp);

   if(m_trade.Sell(g_lotSize, _Symbol, bid, sl, tp, comment))
   {
      ulong ticket = m_trade.ResultOrder();

      if(ticket > 0)
      {
         // [PATCH #1] Ambil harga entry dari posisi aktual, BUKAN dari ResultPrice()
         double price = 0;
         if(PositionSelectByTicket(ticket))
            price = PositionGetDouble(POSITION_PRICE_OPEN);

         if(price <= 0)
         {
            price = bid;
            Print("⚠️ Fallback: menggunakan Bid sebagai entry price");
         }

         Print("✅ SELL Order SUCCESS! Ticket: #", ticket, " Entry Price: ", price);
         PlayAlertSound("ok.wav");

         g_lastOrderTime = TimeCurrent();

         // [PATCH #2] AddToTPTracker sekarang validasi entry > 0
         AddToTPTracker(ticket, price, g_lotSize, POSITION_TYPE_SELL);

         if(InpShowChartLines)
            CreatePositionLines(ticket, price, sl, POSITION_TYPE_SELL);

         g_stats.totalTrades++;
         g_stats.totalLots += g_lotSize;
      }
      else
      {
         Print("⚠️ SELL Order sent but no ticket returned. RetCode: ", m_trade.ResultRetcode());
      }
   }
   else
   {
      uint retcode = m_trade.ResultRetcode();
      Print("❌ SELL Order FAILED! Error: ", retcode, " - ", GetRetcodeDescription(retcode));
      PlayAlertSound("alert2.wav");
   }

   RefreshPanel();
}

//+------------------------------------------------------------------+
//| GET RETCODE DESCRIPTION                                           |
//+------------------------------------------------------------------+
string GetRetcodeDescription(uint retcode)
{
   switch(retcode)
   {
      case TRADE_RETCODE_REQUOTE:            return "Requote";
      case TRADE_RETCODE_REJECT:             return "Request rejected";
      case TRADE_RETCODE_CANCEL:             return "Request canceled";
      case TRADE_RETCODE_PLACED:             return "Order placed";
      case TRADE_RETCODE_DONE:               return "Request completed";
      case TRADE_RETCODE_DONE_PARTIAL:       return "Partial execution";
      case TRADE_RETCODE_ERROR:              return "Request error";
      case TRADE_RETCODE_TIMEOUT:            return "Timeout";
      case TRADE_RETCODE_INVALID:            return "Invalid request";
      case TRADE_RETCODE_INVALID_VOLUME:     return "Invalid volume";
      case TRADE_RETCODE_INVALID_PRICE:      return "Invalid price";
      case TRADE_RETCODE_INVALID_STOPS:      return "Invalid stops";
      case TRADE_RETCODE_TRADE_DISABLED:     return "Trade disabled";
      case TRADE_RETCODE_MARKET_CLOSED:      return "Market closed";
      case TRADE_RETCODE_NO_MONEY:           return "Insufficient funds";
      case TRADE_RETCODE_PRICE_CHANGED:      return "Price changed";
      case TRADE_RETCODE_PRICE_OFF:          return "No quotes";
      case TRADE_RETCODE_INVALID_EXPIRATION: return "Invalid expiration";
      case TRADE_RETCODE_ORDER_CHANGED:      return "Order changed";
      case TRADE_RETCODE_TOO_MANY_REQUESTS:  return "Too many requests";
      case TRADE_RETCODE_NO_CHANGES:         return "No changes";
      case TRADE_RETCODE_SERVER_DISABLES_AT: return "Autotrading disabled";
      case TRADE_RETCODE_CLIENT_DISABLES_AT: return "Client disabled AT";
      case TRADE_RETCODE_LOCKED:             return "Request locked";
      case TRADE_RETCODE_FROZEN:             return "Order frozen";
      case TRADE_RETCODE_INVALID_FILL:       return "Invalid fill";
      case TRADE_RETCODE_CONNECTION:         return "No connection";
      case TRADE_RETCODE_ONLY_REAL:          return "Only real accounts";
      case TRADE_RETCODE_LIMIT_ORDERS:       return "Order limit";
      case TRADE_RETCODE_LIMIT_VOLUME:       return "Volume limit";
      case TRADE_RETCODE_INVALID_ORDER:      return "Invalid order";
      case TRADE_RETCODE_POSITION_CLOSED:    return "Position closed";
      default:                               return "Unknown error " + IntegerToString(retcode);
   }
}

//+------------------------------------------------------------------+
//| NORMALIZE LOT SIZE                                                |
//+------------------------------------------------------------------+
double NormalizeLot(double lot)
{
   double minLot  = m_symbol.LotsMin();
   double maxLot  = m_symbol.LotsMax();
   double lotStep = m_symbol.LotsStep();

   lot = MathMax(minLot, lot);
   lot = MathMin(maxLot, lot);
   lot = MathRound(lot / lotStep) * lotStep;

   int decimals = 2;
   if(lotStep >= 1.0)       decimals = 0;
   else if(lotStep >= 0.1)  decimals = 1;
   else if(lotStep >= 0.01) decimals = 2;
   else                     decimals = 3;

   return NormalizeDouble(lot, decimals);
}

//+------------------------------------------------------------------+
//| ADJUST LOT SIZE                                                   |
//+------------------------------------------------------------------+
void AdjustLot(int direction)
{
   double lotStep = m_symbol.LotsStep();
   double newLot  = g_lotSize + (direction * lotStep);
   g_lotSize = NormalizeLot(newLot);
   UpdateLotDisplay();
   PlayAlertSound("tick.wav");
}

//+------------------------------------------------------------------+
//| AUTO CALCULATE LOT SIZE                                           |
//+------------------------------------------------------------------+
void AutoCalculateLot()
{
   double balance   = m_account.Balance();
   double riskMoney = balance * InpRiskPercent / 100.0;

   double tickValue = m_symbol.TickValue();
   double tickSize  = m_symbol.TickSize();

   if(g_slPoints <= 0)
   {
      Print("⚠️ Cannot calculate lot - SL points is zero");
      return;
   }

   double lossPerLot = 0;
   if(tickSize > 0 && tickValue > 0)
      lossPerLot = (g_slPoints * _Point) / tickSize * tickValue;
   else
   {
      Print("⚠️ Cannot calculate lot - invalid tick parameters");
      return;
   }

   if(lossPerLot <= 0)
   {
      Print("⚠️ lossPerLot is zero or negative - check symbol params");
      return;
   }

   double calcLot = riskMoney / lossPerLot;
   g_lotSize = NormalizeLot(calcLot);
   UpdateLotDisplay();

   Print("📊 Auto Lot: Risk $", DoubleToString(riskMoney, 2),
         " / SL ", g_slPoints, " pts = ", DoubleToString(g_lotSize, 2), " lots");

   PlayAlertSound("tick.wav");
}

//+------------------------------------------------------------------+
//| ADJUST SL POINTS                                                  |
//+------------------------------------------------------------------+
void AdjustSL(int change)
{
   g_slPoints += change;
   if(g_slPoints < 10)   g_slPoints = 10;
   if(g_slPoints > 5000) g_slPoints = 5000;
   UpdateSLDisplay();
   PlayAlertSound("tick.wav");
}

//+------------------------------------------------------------------+
//| BREAK EVEN HANDLER                                                |
//+------------------------------------------------------------------+
void OnBreakEvenClick()
{
   int count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!m_position.SelectByIndex(i)) continue;
      if(m_position.Symbol() != _Symbol) continue;
      if(m_position.Magic() != InpMagicNumber) continue;

      double entry  = m_position.PriceOpen();
      double sl     = m_position.StopLoss();
      double tp     = m_position.TakeProfit();
      ulong  ticket = m_position.Ticket();
      ENUM_POSITION_TYPE type = m_position.PositionType();

      m_symbol.Refresh();
      m_symbol.RefreshRates();

      double newSL;
      bool canModify = false;

      if(type == POSITION_TYPE_BUY)
      {
         double bid = m_symbol.Bid();
         newSL = NormalizeDouble(entry + InpBE_Offset * _Point, _Digits);
         if(bid > entry + InpBE_Offset * _Point && (newSL > sl || sl == 0))
            canModify = true;
      }
      else
      {
         double ask = m_symbol.Ask();
         newSL = NormalizeDouble(entry - InpBE_Offset * _Point, _Digits);
         if(ask < entry - InpBE_Offset * _Point && (newSL < sl || sl == 0))
            canModify = true;
      }

      if(canModify)
      {
         if(m_trade.PositionModify(ticket, newSL, tp))
         {
            Print("✅ BE set for #", ticket, " New SL: ", newSL);
            count++;
         }
         else
         {
            Print("❌ Failed to set BE for #", ticket, " Error: ", m_trade.ResultRetcode());
         }
      }
   }

   if(count > 0)
   {
      PlayAlertSound("ok.wav");
      Print("📍 Break Even applied to ", count, " position(s)");
   }
   else
   {
      Print("⚠️ No positions qualified for Break Even");
   }

   RefreshPanel();
}

//+------------------------------------------------------------------+
//| PROCESS TRAILING STOP - [PATCH #4] FIXED BUY sl==0 check         |
//+------------------------------------------------------------------+
void ProcessTrailing()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!m_position.SelectByIndex(i)) continue;
      if(m_position.Symbol() != _Symbol) continue;
      if(m_position.Magic() != InpMagicNumber) continue;

      double entry  = m_position.PriceOpen();
      double sl     = m_position.StopLoss();
      double tp     = m_position.TakeProfit();
      ulong  ticket = m_position.Ticket();
      ENUM_POSITION_TYPE type = m_position.PositionType();

      m_symbol.Refresh();
      double bid = m_symbol.Bid();
      double ask = m_symbol.Ask();

      double newSL = 0;
      bool shouldModify = false;

      if(type == POSITION_TYPE_BUY)
      {
         double profitPoints = (bid - entry) / _Point;
         if(profitPoints >= InpTrailingStart)
         {
            newSL = NormalizeDouble(bid - InpTrailingDistance * _Point, _Digits);
            // [PATCH #4] Tambah cek sl==0 sama seperti SELL
            if(sl == 0 || newSL > sl + InpTrailingStep * _Point)
               shouldModify = true;
         }
      }
      else // SELL
      {
         double profitPoints = (entry - ask) / _Point;
         if(profitPoints >= InpTrailingStart)
         {
            newSL = NormalizeDouble(ask + InpTrailingDistance * _Point, _Digits);
            if(sl == 0 || newSL < sl - InpTrailingStep * _Point)
               shouldModify = true;
         }
      }

      if(shouldModify && newSL > 0)
      {
         if(m_trade.PositionModify(ticket, newSL, tp))
            Print("🔄 Trailing updated #", ticket, " New SL: ", newSL);
      }
   }
}

//+------------------------------------------------------------------+
//| ADD POSITION TO TP TRACKER - [PATCH #2] Validasi entry > 0       |
//+------------------------------------------------------------------+
void AddToTPTracker(ulong ticket, double entry, double lot, ENUM_POSITION_TYPE type)
{
   // [PATCH #2] Entry price TIDAK BOLEH 0 - ini penyebab TP trigger instan
   if(entry <= 0)
   {
      Print("❌ AddToTPTracker ABORTED: entry price = 0 for ticket #", ticket,
            " | TP tracker TIDAK ditambahkan. Periksa koneksi broker.");
      return;
   }

   int size = ArraySize(g_tpInfo);
   ArrayResize(g_tpInfo, size + 1);

   g_tpInfo[size].ticket     = ticket;
   g_tpInfo[size].entryPrice = entry;
   g_tpInfo[size].initialLot = lot;
   g_tpInfo[size].posType    = type;
   g_tpInfo[size].tp1Closed  = false;
   g_tpInfo[size].tp2Closed  = false;
   g_tpInfo[size].tp3Closed  = false;
   g_tpInfo[size].movedToBE  = false;

   if(type == POSITION_TYPE_BUY)
   {
      g_tpInfo[size].tp1Price = NormalizeDouble(entry + InpTP1_Points * _Point, _Digits);
      g_tpInfo[size].tp2Price = NormalizeDouble(entry + InpTP2_Points * _Point, _Digits);
      g_tpInfo[size].tp3Price = NormalizeDouble(entry + InpTP3_Points * _Point, _Digits);
   }
   else
   {
      g_tpInfo[size].tp1Price = NormalizeDouble(entry - InpTP1_Points * _Point, _Digits);
      g_tpInfo[size].tp2Price = NormalizeDouble(entry - InpTP2_Points * _Point, _Digits);
      g_tpInfo[size].tp3Price = NormalizeDouble(entry - InpTP3_Points * _Point, _Digits);
   }

   Print("📋 TP Tracker added: #", ticket,
         " Entry=", entry,
         " TP1=", g_tpInfo[size].tp1Price,
         " TP2=", g_tpInfo[size].tp2Price,
         " TP3=", g_tpInfo[size].tp3Price);
}

//+------------------------------------------------------------------+
//| REBUILD TP TRACKER FOR EXISTING POSITIONS                         |
//+------------------------------------------------------------------+
void RebuildTPTracker()
{
   ArrayResize(g_tpInfo, 0);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!m_position.SelectByIndex(i)) continue;
      if(m_position.Symbol() != _Symbol) continue;
      if(m_position.Magic() != InpMagicNumber) continue;

      ulong  ticket = m_position.Ticket();
      double entry  = m_position.PriceOpen();
      double lot    = m_position.Volume();
      ENUM_POSITION_TYPE type = m_position.PositionType();

      AddToTPTracker(ticket, entry, lot, type);

      int idx = ArraySize(g_tpInfo) - 1;
      if(idx < 0) continue;

      m_symbol.Refresh();
      double bid = m_symbol.Bid();
      double ask = m_symbol.Ask();

      if(type == POSITION_TYPE_BUY)
      {
         if(bid > g_tpInfo[idx].tp1Price) g_tpInfo[idx].tp1Closed = true;
         if(bid > g_tpInfo[idx].tp2Price) g_tpInfo[idx].tp2Closed = true;
      }
      else
      {
         if(ask < g_tpInfo[idx].tp1Price) g_tpInfo[idx].tp1Closed = true;
         if(ask < g_tpInfo[idx].tp2Price) g_tpInfo[idx].tp2Closed = true;
      }

      Print("🔄 Rebuilt TP tracker for existing position #", ticket);
   }

   if(ArraySize(g_tpInfo) > 0)
      Print("📋 TP Tracker rebuilt: ", ArraySize(g_tpInfo), " position(s)");
}

//+------------------------------------------------------------------+
//| CHECK TP LEVELS FOR PARTIAL CLOSE                                 |
//+------------------------------------------------------------------+
void CheckTPLevels()
{
   m_symbol.Refresh();
   double bid = m_symbol.Bid();
   double ask = m_symbol.Ask();

   for(int i = ArraySize(g_tpInfo) - 1; i >= 0; i--)
   {
      if(!PositionSelectByTicket(g_tpInfo[i].ticket))
      {
         RemoveFromTPTracker(i);
         continue;
      }

      m_position.SelectByTicket(g_tpInfo[i].ticket);
      double currentVolume = m_position.Volume();

      // CHECK TP1
      if(g_tp1Active && !g_tpInfo[i].tp1Closed)
      {
         bool tp1Hit = false;
         if(g_tpInfo[i].posType == POSITION_TYPE_BUY  && bid >= g_tpInfo[i].tp1Price) tp1Hit = true;
         if(g_tpInfo[i].posType == POSITION_TYPE_SELL && ask <= g_tpInfo[i].tp1Price) tp1Hit = true;

         if(tp1Hit)
         {
            double closeLot = NormalizeLot(g_tpInfo[i].initialLot * InpTP1_Percent / 100.0);
            if(closeLot >= m_symbol.LotsMin() && closeLot <= currentVolume)
            {
               if(m_trade.PositionClosePartial(g_tpInfo[i].ticket, closeLot))
               {
                  Print("🎯 TP1 Hit! Closed ", InpTP1_Percent, "% of #", g_tpInfo[i].ticket);
                  g_tpInfo[i].tp1Closed = true;
                  PlayAlertSound("ok.wav");

                  if(InpMoveSLToBE_OnTP1 && !g_tpInfo[i].movedToBE)
                  {
                     MovePositionToBE(g_tpInfo[i].ticket, g_tpInfo[i].entryPrice, g_tpInfo[i].posType);
                     g_tpInfo[i].movedToBE = true;
                  }
               }
            }
            else
            {
               g_tpInfo[i].tp1Closed = true;
            }
         }
      }

      // CHECK TP2
      if(g_tp2Active && (g_tpInfo[i].tp1Closed || !g_tp1Active) && !g_tpInfo[i].tp2Closed)
      {
         bool tp2Hit = false;
         if(g_tpInfo[i].posType == POSITION_TYPE_BUY  && bid >= g_tpInfo[i].tp2Price) tp2Hit = true;
         if(g_tpInfo[i].posType == POSITION_TYPE_SELL && ask <= g_tpInfo[i].tp2Price) tp2Hit = true;

         if(tp2Hit)
         {
            if(PositionSelectByTicket(g_tpInfo[i].ticket))
            {
               m_position.SelectByTicket(g_tpInfo[i].ticket);
               currentVolume = m_position.Volume();

               double closeLot = NormalizeLot(g_tpInfo[i].initialLot * InpTP2_Percent / 100.0);
               closeLot = MathMin(closeLot, currentVolume);

               if(closeLot >= m_symbol.LotsMin())
               {
                  if(m_trade.PositionClosePartial(g_tpInfo[i].ticket, closeLot))
                  {
                     Print("🎯 TP2 Hit! Closed ", InpTP2_Percent, "% of #", g_tpInfo[i].ticket);
                     g_tpInfo[i].tp2Closed = true;
                     PlayAlertSound("ok.wav");
                  }
               }
               else
               {
                  g_tpInfo[i].tp2Closed = true;
               }
            }
         }
      }

      // CHECK TP3
      if(g_tp3Active && (g_tpInfo[i].tp2Closed || !g_tp2Active) && !g_tpInfo[i].tp3Closed)
      {
         bool tp3Hit = false;
         if(g_tpInfo[i].posType == POSITION_TYPE_BUY  && bid >= g_tpInfo[i].tp3Price) tp3Hit = true;
         if(g_tpInfo[i].posType == POSITION_TYPE_SELL && ask <= g_tpInfo[i].tp3Price) tp3Hit = true;

         if(tp3Hit)
         {
            if(PositionSelectByTicket(g_tpInfo[i].ticket))
            {
               m_position.SelectByTicket(g_tpInfo[i].ticket);
               currentVolume = m_position.Volume();

               double closeLot = NormalizeLot(g_tpInfo[i].initialLot * InpTP3_Percent / 100.0);
               closeLot = MathMin(closeLot, currentVolume);

               if(closeLot >= m_symbol.LotsMin())
               {
                  if(m_trade.PositionClosePartial(g_tpInfo[i].ticket, closeLot))
                  {
                     Print("🎯 TP3 Hit! Closed ", InpTP3_Percent, "% of #", g_tpInfo[i].ticket);
                     g_tpInfo[i].tp3Closed = true;
                     PlayAlertSound("ok.wav");
                  }
               }
               else
               {
                  g_tpInfo[i].tp3Closed = true;
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| MOVE POSITION TO BREAK EVEN                                       |
//+------------------------------------------------------------------+
void MovePositionToBE(ulong ticket, double entry, ENUM_POSITION_TYPE type)
{
   if(!PositionSelectByTicket(ticket)) return;

   m_position.SelectByTicket(ticket);
   double tp = m_position.TakeProfit();

   double newSL;
   if(type == POSITION_TYPE_BUY)
      newSL = NormalizeDouble(entry + InpBE_Offset * _Point, _Digits);
   else
      newSL = NormalizeDouble(entry - InpBE_Offset * _Point, _Digits);

   if(m_trade.PositionModify(ticket, newSL, tp))
      Print("📍 SL moved to BE for #", ticket);
}

//+------------------------------------------------------------------+
//| REMOVE FROM TP TRACKER                                            |
//+------------------------------------------------------------------+
void RemoveFromTPTracker(int index)
{
   int size = ArraySize(g_tpInfo);
   if(index < 0 || index >= size) return;

   DeletePositionLines(g_tpInfo[index].ticket);

   for(int i = index; i < size - 1; i++)
      g_tpInfo[i] = g_tpInfo[i + 1];

   ArrayResize(g_tpInfo, size - 1);
}

//+------------------------------------------------------------------+
//| PARTIAL CLOSE ALL                                                 |
//+------------------------------------------------------------------+
void PartialCloseAll(int percent)
{
   int count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!m_position.SelectByIndex(i)) continue;
      if(m_position.Symbol() != _Symbol) continue;
      if(m_position.Magic() != InpMagicNumber) continue;

      ulong  ticket   = m_position.Ticket();
      double volume   = m_position.Volume();
      double closeLot = NormalizeLot(volume * percent / 100.0);

      if(closeLot < m_symbol.LotsMin())
         closeLot = volume;

      if(m_trade.PositionClosePartial(ticket, closeLot))
      {
         Print("📉 Partial close ", percent, "% of #", ticket, " (", closeLot, " lots)");
         count++;
      }
   }

   if(count > 0)
   {
      PlayAlertSound("ok.wav");
      Print("✅ Partial closed ", count, " position(s) at ", percent, "%");
   }

   RefreshPanel();
}

//+------------------------------------------------------------------+
//| CLOSE ALL POSITIONS                                               |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
   int    count       = 0;
   double totalProfit = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!m_position.SelectByIndex(i)) continue;
      if(m_position.Symbol() != _Symbol) continue;
      if(m_position.Magic() != InpMagicNumber) continue;

      ulong  ticket = m_position.Ticket();
      double profit = m_position.Profit() + m_position.Swap() + m_position.Commission();

      if(m_trade.PositionClose(ticket))
      {
         Print("🔴 Closed #", ticket, " P/L: ", DoubleToString(profit, 2));
         totalProfit += profit;
         count++;
         DeletePositionLines(ticket);
      }
   }

   if(count > 0)
   {
      PlayAlertSound(totalProfit >= 0 ? "ok.wav" : "alert.wav");
      Print("═══ Closed ", count, " positions | Total P/L: $", DoubleToString(totalProfit, 2), " ═══");
   }

   RefreshPanel();
}

//+------------------------------------------------------------------+
//| CLOSE POSITIONS BY TYPE                                           |
//+------------------------------------------------------------------+
void ClosePositionsByType(ENUM_POSITION_TYPE type)
{
   int count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!m_position.SelectByIndex(i)) continue;
      if(m_position.Symbol() != _Symbol) continue;
      if(m_position.Magic() != InpMagicNumber) continue;
      if(m_position.PositionType() != type) continue;

      ulong ticket = m_position.Ticket();
      if(m_trade.PositionClose(ticket))
      {
         count++;
         DeletePositionLines(ticket);
      }
   }

   if(count > 0)
   {
      string typeStr = (type == POSITION_TYPE_BUY) ? "BUY" : "SELL";
      Print("🔴 Closed ", count, " ", typeStr, " position(s)");
      PlayAlertSound("ok.wav");
   }

   RefreshPanel();
}

//+------------------------------------------------------------------+
//| CLOSE POSITIONS BY PROFIT                                         |
//+------------------------------------------------------------------+
void ClosePositionsByProfit(bool profitOnly)
{
   int count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!m_position.SelectByIndex(i)) continue;
      if(m_position.Symbol() != _Symbol) continue;
      if(m_position.Magic() != InpMagicNumber) continue;

      double profit = m_position.Profit() + m_position.Swap() + m_position.Commission();
      bool shouldClose = profitOnly ? (profit > 0) : (profit < 0);

      if(shouldClose)
      {
         ulong ticket = m_position.Ticket();
         if(m_trade.PositionClose(ticket))
         {
            count++;
            DeletePositionLines(ticket);
         }
      }
   }

   if(count > 0)
   {
      string typeStr = profitOnly ? "profitable" : "losing";
      Print("🔴 Closed ", count, " ", typeStr, " position(s)");
      PlayAlertSound("ok.wav");
   }

   RefreshPanel();
}

//+------------------------------------------------------------------+
//| IS SESSION ACTIVE                                                 |
//+------------------------------------------------------------------+
bool IsSessionActive()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int gmtHour = (dt.hour - InpGMT_Offset + 24) % 24;

   bool asia   = (gmtHour >= 0  && gmtHour < 9);
   bool london = (gmtHour >= 8  && gmtHour < 17);
   bool ny     = (gmtHour >= 13 && gmtHour < 22);

   return (asia || london || ny);
}

//+------------------------------------------------------------------+
//| PLAY ALERT SOUND                                                  |
//+------------------------------------------------------------------+
void PlayAlertSound(string soundFile)
{
   if(InpEnableSounds)
      PlaySound(soundFile);
}

//+------------------------------------------------------------------+
//| LOAD DAILY STATS                                                  |
//+------------------------------------------------------------------+
void LoadDailyStats()
{
   datetime today  = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
   string   prefix = PREFIX + "Stats_";

   if(GlobalVariableCheck(prefix + "Date"))
   {
      datetime savedDate = (datetime)GlobalVariableGet(prefix + "Date");
      if(savedDate == today)
      {
         g_stats.date        = today;
         g_stats.realizedPnL = GlobalVariableGet(prefix + "PnL");
         g_stats.wins        = (int)GlobalVariableGet(prefix + "Wins");
         g_stats.losses      = (int)GlobalVariableGet(prefix + "Losses");
         g_stats.totalTrades = (int)GlobalVariableGet(prefix + "Trades");
         g_stats.totalLots   = GlobalVariableGet(prefix + "Lots");
         Print("📊 Daily stats loaded: PnL=$", DoubleToString(g_stats.realizedPnL, 2));
         return;
      }
   }

   g_stats.date        = today;
   g_stats.realizedPnL = 0;
   g_stats.wins        = 0;
   g_stats.losses      = 0;
   g_stats.totalTrades = 0;
   g_stats.totalLots   = 0;
}

//+------------------------------------------------------------------+
//| SAVE DAILY STATS                                                  |
//+------------------------------------------------------------------+
void SaveDailyStats()
{
   string prefix = PREFIX + "Stats_";
   GlobalVariableSet(prefix + "Date",   (double)g_stats.date);
   GlobalVariableSet(prefix + "PnL",    g_stats.realizedPnL);
   GlobalVariableSet(prefix + "Wins",   g_stats.wins);
   GlobalVariableSet(prefix + "Losses", g_stats.losses);
   GlobalVariableSet(prefix + "Trades", g_stats.totalTrades);
   GlobalVariableSet(prefix + "Lots",   g_stats.totalLots);
}

//+------------------------------------------------------------------+
//| CHECK FOR NEW DAY                                                 |
//+------------------------------------------------------------------+
void CheckNewDay()
{
   datetime today = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
   if(g_stats.date != today)
   {
      Print("═══ NEW TRADING DAY - Stats Reset ═══");
      g_stats.date        = today;
      g_stats.realizedPnL = 0;
      g_stats.wins        = 0;
      g_stats.losses      = 0;
      g_stats.totalTrades = 0;
      g_stats.totalLots   = 0;
      SaveDailyStats();
   }
}

//+------------------------------------------------------------------+
//| CREATE PANEL                                                      |
//+------------------------------------------------------------------+
void CreatePanel()
{
   int y          = g_panelY;
   int contentX   = g_panelX + PADDING;
   int contentWidth = PANEL_WIDTH - 2 * PADDING;
   int halfWidth  = (contentWidth - 5) / 2;
   int thirdWidth = (contentWidth - 10) / 3;

   g_panelHeight  = CalculatePanelHeight();

   CreateRectLabel(OBJ_MAIN_BG, g_panelX, g_panelY, PANEL_WIDTH, g_panelHeight, CLR_PANEL_BG, CLR_PANEL_BORDER, 2);

   CreateRectLabel(OBJ_HEADER_BG, g_panelX, y, PANEL_WIDTH, 65, CLR_HEADER_BG, CLR_HEADER_ACCENT, 1);
   CreateRectLabel(OBJ_DRAGAREA,  g_panelX, y, PANEL_WIDTH, 65, clrNONE, clrNONE, 0);
   ObjectSetInteger(0, OBJ_DRAGAREA, OBJPROP_BGCOLOR, CLR_HEADER_BG);

   y += 12;
   CreateTextLabel(OBJ_TITLE, contentX, y, "M4DI~UciH4", CLR_ACCENT_PURPLE, 16, "Arial Black");

   y += 22;
   CreateTextLabel(OBJ_SUBTITLE, contentX, y, "ULTRA BUTTON PANEL • MT5", CLR_TEXT_DIM, 9, "Arial");

   y += 14;
   CreateTextLabel(OBJ_VERSION, contentX, y, "github.com/RizkyEvory • v2.02 PATCHED", CLR_ACCENT_GOLD, 8, "Arial");

   y += 18;
   CreateRectLabel(OBJ_HEADER_LINE, g_panelX + 5, y, PANEL_WIDTH - 10, 2, CLR_PANEL_BORDER, CLR_PANEL_BORDER, 0);

   y += SECTION_GAP + 5;
   CreateRectLabel(OBJ_SYMBOL_BG, contentX, y, contentWidth, 50, CLR_PANEL_BG_LIGHT, CLR_PANEL_BORDER, 1);

   y += 8;
   CreateTextLabel(OBJ_SYMBOL_NAME, contentX + 8, y, _Symbol, CLR_TEXT_WHITE, 12, "Arial Bold");

   y += 18;
   CreateTextLabel(OBJ_SPREAD_LBL,  contentX + 8,   y, "Spread:",  CLR_TEXT_DIM,   9, "Arial");
   CreateTextLabel(OBJ_SPREAD_VAL,  contentX + 55,  y, "0.0 pips", CLR_TEXT_LIGHT, 9, "Arial Bold");
   CreateTextLabel(OBJ_SPREAD_WARN, contentX + 140, y, "",          CLR_WARNING,    9, "Arial Bold");

   y += 16;
   CreateTextLabel(OBJ_SWAP_LONG,  contentX + 8,  y, "L: 0.00", CLR_TEXT_DIM, 8, "Arial");
   CreateTextLabel(OBJ_SWAP_SHORT, contentX + 80, y, "S: 0.00", CLR_TEXT_DIM, 8, "Arial");

   y += 25;
   CreateButton(OBJ_BUY_BTN,  contentX,                y, halfWidth, 50, "", CLR_BUY_BG,  CLR_BUY_BORDER);
   CreateTextLabel(OBJ_BUY_LBL,   contentX + 10, y + 8,  "BUY",     CLR_BUY_TEXT,  14, "Arial Black");
   CreateTextLabel(OBJ_BUY_PRICE, contentX + 10, y + 30, "0.00000", CLR_BUY_TEXT,  10, "Arial");

   CreateButton(OBJ_SELL_BTN, contentX + halfWidth + 5, y, halfWidth, 50, "", CLR_SELL_BG, CLR_SELL_BORDER);
   CreateTextLabel(OBJ_SELL_LBL,   contentX + halfWidth + 15, y + 8,  "SELL",    CLR_SELL_TEXT, 14, "Arial Black");
   CreateTextLabel(OBJ_SELL_PRICE, contentX + halfWidth + 15, y + 30, "0.00000", CLR_SELL_TEXT, 10, "Arial");

   y += 60;
   CreateRectLabel(OBJ_LOT_BG, contentX, y, contentWidth, 85, CLR_PANEL_BG_LIGHT, CLR_PANEL_BORDER, 1);

   y += 8;
   CreateTextLabel(OBJ_LOT_LBL,  contentX + 8,   y,     "Lot Size:", CLR_TEXT_DIM,   9,  "Arial");
   CreateButton(OBJ_LOT_MINUS,   contentX + 70,  y - 3, 28, 20, "−",    CLR_BTN_NORMAL, CLR_ACCENT_PURPLE);
   CreateTextLabel(OBJ_LOT_VAL,  contentX + 105, y,     "0.01",     CLR_ACCENT_GOLD, 11, "Arial Bold");
   CreateButton(OBJ_LOT_PLUS,    contentX + 155, y - 3, 28, 20, "+",    CLR_BTN_NORMAL, CLR_ACCENT_PURPLE);
   CreateButton(OBJ_LOT_AUTO,    contentX + 190, y - 3, 55, 20, "AUTO", CLR_BTN_ACTIVE, CLR_ACCENT_PURPLE);

   y += 22;
   CreateTextLabel(OBJ_SL_LBL,  contentX + 8,   y,     "SL Points:", CLR_TEXT_DIM,  9,  "Arial");
   CreateButton(OBJ_SL_MINUS,   contentX + 70,  y - 3, 28, 20, "−", CLR_BTN_NORMAL, CLR_ACCENT_PURPLE);
   CreateTextLabel(OBJ_SL_VAL,  contentX + 105, y,     "500",        CLR_LOSS,      11, "Arial Bold");
   CreateButton(OBJ_SL_PLUS,    contentX + 155, y - 3, 28, 20, "+", CLR_BTN_NORMAL, CLR_ACCENT_PURPLE);

   y += 22;
   CreateTextLabel(OBJ_RISK_LBL, contentX + 8, y, "Risk: " + DoubleToString(InpRiskPercent, 1) + "%", CLR_TEXT_DIM, 9, "Arial");

   y += 18;
   CreateTextLabel(OBJ_RISK_MONEY, contentX + 8,   y, "Risk: $0.00", CLR_WARNING,       9, "Arial");
   CreateTextLabel(OBJ_CALC_LOT,  contentX + 130, y, "Calc: 0.01",  CLR_ACCENT_PURPLE, 9, "Arial");

   y += 25;
   CreateTextLabel(OBJ_TP_HEADER, contentX, y, "━━━ TP LEVELS ━━━", CLR_ACCENT_PURPLE, 9, "Arial Bold");

   y += 18;
   string tp1txt = g_tp1Active ? "☑ TP1" : "☐ TP1";
   CreateButton(OBJ_TP1_BTN, contentX, y, 45, 22, tp1txt, CLR_BTN_NORMAL, CLR_TP_LINE);
   CreateTextLabel(OBJ_TP1_INFO, contentX + 50, y + 4, IntegerToString(InpTP1_Points) + " pts | " + IntegerToString(InpTP1_Percent) + "%", CLR_TP_LINE, 9, "Arial");

   y += 24;
   string tp2txt = g_tp2Active ? "☑ TP2" : "☐ TP2";
   CreateButton(OBJ_TP2_BTN, contentX, y, 45, 22, tp2txt, CLR_BTN_NORMAL, CLR_TP_LINE);
   CreateTextLabel(OBJ_TP2_INFO, contentX + 50, y + 4, IntegerToString(InpTP2_Points) + " pts | " + IntegerToString(InpTP2_Percent) + "%", CLR_TP_LINE, 9, "Arial");

   y += 24;
   string tp3txt = g_tp3Active ? "☑ TP3" : "☐ TP3";
   CreateButton(OBJ_TP3_BTN, contentX, y, 45, 22, tp3txt, CLR_BTN_NORMAL, CLR_TP_LINE);
   CreateTextLabel(OBJ_TP3_INFO, contentX + 50, y + 4, IntegerToString(InpTP3_Points) + " pts | " + IntegerToString(InpTP3_Percent) + "%", CLR_TP_LINE, 9, "Arial");

   y += 30;
   CreateTextLabel(OBJ_MGMT_HEADER, contentX, y, "━━━ MANAGEMENT ━━━", CLR_ACCENT_PURPLE, 9, "Arial Bold");

   y += 18;
   CreateButton(OBJ_BE_BTN,    contentX,                y, halfWidth, BUTTON_HEIGHT, "BREAK EVEN", CLR_BTN_NORMAL, CLR_BE_LINE);
   CreateButton(OBJ_TRAIL_BTN, contentX + halfWidth + 5, y, halfWidth, BUTTON_HEIGHT, "TRAIL: OFF", CLR_BTN_NORMAL, CLR_TEXT_DIM);

   y += BUTTON_HEIGHT + 10;
   CreateTextLabel(OBJ_PARTIAL_HEADER, contentX, y, "━━━ PARTIAL CLOSE ━━━", CLR_ACCENT_PURPLE, 9, "Arial Bold");

   y += 18;
   CreateButton(OBJ_CLOSE_25, contentX,                        y, thirdWidth, 26, "25%", CLR_BTN_NORMAL, CLR_TEXT_LIGHT);
   CreateButton(OBJ_CLOSE_50, contentX + thirdWidth + 5,       y, thirdWidth, 26, "50%", CLR_BTN_NORMAL, CLR_TEXT_LIGHT);
   CreateButton(OBJ_CLOSE_75, contentX + 2*(thirdWidth + 5),   y, thirdWidth, 26, "75%", CLR_BTN_NORMAL, CLR_TEXT_LIGHT);

   y += 35;
   CreateButton(OBJ_CLOSE_ALL, contentX, y, contentWidth, BUTTON_HEIGHT, "CLOSE ALL", CLR_SELL_BG, CLR_SELL_TEXT);

   y += BUTTON_HEIGHT + 5;
   CreateButton(OBJ_CLOSE_BUY,  contentX,                y, halfWidth, 26, "CLOSE BUY",  CLR_BUY_BG,  CLR_BUY_TEXT);
   CreateButton(OBJ_CLOSE_SELL, contentX + halfWidth + 5, y, halfWidth, 26, "CLOSE SELL", CLR_SELL_BG, CLR_SELL_TEXT);

   y += 30;
   CreateButton(OBJ_CLOSE_PROFIT, contentX,                y, halfWidth, 26, "✓ PROFIT", CLR_BUY_BG,  CLR_PROFIT);
   CreateButton(OBJ_CLOSE_LOSS,   contentX + halfWidth + 5, y, halfWidth, 26, "✗ LOSS",   CLR_SELL_BG, CLR_LOSS);

   if(InpShowSessionFilter)
   {
      y += 35;
      CreateTextLabel(OBJ_SESSION_HEADER, contentX, y, "━━━ SESSIONS ━━━", CLR_ACCENT_PURPLE, 9, "Arial Bold");

      y += 18;
      CreateButton(OBJ_SESSION_ASIA,   contentX,                      y, thirdWidth, 26, "ASIA",   CLR_SESSION_INACTIVE, CLR_TEXT_DIM);
      CreateButton(OBJ_SESSION_LONDON, contentX + thirdWidth + 5,     y, thirdWidth, 26, "LONDON", CLR_SESSION_INACTIVE, CLR_TEXT_DIM);
      CreateButton(OBJ_SESSION_NY,     contentX + 2*(thirdWidth + 5), y, thirdWidth, 26, "N.YORK", CLR_SESSION_INACTIVE, CLR_TEXT_DIM);
   }

   if(InpShowDailyStats)
   {
      y += 35;
      CreateTextLabel(OBJ_STATS_HEADER,  contentX, y,      "━━━ DAILY STATS ━━━",    CLR_ACCENT_PURPLE, 9,  "Arial Bold");

      y += 18;
      CreateTextLabel(OBJ_STATS_DAILY,   contentX, y,      "Daily P/L: $0.00",       CLR_TEXT_LIGHT,    10, "Arial");

      y += 18;
      CreateTextLabel(OBJ_STATS_FLOATING, contentX, y,     "Floating: $0.00",         CLR_TEXT_DIM,      9,  "Arial");

      y += 16;
      CreateTextLabel(OBJ_STATS_TRADES,  contentX, y,      "Trades: 0 | Lots: 0.00", CLR_TEXT_DIM,      9,  "Arial");

      y += 16;
      CreateTextLabel(OBJ_STATS_WINRATE, contentX, y,      "Win Rate: 0% (0/0)",      CLR_TEXT_DIM,      9,  "Arial");
   }

   y += 25;
   CreateRectLabel(OBJ_FOOTER_LINE, g_panelX + 5, y, PANEL_WIDTH - 10, 1, CLR_PANEL_BORDER, CLR_PANEL_BORDER, 0);

   y += 8;
   CreateTextLabel(OBJ_FOOTER, contentX, y, "M4DI~UciH4 © 2024 | Keys: B/S/Q/E/T", CLR_TEXT_DARK, 8, "Arial");

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| CALCULATE PANEL HEIGHT                                            |
//+------------------------------------------------------------------+
int CalculatePanelHeight()
{
   int height = 540;
   if(InpShowSessionFilter) height += 60;
   if(InpShowDailyStats)    height += 95;
   return height;
}

//+------------------------------------------------------------------+
//| CREATE RECTANGLE LABEL                                            |
//+------------------------------------------------------------------+
void CreateRectLabel(string name, int x, int y, int width, int height, color bgColor, color borderColor, int borderWidth)
{
   ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,   x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,   y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,       width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,       height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,     bgColor);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_COLOR,       borderColor);
   ObjectSetInteger(0, name, OBJPROP_WIDTH,       borderWidth);
   ObjectSetInteger(0, name, OBJPROP_CORNER,      InpPanelCorner);
   ObjectSetInteger(0, name, OBJPROP_BACK,        false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,      true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER,      0);
}

//+------------------------------------------------------------------+
//| CREATE TEXT LABEL                                                 |
//+------------------------------------------------------------------+
void CreateTextLabel(string name, int x, int y, string text, color textColor, int fontSize, string fontName)
{
   ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,  x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,  y);
   ObjectSetString(0,  name, OBJPROP_TEXT,       text);
   ObjectSetInteger(0, name, OBJPROP_COLOR,      textColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,   fontSize);
   ObjectSetString(0,  name, OBJPROP_FONT,       fontName);
   ObjectSetInteger(0, name, OBJPROP_CORNER,     InpPanelCorner);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,     ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_BACK,       false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER,     1);
}

//+------------------------------------------------------------------+
//| CREATE BUTTON                                                     |
//+------------------------------------------------------------------+
void CreateButton(string name, int x, int y, int width, int height, string text, color bgColor, color borderColor)
{
   ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,    x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,    y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,        width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,        height);
   ObjectSetString(0,  name, OBJPROP_TEXT,         text);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,      bgColor);
   ObjectSetInteger(0, name, OBJPROP_COLOR,        borderColor);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, borderColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,     9);
   ObjectSetString(0,  name, OBJPROP_FONT,         "Arial Bold");
   ObjectSetInteger(0, name, OBJPROP_CORNER,       InpPanelCorner);
   ObjectSetInteger(0, name, OBJPROP_BACK,         false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,   false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,       true);
   ObjectSetInteger(0, name, OBJPROP_STATE,        false);
   ObjectSetInteger(0, name, OBJPROP_ZORDER,       2);
}

//+------------------------------------------------------------------+
//| MOVE ALL OBJECTS (Panel Drag)                                     |
//+------------------------------------------------------------------+
void MoveAllObjects()
{
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i);
      if(StringFind(name, PREFIX) != 0) continue;

      ENUM_OBJECT objType = (ENUM_OBJECT)ObjectGetInteger(0, name, OBJPROP_TYPE);
      if(objType == OBJ_RECTANGLE_LABEL || objType == OBJ_LABEL || objType == OBJ_BUTTON)
      {
         int currX = (int)ObjectGetInteger(0, name, OBJPROP_XDISTANCE);
         int currY = (int)ObjectGetInteger(0, name, OBJPROP_YDISTANCE);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, currX + g_deltaMoveX);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, currY + g_deltaMoveY);
      }
   }
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| REFRESH PANEL                                                     |
//+------------------------------------------------------------------+
void RefreshPanel()
{
   UpdatePriceDisplay();
   UpdateSpreadDisplay();
   UpdateSwapDisplay();
   UpdateLotDisplay();
   UpdateSLDisplay();
   UpdateRiskDisplay();
   UpdateTPButtons();
   UpdateTrailingButton();

   if(InpShowSessionFilter) UpdateSessionDisplay();
   if(InpShowDailyStats)    UpdateStatsDisplay();

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| UPDATE PRICE DISPLAY                                              |
//+------------------------------------------------------------------+
void UpdatePriceDisplay()
{
   m_symbol.Refresh();
   m_symbol.RefreshRates();
   ObjectSetString(0, OBJ_BUY_PRICE,  OBJPROP_TEXT, DoubleToString(m_symbol.Ask(), _Digits));
   ObjectSetString(0, OBJ_SELL_PRICE, OBJPROP_TEXT, DoubleToString(m_symbol.Bid(), _Digits));
}

//+------------------------------------------------------------------+
//| UPDATE SPREAD DISPLAY                                             |
//+------------------------------------------------------------------+
void UpdateSpreadDisplay()
{
   int    spreadPts  = (int)m_symbol.Spread();
   double spreadPips = spreadPts * _Point / GetPipSize();
   string spreadText = DoubleToString(spreadPips, 1) + " pips";

   ObjectSetString(0, OBJ_SPREAD_VAL, OBJPROP_TEXT, spreadText);

   color  spreadClr = CLR_PROFIT;
   string warnText  = "";

   if(spreadPts > InpMaxSpread)
   {
      spreadClr = CLR_LOSS;
      warnText  = "⚠ HIGH";
   }
   else if(spreadPts > InpMaxSpread * 0.7)
   {
      spreadClr = CLR_WARNING;
   }

   ObjectSetInteger(0, OBJ_SPREAD_VAL,  OBJPROP_COLOR, spreadClr);
   ObjectSetString(0,  OBJ_SPREAD_WARN, OBJPROP_TEXT,  warnText);
}

//+------------------------------------------------------------------+
//| GET PIP SIZE                                                      |
//+------------------------------------------------------------------+
double GetPipSize()
{
   if(_Digits == 3 || _Digits == 5)
      return _Point * 10;
   return _Point;
}

//+------------------------------------------------------------------+
//| UPDATE SWAP DISPLAY                                               |
//+------------------------------------------------------------------+
void UpdateSwapDisplay()
{
   double swapLong  = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_LONG);
   double swapShort = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_SHORT);

   ObjectSetString(0,  OBJ_SWAP_LONG,  OBJPROP_TEXT,  "L: " + DoubleToString(swapLong,  2));
   ObjectSetString(0,  OBJ_SWAP_SHORT, OBJPROP_TEXT,  "S: " + DoubleToString(swapShort, 2));
   ObjectSetInteger(0, OBJ_SWAP_LONG,  OBJPROP_COLOR, swapLong  >= 0 ? CLR_PROFIT : CLR_LOSS);
   ObjectSetInteger(0, OBJ_SWAP_SHORT, OBJPROP_COLOR, swapShort >= 0 ? CLR_PROFIT : CLR_LOSS);
}

//+------------------------------------------------------------------+
//| UPDATE LOT DISPLAY                                                |
//+------------------------------------------------------------------+
void UpdateLotDisplay()
{
   ObjectSetString(0, OBJ_LOT_VAL, OBJPROP_TEXT, DoubleToString(g_lotSize, 2));
}

//+------------------------------------------------------------------+
//| UPDATE SL DISPLAY                                                 |
//+------------------------------------------------------------------+
void UpdateSLDisplay()
{
   ObjectSetString(0, OBJ_SL_VAL, OBJPROP_TEXT, IntegerToString(g_slPoints));
}

//+------------------------------------------------------------------+
//| UPDATE RISK DISPLAY                                               |
//+------------------------------------------------------------------+
void UpdateRiskDisplay()
{
   double balance   = m_account.Balance();
   double riskMoney = balance * InpRiskPercent / 100.0;

   double tickValue = m_symbol.TickValue();
   double tickSize  = m_symbol.TickSize();
   double calcLot   = 0;

   if(tickValue > 0 && tickSize > 0 && g_slPoints > 0)
   {
      double lossPerLot = (g_slPoints * _Point) / tickSize * tickValue;
      if(lossPerLot > 0)
         calcLot = riskMoney / lossPerLot;
      calcLot = NormalizeLot(calcLot);
   }

   ObjectSetString(0, OBJ_RISK_MONEY, OBJPROP_TEXT, "Risk: $" + DoubleToString(riskMoney, 2));
   ObjectSetString(0, OBJ_CALC_LOT,   OBJPROP_TEXT, "Calc: "  + DoubleToString(calcLot,   2));
}

//+------------------------------------------------------------------+
//| UPDATE TP BUTTONS                                                 |
//+------------------------------------------------------------------+
void UpdateTPButtons()
{
   ObjectSetString(0,  OBJ_TP1_BTN,  OBJPROP_TEXT,  g_tp1Active ? "☑ TP1" : "☐ TP1");
   ObjectSetString(0,  OBJ_TP2_BTN,  OBJPROP_TEXT,  g_tp2Active ? "☑ TP2" : "☐ TP2");
   ObjectSetString(0,  OBJ_TP3_BTN,  OBJPROP_TEXT,  g_tp3Active ? "☑ TP3" : "☐ TP3");

   color tp1clr = g_tp1Active ? CLR_TP_LINE : CLR_TEXT_DIM;
   color tp2clr = g_tp2Active ? CLR_TP_LINE : CLR_TEXT_DIM;
   color tp3clr = g_tp3Active ? CLR_TP_LINE : CLR_TEXT_DIM;

   ObjectSetInteger(0, OBJ_TP1_BTN,  OBJPROP_COLOR, tp1clr);
   ObjectSetInteger(0, OBJ_TP2_BTN,  OBJPROP_COLOR, tp2clr);
   ObjectSetInteger(0, OBJ_TP3_BTN,  OBJPROP_COLOR, tp3clr);
   ObjectSetInteger(0, OBJ_TP1_INFO, OBJPROP_COLOR, tp1clr);
   ObjectSetInteger(0, OBJ_TP2_INFO, OBJPROP_COLOR, tp2clr);
   ObjectSetInteger(0, OBJ_TP3_INFO, OBJPROP_COLOR, tp3clr);
}

//+------------------------------------------------------------------+
//| UPDATE TRAILING BUTTON                                            |
//+------------------------------------------------------------------+
void UpdateTrailingButton()
{
   string txt = g_trailingOn ? "TRAIL: ON" : "TRAIL: OFF";
   color  clr = g_trailingOn ? CLR_PROFIT   : CLR_TEXT_DIM;
   color  bg  = g_trailingOn ? CLR_BTN_ACTIVE : CLR_BTN_NORMAL;

   ObjectSetString(0,  OBJ_TRAIL_BTN, OBJPROP_TEXT,   txt);
   ObjectSetInteger(0, OBJ_TRAIL_BTN, OBJPROP_COLOR,  clr);
   ObjectSetInteger(0, OBJ_TRAIL_BTN, OBJPROP_BGCOLOR, bg);
}

//+------------------------------------------------------------------+
//| UPDATE SESSION DISPLAY                                            |
//+------------------------------------------------------------------+
void UpdateSessionDisplay()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int gmtHour = (dt.hour - InpGMT_Offset + 24) % 24;

   bool asia   = (gmtHour >= 0  && gmtHour < 9);
   bool london = (gmtHour >= 8  && gmtHour < 17);
   bool ny     = (gmtHour >= 13 && gmtHour < 22);

   ObjectSetInteger(0, OBJ_SESSION_ASIA,   OBJPROP_BGCOLOR, asia   ? CLR_SESSION_ACTIVE : CLR_SESSION_INACTIVE);
   ObjectSetInteger(0, OBJ_SESSION_ASIA,   OBJPROP_COLOR,   asia   ? CLR_TEXT_WHITE : CLR_TEXT_DIM);
   ObjectSetInteger(0, OBJ_SESSION_LONDON, OBJPROP_BGCOLOR, london ? CLR_SESSION_ACTIVE : CLR_SESSION_INACTIVE);
   ObjectSetInteger(0, OBJ_SESSION_LONDON, OBJPROP_COLOR,   london ? CLR_TEXT_WHITE : CLR_TEXT_DIM);
   ObjectSetInteger(0, OBJ_SESSION_NY,     OBJPROP_BGCOLOR, ny     ? CLR_SESSION_ACTIVE : CLR_SESSION_INACTIVE);
   ObjectSetInteger(0, OBJ_SESSION_NY,     OBJPROP_COLOR,   ny     ? CLR_TEXT_WHITE : CLR_TEXT_DIM);
}

//+------------------------------------------------------------------+
//| UPDATE STATS DISPLAY                                              |
//+------------------------------------------------------------------+
void UpdateStatsDisplay()
{
   string pnlSign  = g_stats.realizedPnL >= 0 ? "+" : "";
   color  pnlClr   = g_stats.realizedPnL >= 0 ? CLR_PROFIT : CLR_LOSS;
   ObjectSetString(0,  OBJ_STATS_DAILY,   OBJPROP_TEXT,  "Daily P/L: " + pnlSign + "$" + DoubleToString(g_stats.realizedPnL, 2));
   ObjectSetInteger(0, OBJ_STATS_DAILY,   OBJPROP_COLOR, pnlClr);

   double floating   = GetFloatingPnL();
   string floatSign  = floating >= 0 ? "+" : "";
   color  floatClr   = floating >= 0 ? CLR_PROFIT : CLR_LOSS;
   ObjectSetString(0,  OBJ_STATS_FLOATING, OBJPROP_TEXT,  "Floating: " + floatSign + "$" + DoubleToString(floating, 2));
   ObjectSetInteger(0, OBJ_STATS_FLOATING, OBJPROP_COLOR, floatClr);

   int openTrades = CountOpenPositions();
   ObjectSetString(0, OBJ_STATS_TRADES, OBJPROP_TEXT,
      "Open: " + IntegerToString(openTrades) + " | Lots: " + DoubleToString(g_stats.totalLots, 2));

   int    total   = g_stats.wins + g_stats.losses;
   double winrate = total > 0 ? (double)g_stats.wins / total * 100.0 : 0;
   ObjectSetString(0, OBJ_STATS_WINRATE, OBJPROP_TEXT,
      "Win Rate: " + DoubleToString(winrate, 1) + "% (" + IntegerToString(g_stats.wins) + "/" + IntegerToString(total) + ")");
}

//+------------------------------------------------------------------+
//| GET FLOATING PNL                                                  |
//+------------------------------------------------------------------+
double GetFloatingPnL()
{
   double pnl = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!m_position.SelectByIndex(i)) continue;
      if(m_position.Symbol() != _Symbol) continue;
      if(m_position.Magic() != InpMagicNumber) continue;
      pnl += m_position.Profit() + m_position.Swap() + m_position.Commission();
   }
   return pnl;
}

//+------------------------------------------------------------------+
//| COUNT OPEN POSITIONS                                              |
//+------------------------------------------------------------------+
int CountOpenPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!m_position.SelectByIndex(i)) continue;
      if(m_position.Symbol() != _Symbol) continue;
      if(m_position.Magic() != InpMagicNumber) continue;
      count++;
   }
   return count;
}

//+------------------------------------------------------------------+
//| CREATE POSITION LINES ON CHART                                    |
//+------------------------------------------------------------------+
void CreatePositionLines(ulong ticket, double entry, double sl, ENUM_POSITION_TYPE type)
{
   string ticketStr = IntegerToString(ticket);

   CreateHorizontalLine(PREFIX + "Entry_" + ticketStr, entry, CLR_ENTRY_LINE, STYLE_SOLID, 1, "Entry #" + ticketStr);
   CreateHorizontalLine(PREFIX + "SL_"    + ticketStr, sl,    CLR_SL_LINE,    STYLE_DASH,  1, "SL #"    + ticketStr);

   if(g_tp1Active)
   {
      double tp1 = (type == POSITION_TYPE_BUY) ? entry + InpTP1_Points * _Point : entry - InpTP1_Points * _Point;
      CreateHorizontalLine(PREFIX + "TP1_" + ticketStr, NormalizeDouble(tp1, _Digits), CLR_TP_LINE, STYLE_DASH, 1, "TP1 #" + ticketStr);
   }
   if(g_tp2Active)
   {
      double tp2 = (type == POSITION_TYPE_BUY) ? entry + InpTP2_Points * _Point : entry - InpTP2_Points * _Point;
      CreateHorizontalLine(PREFIX + "TP2_" + ticketStr, NormalizeDouble(tp2, _Digits), CLR_TP_LINE, STYLE_DASH, 1, "TP2 #" + ticketStr);
   }
   if(g_tp3Active)
   {
      double tp3 = (type == POSITION_TYPE_BUY) ? entry + InpTP3_Points * _Point : entry - InpTP3_Points * _Point;
      CreateHorizontalLine(PREFIX + "TP3_" + ticketStr, NormalizeDouble(tp3, _Digits), CLR_TP_LINE, STYLE_DASH, 1, "TP3 #" + ticketStr);
   }

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| CREATE HORIZONTAL LINE                                            |
//+------------------------------------------------------------------+
void CreateHorizontalLine(string name, double price, color lineColor, ENUM_LINE_STYLE style, int width, string tooltip)
{
   ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR,      lineColor);
   ObjectSetInteger(0, name, OBJPROP_STYLE,      style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH,      width);
   ObjectSetInteger(0, name, OBJPROP_BACK,       true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
   ObjectSetString(0,  name, OBJPROP_TOOLTIP,    tooltip);
}

//+------------------------------------------------------------------+
//| DELETE POSITION LINES                                             |
//+------------------------------------------------------------------+
void DeletePositionLines(ulong ticket)
{
   string ticketStr = IntegerToString(ticket);
   ObjectDelete(0, PREFIX + "Entry_" + ticketStr);
   ObjectDelete(0, PREFIX + "SL_"    + ticketStr);
   ObjectDelete(0, PREFIX + "TP1_"   + ticketStr);
   ObjectDelete(0, PREFIX + "TP2_"   + ticketStr);
   ObjectDelete(0, PREFIX + "TP3_"   + ticketStr);
   ObjectDelete(0, PREFIX + "BE_"    + ticketStr);
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| UPDATE CHART LINES                                                |
//+------------------------------------------------------------------+
void UpdateChartLines()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!m_position.SelectByIndex(i)) continue;
      if(m_position.Symbol() != _Symbol) continue;
      if(m_position.Magic() != InpMagicNumber) continue;

      ulong  ticket    = m_position.Ticket();
      string ticketStr = IntegerToString(ticket);
      double sl        = m_position.StopLoss();

      string slName = PREFIX + "SL_" + ticketStr;
      if(ObjectFind(0, slName) >= 0 && sl > 0)
         ObjectSetDouble(0, slName, OBJPROP_PRICE, sl);
   }
}

//+------------------------------------------------------------------+
//| END OF FILE                                                       |
//+------------------------------------------------------------------+
