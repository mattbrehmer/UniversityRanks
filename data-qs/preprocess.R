require(data.table)

#load files
qs2012 = as.data.table(read.csv(file = "qs12.csv",stringsAsFactors=TRUE))
qs2013 = as.data.table(read.csv(file = "qs13.csv",stringsAsFactors=TRUE))
qs2014 = as.data.table(read.csv(file = "qs14.csv",stringsAsFactors=TRUE))

#throw out unecessary attributes
qs2012 = subset(qs2012, select=-c(age,rank_11))
qs2013 = subset(qs2013, select=-c(age,rank_12))
qs2014 = subset(qs2014, select=-c(rank_13))

qs2012$research = gsub("^$",NA,qs2012$research)
qs2012$research = as.factor(qs2012$research)
qs2013$research = gsub("^$",NA,qs2013$research)
qs2013$research = as.factor(qs2013$research)
qs2014$research = gsub("^$",NA,qs2014$research)
qs2014$research = as.factor(qs2014$research)

#set institution metadata as multi-attribute key for each table
setkey(qs2012,institution,country,size,focus,research,status)
setkey(qs2013,institution,country,size,focus,research,status)
setkey(qs2014,institution,country,size,focus,research,status)

#join
qsJoined = qs2012[qs2013[qs2014]]

#subset to attributes of interest
qsJoined = subset(qsJoined, select=c(
  institution,
  country,
  size,
  focus,
  research,
  status,
  age,
  overall_score_14,
  overall_score_13,
  overall_score_12,
  rank_14,
  rank_13,
  rank_12
  ))

qsJoined$rank_14 = findInterval(qsJoined$rank_14, sort(unique(qsJoined$rank_14)))
qsJoined$rank_13 = findInterval(qsJoined$rank_13, sort(unique(qsJoined$rank_13)))
qsJoined$rank_12  = findInterval(qsJoined$rank_12, sort(unique(qsJoined$rank_12)))

setnames(qsJoined,"overall_score_14","score_2014")
setnames(qsJoined,"overall_score_13","score_2013")
setnames(qsJoined,"overall_score_12","score_2012")

qsJoined = transform(qsJoined, score=apply(qsJoined[,8:10, with = F],1, mean, na.rm = TRUE))
qsJoined = transform(qsJoined, rank=apply(qsJoined[,11:13, with = F],1, mean, na.rm = TRUE))
qsJoined$rank  = findInterval(qsJoined$score, sort(unique(qsJoined$score)))
qsJoined$rank = rank(-qsJoined$rank)
qsJoined$rank  = findInterval(qsJoined$rank, sort(unique(qsJoined$rank)))

qsJoined$score = round(qsJoined$score,1)

qsJoined = qsJoined[order(score,decreasing = T)]

write.csv(qsJoined,file="qsScores.csv",quote=F,row.names=T,na="")