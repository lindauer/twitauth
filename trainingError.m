trainFileDir = './train';
modelDir = './model';
mapFile = sprintf('%s/map.csv', modelDir);
f = fopen(mapFile);
mapF=textscan(f,'%d,%s\n');
fclose(f);

correctGuesses_5 = 0;
correctGuesses_1 = 0;
correctGuesses_10 = 0;
totalPopulation = 0;

accuracy = zeros(size(mapF,1),4);

% calculate training error
for i=1:size(mapF{1,1})
  rawname=mapF{1,2}{i,1};
  filename = sprintf('%s/%s', trainFileDir, rawname);
  % Read CSV file, skipping header
  M = csvread(filename, 1, 0);
  for j=1:size(M,1)
      prediction = nn_predict(filename,1,j);
           
      % if the correct answer is in the top 5
      if prediction(1)==mapF{1,1}(i)==1
          correctGuesses_1 = correctGuesses_1 +1;
          accuracy(i,1) = accuracy(i,1) + 1;
      end
      if sum(prediction(1:5,1)==mapF{1,1}(i))==1
          correctGuesses_5 = correctGuesses_5 +1;
          accuracy(i,2) = accuracy(i,2) + 1;
      end
      if sum(prediction(1:10,1)==mapF{1,1}(i))==1
          correctGuesses_10 = correctGuesses_10 +1;
          accuracy(i,3) = accuracy(i,3) + 1;
      end
      totalPopulation=totalPopulation+1;     
      accuracy(i,4) = accuracy(1,4)+1;
  end
  mapF{1,2}{i,1}
  correctGuesses_10/totalPopulation  
end

correctGuesses_1
correctGuesses_5
correctGuesses_10
totalPopulation