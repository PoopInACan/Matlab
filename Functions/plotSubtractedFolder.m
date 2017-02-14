function plotSubtractedFolder
close all force
dbstop if error
% spcFolder = '../../Documents/Google Drive/Linkoping/Master Thesis/Data/Raman/X939/Subtracted';
%% Load Folder or "mat" file
startingFolder = '../../Documents/Google Drive/Linkoping/Master Thesis/Data/Raman/';
loadFromSPC = questdlg('Plot from subtracted folder?','Plot from subtracted folder?','Subtracted','Mat','Text','Text');
switch loadFromSPC
    case 'Subtracted'
        spcFolder = uigetdir(startingFolder,['Pick Subtracted Folder with ".spc" files']);
        if isequal(spcFolder,0)
            disp('you didnt choose a folder');
            return;
        end
        subtractedFolder = fileparts(spcFolder);
        [~,sampleName] = fileparts(subtractedFolder);
        [xData,yData] = loadSPCfolder(spcFolder);
        putvar('xData','yData');
    case 'Mat'
        [file,path]  = uigetfile('./Mat and textfiles/*.mat');
        if isequal(file,0)
            disp('you didnt choose a mat file');
            return;
        end
        a = load([path file]);
        try
            yData = a.sam;
        end
        try
            yData = a.yData;
        end
        try
            sampleName = a.sampleName;
        end
        xData = repmat(a.x,[1,size(yData,2)]);
    case 'Text'
        [textFile,pathnamefile] = uigetfile('./*.txt',['Pick from text file']);
        if isequal(textFile,0)
            return;
        end
        yData = importdata([pathnamefile textFile]);
        xData = importdata('xAxis.txt');
        sampleName = textFile;
        
    otherwise
        disp('nothing chosen');
        return;
end
%% UI controls
numOfPoints = size(yData,2);
currentFigure = figure(6); clf;
set(currentFigure,'name','Graphene Raman Spectra', ...
    'NumberTitle','off', ...
    'Units','normalized', ...
    'Position', [0.15 0.15 0.55 0.75]);
sliderHandle = uicontrol('Style', 'slider',...
    'Units', 'normalized',...
    'Min',1,'Max',50,'Value',1,...
    'Callback', @sliderControlCallback,...
    'Position',[0.0375 0.95 0.90 0.0375]);
layerText = uicontrol('Style', 'edit',...
    'Units', 'normalized',...
    'String','All',...
    'Callback', @viewTheSpectraOfThisManyLayers,...
    'Position',[0.0375 0.01 0.30 0.0375]);
adjustSliderMax(numOfPoints);
%% Startup
[layerNumber,...
    layersPossible,...
    indLayers,...
    numOfLayers,...
    maximum,...
    maxIndex,...
    fwhm2D,...
    x0] = getIndexAndValuesOf2DFWHM(xData,yData);
for j = 1:numOfPoints
    ynorm = yData(:,j)
    [maximumG(j), maxIndex, fwhmG(j), x0_G(j)] = getLorentzianParameters([1550,1650],ynorm,xData(:,j));
end
ratio2DG = maximum./maximumG;
indOfRatio = find(~isnan(ratio2DG) & ~isinf(ratio2DG));
for j = layersPossible
    indOfLayers = indLayers(j,find(indLayers(j,:)));
    intersectionRatio = intersect(indOfLayers,indOfRatio);
    [avGFWHM(j), stdGFWHM(j)] = getAvStd(indLayers(j,find(indLayers(j,:))),fwhmG);
    [av2DFWHM(j), std2DFWHM(j)] = getAvStd(indLayers(j,find(indLayers(j,:))),fwhm2D);
    [avGPOS(j), stdGPOS(j)] = getAvStd(indLayers(j,find(indLayers(j,:))),x0_G);
    [av2DPOS(j), std2DPOS(j)] = getAvStd(indLayers(j,find(indLayers(j,:))), x0);
    [avIntRatio(j), stdIntRatio(j)] = getAvStd(intersectionRatio,ratio2DG);
end
aV = [avGFWHM;av2DFWHM;avGPOS;av2DPOS;avIntRatio];
stD = [stdGFWHM;std2DFWHM;stdGPOS;std2DPOS;stdIntRatio];
titleNames = {'G FWHM';'2D FWHM';'G POS';'2D POS';'Int. Ratio'};
indtoplot = find(layersPossible);
if max(layersPossible) > 88
    indtoplot = find(layersPossible < 88);
end
for i = 1:size(titleNames,1)
    figure(i);clf;
    errorbar(layersPossible(indtoplot),aV(i,layersPossible(indtoplot)),stD(i,layersPossible(indtoplot)),'o');
    %     axis([-inf 4.5 -inf inf])
    title(titleNames{i});
    prettyPlotLoop(figure(i),14,'yes');
