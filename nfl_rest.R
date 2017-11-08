#import data set 
nfl_pbp1 <- read.csv("/Users/jmc/Downloads/driveinfo1.txt",sep=";")
rf<-as.data.frame(nfl_pbp2) #convert to dataframe 
colnames(rf) <- c("start","end","x") #name columns 
rf1<-substring(rf$start,13) #remove part of the 'start' column 
rf2<-as.data.frame(rf1) 
colnames(rf2)<-c("start") 

#get team names 
rf_team <- substr(rf$start,start=1,stop=4)
rf_team1<-as.data.frame(rf_team)
colnames(rf_team1)<-c("team")

#extract quarter names
rf3<-substr(rf2$start, start = 1, stop = 3) 
#extract time 
rf4<-substring(rf2$start,5)
#combine start & quarter
final_start<-cbind(rf3,rf4)
final_start1<-as.data.frame(final_start)
colnames(final_start1)<-c("quarter_start","start")

#end of quarter (column wrangling)
rf5<-substring(rf$end,7)
rfX<-as.data.frame(rf5)
colnames(rfX)<-c("end")
rf6<-as.data.frame(rf5)
colnames(rf6)<-c("end")
#extract the quarter names 
rf7<-substr(rf6$end,start=1,stop=3)
rf8<-as.data.frame(rf7)
colnames(rf8)<-c("end")
#split the time and the result
rf9<-substring(rfX$end,3) 
rf10<-as.data.frame(rf9)
colnames(rf10)<-c("end")
rf11<-gsub("\\)", " -", rf10$end) #replace - for )
rf12<-as.data.frame(rf11)
colnames(rf12)<-c("end")
rf13<-str_split(rf12$end,pattern="-",simplify=TRUE)
rf14<-as.data.frame(rf13)
colnames(rf14)<-as.data.frame("end","result")

# column bind data frames 
combine_full<-cbind(final_start1,rf14)
combine_full1<-cbind(nfl_pbp1,combine_full)

colnames(combine_full1)[9] <- "end"
colnames(combine_full1)[10] <- "Result"

#assign play by play id (for each drive)
combine_full1$game_id <- seq.int(nrow(combine_full1))

#convert minutes to seconds 
combine_full1$start<-lubridate::period_to_seconds(ms(combine_full1$start)) 
combine_full1$end<-lubridate::period_to_seconds(ms(combine_full1$end)) 

# assign time (in seconds) for each quarter 
#data wrangling 
#quarter one 
q1<-combine_full1[grep("Q1",combine_full1$quarter_start),] 
q1$adj_start<-900-q1$start
q1$adj_end<-900-q1$end
q11<-q1[grep("Q2",q1$end),]
q11$adj_end<-900+q11$adj_end
merge_q1<-rbind(q1,q11)
merge_q1$abs_diff<-merge_q1$adj_end-merge_q1$adj_start
merge_q1_final<-subset(merge_q1, merge_q1$abs_diff>0)

#quarter two 
q2<-combine_full1[grep("Q2",combine_full1$quarter_start),]
q2$adj_end<-1800-q2$end
q2$abs_diff<-q2$adj_end-q2$adj_start
q2_final<-subset(q2, merge_q1$abs_diff>0)

#row bind 'quarter one' and 'quarter two' dataframes 
q1_q2<-rbind(merge_q1_final,q2_final)

#quarter three
q3<-combine_full1[grep("Q3",combine_full1$quarter_start),] 
q3$adj_start<-2700-q3$start
q3$adj_end<-2700-q3$end
q33<-q3[grep("Q4",q3$quarter_end),]
q33$adj_end<-2700-q33$adj_end
merge_q3<-rbind(q3,q33)
merge_q3$abs_diff<-merge_q3$adj_end-merge_q3$adj_start
merge_q3_final<-subset(merge_q3, merge_q3$abs_diff>0)

#quarter four 
q4<-combine_full1[grep("Q4",combine_full1$quarter_start),] #subtract 900 from start and end? #add 900 to Q2 adj scores?
q4$adj_start<-3600-q4$start
q4$adj_end<-3600-q4$end
q4$abs_diff<-q4$adj_end-q4$adj_start
q4_final<-subset(q4, q4$abs_diff>0)

#row bind row 'quarter three' and 'quarter four' 
q3_q4<-rbind(merge_q3_final,q4_final)

#combine each quarter into a single dataframe 
final_pbp_all<-rbind(q1_q2,q3_q4)
write.csv(final_pbp_all,file="nfl_rest.csv") #save as dataframe nef_rest.csv 

#account if offense is home or not 
home_off<-startsWith(as.character(nfl_rest$Drives),as.character(nfl_rest$HomeTeam))
#merge nfl_rest and home_off dataframes 
nfl_final<-cbind(nfl_rest,home_off) 
#assign a binary 0,1 variable (home field)
nfl_final$is_home_off<-ifelse(nfl_final$home_off=="TRUE",1,0)
#convert the variable 'is_home' from numeric to a factor
nfl_final$is_home_off<-as.factor(nfl_final$is_home_off)
nfl_final$score<-as.factor(nfl_final$score)

#drives with home team on offense
home_off<-subset(nfl_final,is_home=="1")
home_off1<- subset(home_off, select = -c(Home.rating.def,Away.rating.off)) #drop home defense and away offense ratings 
#rename columns
names(home_off1)[5] <- "off_rating"
names(home_off1)[6] <- "def_rating"

