@echo off
echo Installing R packages for Stock Dashboard...

"C:\Program Files\R\R-4.4.1\bin\Rscript.exe" -e "install.packages(c('shiny', 'shinydashboard', 'DT', 'dplyr', 'readr', 'lubridate', 'tidyr', 'plotly', 'httr', 'jsonlite', 'shinycssloaders', 'htmltools'), repos='https://cran.r-project.org')"

echo Package installation complete!
pause