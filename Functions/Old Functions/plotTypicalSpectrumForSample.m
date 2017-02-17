% function plotTypicalSpectrumForSample
close all force;
a = load('x999.mat');
v2struct(a); % loads in variables
if not(isequal(sampleName,'x930'))
    return;
end
clear a;
tLength = 1:length(fwhm2D);
xMin = 2550;
xMax = 2900;
i = 1;
% Plot typical spectrum
xmin = 1000;
range_to_plot = 1:4000;
lorentzianFit = maxValue2D(i).*(1/2*fwhm2D(i)).^2./( (xi-x0_2D(i)).^2 + (1/2*fwhm2D(i)).^2);
lorentzianFitG = maxValueG(i).*(1/2*fwhmG(i)).^2./( (xi-x0_G(i)).^2 + (1/2*fwhmG(i)).^2);
lorentzianFitD = maxValueD(i).*(1/2*fwhmD(i)).^2./( (xi-x0_D(i)).^2 + (1/2*fwhmD(i)).^2);
myFigure = figure;clf;
plotaa=plot(xi(range_to_plot),intY(range_to_plot,i),'o',...
    xi,lorentzianFit,...
    xi,lorentzianFitG,...
    xi,lorentzianFitD);
title('Monolayer Spectrum');
text(x0_2D(i)+70,maxValue2D(i)*.8,sprintf('2D peak: %.0f cm^{-1}\nFWHM: %.0f cm^{-1}',x0_2D(i),fwhm2D(i)));
text(x0_G(i)+120,maxValueG(i)*.8,sprintf('G peak: %.0f cm^{-1}\nFWHM: %.0f cm^{-1}',x0_G(i),fwhmG(i)));
text((xmin+x0_D(i))/2-100,maxValueD(i)*1.45,sprintf('D peak:\n %.0f cm^{-1}',x0_D(i)));
xlabel('Raman Shift (cm^{-1})');
ylabel('Intensity');
arrow([2600 2605]',[.016 .02]')
axis([xmin 3500 0 maxValue2D(i)*1.5]);
legend('Data','2D Fit','G Fit','D Fit');
prettyPlotLoop(myFigure)
printNow = 0;
if isequal(printNow,1)
    saveFigure(myFigure,'typical_raman_spectrum');
end
%% Plot reason to subtract SiC background
myFigure = figure;
clf;
% Spike Removed Plot
spikeRemovedPlot = subplot(2,1,1);
hData2 = plot(ramanShift,spikeRemovedData(:,i));
hXLabel2 = xlabel('Wavelength (nm)');
hYLabel2 = ylabel('Intensity');
hTextD2 = text(1300,26500,'D peak');
annotation(myFigure,'arrow',[0.267857142857143 0.269642857142857],...
    [0.701380952380952 0.630952380952381]);
hTextG2 = text(1637.19422983236,33813.3696719673,'G peak');
annotation(myFigure,'arrow',[0.351785714285714 0.332142857142857],...
    [0.735714285714286 0.652380952380952]);
annotation(myFigure,'arrow',[0.65 0.644642857142857],...
    [0.677571428571429 0.626190476190476]);
hText2D2 = text(2690.01946728588,23356.0456608975,'2D peak');
% prettyPlotLoop(myFigure);
% Subtract Plot
subtractPlot = subplot(2,1,2);
hData3 = plot(ramanShift,newsam(:,i));
hXLabel3 = xlabel('Raman Shift (cm^{-1})');
hYLabel = ylabel('Intensity');
hText2D3 = text(x0_2D(i)+120,maxValue2D(i)*.8,'2D peak');
hTextG3 = text(x0_G(i)+120,maxValueG(i)*.8,'G peak');
hTextD3 = text((xmin+x0_D(i))/2,maxValueD(i)*1.4,'D peak');
prettyPlotLoop(myFigure);
% Axis
axis(spikeRemovedPlot,[min(ramanShift) max(ramanShift) 0 inf])
axis(subtractPlot,[min(ramanShift) max(ramanShift) 0 inf])
printNow = 0;
if isequal(printNow,1)
    set(myFigure, 'PaperPositionMode', 'auto');
    PathName = '/Users/Kevin/Documents/Google Drive/Linkoping/Master Thesis/Thesis/Figures/';
    FileName = 'reason_to_subtract_SiC';
    print(myFigure, '-depsc', [PathName FileName])
