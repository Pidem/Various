rm(list=ls(all=TRUE))

setwd("C:/Users/p_mal/Documents/Columbia/Courses/Machine_Learning/HW")

emails<-read.csv("spam.csv")

#We first divide the data into a training (75%) and test set (25%)
set.seed(1)
train=sample(1:nrow(emails),0.75*nrow(emails))
test = -train 

library(e1071)
model<-naiveBayes(spam~.,data=emails[train,],na.action = na.pass)
pred<-predict(model, emails[test,-1])
results<-table(pred, emails[test,]$spam)
(results[2,1]+results[1,2])/length(emails[test,]$spam)

#Average error for 10 samples
error<-vector(mode="numeric")
sample<-as.double(seq(1:10))
set.seed(10)
for(i in 1:10){
  train=sample(1:nrow(emails),0.8*nrow(emails))
  test = -train 
  
  model<-naiveBayes(spam~.,data=emails[train,])
  pred<-predict(model, emails[test,-1])
  results<-table(pred, emails[test,]$spam)
  error[i]=as.double((results[2,1]+results[1,2])/length(emails[test,]$spam))
}
mean(error)

library(ggplot2)
plot(error~sample)
ggplot()+geom_point(aes(x=sample,y=error))+geom_hline(yintercept=mean(error),color="red")+scale_x_continuous(breaks=c(1,2,3,4,5,6,7,8,9,10))


#LOOCV
set.seed (1)
y=rnorm (100)
x=rnorm (100)
y=x-2* x^2+ rnorm (100)
ggplot()+geom_point(aes(x,y))
dat<-data.frame(y,x)

library (boot)
err1=rep(0,5)  
for (i in 1:5){
  glmFit=glm(y~poly(x,i), data=dat)
  err1[i]=cv.glm(dat,glmFit)$delta[1]
}

set.seed (400)
y=rnorm (100)
x=rnorm (100)
y=x-2* x^2+ rnorm (100)
ggplot()+geom_point(aes(x,y))
dat<-data.frame(y,x)

err2=rep(0,5)  
for (i in 1:5){
  glmFit=glm(y~poly(x,i), data=dat)
  err2[i]=cv.glm(dat,glmFit)$delta[1]
}

sample<-as.double(seq(1:5))
ggplot()+geom_line(aes(x=sample,y=err1),colour="red")+geom_line(aes(x=sample,y=err2),colour="blue")+
  scale_colour_manual(values=c("green","yellow"), name="Seed", labels=c("Seed=1", "Seed=400")) +
  ylab("Error")

err<-data.frame(sample,err1,err2)
ggplot(err) + geom_line(aes(x=sample, y=c(err1,err2))) +
  scale_colour_manual(values=c("red","green"))
set.seed(1)
glm.fit=glm(dat$y~dat$x,data=dat)
cv.err=cv.glm(data,glm.fit)
for (i in 1:10) {
  glm.fit=glm(y~x,data=dat)
  cv.err =cv.glm(data,glm.fit)$delta[1]
  cv.error.1[i]=cv.err
  
  glm.fit=glm(y~x+x^2,data=dat)
  cv.err =cv.glm(data,glm.fit)$delta[1]
  cv.error.2[i]=cv.err
  
  glm.fit=glm(y~x+x^2+x^3,data=dat)
  cv.err =cv.glm(data,glm.fit)$delta[1]
  cv.error.3[i]=cv.err
  
  glm.fit=glm(y~x+x^2+x^3+x^4,data=dat)
  cv.err =cv.glm(data,glm.fit,K=10)$delta[1]
  cv.error.4[i]=cv.err
  
}
error<-data.frame(cv.error.1,cv.error.2,cv.error.3,cv.error.4)
a<-mean(error$cv.error.1)
b<-mean(error$cv.error.2)
c<-mean(error$cv.error.3)
d<-mean(error$cv.error.4)

mean(error$cv.error.1)
mean(error$cv.error.2)
mean(error$cv.error.3)
mean(error$cv.error.4)

#Default credit
library(ISLR)

