% Computes quantile probability for each feature in each class, then
% computes mutual information for each feature.

trainFileDir='./train-full';
quantilesFile = 'quantiles.csv';

Q = dlmread(quantilesFile)';

X = sparse(zeros(0,0));
Y = sparse(zeros(0,0));

trainFiles = sprintf('%s/*.csv', trainFileDir);
nclass = length(trainFileList);
for i=1:nclass
  filename = sprintf('%s/%s', trainFileDir, trainFileList(i).('name'));
  % Read CSV file, skipping header
  M = csvread(filename, 1, 0);
  X = [X; sparse(M)];
  Y = [Y; sparse(ones(size(M, 1), 1) * i)];
end

m = size(X, 1);
nfeat = size(X, 2);

% Convert values in X to their quantile numbers.
qX = X;
for f=1:nfeat
  for q=1:size(Q,1);
    if (q==1)
      select = (X(:,f)==0);
    else
      select = ((X(:,f) > Q(q-1,f)) & (X(:,f) <= Q(q,f)));
    end
    qX(select,f) = q;
  end
end
X = qX;
clear qX;

gain = zeros(nfeat, 2);

class_entropy = sentropy(Y);
for f=1:nfeat
  feature_entropy = sentropy(X(:,f));
  % Need to combine class column and feature column to find joint entropy.
  joint_entropy = sentropy(Y * 1e6 + X(:,f));
  
  gain(f,:) = [f (class_entropy + feature_entropy - joint_entropy)];
end

dlmwrite('gain.csv', gain);
