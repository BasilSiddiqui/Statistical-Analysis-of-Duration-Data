bug_time = scan("C:/Users/basil/OneDrive/Desktop/Base/Studies/Undergraduate/Semester 6/F79MB - Statistical Models B/bug_time.txt")
app_time = scan("C:/Users/basil/OneDrive/Desktop/Base/Studies/Undergraduate/Semester 6/F79MB - Statistical Models B/app_session_duration.txt")

#TASK1A
par(mfrow=c(1,1))

hist(bug_time, #Histogram to visualize distribution shape
     main = "Distribution of Bug Resolution Times",
     xlab = "Resolution Time (Minutes)",
     ylab = "Frequency",
     col = "darkslategray3",
     border = "darkslategray", #Cool color
     breaks = 20)

boxplot(bug_time, #Boxplot with mean highlighted
        main = "Bug Resolution Time Summary",
        horizontal = TRUE,
        xlab = "Minutes",
        col = "aquamarine3",
        border = "aquamarine4",
        pch = 19)

mean_val = mean(bug_time) #Add mean to plot in the box plot to compare with median
points(mean_val, 1, 
       pch = 19,
       col = "indianred4",
       cex = 1.5)

legend("topright", #Adding legend to identify its mean
       legend = c("Mean"), 
       col = c("indianred4"), 
       pch = 19,
       pt.cex = 1.5,
       bty = "n")

summary(bug_time) #Summary including standard deviation and Interquartile range
sd(bug_time)
IQR(bug_time)

#TASK 1Bii
y = log(bug_time)
n = length(y)   #Sample size

#MLE
mhat = mean(y)                      ; mhat
sigma2_mle = sum((y - mhat)^2) / n  ; sigma2_mle
sigma2_sample = var(y)              ; sigma2_sample


#TASK 1C
qqnorm(y, #Q-Q plot to check normality assumption
       main = "Q-Q Plot of Log-Transformed Bug Resolution Times",
       xlab = "Theoretical Normal Quantiles",
       ylab = "Sample Quantiles",
       pch = 19,
       col = "mediumpurple",
       cex = 1.2,
       cex.main = 1.3,
       cex.lab = 1.1,
       cex.axis = 1)

qqline(y, #Add reference line for perfect normality
       col = "mediumpurple4", #Add reference line
       lwd = 2.5,
       lty = 1)

#TASK 1D
#Create 10 equal bins using lognormal quantiles
breaks = qlnorm(seq(0,1,by=1/10), meanlog=mhat, sdlog=sqrt(sigma2_mle)); breaks #Breaks from lognormal quantiles

#Cut data into bins
bug.cut = cut(bug_time, breaks=breaks, right=F)
bug.table = table(bug.cut); bug.table

#Extract observed frequencies
obs.f = numeric(10)
for(i in 1:10) obs.f[i] = bug.table[[i]] ; obs.f

#Expected frequencies
exp.f = numeric(10)
for(i in 1:10) exp.f[i] = length(bug_time)*(1/10) ; exp.f

#Calculate chi-square test statistic
chi_sq = sum((obs.f - exp.f)^2 / exp.f) ; chi_sq

df = 10 - 1 - 2 ; df #Degrees of freedom
p_value = 1 - pchisq(chi_sq, df) ; p_value


###############################################################################
#TASK 2A
hist(app_time, #Histogram of original data
     main = "Distribution of App Session Duration",
     xlab = "Resolution Time (Minutes)",
     ylab = "Frequency",
     col = "darkseagreen3",
     border = "darkseagreen4")

boxplot(app_time, #Boxplot with mean highlighted
        main = "App Session Summary",
        horizontal = TRUE,
        xlab = "Minutes",
        col = "aquamarine3",
        border = "aquamarine4")

mean_val = mean(app_time) #Add mean to boxplot
points(mean_val, 1, 
       pch = 19,          #Solid circle
       col = "indianred4",   #Orange color
       cex = 1.5)     

legend("topright",#Legend for mean
       legend = c("Mean"), 
       col = c("indianred4"), 
       pch = 19,
       pt.cex = 1.5,
       bty = "n")

#Numerical Summaries
summary(app_time)
sd(app_time)
IQR(app_time)

#TASK2B
B = 100000
n2 = length(app_time)

boot.med = numeric(B)

for(i in 1:B){ #Bootstrap for Median
  samp = sample(app_time, n2, replace=TRUE) #Resample with replacement
  boot.med[i] = median(samp)   #Store median of resample
}


hist(boot.med, #Histogram of bootstrap distribution
     main = "Bootstrap Distribution of Median",
     xlab = "Median (Minutes)",
     ylab = "Frequency",
     col = "khaki2",
     border = "khaki4",
     breaks = 25)

#Calculate and display 95% CI
ci = quantile(boot.med, c(0.025, 0.975))
abline(v = ci, col = "khaki4", lty = 2)

#Add CI lines to histogram
legend("topright",
       legend = "95% CI",
       col = "khaki4",
       lty = 2)

#Summary statistics of bootstrap distribution 
summary(boot.med)
sd(boot.med)
IQR(boot.med)
quantile(boot.med, c(0.025,0.975))

#Perform KS test for normality (even though its not part of our syllabus I still wanted to confirm)
ks_result = ks.test(boot.med, "pnorm", 
                     mean = mean(boot.med), 
                     sd = sd(boot.med))

#Display results
print(ks_result) #Making sure if its normal because the graph was not sufficient enough

#TASK 2C
log_app = log(app_time) #Log-transform the data

mhat2 = median(log_app); mhat2

#Density at mhat2
f_mhat = dnorm(mhat2, mean = mean(log_app), sd = sd(log_app)); f_mhat

#Standard error of median
se_mhat = 1 / (2 * f_mhat * sqrt(n2)); se_mhat

#95% CI for log-median
lower_mu = mhat2 - 1.96*(sd(log_app)/sqrt(n2)); lower_mu
upper_mu = mhat2 + 1.96*(sd(log_app)/sqrt(n2)); upper_mu

lower_median = exp(lower_mu); lower_median #Transform to median scale
upper_median = exp(upper_mu); upper_median

#TASK 2D
boot.iqr = numeric(B)

for(i in 1:B){ #Bootstrap for IQR
  samp = sample(app_time, n2, replace=TRUE) 
  boot.iqr[i] = IQR(samp)
}

quantile(boot.iqr, c(0.025,0.975))

#TASK 2E
mu0 = log(15)
sigma0 = sd(log_app)

boot.param.med = numeric(B)

for(i in 1:B){ #Bootstap for median (another one)
  sim = rlnorm(n2, meanlog=mu0, sdlog=sigma0)
  boot.param.med[i] = median(sim)
}

obs.med = median(app_time)

p_value = mean(boot.param.med >= obs.med); p_value