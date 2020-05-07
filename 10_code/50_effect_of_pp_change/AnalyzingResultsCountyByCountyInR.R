dat <- read_csv("~/Documents/GitHub/nc_electioneering/20_intermediate_files/60_voter_panel_10pctsample_long_w_analysisvars_small_forR.csv")


# Percentage in County Impacted by Change
pct.black.pp.12 <- tapply(dat$pp_has_changed[dat$black==1 & dat$year==2012],dat$county_fips[dat$black==1 & dat$year==2012],mean,na.rm=TRUE)
pct.white.pp.12 <- tapply(dat$pp_has_changed[dat$black==0 & dat$year==2012],dat$county_fips[dat$black==0 & dat$year==2012],mean,na.rm=TRUE)
pct.black.pp.16 <- tapply(dat$pp_has_changed[dat$black==1 & dat$year==2016],dat$county_fips[dat$black==1 & dat$year==2016],mean,na.rm=TRUE)
pct.white.pp.16 <- tapply(dat$pp_has_changed[dat$black==0 & dat$year==2016],dat$county_fips[dat$black==0 & dat$year==2016],mean,na.rm=TRUE)

pct.black.pre.12 <- tapply(dat$precinct_changed[dat$black==1 & dat$year==2012],dat$county_fips[dat$black==1 & dat$year==2012],mean,na.rm=TRUE)
pct.white.pre.12 <- tapply(dat$precinct_changed[dat$black==0 & dat$year==2012],dat$county_fips[dat$black==0 & dat$year==2012],mean,na.rm=TRUE)
pct.black.pre.16 <- tapply(dat$precinct_changed[dat$black==1 & dat$year==2016],dat$county_fips[dat$black==1 & dat$year==2016],mean,na.rm=TRUE)
pct.white.pre.16 <- tapply(dat$precinct_changed[dat$black==0 & dat$year==2016],dat$county_fips[dat$black==0 & dat$year==2016],mean,na.rm=TRUE)

# County Level Aggregations
pct.dem <- tapply(as.logical(dat$party=="DEMOCRATIC"),dat$county_fips,mean,na.rm=TRUE)
pct.rep <- tapply(as.logical(dat$party=="REPUBLICAN"),dat$county_fips,mean,na.rm=TRUE)
n.resp <- tapply(as.logical(!is.na(dat$party)),dat$county_fips,sum,na.rm=TRUE)

# Predicting Impact on Black Voters -- more affected by precinct changes than whites
summary(lm(pct.black.pp.12~pct.white.pp.12 + pct.dem + n.resp))
summary(lm(pct.black.pp.16~pct.white.pp.16 + pct.dem + n.resp))
summary(lm(pct.black.pre.12~pct.white.pre.12 + pct.dem + n.resp))
summary(lm(pct.black.pre.16~pct.white.pre.16 + pct.dem + n.resp))


par(mfrow=c(2,2))
plot(pct.black.pp.12,pct.white.pp.12,main="% Affected by Polling Place Change 2012",xlab="Black",ylab="White",pch=18,xlim=c(0,1),ylim=c(0,1))
abline(0,1)
plot(pct.black.pp.16,pct.white.pp.16,main="% Affected by Polling Place Change 2016",xlab="Black",ylab="White",pch=18,xlim=c(0,1),ylim=c(0,1))
abline(0,1)

plot(pct.black.pre.12,pct.white.pre.12,main="% Affected by Precinct Change 2012",xlab="Black",ylab="White",pch=18,xlim=c(0,1),ylim=c(0,1))
abline(0,1)

plot(pct.black.pre.16,pct.white.pre.16,main="% Affected by Precinct Change 2016",xlab="Black",ylab="White",pch=18,xlim=c(0,1),ylim=c(0,1))
#text(pct.black.pre.16,pct.white.pre.16,countyfips)
abline(0,1)

#
# County Level Regressions
# Loop over counties, doing regression for each...
#


