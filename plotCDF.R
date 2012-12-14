#!/usr/bin/Rscript

# You may need to run setwd() first.

library("plyr")
library("ggplot2")

# Read the results csv. Each line gives the name of the test and the
# rank of the first true positive.
nn_results <- read.csv("nn_results.csv", header=F, col.names=c('rank', 'name'))
rlsc_results <- read.csv("rlsc_results.csv", header=F, col.names=c('rank', 'name'))

# The ecdf() function returns a function, which we then evaluate at
# every unique point of r. Then summarize returns a new dataframe with
# columns r and ecdf.
nn_cdf <- summarize(nn_results, r=unique(nn_results$rank), ecdf=ecdf(nn_results$rank)(unique(nn_results$rank)))
nn_cdf$Algorithm <- 'NN'
rlsc_cdf <- summarize(rlsc_results, r=unique(rlsc_results$rank), ecdf=ecdf(rlsc_results$rank)(unique(rlsc_results$rank)))
rlsc_cdf$Algorithm <- 'RLSC'
all_cdf <- rbind(nn_cdf, rlsc_cdf)

theme_set(theme_gray(base_size = 16))

gg <- ggplot(data=all_cdf, aes(x=r, y=ecdf, linetype=Algorithm, group=Algorithm)) + geom_line(se=F) + scale_linetype_manual(values=c("solid", "longdash")) + scale_color_manual(values=c("#56B4E9", "#009E73"))

xlab <- scale_x_continuous("K (vertical lines denote 5% and 20% thresholds)")
ylab <- scale_y_continuous("Fraction of tests with TP in top K")
gg <- gg + xlab + ylab

# Add vertical threshold lines
thresholds <- data.frame(Threshold=c("5%", "20%"), vals=c(0.05, 0.2) * 844)
# Explicitly order the levels to force correct plot legend ordering.
thresholds$Threshold = factor(thresholds$Threshold, levels=c("5%", "20%"))

gg <- gg + geom_vline(data=thresholds, aes(xintercept=vals, group=Threshold), show_guide=F, linetype="3313", color=c("#999999", "#E69F00"))

color_palette <- c("#999999", "#E69F00", "#56B4E9", "#009E73")
gg <- gg + scale_color_manual(values=color_palette)

#gg <- gg + guides(linetype=guide_legend(order=1))
#                  color=guide_legend(title="Threshold", order=2))

# Uncomment this line and dev.off() to output to pdf in a non-IDE environment.
#pdf('resultcdf.pdf')
gg
#dev.off()

