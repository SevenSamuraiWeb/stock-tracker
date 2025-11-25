# NIFTY 50 Stock Dashboard - Quick Start Guide

## 🎉 SUCCESS! Your R Shiny Application is Running!

### 📊 **Your dashboard is now accessible at:**
**http://127.0.0.1:4300**

---

## 🚀 **How to Run the Application**

### Option 1: Double-click to run
- **Double-click**: `run_app.bat`
- The dashboard will automatically open in your browser

### Option 2: Command line
```bash
# In PowerShell or Command Prompt:
cd "C:\Users\Joseph\Desktop\projects\stock_tracker"
.\run_app.bat
```

### Option 3: From R/RStudio
```r
setwd("C:/Users/Joseph/Desktop/projects/stock_tracker")
shiny::runApp("app.R")
```

---

## ⚙️ **Application Features**

### 🔍 **Filter Options (Left Sidebar)**
- **Industry Filter**: Filter stocks by sector
- **Stock Search**: Select specific NIFTY 50 stocks  
- **Date Range**: Analyze custom time periods

### 📈 **Main Dashboard**
- **Key Metrics**: Latest price, volume, day high/low
- **Interactive Charts**: Line and candlestick price charts
- **Volume Analysis**: Trading volume visualization
- **Industry Analysis**: Market share and comparison charts
- **Real-time News**: Latest financial news for selected stocks

---

## 🛠️ **Troubleshooting**

### **App won't start?**
1. Ensure all data files exist:
   - `NIFTY50_all.csv`
   - `stock_metadata.csv`
2. Run package installation: `.\install_packages.bat`
3. Check R installation: R should be in `C:\Program Files\R\`

### **Browser doesn't open automatically?**
- Manually navigate to: **http://127.0.0.1:4300**
- Or try: **http://localhost:4300**

### **Charts not displaying?**
- Wait for data to load (may take a few seconds)
- Try refreshing the browser page
- Ensure internet connection for news features

### **Performance Issues?**
- The application loads ~235K rows of stock data
- First load may take 10-15 seconds
- Subsequent interactions should be fast

---

## 📋 **Current Status**

✅ **R Installation**: Working (Version 4.4.1)  
✅ **Required Packages**: All installed successfully  
✅ **Data Files**: Present and loading  
✅ **Shiny Server**: Running on port 4300  
✅ **Dashboard**: Fully functional  

---

## 🔧 **Technical Details**

### **Files Created:**
- `app.R` - Main Shiny application
- `utils.R` - Data processing functions  
- `charts.R` - Interactive chart functions
- `news.R` - News fetching functionality
- `assets/style.css` - Dark theme styling
- `run_app.bat` - Windows launcher
- `install_packages.bat` - Package installer

### **R Packages Used:**
- `shiny` - Web application framework
- `shinydashboard` - Dashboard UI components
- `plotly` - Interactive charts
- `dplyr` - Data manipulation
- `httr` - API requests for news
- And 7 other supporting packages

---

## 🔄 **Stopping the Application**

To stop the dashboard:
1. **In terminal**: Press `Ctrl + C`
2. **Close browser tab**: Application keeps running in background
3. **Force stop**: Close the Command Prompt/PowerShell window

---

## 🎯 **Next Steps**

1. **Explore the Dashboard**: Try different stocks and date ranges
2. **Customize**: Modify `assets/style.css` for different themes
3. **Add Features**: Extend functionality in the R files
4. **Data Updates**: Replace CSV files with newer data as needed

---

## 📞 **Support**

The application has been successfully converted from Python to R Shiny with enhanced features:
- Better performance with large datasets
- More interactive charts  
- Professional dashboard layout
- Responsive design for different screen sizes

**Enjoy your new R-powered stock dashboard! 🚀📊**