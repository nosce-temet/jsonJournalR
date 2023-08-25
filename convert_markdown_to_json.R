library(stringr)

stringdata <- paste(readLines('testing.md'), collapse = '')
stringdata <- unlist(str_extract_all(stringdata, '[0-9]{4}-[0-9]{2}-[0-9]{2}.*?(#|$)'))

dates <- unlist(str_extract_all(stringdata, '[0-9]{4}-[0-9]{2}-[0-9]{2}'))

entries <- str_extract(stringdata, '[0-9]{4}-[0-9]{2}-[0-9]{2}(.*?)(#|$)', group = 1) 
  
listdata <- setNames(as.list(entries), dates)  
listdata <- listdata[order(names(listdata))]  

library(rjson)
jsondata <- toJSON(listdata)
write(jsondata, 'jsondata.json')
