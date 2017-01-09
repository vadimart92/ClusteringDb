#write("TMP = 'C:\\Temp'", file = file.path(Sys.getenv('R_USER'), '.Renviron'))
install.packages("igraph")

if (!require(devtools)) {
    install.packages('devtools')
}
devtools::install_github('hadley/scales')
if (!require(assertthat)) {
    install.packages('assertthat')
}
devtools::install_github('hadley/ggplot2')
if (!require(DBI)) {
    install.packages('DBI')
}
devtools::install_github('pacificclimate/Rudunits2')
devtools::install_github('edzer/units')
devtools::install_github('thomasp85/ggforce')
devtools::install_github('thomasp85/ggraph')


install.packages('RODBC')

#Rtools34