set.seed(1)
glm.fit=glm(default~balance+income,data=Default,family=binomial)
summary(glm.fit)
coef(glm.fit)


glm.probs=predict(glm.fit,type="response")
glm.pred=rep("SAFE",nrow(Default))
glm.pred[glm.probs>.5]="DEFAULT"
table(glm.pred,Default$default) 

#Spitting the data in train and validation
set.seed(1)
train=sample(1:nrow(Default),0.75*nrow(Default))
valid=-train

glm.fit=glm(default~balance+income,data=Default,family=binomial,subset=train)
glm.probs=predict(glm.fit,Default[valid,],type="response")
glm.pred=rep("FAIL",nrow(Default[valid,]))
glm.pred[glm.probs>.5]="SAFE"
results<-table(glm.pred,Default[valid,]$default) 
(results[2,1]+results[1,2])/length(Default[valid,]$default)

#Using three different splits: 
error<-vector(mode="numeric")
sample<-as.double(seq(1:3))
set.seed(3)
for(i in 1:3){
  train=sample(1:nrow(Default),0.75*nrow(Default))
  valid=-train
  
  glm.fit=glm(default~balance+income,data=Default,family=binomial,subset=train)
  glm.probs=predict(glm.fit,Default[valid,],type="response")
  glm.pred=rep("FAIL",nrow(Default[valid,]))
  glm.pred[glm.probs>.5]="SAFE"
  results<-table(glm.pred,Default[valid,]$default) 
  error[i]=(results[2,1]+results[1,2])/length(Default[valid,]$default)
}

ggplot()+geom_point(aes(x=sample,y=error))+geom_hline(yintercept=mean(error),color="red")+scale_x_continuous(breaks=c(1,2,3))


#Using a dummy variable
Default$dummy<-ifelse(Default$student=="Yes",1,0)
table(Default$student)
table(Default$dummy)

error_dummy<-vector(mode="numeric")
sample<-as.double(seq(1:3))
set.seed(3)
for(i in 1:3){
  train=sample(1:nrow(Default),0.75*nrow(Default))
  valid=-train
  
  glm.fit=glm(default~balance+income,data=Default,family=binomial,subset=train)
  glm.probs=predict(glm.fit,Default[valid,],type="response")
  glm.pred=rep("FAIL",nrow(Default[valid,]))
  glm.pred[glm.probs>.5]="SAFE"
  results<-table(glm.pred,Default[valid,]$default) 
  error[i]=(results[2,1]+results[1,2])/length(Default[valid,]$default)
  
  glm.fit=glm(default~balance+income+dummy,data=Default,family=binomial,subset=train)
  glm.probs=predict(glm.fit,Default[valid,],type="response")
  glm.pred=rep("FAIL",nrow(Default[valid,]))
  glm.pred[glm.probs>.5]="SAFE"
  results<-table(glm.pred,Default[valid,]$default) 
  error_dummy[i]=(results[2,1]+results[1,2])/length(Default[valid,]$default)
}

ggplot()+geom_point(aes(x=sample,y=error))+geom_hline(yintercept=mean(error),color="red")+scale_x_continuous(breaks=c(1,2,3))




qplot(emails$isuid, geom="histogram")
qplot(emails$time.of.day, geom="histogram")

