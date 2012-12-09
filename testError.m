% Directory containing test data. The filename should be the name of the
% account you hope to match.
testFileDir = './test';
modelDir = './model';
progressDir = './tmp';
mapFile = sprintf('%s/map.csv', modelDir);
f = fopen(mapFile);
mapF=textscan(f,'%d,%s\n');
fclose(f);

mkdir(progressDir);
delete(sprintf('%s/*.progress', progressDir));

% Vector (fixed string length version) of filenames for progress bar.
vFilenames = char(mapF{1,2});

% The resulting ranking for each test.
rankings = zeros(size(mapF{1,1},1), 2);

% Set up parallel processing worker pool.
if (matlabpool('size') == 0)
  % Limit to 6 cores because of out of memory errors on corn.
  matlabpool('open', min(feature('numCores'), 6));
end

cpb = ConsoleProgressBar();
cpb.setLength(20);
cpb.start();
cpb.setText('Making predictions...');
% calculate training accuracy
parfor i=1:size(mapF{1,1},1)
  rawname=mapF{1,2}{i,1};
  filename = sprintf('%s/%s', testFileDir, rawname);
  
  % Read CSV file, skipping header
  M = csvread(filename, 1, 0);

  [prediction distances] = nn_predict(filename);
  
  % Get ranking of correct answer.
  rank = find(prediction(:,1)==mapF{1,1}(i));
  rankings(i,:) = [i rank(1,1)];
  
  fclose(fopen(sprintf('%s/%s.progress', progressDir, rawname), 'w'));
  num_complete = size(dir(sprintf('%s/*.progress', progressDir)), 1);
  
  cpb.setText(sprintf('Making predictions... %s: %d', vFilenames(i,:), rank(1,1)));
  cpb.setValue(100*(num_complete/size(mapF{1,1},1)));
  fprintf('\n'); % Force output
end

num_correct = sum(rankings(:,2)==1);
num_correct/size(mapF{1,1},1)

dlmwrite('rankings.csv', rankings);

matlabpool close;