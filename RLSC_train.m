trainFileDir = './train';
trainFiles = sprintf('%s/*.csv', trainFileDir);
modelDir = './model';
% Lookup table of Twitter accounts.
mapFile = sprintf('%s/map.csv', modelDir);
wFile = sprintf('%s/w.csv', modelDir);
colNormFile = sprintf('%s/col_nz_means.csv', modelDir);
featureMeanFile = sprintf('%s/featureMean.csv',modelDir);
featureStdFile = sprintf('%s/featureStd.csv',modelDir);


% 65 accuracy
%lambda=0.001

lambda=10^-9;

trainFileList = dir(trainFiles);
mapFd = fopen(mapFile, 'w');

trainX = sparse(zeros(0,0));
trainY = sparse(zeros(0,0));

% Read all the feature data into a design matrix, keeping track of int->name
% mapping.

sprintf('loading %d files...',size(trainFileList,1))

for i=1:length(trainFileList)
  filename = sprintf('%s/%s', trainFileDir, trainFileList(i).('name'));
  % Read CSV file, skipping header
  M = csvread(filename, 1, 0);
  trainX = [trainX; M];
  trainY = [trainY; ones(size(M, 1), 1) * i];
  
  fprintf(mapFd, '%d,%s\n', i, trainFileList(i).('name'));
end

sprintf('successfully loaded %d tweets. Beginning Normalization Step',size(trainX,1))

fclose(mapFd);

% perform feature mean normalization of columns
% for i=1:size(trainX,2)
%     feature_std(1,i)=std(trainX(:,i));
% end    
% feature_means=mean(trainX);
% for i=1:size(trainX)
%     trainX(i,:)=(trainX(i,:)-feature_means)./feature_std;
% end

% Normalize data columns using mean of non-zero features.
col_non_zero_means = sum(trainX) ./ sum(trainX ~= 0);
% Avoid dividing by zero or NaN in columns that are all zeros.
col_non_zero_means((col_non_zero_means==0) | isnan(col_non_zero_means)) = 1;
trainX = trainX * diag(1 ./ col_non_zero_means);

% Normalize data rows to norm=1.
for i=1:size(trainX,1)
    row_norms(i,1)= sqrt(sum(trainX(i,:).^2, 2));
end

%trainX = diag(1 ./ row_norms) * trainX;
for i=1:size(trainX,1)
    trainX(i,:)=trainX(i,:)./ row_norms(i);
end

disp('Completed normalization. Beginning Y Matrix Generation')

%w=zeros(length(trainFileList),size(trainX,2));
%sigX=sigmoid(trainX);
superY=sparse(size(trainX,1),length(trainFileList));
for i=1:length(trainFileList)
    superY(:,i)=trainY==i;
end

disp('Completed Y Matrix Generation. Beginning Training Step')

% this method does not penalize false positives
%w =((lambda*eye(size(trainX,2),size(trainX,2))+trainX'*trainX))^-1*(trainX'*(superY));   


for i=1:size(superY,2)
    i
    weight = (size(superY,1)-sum(superY(:,i)))/sum(superY(:,i));
    
    constant=sparse(weight*(superY(:,i))+(1-superY(:,i)));
    
    phi=spdiags(constant(:),0,length(constant),length(constant));   
    
%    w(:,i)=((lambda*eye(size(trainX,2),size(trainX,2))+trainX'*trainX))^-1*(trainX'*(superY(:,i)));
    w(:,i)=(trainX'*phi*trainX+2*lambda*eye(size(trainX,2),size(trainX,2)))^-1*(trainX'*phi*superY(:,i));
end
                

dlmwrite(wFile,w);
dlmwrite(colNormFile, full(col_non_zero_means));
% dlmwrite(featureMeanFile, full(feature_means));
% dlmwrite(featureStdFile, full(feature_std));


