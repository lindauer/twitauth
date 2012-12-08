trainFileDir = './train';
modelDir = './model';
mapFile = sprintf('%s/map.csv', modelDir);
f = fopen(mapFile);
mapF=textscan(f,'%d,%s\n');
fclose(f);

num_correct=0;

%complete_distances = zeros(1,620);
%train_results_file = fopen('train_accuracy.csv');

% The resulting ranking for each test.
rankings = zeros(size(mapF{1,1},1), 2);

% calculate training accuracy
for i=1:size(mapF{1,1})
  rawname=mapF{1,2}{i,1};
  filename = sprintf('%s/%s', trainFileDir, rawname);
  % Read CSV file, skipping header
  M = csvread(filename, 1, 0);

  [prediction distances] = nn_predict(filename);
  
  %add Y to matrix
  %z=ones(size(distances,1),1);
  %distances = [z*i distances];
  %complete_distances = [complete_distances;distances];
  
  dlmwrite('train_accuracy.csv',distances, '-append');

  % Get ranking of correct answer.
  rank = find(prediction(:,1)==mapF{1,1}(i));
  rankings(i,:) = [i rank(1,1)];
  
  if (rankings(i,2) == 1)
      num_correct = num_correct+1;
  end

  fprintf('%s: %d (%d/%d correct so far)\n', mapF{1,2}{i}, rankings(i,2), num_correct, i);
end

num_correct/size(mapF{1,1},1);

dlmwrite('rankings.csv', rankings);