library(dplyr)
ggplot(emails,aes(isuid))+geom_bar(aes(fill=spam))
ggplot(emails,aes(id))+geom_bar(aes(fill=spam))
ggplot(emails,aes(day.of.week))+geom_bar(aes(fill=spam),position = "fill")
ggplot(emails,aes(time.of.day))+geom_bar(aes(fill=spam))
ggplot(filter(emails,size.kb<50),aes(size.kb))+geom_histogram(aes(fill=spam),binwidth = 4,position="fill")
ggplot(emails,aes(domain))+geom_bar(aes(fill=spam),position = "fill")
ggplot(emails,aes(local))+geom_bar(aes(fill=spam))
ggplot(emails,aes(digits))+geom_bar(aes(fill=spam), position = "fill")
ggplot(emails,aes(name))+geom_bar(aes(fill=spam), position = "fill")
ggplot(emails,aes(cappct))+geom_histogram(aes(fill=spam),binwidth = 0.10, position = "fill")
ggplot(emails,aes(special))+geom_histogram(aes(fill=spam),binwidth= 10, position = "fill")
ggplot(emails,aes(credit))+geom_bar(aes(fill=spam),position = "fill")
ggplot(emails,aes(sucker))+geom_bar(aes(fill=spam),position="fill")
ggplot(emails,aes(porn))+geom_bar(aes(fill=spam),position="fill")
ggplot(emails,aes(chain))+geom_bar(aes(fill=spam),position="fill")
ggplot(emails,aes(sucker))+geom_bar(aes(fill=spam),position="fill")
ggplot(emails,aes(username))+geom_bar(aes(fill=spam),position="fill")
ggplot(emails,aes(large.text))+geom_bar(aes(fill=spam),position="fill")
ggplot(emails,aes(spampct))+geom_histogram(aes(fill=spam),position="fill")
ggplot(emails,aes(category))+geom_bar(aes(fill=spam),position="fill")

#spampct
summary(emails$spampct)
ggplot(emails, aes(x = factor(0), y = spampct)) + geom_boxplot(width=0.2) + xlab("spampct")
emails$spampctNA=ifelse(is.na(emails$spampct),"NULL VALUE","NOT NULL")
ggplot(emails,aes(time.of.day))+geom_bar(binwidth = 1)+facet_grid(~spampctNA)
ggplot(emails,aes(time.of.day,spampct))+geom_point()+stat_sum(aes(group = 1))

#missing values
set.seed(50)
data2<-rnorm(50, mean = 125, sd = 25)
hist(data2)
ggplot()+geom_histogram(aes(data2),binwidth= 20)+stat_function(fun = dnorm, args = list(mean = 125, sd = 25),colour="red")

rbivariate <- function(m=125, s=25,r=.7, iter=50) {
  z1 <- rnorm(iter)
  z2 <- rnorm(iter)
  x <- sqrt(1-r^2)*s*z1 + r*s*z2 + m
  y <- s*z2 + m
  return(list(x,y))
}

data <- rbivariate(iter=50)
mean(data[[1]])
sd(data[[1]])
mean(data[[2]])
sd(data[[2]])
plot(data[[1]],data[[2]])
cor(data[[1]],data[[2]])

xx<-data[[1]]
yy<-data[[2]]
fit1 = lm(yy~xx)
summary(fit1)
fun.1 <- function(x) 0.69316*x + 40.07077

#MCAR
fit2 = lm(yy[37:50]~xx[37:50])
summary(fit2)
fun.2 <- function(x) 0.9052*x + 9.6232

#MAR
col=vector(mode="numeric")
for(i in 1:50){
  if(xx[i]>140){
    col[length(col)+1]<-i
  }
}
fit3 = lm(yy[col]~xx[col])
summary(fit3)
fun.3 <- function(x) 0.1910*x + 121.4277

#MNAR
col=vector(mode="numeric")
for(i in 1:50){
  if(yy[i]>140){
    col[length(col)+1]<-i
  }
}
fit4 = lm(yy[col]~xx[col])
summary(fit4)
fun.4 <- function(x) 0.06215*x + 144.50812
ggplot(mapping = aes(x = xx,y=yy))+geom_point(aes(xx,yy))+
  stat_function(fun = fun.1,aes(colour = "No missing values"))+
  stat_function(fun = fun.2,aes(colour = "MCAR"))+
  stat_function(fun = fun.3,aes(colour = "MAR"))+
  stat_function(fun = fun.4,aes(colour = "MNAR"))+
  scale_colour_manual("Label", values = c("red", "blue", "green", "orange"))

#Repeating this procedure T=100. 
intercept=vector(mode="numeric")
for(j in 1:100){
  col<-sample(50, 13, replace = FALSE)
  fit5=lm(yy[col]~xx[col])
  intercept[length(intercept)+1]<-summary(fit5)$coefficients[2]
}
mean(intercept)