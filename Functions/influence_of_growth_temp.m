function influence_of_growth_temp
% Initialize variables.
filename = '/Users/Kevin/Dropbox/Matlab programs/Mat and text files/growth_temp_effect.txt';
delimiter = '\t';
startRow = 1;
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
% Open the text file.
fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
% Close the text file.
fclose(fileID);
% Allocate imported array to column variable names
growth_temp = dataArray{:, 6}';
bare = dataArray{:, 9}';
buffer = dataArray{:, 10}';
one_layer = dataArray{:, 11}';
two_layer = dataArray{:, 12}';
three_layer = dataArray{:, 13}';
% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;%% Plot figure
%%
sigma = ones(1,length(bare));    % Constant error bar
M = 2; % 2 for line, 3 for quadratic
[a_fit, sig_a, yybuffer, chisqr]    = pollsf(growth_temp,buffer,sigma,M)
[a_fit, sig_a, yyone, chisqr]       = pollsf(growth_temp,one_layer,sigma,M)
[a_fit, sig_a, yytwo, chisqr]       = pollsf(growth_temp,two_layer,sigma,M)



%% Plot
myfig = figure(1);
clf;
theplot = plot(...
    growth_temp,buffer,'o',...
    growth_temp,one_layer,'o',...
    growth_temp,two_layer,'o',...
    growth_temp,yybuffer,'-.',...
    growth_temp,yyone,'-.',...
    growth_temp,yytwo,'-.');
prettyPlotLoop(myfig,14,'yes')
% match colors
colorsP = get(theplot,'Color');
n = length(colorsP);
colorsP = cell2mat(colorsP);
count = 1;
for i = (n/2+1):n
    set(theplot(i),'Color',colorsP(count,:));
    count = count + 1;
end
axis([1570 1600 0 100]);
title('Growth Temperature effect on layer thickness')
xlabel('Growth Temperature (\circC)');
ylabel('Percentage');
legend('Buffer Layer','One Layer','Two Layers','location','best')
prettyPlotLoop(myfig,14,'yes')
saveFigure(myfig,'growthTempVsLayerThickness')
