trainFileDir = './train';
trainFiles = sprintf('%s/*.csv', trainFileDir);
modelDir = './model';
% Lookup table of Twitter accounts.
mapFile = sprintf('%s/map.csv', modelDir);
wFile = sprintf('%s/w.csv', modelDir);
% 65 accuracy
%lambda=0.001

lambda=2;

trainFileList = dir(trainFiles);
mapFd = fopen(mapFile, 'w');

trainX = sparse(zeros(0,0));
trainY = sparse(zeros(0,0));

% Read all the feature data into a design matrix, keeping track of int->name
% mapping.

for i=1:length(trainFileList)
  filename = sprintf('%s/%s', trainFileDir, trainFileList(i).('name'));
  % Read CSV file, skipping header
  M = csvread(filename, 1, 0);
  trainX = [trainX; M];
  trainY = [trainY; ones(size(M, 1), 1) * i];
  
  fprintf(mapFd, '%d,%s\n', i, trainFileList(i).('name'));
end

fclose(mapFd);

%w=zeros(length(trainFileList),size(trainX,2));
%sigX=sigmoid(trainX);
superY=sparse(size(trainX,1),length(trainFileList));
for i=1:length(trainFileList)
    superY(:,i)=trainY==i;
end

w =((lambda*eye(size(trainX,2),size(trainX,2))+trainX'*trainX))^-1*(trainX'*(superY));   

dlmwrite(wFile,w);
