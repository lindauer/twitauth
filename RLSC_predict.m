function [ ranking, distances ] = RLSC_predict( varargin )
% RLSC_predict predicts the class for a test Twitter feed.
% The return value is a  matrix where the
% first column is the numeric identifier for a class
% (Twitter author) and the second column is a number in
% [0,1] where a larger number indicuates higher confidence
% that the feed comes from this author.
%
% 3 uses:
% nn_predict(filename)
% nn_predict(filename,sample_size)
% nn_predict(filename,sample_size,page)
%
% where filename is the name of a features extracted csv file
% sample_size is the number of tweets to take from that file (sequential)
% page allows you to select which x

modelDir = './model';
% Lookup table of centroid ID to Twitter account.
wFile = sprintf('%s/w.csv', modelDir);

% centroids contains a row for each centroid and a column for each feature.
w = dlmread(wFile);

% Read example tweets.
testX = csvread(varargin{1}, 1, 0);

% Use args in to trim sample size and page
if(length(varargin)==2)
    testX = testX(1:varargin{2},:);
end
if(length(varargin)==3)
    testX = testX(varargin{2}*(varargin{3}-1)+1:varargin{2}*(varargin{3}),:);
end
m = size(testX, 1);

% Produce a ranking for each example tweet.
for i=1:m
  distances(i,:) = w'*testX(i,:)';
end

% Aggregate and normalize rankings.
agg_score = (sum(distances,1))';
[score, centroid_number] = sort(agg_score, 'descend');
score = 1 - (score ./ sum(score));
ranking = [centroid_number score];



%  
% score_twt = zeros(size(distance));
% centroid_number_twt(i,:) = zeros(size(distance));
% 
% for i=1:size(distances,1)
%     [score_twt(i,:), centroid_number_twt(i,:)] = sort(distances(i,:),'ascend');
%     score_twt(i,:)=(score_twt(i,:)) ./ sum(score_twt(i,:));
% end
% 
% tweet_ranking = [centroid_number_twt score-twt];

