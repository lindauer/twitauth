% trainFileDir = './train';
% trainFiles = sprintf('%s/*.csv', trainFileDir);
% 
% modelDir = './model';
% mapFile = sprintf('%s/map.csv', modelDir);
% f = fopen(mapFile);
% mapF=textscan(f,'%d,%s\n');
% fclose(f)

total_correct=0;
total_correct_5=0;
total_correct_10=0;
total_count=0;
for i=1:1000000
    V = dlmread('train_accuracy.csv',',',[i-1 0 i-1 260]);
    
    correct_answer = V(1,1);
    [V index] = sort(V,'ascend');
    if(index(correct_answer)==(1))
        total_correct=total_correct+1
    end
    if((index(correct_answer)<5))
        total_correct_5=total_correct_5+1
    end
    if((index(correct_answer)<10))
        total_correct_10=total_correct_10+1
    end
    total_count=total_count+1;
end