#drives with away team on offense
away_off<-subset(nfl_final,is_home=="0")
away_off1<- subset(away_off, select = -c(Home.rating.off,Away.rating.def)) #drop home offense and away defense ratings 
#rename columns
names(away_off1)[5]<- "def_rating"
names(away_off1)[6]<- "off_rating"

#switch column placement  
away_off2<-away_off1[, c(1,2,3,4,6,5,7,8,9,10,11,12,13,14,15,16,17,18,19,
                         20,21)]
#rbind the 'home_off1' and 'away_off2' dataframes 
nfl_finals_pbp<-rbind(home_off1,away_off2)
write.csv(nfl_finals_pbp,file="nfl_finals_pbp.csv")

#function that checks if a tocuhdown was scored by offense or defense (i.e. interception)
myfunc <- function(x){
  return(strsplit(as.character(x)," ")[[1]][1])
}
drives = nfl_finals_pbp$Drives
teamdriving = apply(as.matrix(drives),1,FUN=myfunc)
nfl_finals_pbp$teamdriving = teamdriving

teams1 = teamdriving[1:length(teamdriving)-1]
teams2 = teamdriving[2:length(teamdriving)]
ind = which(teams2==teams1)
nfl_finals_pbp$defenseScore <- rep(0,dim(nfl_finals_pbp)[1])
nfl_finals_pbp[ind,]$defenseScore=1
ind <- which(nfl_finals_pbp$defenseScore == 1 & !grepl("Interception",as.character(nfl_finals_pbp$Drives)))  # these are not necessarily defensive scores but maybe punt returns for touchdown, safeties etc. 
nfl_finals_pbp[ind,]$defenseScore = 0
ind <- which(nfl_finals_pbp$defenseScore == 1)

for (i in 1:length(ind)){
  if (grepl("End of",as.character(nfl_finals_pbp[ind[i]-1,]$Drives))){
    nfl_finals_pbp[ind[i],]$defenseScore=0
  }
}

write.csv(nfl_finals_pbp,file="nfl_model.csv") #save as 'nfl_model.csv' 

#upload the final dataframe
nfl_model<- read.csv(file.choose(),header=TRUE)

#convert variable types
nfl_model$score<-as.factor(nfl_model$score)
nfl_model$is_home<-as.factor(nfl_model$is_home)

# train and test datasets (for model building) 
smp_size<-floor(0.75*nrow(nfl_model))
set.seed(123)
train_ind<- sample(seq_len(nrow(nfl_model)),size=smp_size)
train<-nfl_final[nfl_model,]
test<-nfl_final[-nfl_model,]

#1.multilevel logistic regression model
model_logit<-glm(score~off_rating+def_rating+def_rest+adj_start+is_home,
                 family=binomial(link="logit"),data=train)
summary(model_logit)
test$classify_score_outcome<-predict(model_logit,test)

#2. 
#classify score (0,1)-field goal, touchdown
nfl_model$score_binary<-ifelse(nfl_model$score==3 | nfl_model$score==6,1,0)
nfl_model$score_binary<-as.factor(nfl_model$score_binary)

# logistic regression model
model_logit1<-glm(score_binary~off_rating+def_rating+def_rest+adj_start+is_home,
                  family=binomial,data=train)
summary(model_logit1)

#check the model (accuracy scores)
fitted.results <- predict(model_logit1,test,type='response')
fitted.results <- ifelse(fitted.results > 0.5,1,0)
misClasificError <- mean(fitted.results != test$score_binary)
print(paste('Accuracy',1-misClasificError))
# Anova
anova(model_logit1,test="Chisq")
#model fit
library(pscl)
pR2(model_logit1)
#ROC and AUC
library(ROCR)
p <- predict(model_logit1, newdata=test, type="response")
pr <- prediction(p, test$score_binary)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)

auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]
auc

# count predicted scores for each nfl team (2009-2016)
count_scores<-nfl_model %>% 
  group_by(teamdriving,score_classify_binary) %>%
  summarise(n=n())
library(reshape)
count_scores1<-cast(count_scores,teamdriving~score_classify_binary)
#predicted percentage of drives that ended in a touchdown or field goal (for each nfl team)
count_scores1$percent_score_model<-count_scores1$`1`/(count_scores1$`0`+count_scores1$`1`)

#count offensive scores for each nfl team (2009-2016)*************
team_score_count<-count(nfl_model, 'score_binary','teamdriving')
#by team (percentage of time a team is expected to score?)
count<-nfl_model %>% 
  group_by(teamdriving,score_binary) %>%
  summarise(n=n())
#percentage of drives that ended in a touchdown or field goal (for each nfl team)
count1<-cast(count,teamdriving~score_binary)
count1$percent_score<-count1$`1`/(count1$`0`+count1$`1`)

#merge the actual and predicted score count (for each team) into a single dataframe 
team_score_final<-merge(count1,count_scores1,by="teamdriving")
team_score_final1<-subset(team_score_final,select=c(1,4,7))
#Difference between actual percentage of scoring drives and predicted percentage of scoring drives 
team_score_final1$diff<-team_score_final1$percent_score-team_score_final1$percent_score_model