# Define county index
countyfips<- unique(dat$county_fips)

# Create Placeholders
regcoef<-matrix(NA,ncol=11,nrow=length(countyfips))
ppchangecoef12<-rep(NA,times=length(countyfips))
ppblkchangecoef12<-rep(NA,times=length(countyfips))
prechangecoef12<-rep(NA,times=length(countyfips))
preblkchangecoef12<-rep(NA,times=length(countyfips))
ppchangecoef16<-rep(NA,times=length(countyfips))
ppblkchangecoef16<-rep(NA,times=length(countyfips))
prechangecoef16<-rep(NA,times=length(countyfips))
preblkchangecoef16<-rep(NA,times=length(countyfips))

ppchangecoef12se<-rep(NA,times=length(countyfips))
ppblkchangecoef12se<-rep(NA,times=length(countyfips))
prechangecoef12se<-rep(NA,times=length(countyfips))
preblkchangecoef12se<-rep(NA,times=length(countyfips))
ppchangecoef16se<-rep(NA,times=length(countyfips))
ppblkchangecoef16se<-rep(NA,times=length(countyfips))
prechangecoef16se<-rep(NA,times=length(countyfips))
preblkchangecoef16se<-rep(NA,times=length(countyfips))


# Now do the regression -- conditioning on past election day voter

# Race interactions
# Screwed up indexing for SE
# for(i in 1:length(countyfips)){
  smalldat<-dat[dat$county_fips==countyfips[i],]
  smallreg12<-lm(voted_elecday ~ pp_has_changed + blackppchange + precinct_changed + blackprechange + black + age + age2 + as.factor(party), data=smalldat[smalldat$lagelec==1 & smalldat$year==2012,])
  ppchangecoef12se[i]<-coef(summary(smallreg12))[2, 2]
  ppblkchangecoef12se[i]<-coef(summary(smallreg12))[3, 2]
  prechangecoef12se[i]<-coef(summary(smallreg12))[4, 2]
  preblkchangecoef12se[i]<-coef(summary(smallreg12))[5, 2]
  ppchangecoef12[i]<-coef(smallreg12)[2]
  ppblkchangecoef12[i]<-coef(smallreg12)[3]
  prechangecoef12[i]<-coef(smallreg12)[4]
  preblkchangecoef12[i]<-coef(smallreg12)[5]

  smallreg16<-lm(voted_elecday ~ pp_has_changed + blackppchange + precinct_changed + blackprechange + black + age + age2 + as.factor(party), data=smalldat[smalldat$lagelec==1 & smalldat$year==2016,])
  ppchangecoef16[i]<-coef(smallreg16)[2]
  ppblkchangecoef16[i]<-coef(smallreg16)[3]
  prechangecoef16[i]<-coef(smallreg16)[4]
  preblkchangecoef16[i]<-coef(smallreg16)[5]
  ppchangecoef16se[i]<-coef(summary(smallreg16))[2, 2]
  ppblkchangecoef16se[i]<-coef(summary(smallreg16))[3, 2]
  prechangecoef16se[i]<-coef(summary(smallreg16))[4, 2]
  preblkchangecoef16se[i]<-coef(summary(smallreg16))[5, 2]
}

# Only main effects
for(i in 1:length(countyfips)){
  smalldat<-dat[dat$county_fips==countyfips[i],]
  smallreg12<-lm(voted_elecday ~ pp_has_changed + precinct_changed + black + age + age2 + as.factor(party), data=smalldat[smalldat$lagelec==1 & smalldat$year==2012,])
  ppchangecoef12[i]<-coef(smallreg12)[2]
  ppchangecoef12se[i]<-coef(summary(smallreg12))[2, 2]
  prechangecoef12[i]<-coef(smallreg12)[3]
  prechangecoef12se[i]<-coef(summary(smallreg12))[3, 2]

  smallreg16<-lm(voted_elecday ~ pp_has_changed + precinct_changed + black + age + age2 + as.factor(party), data=smalldat[smalldat$lagelec==1 & smalldat$year==2016,])
  ppchangecoef16[i]<-coef(smallreg16)[2]
  ppchangecoef16se[i]<-coef(summary(smallreg16))[2, 2]
  prechangecoef16[i]<-coef(smallreg16)[3]
  prechangecoef16se[i]<-coef(summary(smallreg16))[3, 2]
}


