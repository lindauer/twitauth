#!/usr/bin/Rscript

# You may need to run setwd() first.

library("plyr")
library("ggplot2")

# Read the results csv. Each line gives the name of the test and the
# rank of the first true positive.
results <- read.csv("nn_results.csv", header=F, col.names=c('rank', 'name'))

# The ecdf() function returns a function, which we then evaluate at
# every unique point of r. Then summarize returns a new dataframe with
# columns r and ecdf.
cdf <- summarize(results, r=unique(results$rank), ecdf=ecdf(results$rank)(unique(results$rank)))

# Larger fonts!
#theme_set(theme_gray(base_size = 16))

xlab <- scale_x_continuous("K")
ylab <- scale_y_continuous("Fraction of tests with TP in top K")
gg <- ggplot(data=cdf, aes(x=r, y=ecdf)) + geom_step() + xlab + ylab

# Add vertical threshold lines
thresholds <- data.frame(Threshold=c("5%", "20%"), vals=c(0.05, 0.2) * 844)
# Explicitly order the levels to force correct plot legend ordering.
thresholds$Threshold = factor(thresholds$Threshold, levels=c("5%", "20%"))

gg <- gg + geom_vline(data=thresholds, aes(xintercept=vals, color=Threshold), show_guide=T, linetype="dashed")

# Uncomment this line and dev.off() to output to pdf in a non-IDE environment.
#pdf('nn_cdf.pdf')
gg
#dev.off()