end

%% Plot steps of raman analysis
for i = 7
    lorentzianFit = maxValue2D(i).*(1/2*fwhm2D(i)).^2./( (xi-x0_2D(i)).^2 + (1/2*fwhm2D(i)).^2);
    lorentzianFitG = maxValueG(i).*(1/2*fwhmG(i)).^2./( (xi-x0_G(i)).^2 + (1/2*fwhmG(i)).^2);
    lorentzianFitD = maxValueD(i).*(1/2*fwhmD(i)).^2./( (xi-x0_D(i)).^2 + (1/2*fwhmD(i)).^2);
    stepFigure = figure;
    clf;
    set(stepFigure,'Position',[360 278 560 600]);
    % Original
    x = xAngstroms/10;
    originalPlot = subplot(4,1,1);
    hData1 = plot(x,originalData(:,i));
    hXLabel1 = xlabel('Wavelength (nm)');
    % 	hTitle1 = title('Raw Spectra');
    hYLabel1 = ylabel('Intensity');
%     prettyPlot(hData1,gca,hXLabel1,hYLabel1)
    % Remove Spike
    spikeRemovedPlot = subplot(4,1,2);
    hData2 = plot(x,spikeRemovedData(:,i));
    hXLabel2 = xlabel('Wavelength (nm)');
    % 	hTitle2 = title('Cosmic Rays removed');
    hYLabel2 = ylabel('Intensity');
%     prettyPlot(hData2,gca,hXLabel2,hYLabel2)
    % Subtract Plot
    subtractPlot = subplot(4,1,3);
    hData3 = plot(ramanShift,newsam(:,i));
    hXLabel3 = xlabel('Raman Shift (cm^{-1})');
    % 	hTitle3 = title('Subtracted SiC spectra');
    hYLabel3 = ylabel('Intensity');
%     prettyPlot(hData3,gca,hXLabel3,hYLabel3)
    % Fit plot
    fitPlot = subplot(4,1,4);
    hData4 = plot(ramanShift,newsam(:,i),xi,lorentzianFit,xi,lorentzianFitG,xi,lorentzianFitD);
    hXLabel4 = xlabel('Raman Shift (cm^{-1})');
    axis([originalPlot,spikeRemovedPlot],[min(x) max(x) 0 inf])
    axis([subtractPlot,fitPlot],[min(ramanShift) max(ramanShift) 0 inf])
    %     hTitle4 = title('Experimental Data with Lorentzian Peak Fits');
    hYLabel4 = ylabel('Intensity');
%     prettyPlot(hData4,gca,hXLabel4,hYLabel4)
prettyPlotLoop(stepFigure);
end
printNow = 0;
if isequal(printNow,1)
    set(stepFigure, 'PaperPositionMode', 'auto');
    PathName = '/Users/Kevin/Documents/Google Drive/Linkoping/Master Thesis/Thesis/Figures/';
    FileName = 'raman_matlab_steps';
    print(stepFigure, '-depsc', [PathName FileName])
end

