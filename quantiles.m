% Computes nquantiles quantiles for each feature to support
% discretized computation of mutual information. Zero always
% gets its own quantile and the rest of the data is divided
% into 19 buckets of approximately equal size.

nquantiles = 19;
trainFileDir='./train-full';
quantilesFile = 'quantiles.csv';

X = sparse(zeros(0,0));
Y = sparse(zeros(0,0));

trainFiles = sprintf('%s/*.csv', trainFileDir);
for i=1:length(trainFileList)
  filename = sprintf('%s/%s', trainFileDir, trainFileList(i).('name'));
  % Read CSV file, skipping header
  M = csvread(filename, 1, 0);
  X = [X; sparse(M)];
  Y = [Y; sparse(ones(size(M, 1), 1) * i)];
end

qs = (1:nquantiles)' * (1/nquantiles);

n = size(X, 2);

% First quantile is always zero.
Q = zeros(nquantiles + 1, n);

for i=1:n
  nzX = X(X(:,i)~=0);
  if (size(nzX,1) > 0)
    Q(:,i) = [0; quantile(nzX,qs)];
  end
end

% Write matrix transpose, so each feature is a row.
dlmwrite(quantilesFile, Q');
