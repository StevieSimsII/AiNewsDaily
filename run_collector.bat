@echo off
echo AI News Collector Menu
echo ---------------------
echo 1. Collect new AI and ML articles
echo 2. Analyze research insights
echo 3. Exit
echo.

set /p choice=Enter your choice (1-3): 

if "%choice%"=="1" goto collect
if "%choice%"=="2" goto analyze
if "%choice%"=="3" goto end

:collect
echo Running AI News Collector...
python ai_news_collector.py
echo Collection completed!
goto end

:analyze
echo Analyzing research insights...
python analyze_research.py
goto end

:end
pause