%% Plot spike removal
for i = 7
    lorentzianFit = maxValue2D(i).*(1/2*fwhm2D(i)).^2./( (xi-x0_2D(i)).^2 + (1/2*fwhm2D(i)).^2);
    lorentzianFitG = maxValueG(i).*(1/2*fwhmG(i)).^2./( (xi-x0_G(i)).^2 + (1/2*fwhmG(i)).^2);
    lorentzianFitD = maxValueD(i).*(1/2*fwhmD(i)).^2./( (xi-x0_D(i)).^2 + (1/2*fwhmD(i)).^2);
    stepFigureSeparate = figure;
    clf;
    % Original
    x = xAngstroms/10;
    originalPlot = subplot(2,1,1);
    hData1 = plot(x,originalData(:,i));
    hXLabel1 = xlabel('Wavelength (nm)');
    % 	hTitle1 = title('Raw Spectra');
    hYLabel1 = ylabel('Intensity');
    annotation(stepFigureSeparate,'textarrow',[0.567857142857143 0.489285714285714],...
        [0.744238095238095 0.640476190476191],'String',{'Spikes'});
    annotation(stepFigureSeparate,'arrow',[0.598214285714286 0.601785714285714],...
        [0.729952380952381 0.642857142857143]);
    annotation(stepFigureSeparate,'arrow',[0.625 0.757142857142857],...
        [0.737095238095238 0.633333333333334]);
    % Remove Spike
    spikeRemovedPlot = subplot(2,1,2);
    hData2 = plot(x,spikeRemovedData(:,i));
    hXLabel2 = xlabel('Wavelength (nm)');
    % 	hTitle2 = title('Cosmic Rays removed');
    hYLabel2 = ylabel('Intensity');
    % Subtract Plot
    subtractionFigure = figure;
    subtractPlot = subplot(2,1,1);
    hData3 = plot(ramanShift,newsam(:,i));
    hXLabel3 = xlabel('Raman Shift (cm^{-1})');
    % 	hTitle3 = title('Subtracted SiC spectra');
    hYLabel3 = ylabel('Intensity');
    % Fit plot
    fitPlot = subplot(2,1,2);
    hData4 = plot(ramanShift,newsam(:,i),xi,lorentzianFit,xi,lorentzianFitG,xi,lorentzianFitD);
    hXLabel4 = xlabel('Raman Shift (cm^{-1})');
    axis([originalPlot,spikeRemovedPlot],[min(x) max(x) 0 inf])
    axis([subtractPlot,fitPlot],[min(ramanShift) max(ramanShift) 0 inf])
    %     hTitle4 = title('Experimental Data with Lorentzian Peak Fits');
    hYLabel4 = ylabel('Intensity');
    prettyPlotLoop(stepFigureSeparate)
end
printNow = 0;
if isequal(printNow,1)
    set(stepFigureSeparate, 'PaperPositionMode', 'auto');
    PathName = '/Users/Kevin/Documents/Google Drive/Linkoping/Master Thesis/Thesis/Figures/';
    FileName = 'raman_matlab_steps_separate';
    print(stepFigureSeparate, '-depsc', [PathName FileName])
end

