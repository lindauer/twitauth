trainFileDir = './train';
modelDir = './model';
mapFile = sprintf('%s/map.csv', modelDir);
f = fopen(mapFile);
mapF=textscan(f,'%d,%s\n');
fclose(f);

num_correct=0;

%complete_distances = zeros(1,620);
%train_results_file = fopen('train_accuracy.csv');

% calculate training accuracy
for i=1:size(mapF{1,1})
  rawname=mapF{1,2}{i,1};
  filename = sprintf('%s/%s', trainFileDir, rawname);
  % Read CSV file, skipping header
  M = csvread(filename, 1, 0);

  [prediction distances] = nn_predict(filename);
  
  %add Y to matrix
  z=ones(size(distances,1),1);
  distances = [z*i distances];
  %complete_distances = [complete_distances;distances];
  
  dlmwrite('train_accuracy.csv',distances, '-append');
  
  if prediction(1,1)==mapF{1,1}(i)
      num_correct = num_correct+1
  end
  mapF{1,2}{i,1}
  prediction(1,1)==mapF{1,1}(1)

end

num_correct/size(mapF{1,1},1);

