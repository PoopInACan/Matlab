function [ x_01,maximum1,fwhm1,x_02,maximum2,fwhm2,x_03,maximum3,fwhm3,x_0D,maximumD,fwhmD,x_0G,maximumG,fwhmG,x_0Dp,maximumDp,fwhmDp] = peakFitFuncBufferx3( x,y,layerNumber)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% Use peakfit to find a good fit
% DprimePeakindex = [16:51,65:102,114:153,166:202]; % for x3
% DprimePeakindex = [35,36,37,38,39,52,53,54,55,69,70,86]; % for x947
% DprimePeakindex = load('../../Data/Defect Positions on Raman/x949_defect_positions.txt'); % for x949
% DprimePeakindex = load('../../Data/Defect Positions on Raman/x3_defect_positions.txt'); % for x3
% spectraToFitFor = load('../../Data/Defect Positions on Raman/934_defect_positions.txt');
spectraToFitFor = []; % for monolayer or buffer samples where all spectra need to be fit
%% Initialize variables to save time in "for" loop
numLayers = ones(1,size(y,2));
loopLength = length(numLayers);
x_0G = ones(1,size(y,2));
maximumG = ones(1,size(y,2));
fwhmG = ones(1,size(y,2));
x_0D = ones(1,size(y,2));
maximumD = ones(1,size(y,2));
fwhmD = ones(1,size(y,2));
x_0Dp = ones(1,size(y,2));
maximumDp = ones(1,size(y,2));
fwhmDp = ones(1,size(y,2));
fwhm1 = ones(1,size(y,2));
maximum1 = ones(1,size(y,2));
x_01 = ones(1,size(y,2));
fwhm2 = ones(1,size(y,2));
maximum2 = ones(1,size(y,2));
x_02 = ones(1,size(y,2));
fwhm3 = ones(1,size(y,2));
maximum3 = ones(1,size(y,2));
x_03 = ones(1,size(y,2));
%% Set parameters for function called
% "peakfit(signal,center,window,NumPeaks,peakshape,extra,NumTrials,start,autozero,fixedparameters,plots,bipolar,minwidth)"
center2d = 2700;
window = 100;
NumPeaks = 1; % number of peaks to fit for
peakshape = 2; % 2 means Lorentzian
extra = 0; %
NumTrials = 40; % number of tries trying to fit
start2d = [center2d 35]; % starting numbers for center position and fwhm
autozero = 0; % subtract background? 0 means none, 1 means linear, 2 means quadratic
fixedparameters = 2; % lorentzian is fixed, we don't want to fix anything else
plots = 0; % show plots? 0 means no, 1 means yes
bipolar = 0; % im not bipolar
minwidth = 10; % minimum fwhm
%% Fitting
h = waitbar(0,'Initializing waitbar...');
tic;
switch layerNumber
    case {'Yes',0, 'Buffer'} % Buffer layer
        for i = spectraToFitFor' % we only fit for this
            signal = [x',y(:,i)];
            % 2D peaks
            [FitResults,~,~,~,~,~] = ...
                peakfit(signal,2850,300,3,peakshape,extra,NumTrials,[2650 100 2950 70 3200 50],autozero,fixedparameters,plots,bipolar,minwidth);
            FitResults = num2cell(FitResults);
            [~,x_01(i),maximum1(i),fwhm1(i),~] = deal(FitResults{1,:});
            [~,x_02(i),maximum2(i),fwhm2(i),~] = deal(FitResults{2,:});
            [~,x_03(i),maximum3(i),fwhm3(i),~] = deal(FitResults{3,:});
            % G and D together (for buffer layer)
            [FitResults,~,~,~,~,~] = ...
                peakfit(signal,1450,400,2,peakshape,extra,NumTrials,[1595 30 1360 60],autozero,fixedparameters,plots,bipolar,minwidth);
            FitResults = num2cell(FitResults);
            [~,x_0G(i),maximumG(i),fwhmG(i),~] = deal(FitResults{1,:});
            [~,x_0D(i),maximumD(i),fwhmD(i),~] = deal(FitResults{2,:});
%           G and D peak are swapped sometimes, so we check for this and
%           swap them back
            if x_0G(i) < x_0D(i)
                [~,x_0G(i),maximumG(i),fwhmG(i),~] = deal(FitResults{2,:});
                [~,x_0D(i),maximumD(i),fwhmD(i),~] = deal(FitResults{1,:});
            end
            time_elapsed = toc;
            time_left = time_elapsed*size(y,2)/i - time_elapsed;
            h = waitbar(i/loopLength, h,['Time left for peak fit ' sprintf('%.2d',floor(time_left/60)) ':' sprintf('%.2d',floor(mod(time_left,60))) ]);
        end
    case {'No',1,'Mono'} % as-grown monolayer, fit all spectra and special spectra to signal D' peak
        % spectraToFitFor is for D' peak
        for i = 1:size(y,2)
            signal = [x',y(:,i)];
            % 2D peaks
            [FitResults,LowestError,baseline,BestStart,xi,yi] = ...
                peakfit(signal,center2d,window,NumPeaks,peakshape,extra,NumTrials,start2d,autozero,fixedparameters,plots,bipolar,minwidth);
            FitResults = num2cell(FitResults);
            [~,x_01(i),maximum1(i),fwhm1(i),~] = deal(FitResults{:});
            % G and D peak
            if isempty(intersect(i,spectraToFitFor))
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
                        peakfit(signal,1600,150,2,peakshape,extra,50,[1590 30 1624 20],autozero,fixedparameters,0,bipolar,5);
                    FitResults = num2cell(FitResults);
                    [~,x_0G(i),maximumG(i),fwhmG(i),~] = deal(FitResults{1,:});
                    [~,x_0Dp(i),maximumDp(i),fwhmDp(i),~] = deal(FitResults{2,:});
                    if x_0Dp(i) < x_0G(i) % G and Dp peaks are swapped from FitResults
                        [~,x_0G(i),maximumG(i),fwhmG(i),~] = deal(FitResults{2,:});
                        [~,x_0Dp(i),maximumDp(i),fwhmDp(i),~] = deal(FitResults{1,:});
                    end
                end
                % then D
                [FitResults,LowestError,baseline,BestStart,xi,yi] = ...
                    peakfit(signal,1340,150,1,peakshape,extra,NumTrials,[1340 60],autozero,fixedparameters,plots,bipolar,5);
                FitResults = num2cell(FitResults);
                [~,x_0D(i),maximumD(i),fwhmD(i),~] = deal(FitResults{1,:});
            end
            time_elapsed = toc;
            time_left = time_elapsed*size(y,2)/i - time_elapsed;
            h = waitbar(i/loopLength, h,['Time left for peak fit ' sprintf('%.2d',floor(time_left/60)) ':' sprintf('%.2d',floor(mod(time_left,60))) ]);
        end
        %       These peaks are only used for buffer layer, since 2D peak has 3
        %       peaks to fit for.
        [x_02,maximum2,fwhm2] = deal(0);
        [x_03,maximum3,fwhm3] = deal(0);
end


close(h);

end

