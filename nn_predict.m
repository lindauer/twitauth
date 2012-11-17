function [ ranking ] = nn_predict( infile )
% nn_predict predicts the class for a test Twitter feed.
% The return value is a ncentroids x 2 matrix where the
% first column is the numeric identifier for a class
% (Twitter author) and the second column is a number in
% [0,1] where a larger number indicuates higher confidence
% that the feed comes from this author.

modelDir = './model';
% Lookup table of centroid ID to Twitter account.
centroidsFile = sprintf('%s/centroids.csv', modelDir);
colNormFile = sprintf('%s/col_nz_means.csv', modelDir);

% centroids contains a row for each centroid and a column for each feature.
centroids = dlmread(centroidsFile);
ncentroids = size(centroids, 1);
col_non_zero_means = dlmread(colNormFile);

% Read example tweets.
testX = csvread(infile, 1, 0);
m = size(testX, 1);

% Normalize example tweets by column.
testX = testX * diag(1 ./ col_non_zero_means);

% Normalize example tweets by row.
row_norms = sqrt(sum(testX.^2, 2));
testX = diag(1 ./ row_norms) * testX;

distances = zeros(m, ncentroids);

% Produce a ranking for each example tweet.
for i=1:m
  distances(i,:) = (sqrt(sum(bsxfun(@minus, testX(i,:), centroids).^2, 2)))';
end

% Aggregate and normalize rankings.
agg_score = (sum(distances))';
[score, centroid_number] = sort(agg_score, 'ascend');
score = 1 - (score ./ sum(score));
ranking = [centroid_number score];

end

