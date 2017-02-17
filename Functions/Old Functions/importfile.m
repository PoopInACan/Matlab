function y = importfile(filename)
% %% Open the text file.
formatSpec = '%f';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, Inf);
dataArrayn = cell2mat(dataArray);
y = transpose(reshape(dataArrayn,[size(dataArrayn,1)/2000,2000]));
fclose(fileID);
