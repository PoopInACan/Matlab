function [ x_01,maximum1,fwhm1,x_02,maximum2,fwhm2,x_03,maximum3,fwhm3,x_0D,maximumD,fwhmD,x_0G,maximumG,fwhmG,x_0Dp,maximumDp,fwhmDp] = peakFitFuncBufferx3( x,y)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% Use peakfit to find a good fit
% DprimePeakindex = [16:51,65:102,114:153,166:202]; % for x3
% DprimePeakindex = [35,36,37,38,39,52,53,54,55,69,70,86]; % for x947
% fileID = fopen('D_defect_x22.txt','r');
% fmt = '%5d,\n';
% frewind(fileID);
% DprimePeakindex = fscanf(fileID,'%f,\n');
% fclose(fileID);
% DprimePeakindex = DprimePeakindex';
% DprimePeakindex = load('../../Data/Defect Positions on Raman/x949_defect_positions.txt'); % for x949
DprimePeakindex = load('../../Data/Defect Positions on Raman/x3_defect_positions.txt'); % for x3
% DprimePeakindex = [];
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
x_0G = ones(1,size(y,2));
maximumG = ones(1,size(y,2));
fwhmG = ones(1,size(y,2));
x_0D = ones(1,size(y,2));
maximumD = ones(1,size(y,2));
fwhmD = ones(1,size(y,2));
x_0Dp = ones(1,size(y,2));
maximumDp = ones(1,size(y,2));
fwhmDp = ones(1,size(y,2));

% Set parameters for function called
% "peakfit(signal,center,window,NumPeaks,peakshape,extra,NumTrials,start,autozero,fixedparameters,plots,bipolar,minwidth)"
center2d = 2700;
window = 100;
NumPeaks = 1; % number of peaks to fit for
peakshape = 2; % 2 means Lorentzian
extra = 0; %
NumTrials = 20; % number of tries trying to fit
start2d = [center2d 35]; % starting numbers for center position and fwhm
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
%     2D peaks
        [FitResults,LowestError,baseline,BestStart,xi,yi] = ...
            peakfit(signal,center2d,window,NumPeaks,peakshape,extra,NumTrials,start2d,autozero,fixedparameters,plots,bipolar,minwidth);
        FitResults = num2cell(FitResults);
        [~,x_01(i),maximum1(i),fwhm1(i),~] = deal(FitResults{:});
%     G and D peak
    if isempty(intersect(i,DprimePeakindex))
%         G and D together (for buffer layer)
%         [FitResults,LowestError,baseline,BestStart,xi,yi] = ...
%             peakfit(signal,1450,400,2,peakshape,extra,NumTrials,[1595 30 1360 60],autozero,fixedparameters,plots,bipolar,minwidth);
%         FitResults = num2cell(FitResults);
%         [~,x_0G(i),maximumG(i),fwhmG(i),~] = deal(FitResults{1,:});
%         [~,x_0D(i),maximumD(i),fwhmD(i),~] = deal(FitResults{2,:});
        % G and D separate (for monolayer)
        [FitResults,LowestError,baseline,BestStart,xi,yi] = ...
            peakfit(signal,1595,70,1,peakshape,extra,NumTrials,[1595 30],autozero,fixedparameters,plots,bipolar,minwidth);
        FitResults = num2cell(FitResults);
        [~,x_0G(i),maximumG(i),fwhmG(i),~] = deal(FitResults{1,:});
        [FitResults,LowestError,baseline,BestStart,xi,yi] = ...
            peakfit(signal,1365,200,1,peakshape,extra,NumTrials,[1360 60],autozero,fixedparameters,plots,bipolar,minwidth);
        FitResults = num2cell(FitResults);
        [~,x_0D(i),maximumD(i),fwhmD(i),~] = deal(FitResults{1,:});
    else % G and Dp together
        [FitResults,LowestError,baseline,BestStart,xi,yi] = ...
            peakfit(signal,1600,150,2,peakshape,extra,NumTrials,[1590 30 1624 20],autozero,fixedparameters,plots,bipolar,5);
        FitResults = num2cell(FitResults);
        [~,x_0G(i),maximumG(i),fwhmG(i),~] = deal(FitResults{1,:});
        [~,x_0Dp(i),maximumDp(i),fwhmDp(i),~] = deal(FitResults{2,:});
        if x_0Dp(i) < x_0G(i) % G and Dp peaks are swapped from FitResults
            [~,x_0G(i),maximumG(i),fwhmG(i),~] = deal(FitResults{2,:});
            [~,x_0Dp(i),maximumDp(i),fwhmDp(i),~] = deal(FitResults{1,:});
        end
        if 2*maximumDp(i) > maximumG(i)
            [FitResults,LowestError,baseline,BestStart,xi,yi] = ...
                peakfit(signal,1600,150,2,peakshape,extra,50,[1590 30 1624 20],autozero,fixedparameters,1,bipolar,5);
            FitResults = num2cell(FitResults);
            [~,x_0G(i),maximumG(i),fwhmG(i),~] = deal(FitResults{1,:});
            [~,x_0Dp(i),maximumDp(i),fwhmDp(i),~] = deal(FitResults{2,:});
            if x_0Dp(i) < x_0G(i) % G and Dp peaks are swapped from FitResults
                [~,x_0G(i),maximumG(i),fwhmG(i),~] = deal(FitResults{2,:});
                [~,x_0Dp(i),maximumDp(i),fwhmDp(i),~] = deal(FitResults{1,:});
            end
        end
%       then D
        [FitResults,LowestError,baseline,BestStart,xi,yi] = ...
            peakfit(signal,1340,150,1,peakshape,extra,NumTrials,[1340 60],autozero,fixedparameters,plots,bipolar,5);
        FitResults = num2cell(FitResults);
        [~,x_0D(i),maximumD(i),fwhmD(i),~] = deal(FitResults{1,:});
    end
    time_elapsed = toc;
    time_left = time_elapsed*size(y,2)/i - time_elapsed;
    h = waitbar(i/loopLength, h,['Time left for peak fit ' sprintf('%.2d',floor(time_left/60)) ':' sprintf('%.2d',floor(mod(time_left,60))) ]);
end
close(h);
[x_02,maximum2,fwhm2] = deal(0);
[x_03,maximum3,fwhm3] = deal(0);
end

