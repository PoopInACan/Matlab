function stationary_vs_gas_flow_plot
% Initialize variables.
filename = '/Users/kevme20/Dropbox/Matlab programs/Mat and text files/stationary_vs_gas_flow.txt';
delimiter = '\t';
startRow = 2;
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
% Open the text file.
fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
% Close the text file.
fclose(fileID);
% Allocate imported array to column variable names
Run = dataArray{:, 1};
Timemin = dataArray{:, 2};
TemperatureC = dataArray{:, 3};
Pressurembar = dataArray{:, 4};
Timemin2 = dataArray{:, 5};
TemperatureC3 = dataArray{:, 6};
Pressurembar4 = dataArray{:, 7};
flow_rate = dataArray{:, 8}';
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
[a_fit, sig_a, yybare, chisqr]      = pollsf(flow_rate,bare,sigma,M)
[a_fit, sig_a, yybuffer, chisqr]    = pollsf(flow_rate,buffer,sigma,M)
[a_fit, sig_a, yyone, chisqr]       = pollsf(flow_rate,one_layer,sigma,M)
[a_fit, sig_a, yytwo, chisqr]       = pollsf(flow_rate,two_layer,sigma,M)



%% Plot
myfig = figure(1);
clf;
theplot = plot(flow_rate,bare,'.',...
    flow_rate,buffer,'.',...
    flow_rate,one_layer,'.',...
    flow_rate,two_layer,'.',...
    flow_rate,yybare,'-.',...
    flow_rate,yybuffer,'-.',...
    flow_rate,yyone,'-.',...
    flow_rate,yytwo,'-.');
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
axis([0 10 0 100]);
title('Flow rate effect on number of layers')
xlabel('Flow rate (L/min)');
ylabel('Percentage');
legend('Bare','Buffer','One','Two','location','best')
prettyPlotLoop(myfig,14,'yes')
theChoice = questdlg('Save Figures?','Save Figures?','Yes','No','No');
switch theChoice
    case 'Yes'
        saveFigure(myfig,'stationaryVsFlowingGas')
    otherwise
end


