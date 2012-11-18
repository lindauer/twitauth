trainFileDir = './train';
modelDir = './model';
mapFile = sprintf('%s/map.csv', modelDir);
f = fopen(mapFile);
mapF=textscan(f,'%d,%s\n');
fclose(f);

correctGuesses = 0;
totalPopulation = 0;

% calculate training error
for i=1:size(mapF{1,1})
  rawname=mapF{1,2}{i,1};
  filename = sprintf('%s/%s', trainFileDir, rawname);
  % Read CSV file, skipping header
  M = csvread(filename, 1, 0);
  for j=1:size(M,1)
      prediction = nn_predict(filename,1,j);
      % if the correct answer is in the top 5
      if sum(prediction(1:5,1)==mapF{1,1}(i))==1
          correctGuesses = correctGuesses +1;
      end
      totalPopulation=totalPopulation+1;          
  end
  mapF{1,2}{i,1}
  correctGuesses/totalPopulation  
end

correctGuesses
totalPopulation