# Compute T-Stats

stat.sig.pp.12 <-  ppchangecoef12/ppchangecoef12se
stat.sig.pp.16 <-  ppchangecoef16/ppchangecoef16se
stat.sig.pre.12 <-  prechangecoef12/prechangecoef12se
stat.sig.pre.16 <-  prechangecoef16/prechangecoef16se

plot(stat.sig.pp.12,stat.sig.pp.16)
abline(v=2)
abline(v=-2)
abline(h=2)
abline(h=-2)

# Plot Marginal Impact of Changes

plot(ppchangecoef12,ppchangecoef16,type="n",main="Marginal Impact of Polling Place Change",xlab="2012",ylab="2016",xlim=c(-.5,.5),ylim=c(-.5,.5))
text(ppchangecoef12,ppchangecoef16,countyfips,cex=.75)
abline(h=0)
abline(v=0)
points(ppchangecoef12[abs(stat.sig.pp.12)>=2],ppchangecoef16[abs(stat.sig.pp.12)>=2],pch=8,col="BLUE")
points(ppchangecoef12[abs(stat.sig.pp.16)>=2],ppchangecoef16[abs(stat.sig.pp.16)>=2],pch=18,col="RED")

# Plot Marginal Impact of Changes

plot(prechangecoef12,prechangecoef16,type="n",main="Marginal Impact of Precinct Change",xlab="2012",ylab="2016")
text(prechangecoef12,prechangecoef16,countyfips,cex=.75)
abline(h=0)
abline(v=0)
points(prechangecoef12[abs(stat.sig.pre.12)>=2],prechangecoef16[abs(stat.sig.pre.12)>=2],pch=8,col="BLUE")
points(prechangecoef12[abs(stat.sig.pre.16)>=2],prechangecoef16[abs(stat.sig.pre.16)>=2],pch=18,col="RED")

#   Net Impact of Change = Marginal Impact of change * Number affected by change in county
#   Estimated Impact on Vote in county

(100*pct.black.pp.12)*ppchangecoef12
(100*pct.black.pp.16)*ppchangecoef16

(100*pct.black.pp.12[abs(stat.sig.pp.12)>=2])*ppchangecoef12[abs(stat.sig.pp.12)>=2]
(100*pct.black.pp.16[abs(stat.sig.pp.16)>=2])*ppchangecoef16[abs(stat.sig.pp.16)>=2]

(100*pct.white.pp.12[abs(stat.sig.pp.12)>=2])*ppchangecoef12[abs(stat.sig.pp.12)>=2]
(100*pct.white.pp.16[abs(stat.sig.pp.16)>=2])*ppchangecoef16[abs(stat.sig.pp.16)>=2]

(100*pct.black.pre.12[abs(stat.sig.pre.12)>=2])*prechangecoef12[abs(stat.sig.pre.12)>=2]
(100*pct.black.pre.16[abs(stat.sig.pre.16)>=2])*prechangecoef16[abs(stat.sig.pre.16)>=2]


# Overall impact -- need to weight by number impacted

sum(n.resp[abs(stat.sig.pp.12)>=2]*pct.black.pp.12[abs(stat.sig.pp.12)>=2]*ppchangecoef12[abs(stat.sig.pp.12)>=2],na.rm=TRUE)/sum(n.resp)
sum(n.resp[abs(stat.sig.pp.16)>=2]*pct.black.pp.16[abs(stat.sig.pp.16)>=2]*ppchangecoef16[abs(stat.sig.pp.16)>=2],na.rm=TRUE)/sum(n.resp)
