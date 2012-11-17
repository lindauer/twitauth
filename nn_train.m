trainFileDir = './train';
trainFiles = sprintf('%s/*.csv', trainFileDir);
modelDir = './model';
% Lookup table of centroid ID to Twitter account.
mapFile = sprintf('%s/map.csv', modelDir);
centroidsFile = sprintf('%s/centroids.csv', modelDir);
colNormFile = sprintf('%s/col_nz_means.csv', modelDir);

trainFileList = dir(trainFiles);
mapFd = fopen(mapFile, 'w');

trainX = zeros(0,0);
trainY = zeros(0,0);

% Read all the feature data into a design matrix, keeping track of int->name
% mapping.
%
% NOTE: If this is slow, we can move this to a preprocessing step.
for i=1:length(trainFileList)
  filename = sprintf('%s/%s', trainFileDir, trainFileList(i).('name'));
  % Read CSV file, skipping header
  M = csvread(filename, 1, 0);
  trainX = [trainX; M];
  trainY = [trainY; ones(size(M, 1), 1) * i];
  
  fprintf(mapFd, '%d,%s\n', i, trainFileList(i).('name'));
end

fclose(mapFd);

% Normalize data columns using mean of non-zero features.
col_non_zero_means = sum(trainX) ./ sum(trainX ~= 0);
% Avoid dividing by zero or NaN in columns that are all zeros.
col_non_zero_means((col_non_zero_means==0) | isnan(col_non_zero_means)) = 1;
trainX = trainX * diag(1 ./ col_non_zero_means);

% Normalize data rows to norm=1.
row_norms = sqrt(sum(trainX.^2, 2));
trainX = diag(1 ./ row_norms) * trainX;

% Compute the centroid of each training class.
for i=1:length(trainFileList)
  if i==1
    centroids = zeros(length(trainFileList), size(M, 2));
  end
  
  centroids(i,:) = mean(trainX(trainY==i,:));
end

dlmwrite(colNormFile, col_non_zero_means);
dlmwrite(centroidsFile, centroids);