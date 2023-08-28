library(rjson)

json1 <- fromJSON(file = 'journal1.json')
json2 <- fromJSON(file = 'journal2.json')

jsonComplete <- c(json1, json2)

jsonComplete <- jsonComplete[order(names(jsonComplete))]  
jsondata <- toJSON(jsonComplete)
write(jsondata, 'journal.json')