end
%%
sliderControlCallback;
%% Functions
function sliderControlCallback(source,eventdata)
sliderfigure = figure(6);
sliderValueTemp = ceil(sliderHandle.Value);
if ~isequal(layerText.String,'All') && ~isempty(find(layersPossible==str2double(layerText.String), 1))
    lnum = str2double(layerText.String);
    sliderValue = indLayers(lnum,sliderValueTemp);
else
    sliderValue = sliderValueTemp;
end
nx939 = yData(:,sliderValue);
lorentzian = maximum(sliderValue)*(1/2*fwhm2D(sliderValue)).^2./( (xData(:,sliderValue)-x0(sliderValue)).^2 + (1/2*fwhm2D(sliderValue)).^2);
myData = plot(xData(:,sliderValue),nx939,xData(:,sliderValue),lorentzian);
title(['Sample: ' sampleName ...
    ' Spot: ' int2str(sliderValue)]);
[~,ind1] = min(abs(x0(sliderValue)-2*fwhm2D(sliderValue)-xData(:,sliderValue)));
[~,ind2] = min(abs(x0(sliderValue)+2*fwhm2D(sliderValue)-xData(:,sliderValue)));
sumOfError = 0;
for i = ind1:ind2
    diff1 = lorentzian(i)-nx939(i);
    sqdiff = diff1^2;
    sumOfError = sumOfError + sqdiff;
end
percError = sumOfError/sum(nx939(ind1:ind2))*100;
maxy = max(nx939(1000:end));
title(['Sample: ' sampleName ...
    ' Spot: ' int2str(sliderValue) sprintf(' pError: %g',percError)]);
axis([1150,3500,-.015,inf]);
%         axis([2600,2850,0,max(nx939(1000:end))*1.2]);

%         axis([1150,1750,-.05,max(nx939(200:500))*1.5]);
%         axis([2500,2900,0,max(nx939(1000:end))*1.2])
intensityRatio = maximum(sliderValue)/maximumG(sliderValue);
textFWHM = text(2640,.085,['FWHM: ' int2str(fwhm2D(sliderValue))]);
textInt = text(2640,.08,sprintf('2D/G: %.3f',intensityRatio));
textPercentFWHM = text(1900,.085,sprintf(['%g: \n'],1:max(layersPossible)));
textPercentFWHM = text(2000,.085,sprintf(['%g \n'],numOfLayers/length(fwhm2D)*100));
prettyPlotLoop(currentFigure);
%         putvar('nx939','lorentzian','sliderValue');
%         savfig=figure(10);clf;
%         plot(xData(:,sliderValue),nx939,'.',xData(:,sliderValue),lorentzian);
%         axis([2600,2850,0,max(nx939(1000:end))*1.2]);
%         textFWHM = text(2670,.082,['FWHM: ' int2str(fwhm2D(sliderValue))]);
%         legend('Data','Fit');
%         title('Asymmetric 2D peak: 4 layers');
%         ylabel('Intensity');
%         xlabel('Raman Shift (cm^{-1})');
%         prettyPlotLoop(savfig);
%         saveFigure(savfig,'asymmetricMultilayer');
end
function viewTheSpectraOfThisManyLayers(source,eventdata)
if not(isequal(layerText.String,'All')) && ~isempty(find(layersPossible==str2double(layerText.String), 1))
    numLayersToLookAt = round(str2double(source.String));
    amountOfValues = numOfLayers(numLayersToLookAt);
    adjustSliderMax(amountOfValues);
    sliderControlCallback;
else
    adjustSliderMax(numOfPoints);
end
end
function adjustSliderMax(max)
set(sliderHandle,...
    'Value',1,...
    'Max',max,...
    'SliderStep', [1/max , 1/max ]);
end
% a = who;
% ans=1;
% putvar(a{:});
% 	 av2DFWHM995  	= av2DFWHM 	;
% 	  av2DPOS995  	= av2DPOS   ;
% 	  avGFWHM995  	= avGFWHM   ;
% 	   avGPOS995  	= avGPOS    ;
% 	  stdGPOS995  	= stdGPOS   ;
% 	 std2DPOS995  	= std2DPOS 	;
% 	 stdGFWHM995  	= stdGFWHM 	;
%     std2DFWHM995 		= std2DFWHM	;
%    avIntRatio995      = avIntRatio;
%   stdIntRatio995      = stdIntRatio;
%   save('./Mat and text files/intRatios','avIntRatio995','stdIntRatio995','-append');
% clearvars -except ...
%     av2DFWHM995     ...
%      av2DPOS995      ...
%      avGFWHM995      ...
%       avGPOS995       ...
%      stdGPOS995      ...
%     std2DPOS995     ...
%     stdGFWHM995     ...
%    std2DFWHM995
% save('./Mat and text files/995average')
% putvar('av2DFWHM' ,'av2DPOS'  ,'avGFWHM'  ,'avGPOS'   ,'stdGPOS'  ,'std2DPOS' ,'stdGFWHM' ,'std2DFWHM')

end
