% for i=1:length(trainFileList)
%     superY(:,i)=trainY==i;
% end

%disp('Completed Y Matrix Generation. Beginning Training Step')

% this method does not penalize false positives
%w =((lambda*eye(size(trainX,2),size(trainX,2))+trainX'*trainX))^-1*(trainX'*(superY));   


for i=1:length(trainFileList)
    i
    trainTemp=(trainY==i)*length(trainFileList)-1;
    w(:,i)=((lambda*eye(size(trainX,2),size(trainX,2))+trainX'*trainX))^-1*(trainX'*(trainTemp));
end