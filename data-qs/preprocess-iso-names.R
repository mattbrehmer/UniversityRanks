require(data.table)

iso.dt = as.data.table(read.csv("iso_3166_2_countries.csv",header = T))

#subset to attributes of interest
iso.dt = subset(iso.dt, select=c(
  Common.Name,
  ISO.3166.1.2.Letter.Code
))

setnames(iso.dt,"Common.Name","country_name")
setnames(iso.dt,"ISO.3166.1.2.Letter.Code","country")

setkey(iso.dt,country)

getCountryCode = function(row) {
  index = match(row,iso.dt$country)
  
  return (as.character(iso.dt$country_name[index]))
}