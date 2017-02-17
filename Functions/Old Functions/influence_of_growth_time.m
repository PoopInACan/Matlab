% function influence_of_growth_temp
% Initialize variables.
filename = '/Users/Kevin/Dropbox/Matlab programs/Mat and text files/time_effect_layer_number.txt';
delimiter = '\t';
startRow = 1;
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
% Open the text file.
fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
% Close the text file.
fclose(fileID);
% Allocate imported array to column variable names
growth_time = dataArray{:, 5}';
bare = dataArray{:, 9}';
buffer = dataArray{:, 10}';
one_layer = dataArray{:, 11}';
two_layer = dataArray{:, 12}';
three_layer = dataArray{:, 13}';
% Clear temporary variables
% clearvars filename delimiter startRow formatSpec fileID dataArray ans;%% Plot figure
%%
sigma = ones(1,length(bare));    % Constant error bar
sigma(end) = 100;
sigma(end-1) = 100;

M = 2; % 2 for line, 3 for quadratic
[a_fit, sig_a, yybare, chisqr]      = pollsf(growth_time,bare,sigma,M);
[a_fit, sig_a, yybuffer, chisqr]    = pollsf(growth_time,buffer,sigma,M);
[a_fit, sig_a, yyone, chisqr]       = pollsf(growth_time,one_layer,sigma,M);
[a_fit, sig_a, yytwo, chisqr]       = pollsf(growth_time,two_layer,sigma,M);



%% Plot
myfig = figure(1);
clf;
theplot = plot(...
    growth_time,bare,'o',...
    growth_time,buffer,'o',...
    growth_time,one_layer,'o',...
    growth_time,two_layer,'o',...
    growth_time,yybare,'-.',...
    growth_time,yybuffer,'-.',...
    growth_time,yyone,'-.',...
    growth_time,yytwo,'-.');
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
axis([min(growth_time) max(growth_time) 0 100]);
title('Growth Time effect on layer thickness')
xlabel('Growth Time (min)');
ylabel('Percentage');
legend('Bare Substrate','Buffer Layer','One Layer','Two Layers','location','best')
prettyPlotLoop(myfig,14,'yes')
% saveFigure(myfig,'growthTimeEffect')
%%
myfig = figure(5);
clf;
thefit = @(t,h,xx) 100*(-exp(-(t-xx)/h));
x = 10:40;
y = buffer+one_layer+two_layer+three_layer;
yn = log(-y/100+1);
[a_fit, sig_a, theexpfitbufferlayer, chisqr] = pollsf(growth_time,yn,sigma,M);
yybuffexp = 100*(1-exp((a_fit(1)+a_fit(2)*x)))
y = one_layer+two_layer+three_layer;
yn = log(-y/100+1);
[a_fit, sig_a, theexpfitbufferlayer, chisqr] = pollsf(growth_time,yn,sigma,M);
yyoneexp = 100*(1-exp((a_fit(1)+a_fit(2)*x)))
theplot = plot(...
    growth_time,(buffer+one_layer+two_layer+three_layer),'o',...
    growth_time,(one_layer+two_layer+three_layer),'o',...
    x,yybuffexp,...
    x,yyoneexp);
prettyPlotLoop(myfig,14,'yes')
colorsP = get(theplot,'Color');
n = length(colorsP);
colorsP = cell2mat(colorsP);
count = 1;
for i = (n/2+1):n
    set(theplot(i),'Color',colorsP(count,:));
    count = count + 1;
end
axis([min(growth_time) max(growth_time) -inf 100]);
title('Growth Time Saturation')
xlabel('Growth Time (min)');
ylabel('Percentage');
legend('Buffer Layer','One Layer','location','best')
prettyPlotLoop(myfig,14,'yes')
saveFigure(myfig,'influenceOfTimeSaturation');
%%
% myfig = figure(11);
% clf;
% thefit = @(t,h) 100*(-exp(-t/h));
% theexpfitonelayer = thefit(10:40,5);
% plot(10:40,theexpfitonelayer)
% y = one_layer+two_layer+three_layer;
% yn = log(-y/100+1);
% [a_fit, sig_a, yyonelin, chisqr] = pollsf(growth_time,yn,sigma,M);
% yyoneexp = 100*(1-exp((a_fit(1)+a_fit(2)*x)))
% plot(x,yyoneexp)
