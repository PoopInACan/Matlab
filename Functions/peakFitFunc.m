function [ x_0,maximum,fwhm,numLayers,layer0,layer1,layer2,layer3,layer4,ind0,ind1,ind2,ind3,ind4,NLayers] = peakFitFunc( x,y )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
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
    signal = [x',y(:,i)];
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
    h = waitbar(i/loopLength, h,['Time left for peak fit of 2D: ' sprintf('%.2d',floor(time_left/60)) ':' sprintf('%.2d',floor(mod(time_left,60))) ]);
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
[~,ind0]=find(numLayers==0);
[~,ind1]=find(numLayers==1);
[~,ind2]=find(numLayers==2);
[~,ind3]=find(numLayers==3);
[~,ind4]=find(numLayers==4);
layer0 = length(numLayers(numLayers==0))/length(numLayers)*100;
layer1 = length(numLayers(numLayers==1))/length(numLayers)*100;
layer2 = length(numLayers(numLayers==2))/length(numLayers)*100;
layer3 = length(numLayers(numLayers==3))/length(numLayers)*100;
layer4 = length(numLayers(numLayers==4))/length(numLayers)*100;

fwhmLimited = fwhm;
fwhmLimited(fwhm>88) = 85;
NLayers=-45./(fwhmLimited-88);
end

