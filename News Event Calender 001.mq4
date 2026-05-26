//+------------------------------------------------------------------+
//|                                        NewsEventCalendar.mq4     |
//|         Fetch and Display Upcoming Economic News Events          |
//+------------------------------------------------------------------+
#property strict

// Input parameters
input string FileName = "news.csv";  // File name for the news events file
input bool AlertHighImpact = true;   // Enable alerts for high-impact events
input bool ClosePositions = false;  // Close positions before high-impact events
input int AlertMinutesBefore = 30;  // Minutes before the event to alert

//+------------------------------------------------------------------+
//| Main Function                                                   |
//+------------------------------------------------------------------+
void OnStart()
{
   // Open the file for reading
   int handle = FileOpen(FileName, FILE_CSV | FILE_READ, ",");
   if (handle < 0) {
      Print("Failed to open file: ", FileName);
      return;
   }

   datetime now = TimeCurrent();
   Print("Fetching news events...");

   while (!FileIsEnding(handle)) {
      string timeStr = FileReadString(handle);   // Event time
      string impact = FileReadString(handle);    // Impact level
      string event = FileReadString(handle);     // Event description

      // Convert time string to datetime
      datetime eventTime = StringToTime(timeStr);

      // Skip past events
      if (eventTime <= now) continue;

      // Display upcoming event
      Print("Upcoming Event: ", timeStr, " | Impact: ", impact, " | Event: ", event);

      // Alert for high-impact events
      if (AlertHighImpact && StringFind(impact, "High") >= 0) {
         int minutesToEvent = (int)((eventTime - now) / 60);
         if (minutesToEvent <= AlertMinutesBefore) {
            Alert("High-Impact Event: ", event, " in ", minutesToEvent, " minutes.");

            // Close positions if enabled
            if (ClosePositions) {
               CloseAllPositions();
               Print("Closed all positions before high-impact event: ", event);
            }
         }
      }
   }

   // Close the file
   FileClose(handle);
   Print("News events processed.");
}

//+------------------------------------------------------------------+
//| Function to Close All Open Positions                            |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
   int totalOrders = OrdersTotal();
   for (int i = totalOrders - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         int orderType = OrderType();
         double price = (orderType == OP_BUY) ? Bid : Ask;
         if (!OrderClose(OrderTicket(), OrderLots(), price, 3, clrRed)) {
            Print("Failed to close order (Ticket: ", OrderTicket(), "): ", GetLastError());
         } else {
            Print("Closed order (Ticket: ", OrderTicket(), ").");
         }
      }
   }
}
s