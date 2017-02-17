%% testPeakFit
% Fits lorentzians with peakfit function
% It is a better peak fitting function.  Before you fit here, you must
% writeSPCtoText, then open that file in raman_and_reflection_maps because
% that will shift the x-axis, subtract a straight line from the data and
% reference, and multiply the reference so the heights of the SiC peaks
% match.
% help testPeakFit
%% Load x and y data from xx22 (1924 for xx22)
theFiles = dir('../../DataAnalysis/RamanAlreadySubtractedFiles/*_yValues.txt');
fnames = {theFiles.name}.';
[s,v] = listdlg('PromptString','Select files to load for Raman fitting:', ...
    'SelectionMode','single', ...
    'InitialValue',1, ...
    'ListString',fnames);
if isequal(v,0) % if cancel was pressed, close everything
    return;
end
clearvars -except theFiles fnames s v; 
clc; 
close all force;
sampleName = strrep(fnames(s),'_yValues.txt','');
sampleName = cell2mat(sampleName);
formatSpec = '%f';
fileID = fopen(['../../DataAnalysis/RamanAlreadySubtractedFiles/' sampleName '_xValues.txt'],'r');
dataArray = textscan(fileID, formatSpec, Inf);
dataArrayn = cell2mat(dataArray);
nl = size(dataArrayn,1);
x = transpose(reshape(dataArrayn,[size(dataArrayn,1)/nl,nl]));
fclose(fileID);
formatSpec = '%f';
fileID = fopen(['../../DataAnalysis/RamanAlreadySubtractedFiles/' sampleName '_yValues.txt'],'r');
dataArray = textscan(fileID, formatSpec, Inf);
dataArrayn = cell2mat(dataArray);
y = transpose(reshape(dataArrayn,[size(dataArrayn,1)/nl,nl]));
fclose(fileID);
clearvars -except x y sampleName

%% Use peakfit to find a good fit
% Initialize variables to save time in "for" loop
numLayers = ones(1,size(y,2));
x_0 = ones(1,size(y,2));
maximum = ones(1,size(y,2));
LowestError = ones(1,size(y,2));
fwhm = ones(1,size(y,2));
perc = ones(1,size(y,2));
loopLength = length(numLayers);
LowestErrorFirst = LowestError;
xi = ones(600,size(y,2));
yi = ones(600,size(y,2));
% Set parameters for function called
% "peakfit(signal,center,window,NumPeaks,peakshape,extra,NumTrials,start,autozero,fixedparameters,plots,bipolar,minwidth)"
center = 2720;
window = 300;
NumPeaks = 1; % number of peaks to fit for
peakshape = 2; % 2 means Lorentzian
extra = 0; %
NumTrials = 2; % number of tries trying to fit
start = [center 30]; % starting numbers for center position and fwhm
autozero = 0; % subtract background? 0 means none, 1 means linear, 2 means quadratic
fixedparameters = 2; % lorentzian is fixed, we don't want to fix anything else
plots = 0; % show plots? 0 means no, 1 means yes
bipolar = 0; % im not bipolar
minwidth = 20; % minimum fwhm
count = 0;
h = waitbar(0,'Initializing waitbar...');
tic;
for i = 1:size(y,2)
    signal = [x,y(:,i)];
    [FitResults,LowestError(i),baseline,BestStart,xi(:,i),yi(:,i)] = ...
        peakfit(signal,center,window,NumPeaks,peakshape,extra,NumTrials,start,autozero,fixedparameters,plots,bipolar,minwidth);
    FitResults = num2cell(FitResults);
    [~,x_0(i),maximum(i),fwhm(i),~] = deal(FitResults{:});
    LowestErrorFirst(i) = LowestError(i);
    if x_0(i) > 2600 && x_0(i) < 3000
        count = count + 1;
        newstart = [x_0(i),fwhm(i)];
        newcenter = x_0(i);
        newwindow = 300;
        [FitResults,LowestError(i),baseline,BestStart,xi(:,i),yi(:,i)] = ...
            peakfit(signal,newcenter,newwindow,NumPeaks,peakshape,extra,NumTrials,newstart,autozero,fixedparameters,plots,bipolar,minwidth);
        FitResults = num2cell(FitResults);
        [~,x_0(i),maximum(i),fwhm(i),~] = deal(FitResults{:});
    end
    perc(i) = FitResults{5}/trapz(y(:,i));
    time_elapsed = toc;
    time_left = time_elapsed*size(y,2)/i - time_elapsed;
    h = waitbar(i/loopLength, h,['Time left: ' sprintf('%.2d',floor(time_left/60)) ':' sprintf('%.2d',floor(mod(time_left,60))) ]);
