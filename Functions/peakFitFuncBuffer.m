function [ x_01,maximum1,fwhm1,x_02,maximum2,fwhm2,x_03,maximum3,fwhm3,x_0D,maximumD,fwhmD,x_0G,maximumG,fwhmG] = peakFitFuncBuffer( x,y )
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
center = 2900;
window = 700;
NumPeaks = 3; % number of peaks to fit for
peakshape = 2; % 2 means Lorentzian
extra = 0; %
NumTrials = 70; % number of tries trying to fit
start = [center 200 2700 300 3150 200]; % starting numbers for center position and fwhm
autozero = 0; % subtract background? 0 means none, 1 means linear, 2 means quadratic
fixedparameters = 2; % lorentzian is fixed, we don't want to fix anything else
plots = 0; % show plots? 0 means no, 1 means yes
bipolar = 0; % im not bipolar
minwidth = 10; % minimum fwhm
count = 0;
h = waitbar(0,'Initializing waitbar...');
tic;
for i = 1:size(y,2)
    signal = [x',y(:,i)];
    % 2D, D+G and G+D' peaks
%     [FitResults,LowestError,baseline,BestStart,xi,yi] = ...
%         peakfit(signal,center,window,NumPeaks,peakshape,extra,NumTrials,start,autozero,fixedparameters,plots,bipolar,minwidth);
%     FitResults = num2cell(FitResults);
%     [~,x_01(i),maximum1(i),fwhm1(i),~] = deal(FitResults{1,:});
%     [~,x_02(i),maximum2(i),fwhm2(i),~] = deal(FitResults{2,:});
%     [~,x_03(i),maximum3(i),fwhm3(i),~] = deal(FitResults{3,:});
    % G and D peak
    [FitResults,LowestError,baseline,BestStart,xi,yi] = ...
        peakfit(signal,1450,600,2,peakshape,extra,15,[1590 80 1340 100],autozero,fixedparameters,plots,bipolar,minwidth);
    FitResults = num2cell(FitResults);
    [~,x_0G(i),maximumG(i),fwhmG(i),~] = deal(FitResults{1,:});
    [~,x_0D(i),maximumD(i),fwhmD(i),~] = deal(FitResults{2,:});
    time_elapsed = toc;
    time_left = time_elapsed*size(y,2)/i - time_elapsed;
    h = waitbar(i/loopLength, h,['Time left for peak fit of G and D: ' sprintf('%.2d',floor(time_left/60)) ':' sprintf('%.2d',floor(mod(time_left,60))) ]);
end
close(h);
[x_01,maximum1,fwhm1] = deal(0);
[x_02,maximum2,fwhm2] = deal(0);
[x_03,maximum3,fwhm3] = deal(0);
end