%% Plot Contour
plotContour = 1;
if isequal(plotContour,1)
    %% Show contour plot
    if isempty(fwhm2D)
        disp('Fit Lorentzian first');
    else
        prompt = {'Enter matrix size:'};
        dlg_title = 'Number of points along one side';
        num_lines = 1;
        def =  {sprintf('%3d',floor(sqrt(length(fwhm2D))))};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        newanswer = cell2mat(answer);
        sizeOfRaman = str2double(newanswer);
        %% 2D peaks
        % FWHM(2D) = -45(1/N)+88 cm^-1 from Raman Spectra of Epitaxial Graphene on SiC and of Epitaxial Graphene Transferred to SiO2
        % FWHM(1-4 layers) = [43   65.5   73   76.75]
        rFWHM = [fwhm2D; fwhmG];
        peakP = [xi(maxIndex2D); xi(maxIndexG)];
        fwhm = [fwhm2D; fwhmG; xi(maxIndex2D); xi(maxIndexG)];
        titleD = {'2D FWHM of '; 'G FWHM of '; '2D Peak Position of '; 'G Peak Position of '};
        fileD = {'2DRamanPeaks'; 'GRamanPeaks'; '2DPeakPosition'; 'GPeakPosition'};
        layer1middleMatrix = [43; 20; 2743; 1607];
        layerPeakInputs = [-45./(1:4)+88; 0 0 0 0; 2744 2724 2711 2705; 1607 1585 1583 1578]; % 1, 2, 6, HOPG
        layerRangeMatrix = [10; 5; 5; 3];
        for i = 1:length(fwhm(:,1))
            z = fwhm(i,:);
            a = padarray(z,[0, sizeOfRaman^2-length(z)],'post');
            fwhmReshaped = reshape(a,[sizeOfRaman,sizeOfRaman]);
            %             if i == 1 % 2D FWHM is fit with parameters in layerPeakInputs
            %                 maxFWHM = 150;
            %                 layer1middle = layerPeakInputs(i,1);
            %                 layer2middle = layerPeakInputs(i,2);
            %                 layer3middle = layerPeakInputs(i,3);
            %                 hopgMiddle = layerPeakInputs(i,4);
            %                 layer1Max = (layer1middle+layer2middle)/2;
            %                 layer2Min = layer1Max;
            %                 layer2Max = (layer2middle+layer3middle)/2;
            %                 layer3Min = layer2Max;
            %                 layer3Max = (layer3middle+hopgMiddle)/2;
            %                 layer4Min = layer3Max;
            %                 percentZero = percentInRange(z,maxFWHM,maxFWHM*1000); % determine zero layers by large z instead of peak position
            %                 percentSingle = percentInRange(z,0,layer1Max); % peak is above halfway point between 1 and 2 layers
            %                 percentDouble = percentInRange(z,layer2Min,layer2Max);
            %                 percentTriple = percentInRange(z,layer3Min,layer3Max);
            %                 percenthopg = percentInRange(z,layer4Min,maxFWHM);
            %             elseif i == 2 % G FWHM is fit with user parameters
            %                 layer1middle = layer1middleMatrix(i);
            %                 layerRange = layerRangeMatrix(i)*2;
            %                 layer2middle = layer1middle+layerRange;
            %                 layer3middle = layer2middle+layerRange;
            %                 numberOfZeroLayers = length(z(z>layer3middle+layerRange/2 | z<layer1middle-layerRange/2));
            %                 numberOfSingleLayers = length(z(z<layer1middle+layerRange/2 & z>layer1middle-layerRange/2));
            %                 numberOf2Layers = length(z(z<layer2middle+layerRange/2 & z>layer2middle-layerRange/2));
            %                 numberOf3Layers = length(z(z<layer3middle+layerRange/2 & z>layer3middle-layerRange/2));
            %                 percentZero = numberOfZeroLayers/length(z);
            %                 percentSingle = numberOfSingleLayers/length(z);
            %                 percentDouble = numberOf2Layers/length(z);
            %                 percentTriple = numberOf3Layers/length(z);
            %                 percenthopg = 0;
            %             else % fitting positions of 2D and G peak
            %                 maxFWHM = 150;
            %                 layer1middle = layerPeakInputs(i,1);
            %                 layer2middle = layerPeakInputs(i,2);
            %                 layer3middle = layerPeakInputs(i,3);
            %                 hopgMiddle = layerPeakInputs(i,4);
            %                 numberOfZeroLayers = length(fwhm(fwhm(i-2,:) > maxFWHM)); % determine zero layers by large fwhm instead of peak position
            %                 numberOfSingleLayers = length(z(z > layer1Max & fwhm(i-2,:) < maxFWHM)); % peak is above halfway point between 1 and 2 layers
            %                 numberOf2Layers = length(z(z > layer2Max & z < layer1Max & fwhm(i-2,:) < maxFWHM));
            %                 numberOf3Layers = length(z(z > layer3Max & z < layer2Max & fwhm(i-2,:) < maxFWHM));
            %                 numberOfhopgLayers = length(z(z < layer3Max & fwhm(i-2,:) < maxFWHM));
            %                 percentZero = numberOfZeroLayers/length(z);
            %                 percentSingle = numberOfSingleLayers/length(z);
            %                 percentDouble = numberOf2Layers/length(z);
            %                 percentTriple = numberOf3Layers/length(z);
            %                 percenthopg = numberOfhopgLayers/length(z);
            %             end
            maxFWHM = 88;
            if i == 1 % 2D FWHM is fit with parameters in layerPeakInputs
                layer1middle = layerPeakInputs(i,1);
                layer2middle = layerPeakInputs(i,2);
                layer3middle = layerPeakInputs(i,3);
                hopgMiddle = layerPeakInputs(i,4);
                layer1Min = 0;
                layer1Max = (layer1middle+layer2middle)/2;
                layer2Min = layer1Max;
                layer2Max = (layer2middle+layer3middle)/2;
                layer3Min = layer2Max;
                layer3Max = (layer3middle+hopgMiddle)/2;
                layer4Min = layer3Max;
                percentZero = percentInRange(z,maxFWHM,maxFWHM*1000); % determine zero layers by large z instead of peak position
                percentSingle = percentInRange(z,0,layer1Max); % peak is above halfway point between 1 and 2 layers
                percentDouble = percentInRange(z,layer2Min,layer2Max);
                percentTriple = percentInRange(z,layer3Min,layer3Max);
                percenthopg = percentInRange(z,layer4Min,maxFWHM);
            elseif i == 2 % G FWHM is fit with user parameters
                layer1middle = layer1middleMatrix(i);
                layerRange = layerRangeMatrix(i)*2;
                layer2middle = layer1middle+layerRange;
                layer3middle = layer2middle+layerRange;
                layer1Max = (layer1middle+layer2middle)/2;
                layer2Min = layer1Max;
                layer2Max = (layer2middle+layer3middle)/2;
                layer3Min = layer2Max;
                layer3Max = (layer3middle+hopgMiddle)/2;
                layer4Min = layer3Max;
                layer4Max = 2*hopgMiddle-layer4Min;
                percentZero = percentInRange(z,maxFWHM,maxFWHM*1000); % determine zero layers by large z instead of peak position
                percentSingle = percentInRange(z,layer1Min,layer1Max); % peak is above halfway point between 1 and 2 layers
                percentDouble = percentInRange(z,layer2Min,layer2Max);
                percentTriple = percentInRange(z,layer3Min,layer3Max);
                percenthopg = percentInRange(z,layer4Min,layer4Max);
                [layer1Min layer1middle layer1Max; layer2Min layer2middle layer2Max;layer3Min layer3middle layer3Max;layer4Min hopgMiddle layer4Max]
            else % fitting positions of 2D and G peak
                layer1middle = layerPeakInputs(i,1);
                layer2middle = layerPeakInputs(i,2);
                layer3middle = layerPeakInputs(i,3);
                hopgMiddle = layerPeakInputs(i,4);
                layer1Max = (layer1middle+layer2middle)/2;
                layer1Min = 2*layer1middle-layer1Max;
                layer2Min = layer1Max;
                layer2Max = (layer2middle+layer3middle)/2;
                layer3Min = layer2Max;
                layer3Max = (layer3middle+hopgMiddle)/2;
                layer4Min = layer3Max;
                layer4Max = 2*hopgMiddle-layer4Min;
                percentZero = 0; % determine zero layers by large z instead of peak position
                percentSingle = percentInRange(z,layer1Min,layer1Max); % peak is above halfway point between 1 and 2 layers
                percentDouble = percentInRange(z,layer2Min,layer2Max);
                percentTriple = percentInRange(z,layer3Min,layer3Max);
                percenthopg = percentInRange(z,layer4Min,layer4Max);
            end
            name = sampleName;
            contourFigure = figure(2); % create new figure
            subplot(2,2,i) % first subplot
            contourf(fwhmReshaped,'EdgeColor', 'none');
            colorbar;
            colormap('Hot');
            hTitle = title(sprintf([titleD{i} name '\n0Layer: %.3g%%\n 1 Layer: %.3g%%\n2 Layers: %.3g%%\n3 Layers: %.3g%%\nHOPG: %.3g%%'],percentZero*100,percentSingle*100,percentDouble*100,percentTriple*100,percenthopg*100));
            set(hTitle,'FontSize',8,'FontName','Helvetica');
            axis('tight');
        end
        %         set(contourFigure,'Units','normalized','Position',[0.2891    0.0675    0.7109    0.8125]);
        
    end
end