end
close(h);
if isequal(window,300)
    numLayers = ones(1,size(y,2));
    numLayers(LowestError > 3) = 2;
    numLayers(LowestError > 4) = 3;
    numLayers(LowestError > 5.675) = 4;
    numLayers(maximum < 500) = 0;
elseif isequal(window,200)
    numLayers = ones(1,size(y,2));
    numLayers(LowestError > 4) = 2;
    numLayers(LowestError > 5) = 3;
    numLayers(LowestError > 6.675) = 4;
    numLayers(maximum < 1000) = 0;
end

[val0,ind0]=find(numLayers==0);
[val1,ind1]=find(numLayers==1);
[val2,ind2]=find(numLayers==2);
[val3,ind3]=find(numLayers==3);
[val4,ind4]=find(numLayers==4);
layer0 = length(numLayers(numLayers==0))/length(numLayers)*100;
layer1 = length(numLayers(numLayers==1))/length(numLayers)*100;
layer2 = length(numLayers(numLayers==2))/length(numLayers)*100;
layer3 = length(numLayers(numLayers==3))/length(numLayers)*100;
layer4 = length(numLayers(numLayers==4))/length(numLayers)*100;
%%

thelength = sqrt(length(fwhm));
thelength = floor(thelength);
newfwhm = fwhm(1:thelength^2);
figure(1);clf;
z_fwhm = reshape(newfwhm,thelength,thelength);
contourf(z_fwhm')
title([sampleName ': FWHM of 2D'],'Interpreter','none');
colormap('hot')
colorbar
%% 
newx_0 = x_0(1:thelength^2);
figure(2);clf;
z_x_0 = reshape(newx_0,thelength,thelength);
contourf(z_x_0')
title([sampleName ': Position of 2D'],'Interpreter','none');
colormap('hot');

%% FWHM 2D according to equation -45/(fwhm-88)
fwhmLimited = fwhm;
fwhmLimited(fwhm>88) = 85;
NLayers=-45./(fwhmLimited-88);
funN = @(fwhmL) -45./fwhmL+88;
ylim1 = 45/68;
ylim2 = 5;
fig6 = figure(6);clf;
plot(NLayers,'o')
title([sampleName ': 2D FWHM'],'Interpreter','none')
ylim([ylim1 ylim2])
ylabel('Number of Layers')
yyaxis right
theaxes = gca;
ylim([ylim1 ylim2]) % need to make this axis more correct
theaxes.YTick = 1:ylim2;
theaxes.YTickLabel = funN(1:ylim2);
ylabel('FWHM')
prettyPlotLoop(figure(6),14,'yes')
clc;
%% histogram of 2D fwhm
minOf1Layer = min(fwhmLimited);
if minOf1Layer > 57
    minOf1Layer = 43;
end
figure(5);
nbins = 4;
thehist = histogram(fwhmLimited,nbins,'Normalization','Probability','BinEdges',[minOf1Layer,57.999,69.999,75.142,85]);
title([sampleName 'Distribution of 2D FWHM'],'Interpreter','none')
xlabel('FWHM (cm^{-1})')
ylabel('Percentage')
prettyPlotLoop(figure(5),14,'yes')

%% Write stats to file
indexaMonolayer = find(NLayers<1.5); % monolayer according to fwhm
indexbBilayer = find(NLayers<2.5 & NLayers>=1.5); % bilayer according to fwhm
indexcTrilayer = find(NLayers<3.5 & NLayers>=2.5); % bilayer according to fwhm
indexdQuadOrMore = find(NLayers >= 3.5); % 4 or more layers
a = strfind(sampleName,'_');
sampleNumber = sampleName(1:(a(1)-1));
try
    sampleName(a(1)) = '(';
    sampleName(a(2:3)) = ') ';
catch ME
    disp(ME);
end
% fileID = fopen([sampleNumber '.txt'],'a');
% fprintf(fileID,[sampleName '\n']);
% fprintf(fileID,'1: %2g\n', length(indexaMonolayer)/length(NLayers)*100);
% fprintf(fileID,'2: %2g\n', length(indexbBilayer)/length(NLayers)*100);
% fprintf(fileID,'3: %2g\n', length(indexcTrilayer)/length(NLayers)*100);
% fprintf(fileID,'4+: %2g\n', length(indexdQuadOrMore)/length(NLayers)*100);
% fprintf(fileID,[num2str(i) ' points\n\n']);
% fclose(fileID);
