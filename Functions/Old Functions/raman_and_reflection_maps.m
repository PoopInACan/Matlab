function raman_and_reflection_maps
xaxisValue = 1;
refN = 3;
saveAlreadySubtractedRamanText = 'no';

%% Plot raman and reflection maps
% dbstop if error % Stop execution if an error occurs for debugging
mypath = mfilename('fullpath'); % get full path of this function
close all force % close all figures forcefully
try
    cd(fileparts(mypath)); % automatically change folder to this functions folder
end
pathToRamanMaps = '../../DataAnalysis/RamanTextFiles/';
addpath(genpath(cd));
fileNamePrefix = 'y*.txt';
thefig = figure(... % Create Figure, name it, position it
    'NumberTitle','off', ...
    'name','Reflection Mapping', ...
    'Units','normalized', ...
    'Position',[0.0153    0.0588    0.9766    0.8037]);
global x y yref yrefOriginal subtData theData yOriginal hand handlegrid yflat multiplyFactorY figure2D specialSample x_0 maximum fwhm numLayers layer0 layer1 layer2 layer3 layer4 ind0 ind1 ind2 ind3 ind4 NLayers
numSteps = 50;
theFiles = dir([pathToRamanMaps fileNamePrefix]);
fnames = {theFiles.name}.';
ind = ones(length(fnames),1);
% filestoread = {'y116','y930','y933','y18','y19','y10','y949','y10_xx20','y5_xx20','y949_xx20','y951_xx20','y999_xx20'};
[s,v] = listdlg('PromptString','Select files to load for Raman fitting:', ...
    'SelectionMode','multiple', ...
    'InitialValue',1, ...
    'ListString',fnames);
% s = 4;
filestoread = fnames(s)';
if isequal(v,0) % if cancel was pressed, close everything
    close all
    return;
else % else, read all files selected
    for i = 1:length(filestoread)
        ind11 = cellfun(@isempty, regexp(fnames, filestoread(i)));
        ind = ind11 & ind;
    end
end
theFiles = theFiles(~ind);
reflectionAxes = axes('Units', 'normalized',... % Create an axes to draw on
    'Position', [0.78    0.300    0.2    0.45], ...
    'Tag','axesForContour','PickableParts','all','ButtonDownFcn',@getMouseDownPosition);
ramanAxes = axes('Units', 'normalized', ... % Create an axes to draw on
    'Position', [0.0539    0.0600    0.5389    0.7300]);
pathToReflectionMaps = '../../Data/ReflectionMaps/';
addpath(genpath(pathToReflectionMaps)); % Add reflection maps folder to workspace
reflectionFileNamePrefix = 'ReflMap_*.txt';
theReflectionFiles = dir(fullfile(pathToReflectionMaps,reflectionFileNamePrefix)); % all the files in reflection maps folder
theReflectionFiles = {theReflectionFiles.name}.';
ind11 = cellfun(@isempty, regexp(theReflectionFiles, '\w*grid\w*'));
ind22 = cellfun(@isempty, regexp(theReflectionFiles, '\w*Dspot\w*'));
namehandle.fnames_subset = theReflectionFiles(ind11);
namehandle.gridpoints = theReflectionFiles(ind22);

%% Import names of files

totalFiles = length(theFiles);
hand(totalFiles).sampleName = [];
str = cell(1,totalFiles);
for i = 1:totalFiles
    str{i} = theFiles(i).name;
    hand(i).sampleName = theFiles(i).name;
end
hand(totalFiles).layerNumber 	= [];
hand(totalFiles).layersPossible = [];
hand(totalFiles).indLayers 		= [];
hand(totalFiles).numOfLayers 	= [];
hand(totalFiles).maximum_2D 	= [];
hand(totalFiles).maxIndex_2D 	= [];
hand(totalFiles).fwhm_2D 		= [];
hand(totalFiles).x0_2D 			= [];
hand(totalFiles).maximum_G  	= [];
hand(totalFiles).maxIndex_G  	= [];
hand(totalFiles).fwhm_G  		= [];
hand(totalFiles).x0_G  			= [];
hand(totalFiles).maximum_D  	= [];
hand(totalFiles).maxIndex_D  	= [];
hand(totalFiles).fwhm_D  		= [];
hand(totalFiles).x0_D  			= [];
hand(totalFiles).maximum_Dp  	= [];
hand(totalFiles).maxIndex_Dp  	= [];
hand(totalFiles).fwhm_Dp  		= [];
hand(totalFiles).x0_Dp  		= [];
hand(totalFiles).maximum_DDp  	= [];
hand(totalFiles).maxIndex_DDp  	= [];
hand(totalFiles).fwhm_DDp  		= [];
hand(totalFiles).x0_DDp  		= [];

%% Import All Data from theFiles to theData
% loopLength = 5;
loopLength = length(theFiles);
theData = cell(1,loopLength);
h = waitbar(0,'Initializing waitbar...');
for i = 1:loopLength
    theData{i} = importfile([pathToRamanMaps str{i}]);
    h = waitbar(i/loopLength, h, ['Loading ' str{i}]);
end
close(h);
refFiles = {'../../DataAnalysis/RamanTextFiles/yRef6H_20151008.txt', ... % 1
    '../../DataAnalysis/RamanTextFiles/yref.txt', ... % 2
    '../../DataAnalysis/RamanTextFiles/y6HRef.txt',... % 3
    '../../DataAnalysis/RamanTextFiles/y3491134Href.txt', ... % 4
    '../../DataAnalysis/RamanTextFiles/y4Href160628.txt', ... % 5 
    '../../DataAnalysis/RamanTextFiles/yRef_X800.txt', ... % 6
    '../../DataAnalysis/RamanTextFiles/yRef_X823.txt', ... % 7 
    '../../DataAnalysis/RamanTextFiles/yRef_X829.txt', ... % 8
    '../../DataAnalysis/RamanTextFiles/yRef_X834.txt', ... % 9
    '../../DataAnalysis/RamanTextFiles/yRef_X839.txt', ... % 10
    };
yref =  importfile(refFiles{refN}); % import reference
yrefOriginal = yref;

%% Create UI Controls
showOriginal = uicontrol('Style','checkbox',...
    'Tag', 'showOriginalTag',...
    'String', 'Show Original?',...
    'Value',0,...
    'Units', 'Normalized',...
    'Position', [0.6090    0.9571    0.1086    0.0476]);

showLorentzian = uicontrol('Style','checkbox',...
    'Tag', 'showLorentzian',...
    'String', 'Show Lorentzian?',...
    'Callback', @showLorentzianCallback,...
    'Value',1,...
    'Units', 'Normalized',...
    'Position', [0.6090    0.9071    0.1086    0.0476]);

saveAutomatically = uicontrol('Style','checkbox',...
    'Tag', 'saveAutomaticallyTag',...
    'String', 'Autosave Plots?',...
    'Value',0,...
    'Units', 'Normalized',...
    'Position', [0.6090    0.8571    0.1086    0.0476]);

plotIntensityOfDefect = uicontrol('Style','pushbutton',...
    'Tag', 'plotIntensityOfDefectTag',...
    'String', 'Plot defect ratio',...
    'Callback', @defectPeaks,...
    'Units', 'Normalized',...
    'Position', [0.6082    0.7984    0.1386    0.0476]);

save2DPlot = uicontrol('Style','pushbutton',...
    'Tag', 'save2DPlotWithLorentzian',...
    'String', 'Save 2D',...
    'Callback', @plotForSaving,...
    'Units', 'Normalized',...
    'Position', [0.6082    0.7430    0.1386    0.0476]);

saveToWorkspaceButton = uicontrol('Style','pushbutton',...
    'Tag', 'saveToWorkSpaceTag',...
    'String', 'Save to workspace',...
    'Callback', @saveToWorkspaceCallback,...
    'Units', 'Normalized',...
    'Position', [0.6082    0.6876    0.1386    0.0476]);

plotContourButton = uicontrol('Style','pushbutton',...
    'Tag', 'plotContourTag',...
    'String', 'Plot Contour 2D FWHM',...
    'Callback', @plotRamanContourForPresentation,...
    'Units', 'Normalized',...
    'Position', [0.6082    0.6323    0.1386    0.0476]);

plotContourG = uicontrol('Style','pushbutton',...
    'Tag', 'plotContourG',...
    'String', 'Plot Contour G FWHM',...
    'Callback', @plotRamanContourVariable,...
    'Units', 'Normalized',...
    'Position', [0.6082    0.5769    0.1386    0.0476]);

plotContourD = uicontrol('Style','pushbutton',...
    'Tag', 'plotContourD',...
    'String', 'Plot Contour D FWHM',...
    'Callback', @plotRamanContourVariable,...
    'Units', 'Normalized',...
    'Position', [0.6082    0.5215    0.1386    0.0476]);

plotContourDDp = uicontrol('Style','pushbutton',...
    'Tag', 'plotContourDDp',...
    'String', 'Plot Contour D+D'' FWHM',...
    'Callback', @plotRamanContourVariable,...
    'Units', 'Normalized',...
    'Position', [0.6082    0.4661    0.1386    0.0476]);

plotContourPosition2D = uicontrol('Style','pushbutton',...
    'Tag', 'plotContourx02D',...
    'String', 'Plot Contour 2D Pos.',...
    'Callback', @plotRamanContourVariable,...
    'Units', 'Normalized',...
    'Position', [0.6082    0.4561    0.1386    0.0476]);

plotContourPositionG = uicontrol('Style','pushbutton',...
    'Tag', 'plotContourx0G',...
    'String', 'Plot Contour G Pos.',...
    'Callback', @plotRamanContourVariable,...
    'Units', 'Normalized',...
    'Position', [0.6082    0.4461    0.1386    0.0476]);

plotContourPositionD = uicontrol('Style','pushbutton',...
    'Tag', 'plotContourx0D',...
    'String', 'Plot Contour D Pos.',...
    'Callback', @plotRamanContourVariable,...
    'Units', 'Normalized',...
    'Position', [0.6082    0.3    0.1386    0.0476]);

align([plotIntensityOfDefect,save2DPlot,plotContourPositionD,plotContourPositionG,...
    plotContourPosition2D,plotContourD,plotContourDDp,plotContourG,...
    plotContourButton,saveToWorkspaceButton],'Left','Fixed',5);

popupSampleNameButton = uicontrol('Style', 'popupmenu',...
    'Tag', 'popupTag',...
    'String', str,...
    'Value',1,...
    'units', 'normalized',...
    'Position', [0.1    0.87    0.1    0.1008],...
    'Callback', @loadYValues);

popupXAxisButton = uicontrol('Style', 'popupmenu',...
    'Tag', 'popupXAxisTag',...
    'String', {'xAxis', 'xAxis2'},...
    'Value',xaxisValue,...
    'units', 'normalized',...
    'Position', [0.1    0.84    0.1    0.1008],...
    'Callback', @loadXValues);

popupReferenceNameButton = uicontrol('Style', 'popupmenu',...
    'Tag', 'popupRefButtonTag',...
    'String', refFiles,...
    'Value',refN,...
    'units', 'normalized',...
    'Position', [0.1    0.81    0.1    0.1008],...
    'Callback', @loadYValues);

sliderHandle = uicontrol('Style', 'slider',...
    'Units', 'normalized',...
    'Tag','slidertag',...
    'Min',1,...
    'Max',numSteps,...
    'Value',1,...
    'SliderStep',[1/(numSteps-1) , 1/(numSteps-1) ],...
    'Callback', @sliderControlCallback,...
    'Position',[0.2276    0.9200    0.3577    0.0568]);

tableOfValues = uitable(...
    'Tag', 'tabletag',...
    'Units', 'normalized',...
    'Data',[1;2;3;4;5;6;7],...
    'ColumnName','Value',...
    'RowName',{'Ld','nd','Id/Ig','I2d/Ig','Id/Id''','Id/Id+d''','Id''/Id+d'''},...
    'Position',[0.6089    0.0530    0.1432    0.2350]);

reflectionSelection = uicontrol('Style','popupmenu',...
    'Units','normalized',...
    'String',namehandle.fnames_subset,...
    'Callback',@loadReflectionMap,...
    'Position',[0.78    0.1    0.2031    0.1008]);

carbonBufferLayerTextControl = uicontrol('Style','edit',...
    'Tag','carbonBufferLayerTag',...
    'Units','normalized',...
    'String','645',...
    'Callback',@loadReflectionMap,...
    'Position',[0.78    0.05    0.05    0.05]);

rangeOfBufferLayer = uicontrol('Style','edit',...
    'Tag','carbonBufferLayerRange',...
    'Units','normalized',...
    'String','5.4825',...
    'Callback',@loadReflectionMap,...
    'Position',[0.85    0.05    0.05    0.05]);

useMyControlledBufferValuesCheckbox = uicontrol('Style','checkbox',...
    'Tag', 'controlBufferCheckbox',...
    'String', 'Use saved buffer values',...
    'Callback', @enableDisableBufferTextBox,...
    'Value',0,...
    'Units', 'Normalized',...
    'Position', [0.6590    0.9571    0.1086    0.0476]);

set(popupSampleNameButton,'Units', 'pixels');
positionOfSampleNameButton = get(popupSampleNameButton,'Position');
set(popupSampleNameButton,'Units', 'normalized');

positionOfSampleNameButton(1) = positionOfSampleNameButton(1) - 100;
positionOfSampleNameButton(3) = positionOfSampleNameButton(3) - 100;
positionOfSampleNameButton(4) = 97;


positionOfXAxisText = positionOfSampleNameButton;
positionOfXAxisText(2) = positionOfXAxisText(2) - 30;
positionOfYRefText = positionOfSampleNameButton;
positionOfYRefText(2) = positionOfXAxisText(2) - 30;


popupSampleNameText = uicontrol('Style', 'text', ...
    'String', 'Sample Name:', ...
    'HorizontalAlignment', 'left', ...
    'units', 'pixels', ...
    'Position', positionOfSampleNameButton);

popupXAxisText = uicontrol('Style', 'text', ...
    'String', 'X Axis:', ...
    'HorizontalAlignment', 'left', ...
    'units', 'pixels', ...
    'Position', positionOfXAxisText);

popupYRefText = uicontrol('Style', 'text', ...
    'String', 'Reference SiC:', ...
    'HorizontalAlignment', 'left', ...
    'units', 'pixels', ...
    'Position', positionOfYRefText);

set([popupSampleNameText , popupXAxisText , popupYRefText],'Units','normalized');

loadYValues(popupSampleNameButton);
% putvar('thefig','tableOfValues','hand','theFiles');

%% Functions

    function loadYValues(source,eventdata)
        nameOfSample = strrep(popupSampleNameButton.String{popupSampleNameButton.Value},'y','');
        nameOfSample = strrep(nameOfSample,'.txt','');
        if isequal(nameOfSample,'461') || isequal(nameOfSample,'641') || isequal(nameOfSample,'642') || ...
                isequal(nameOfSample,'800') || isequal(nameOfSample,'823') ||...
                isequal(nameOfSample,'826') || isequal(nameOfSample,'829') ||...
                isequal(nameOfSample,'839') || isequal(nameOfSample,'841') ||...
                isequal(nameOfSample,'852') || isequal(nameOfSample,'841')
            specialSample = 1;
        else
            specialSample = 0;
        end
        popupSampleNameButton.Enable = 'off'; pause(0.1);
        y =  theData{popupSampleNameButton.Value}; % all data is in theData
        yrefOriginal = importfile(popupReferenceNameButton.String{popupReferenceNameButton.Value});
        adjustSliderStep(y);
        loadXValues(source);
        [y,multiplyFactorY] = doAllForYValues(y);
        showLorentzianCallback(source);
        plotValues;
        popupSampleNameButton.Enable = 'on';
    end

    function [yReady,multiplyFactor ]= doAllForYValues(yReady)
        try
            yref = mean(yrefOriginal,2); % Take average of reference
            yref = filterSpikesFromData(yref);
            [yref, yReady] = shiftReference(yReady,yref);
            yflat = flattenData(yReady);
            [yref,multiplyFactor] = multiplyHeightOfReference(yflat,yref);
            subtData = subtractRefFromData(yflat,yref);
            yReady = filterSpikesFromData(subtData);
            %             yReady = flipud(yReady);
        catch ME
            ME.getReport
            disp(ME.stack(1));
            disp(ME.message )
            putvar('ME');
        end
    end

    function plotForSaving(source,eventdata)
        % plot original and intercalated
        %         sf = figure(10);clf;
        %         set(sf,'Units','normalized','Position',[.2805 0.3175 0.4555 0.5537]);
        %         pv = popupMenuButton.Value;
        %         val = ceil(sliderHandle.Value);
        %         yInt = importfile('./Original Raman Data/y19.txt'); % import intercalated sample
        %         [yInt,mFactorInt] = doAllForYValues(yInt);
        %         r = 10:1900;
        %         mF = multiplyFactorY(val)/mFactorInt(1);
        %         tn = 2;
        %         yIntvar = yInt(r,tn)*mF + 2700;
        %         yvar = y(r,val);
        %         xvar = x(r);
        %         [ ...
        %             layerNumber,  ...
        %             layersPossible,  ...
        %             indLayers,  ...
        %             numOfLayers,  ...
        %             maximum_2D,  ...
        %             maxIndex_2D,  ...
        %             fwhm_2D,  ...
        %             x0_2D] = getIndexAndValuesOf2DFWHM(x,yInt);
        %         LorFun = @(max2D,fwhm2D,x02D) max2D*(1/2*fwhm2D).^2./( (xvar-x02D).^2 + (1/2*fwhm2D)^2);
        %         lorInt = LorFun(maximum_2D(tn),fwhm_2D(tn),x0_2D(tn));
        %         plot(xvar,yvar,'o',xvar,yIntvar,'o')
        %         legendString = {'Ar grown','H intercalation'};
        %         legend(legendString);
        %         axis('tight');
        %         xmin = 1700;
        %         ymax = 2000;
        %         text(xmin*1.01 ,4500, ...
        %             sprintf(['2D Peak: %.1f cm^{-1}\n2D FWHM: %.1f cm^{-1}'],...
        %             x0_2D(tn) ,fwhm_2D(tn)));
        %         text(xmin*1.01 ,ymax*.75, ...
        %             sprintf(['2D Peak: %.1f cm^{-1}\n2D FWHM: %.1f cm^{-1}'],...
        %             hand(pv).x0_2D(val) ,hand(pv).fwhm_2D(val)));
        % %         axis([-inf inf -inf inf])
        % %         axis([xmin xmax ymin ymax]);
        % %         annotation(sf,'textarrow',[0.277397260273973 0.227739726027397],...
        % %             [0.877103837471783 0.873589164785553],'String',{'D peak'},'FontSize',14);
        % %         annotation(sf,'textarrow',[0.325342465753425 0.294520547945205],...
        % %             [0.644598194130925 0.55530474040632],'String',{'G peak'},'FontSize',14);
        % %         annotation(sf,'textarrow',[0.648972602739726 0.613013698630137],...
        % %             [0.606223476297968 0.528216704288939],'String',{'2D peak'},'FontSize',14);
        %
        %         xlabel('Raman Shift (cm^{-1})');
        %         ylabel('Intensity');
        %         prettyPlotLoop(sf);
        %         putvar('yvar','yIntvar','xvar','sf','yInt');
        %         figure(1);
        %         saveFigure(figure(10),'hIntercalation');
        % plot growth but not intercalation
        sf2 = figure(11);
        clf;
        set(sf2,...
            'Units','normalized',...
            'Position',[.2805 0.3175 0.4555 0.5537]);
        pv = popupSampleNameButton.Value;
        val = ceil(sliderHandle.Value);
        %         yInt = importfile('./Original Raman Data/y19.txt'); % import intercalated sample
        %         [yInt,mFactorInt] = doAllForYValues(yInt);
        r = 1:length(x);
        %         mF = multiplyFactorY(val)/mFactorInt(1);
        tn = 2;
        %         yIntvar = yInt(r,tn)*mF + 2700;
        yvar = y(r,val);
        xvar = x(r);
        %         [ ...
        %             layerNumber,  ...
        %             layersPossible,  ...
        %             indLayers,  ...
        %             numOfLayers,  ...
        %             maximum_2D,  ...
        %             maxIndex_2D,  ...
        %             fwhm_2D,  ...
        %             x0_2D] = getIndexAndValuesOf2DFWHM(x,yInt);
        %         LorFun = @(max2D,fwhm2D,x02D) max2D*(1/2*fwhm2D).^2./( (xvar-x02D).^2 + (1/2*fwhm2D)^2);
        %         lorInt = LorFun(maximum_2D(tn),fwhm_2D(tn),x0_2D(tn));
        linetype = '-';
        plot(xvar,yvar,linetype)
        %         legendString = {'Intercalation'};
        %         legend(legendString);
        axis('tight');
        xmin = 1700;
        ymax = 2000;
        %         text(xmin*1.01 ,4500, ...
        %             sprintf(['2D Peak: %.1f cm^{-1}\n2D FWHM: %.1f cm^{-1}'],...
        %             x0_2D(tn) ,fwhm_2D(tn)));
        text(xmin*1.01 ,ymax*.75, ...
            sprintf(['2D Peak: %.1f cm^{-1}\n2D FWHM: %.1f cm^{-1}'],...
            hand(pv).x0_2D(val) ,hand(pv).fwhm_2D(val)));
        %         axis([-inf inf -inf inf])
        %         axis([xmin xmax ymin ymax]);
        %         annotation(sf,'textarrow',[0.277397260273973 0.227739726027397],...
        %             [0.877103837471783 0.873589164785553],'String',{'D peak'},'FontSize',14);
        %         annotation(sf,'textarrow',[0.325342465753425 0.294520547945205],...
        %             [0.644598194130925 0.55530474040632],'String',{'G peak'},'FontSize',14);
        %         annotation(sf,'textarrow',[0.648972602739726 0.613013698630137],...
        %             [0.606223476297968 0.528216704288939],'String',{'2D peak'},'FontSize',14);
        
        xlabel('Raman Shift (cm^{-1})');
        ylabel('Intensity');
        prettyPlotLoop(sf2,14,'no')
        save('textfile','xvar','yvar','-append');
        %         putvar('yvar','yIntvar','xvar','sf','yInt');
        
        figure(1);
        saveFileName = strrep(hand(pv).sampleName,'.txt','Raman');
        if isequal(saveAutomatically.Value,1)
            saveFigure(figure(11),saveFileName,'-depsc');
        end
    end

    function loadXValues(source,eventdata)
%         if isequal(source.Tag,'popupXAxisTag')
            selectedValue = popupXAxisButton.String{popupXAxisButton.Value};
            x = importdata(['../../DataAnalysis/RamanTextFiles/' selectedValue '.txt']);
%         else
%             if specialSample
%                 x = importdata('../../DataAnalysis/RamanTextFiles/xAxis2.txt');
%             else
%                 x = importdata('../../DataAnalysis/RamanTextFiles/xAxis.txt');
%             end
%         end
        x = AngtoWavenumbers(5318,x);
    end

    function plotValues
        ramanAxes;
        pv = popupSampleNameButton.Value;
        val = ceil(sliderHandle.Value);
        r = 1:length(x);
        if showLorentzian.Value % Determine if lorentzians need to be plotted
            if specialSample % Determine which lorentzians to compute
                lor2d = hand(pv).maximum_2D(val)*(1/2*hand(pv).fwhm_2D(val)).^2./( (x-hand(pv).x0_2D(val)-1).^2 + (1/2*hand(pv).fwhm_2D(val))^2);
                lorG = hand(pv).maximum_G(val)*(1/2*hand(pv).fwhm_G(val)).^2./( (x-hand(pv).x0_G(val)-1).^2 + (1/2*hand(pv).fwhm_G(val))^2);
            else
                lor2d = hand(pv).maximum_2D(val)*(1/2*hand(pv).fwhm_2D(val)).^2./( (x-hand(pv).x0_2D(val)-1).^2 + (1/2*hand(pv).fwhm_2D(val))^2);
                lorG = hand(pv).maximum_G(val)*(1/2*hand(pv).fwhm_G(val)).^2./( (x-hand(pv).x0_G(val)-1).^2 + (1/2*hand(pv).fwhm_G(val))^2);
                lorDp = hand(pv).maximum_D(val)*(1/2*hand(pv).fwhm_D(val)).^2./( (x-hand(pv).x0_D(val)-1).^2 + (1/2*hand(pv).fwhm_D(val))^2);
                lorD = hand(pv).maximum_Dp(val)*(1/2*hand(pv).fwhm_Dp(val)).^2./( (x-hand(pv).x0_Dp(val)-1).^2 + (1/2*hand(pv).fwhm_Dp(val))^2);
                lorDDp = hand(pv).maximum_DDp(val)*(1/2*hand(pv).fwhm_DDp(val)).^2./( (x-hand(pv).x0_DDp(val)-1).^2 + (1/2*hand(pv).fwhm_DDp(val))^2);
            end
        end
        switch showOriginal.Value % Determine if you need to show original plots
            case 1 % If yes
                if isequal(showLorentzian.Value,1) % and if need to show lorentzians
                    if specialSample % 
                        yOriginalFilter = medfilt1(yflat(:,val),10);
                        plot(ramanAxes,x(r),y(r,val),x(r),yOriginalFilter(r),x(r),lor2d(r),x(r),lorG(r))
                        legendString = {'Subtracted','Original','2D Fit','G Fit'};
                        axis('tight');
                    else
                        yOriginalFilter = medfilt1(yflat(:,val),10);
                        plot(ramanAxes,x(r),y(r,val),x(r),yOriginalFilter(r),x(r),lor2d(r),x(r),lorG(r),x(r),lorD(r),x(r),lorDp(r),x(r),lorDDp(r))
                        legendString = {'Subtracted','Original','2D Fit','G Fit','D Fit','D''','D+D'' Fit'};
                        axis('tight');
                    end
                else
                    plot(ramanAxes,x(r),y(r,val))
                end
            case 0
                if isequal(showLorentzian.Value,1)
                    if specialSample
                        plot(ramanAxes,x(r),y(r,val),x(r),lor2d(r),x(r),lorG(r)); % ,xBuffer,yBuffer*15000,xOxide,yOxide*15000
                        xlim([-inf inf]);
                        legendString = {'Subtracted','2D Fit','G Fit','D Fit','D''','D+D'' Fit'};
                    else
                        plot(ramanAxes,x(r),y(r,val),x(r),lor2d(r),x(r),lorG(r),x(r),lorD(r),x(r),lorDp(r),x(r),lorDDp(r)); % ,xBuffer,yBuffer*15000,xOxide,yOxide*15000
%                         xlim([500 4000]);
                        axis('tight');
                        ylim([-inf,max(y(r,val))*1.1]);
                        legendString = {'Subtracted','2D Fit','G Fit','D Fit','D''','D+D'' Fit'};
                    end
                else
                    plot(ramanAxes,x(r),y(r,val))
                end
        end
        
        try
            IdIg = hand(pv).maximum_D(val)/hand(pv).maximum_G(val);
            IdIdprime = hand(pv).maximum_D(val)/hand(pv).maximum_Dp(val);
            IdIdIdprime = hand(pv).maximum_D(val)/hand(pv).maximum_DDp(val);
            IdprimeIdIdprime = hand(pv).maximum_Dp(val)/hand(pv).maximum_DDp(val);
            Ld = sqrt(1.8*1e-9*531.8^4*(IdIg)^-1);
            nd = 1.8*1e22/(531.8^4) * IdIg;
            %% text about info of current raman spectrum
            tLd = text(1,1,sprintf([...
                'L_d: %.2f nm\n' ...
                'n_d: %.3d\n' ...
                'I_{D}/I_{G}: %.2f\n' ...
                'I_{2D}/I_{G}: %.2f\n' ...
                'I_{D}/I_{D''}: %.2f\n' ...
                'I_{D}/I_{D+D''}: %.2f\n' ...
                'I_{D''}/I_{D+D''}: %.2f\n' ...
                '\nLayer Distribution'], ...
                Ld, nd, IdIg, hand(pv).maximum_2D(val)/hand(pv).maximum_G(val), IdIdprime, IdIdIdprime, IdprimeIdIdprime ));
            set(tLd,'Units','normalized','Position',[.8,.83,0],'Parent',ramanAxes);
            set(tableOfValues,'Data',[Ld; nd; IdIg; hand(pv).maximum_2D(val)/hand(pv).maximum_G(val); IdIdprime; IdIdIdprime; IdprimeIdIdprime])
            %% FWHM and peak position text on graph
            thevalues = [ ...
                hand(pv).x0_2D(val)     ,hand(pv).fwhm_2D(val),     hand(pv).maximum_2D(val); ...
                hand(pv).x0_G(val)      ,hand(pv).fwhm_G(val),  hand(pv).maximum_G(val); ...
                hand(pv).x0_D(val)      ,hand(pv).fwhm_D(val),  hand(pv).maximum_D(val); ...
                hand(pv).x0_Dp(val)     ,hand(pv).fwhm_Dp(val), hand(pv).maximum_Dp(val); ...
                hand(pv).x0_DDp(val)    ,hand(pv).fwhm_DDp(val), hand(pv).maximum_DDp(val)];
            peakname = {'2D' 'G' 'D' 'D''' 'D+D'''};
            for k = 1:5
                if isequal(thevalues(k,2),200) % if the fwhm = 200, then the peak doesn't exist because 200 is just a placeholder
                else
                    t2dfwhm = text(1,1, ...
                        sprintf(['\\Delta\\omega_{' peakname{k} '}: %.1f cm^{-1}\n\\Gamma_{' peakname{k} '}: %.1f cm^{-1}'],...
                        thevalues(k,1) , thevalues(k,2)));
                    set(t2dfwhm,'Parent',ramanAxes, 'Position',[thevalues(k,1)+100,thevalues(k,3),0]);
                end
            end
            %% Set percent text
            perc = round(hand(pv).numOfLayers/sum(hand(pv).numOfLayers)*100,2);
            perc(perc==0) = [];
            tlength = length(perc);
            if tlength >= 4
                tlength = 4;
            end
            for ni = 1:tlength
                t1perc = text(1,1, ...
                    sprintf('%g: %.1f\n',...
                    hand(pv).layersPossible(ni) ,perc(ni)));
                set(t1perc,'Units','normalized','Position',[.8,.665-.03*ni,0],'Parent',ramanAxes);
            end
            indexaMonolayer 	= find(NLayers<1.5); % monolayer according to fwhm
            indexbBilayer 		= find(NLayers<2.5 & NLayers>=1.5); % bilayer according to fwhm
            indexcTrilayer 		= find(NLayers<3.5 & NLayers>=2.5); % bilayer according to fwhm
            indexdQuadOrMore 	= find(NLayers >= 3.5); % 4 or more layers
            percMono = length(indexaMonolayer)/length(NLayers);
            percBi = length(indexbBilayer)/length(NLayers);
            percTri = length(indexcTrilayer)/length(NLayers);
            percQuad = length(indexdQuadOrMore)/length(NLayers);
            percFor2D = 100*[percMono,percBi,percTri,percQuad];
            layers = [layer1,layer2,layer3,layer4];
            text1 = text(1,1,'According to lorentzian shape');
            set(text1,'Units','normalized','Position',[.8,.525,0],'Parent',ramanAxes);
            for ni = 1:4 % print out lorentzian shape percents
                t1perc = text(1,1, ...
                    sprintf('%g: %.1f\n',...
                    ni ,layers(ni)));
                set(t1perc,'Units','normalized','Position',[.8,.515-.03*ni,0],'Parent',ramanAxes);
            end
            text2 = text(1,1,'According to 2D FWHM of peakFit');
            set(text2,'Units','normalized','Position',[.8,.375,0],'Parent',ramanAxes);
            for ni = 1:4 % print out percents according to 2D fwhm percents from peakfit
                t1perc = text(1,1, ...
                    sprintf('%g: %.1f\n',...
                    ni ,percFor2D(ni)));
                set(t1perc,'Units','normalized','Position',[.8,.355-.03*ni,0],'Parent',ramanAxes);
            end
            title(ramanAxes,sprintf(['%3g/%3g my FWHM: %.2g, peakfit FWHM: %.2g, 2D Shape: %.2g'], ...
                val,numSteps,hand(pv).layerNumber(val),NLayers(val),numLayers(val)));
            text3 = text(1,1,sprintf('%.1f',fwhm(val)));
            set(text3,'Units','normalized','Position',[.5,.5,0],'Parent',ramanAxes);
        catch ME
        end
        prettyPlotLoop(gcf,14,'show y axis');
%         fwhm2d = hand(pv).fwhm_2D;
        indLayersMine = hand(pv).indLayers;
        layer1Mine = indLayersMine(1,:);
        layer2Mine = indLayersMine(2,:);
        if isequal(size(indLayersMine,1),2)
            layer3Mine = zeros(size(indLayersMine(2,:)));
            layer4Mine = zeros(size(indLayersMine(2,:)));
        elseif isequal(size(indLayersMine,1),3)
            layer3Mine = indLayersMine(3,:);
            layer4Mine = zeros(size(indLayersMine(3,:)));
        elseif size(indLayersMine,1)>=4
            layer3Mine = indLayersMine(3,:);
            layer4Mine = indLayersMine(4,:);
        end
        layer1Mine(layer1Mine==0)=[];
        layer2Mine(layer2Mine==0)=[];
        layer3Mine(layer3Mine==0)=[];
        layer4Mine(layer4Mine==0)=[];
        fwhmMine = hand(pv).fwhm_2D;
        putvar('indexaMonolayer', 'indexbBilayer', 'indexcTrilayer', 'indexdQuadOrMore','ind1','ind2','ind3','ind4','layer1Mine','layer2Mine','layer3Mine','layer4Mine','fwhm','fwhmMine');
        popupSampleNameButton.Enable = 'on';
        if isequal(saveAlreadySubtractedRamanText,'yes')
            sampleName = strrep(popupSampleNameButton.String{popupSampleNameButton.Value},'y','');
            sampleName = strrep(sampleName,'.txt','');
            textfilenamey = ['../../DataAnalysis/RamanAlreadySubtractedFiles/x' sampleName '_yValues.txt'];
            %     save(textfilenamex, 'xData', '-ASCII')
            save(textfilenamey, 'y', '-ASCII')
            textfilenamex = ['../../DataAnalysis/RamanAlreadySubtractedFiles/x' sampleName '_xValues.txt'];
            %     save(textfilenamex, 'xData', '-ASCII')
            save(textfilenamex, 'x', '-ASCII')
        end
    end

    function [yref,data] = shiftReference(data,yref)
        tot = length(yref);
        yref = yref(tot:-1:1); % flips order of numbers
        data = data(tot:-1:1,:);
%         xnew = x;
%         yref = interp1(x,yref,xnew);
%         data = interp1(x,data,xnew);
%         x = xnew;
                
%         
        if specialSample
            gmax = find(x>1532 & x<1570);
        else
            n = find( x > 1050 );
            n = abs(length(n)-length(yref)); % take off first spike since it is a peak we want to ignore
            yref = yref(n:end);
            data = data(n:end,:);
            x = x(n:end);
            gmax = find(x>1450 & x<1600);
        end
        data = filterSpikesFromData(data);
        [~, index_yref] = max(yref(gmax));
        [~, index_y] = max(data(gmax,:));
        shiftnumber = index_y - index_yref;
%         repmat(yref,[size(data,2),1])
        yref = circshift(repmat(yref,[1,size(data,2)]),shiftnumber);
        yref = yref(1:end-max(abs(shiftnumber)),:);
        data = data(1:end-max(abs(shiftnumber)),:);
        x = x(1:end-max(abs(shiftnumber)));
    end

    function data = flattenData(data)
        flatIndex = find(x>2140 & x<2400);
        flatIndex2 = find(x > 2800 & x < 3686);
        flatIndexMonolayer = find(x > 3000 & x < 3200);
        flatIndexMonolayer1 = find(x > 3369 & x < 3686);
        % yref and data flatten
        sigmaref = ones(length(yref([flatIndex' flatIndex2'],1)),1);
        xfitref = x([flatIndex' flatIndex2']);
        sigmadata = ones(length(data([flatIndex' flatIndexMonolayer1'],1)),1);
        xfitdata = x([flatIndex' flatIndexMonolayer1']);
        filteredData = medfilt1(data,70);
        yref_with_subtraction = ones(size(yref));
        data_with_subtraction = yref_with_subtraction;
        yfitref = medfilt1(yref([flatIndex' flatIndex2'],1),70);
        [a_fitref, ~, ~, ~] = linreg(xfitref,yfitref,sigmaref);
        yyref = a_fitref(1) + a_fitref(2)*x;
        yref_with_subtraction = yref - repmat(yyref,[1,size(data,2)]);
        yydata = zeros(size(data));
        for k = 1:size(data,2) %[498 565 1275 1279] %
            yfitdata = filteredData([flatIndex' flatIndexMonolayer1'],k);
            [a_fitdata, ~, ~, ~] = linreg(xfitdata',yfitdata', sigmadata');
            yydata(:,k) = a_fitdata(1) + a_fitdata(2)*x;
            data_with_subtraction(:,k) = data(:,k) - yydata(:,k);
        end
        data = data_with_subtraction;
        yref = yref_with_subtraction;
    end

    function [adjref, multiplyFactor] = multiplyHeightOfReference(data,yref)
        fitIndex = find(x > 1700 & x < 2470); % this area should be the same on
        %         both graphs...there is only a SiC signal here
        % Fit with a constant
        A = [yref(fitIndex,:)  ones(size(yref(fitIndex,:)))];
        b = data(fitIndex,:);
        xsolution = A\b;
        adjref = [yref ones(size(yref))]*xsolution;
        multiplyFactor = mean(mean(xsolution));
%         putvar('xsolution','adjref','x','yref','data');
        return;
    end

    function subtractedData = subtractRefFromData(data,ref)
        subtractedData = data - ref;
    end

    function sliderControlCallback(source,eventdata)
        plotValues;
    end

    function showLorentzianCallback(source,eventdata)
        if isequal(source.Tag,'showLorentzian') && showLorentzian.Value
            sliderHandle.Enable = 'off';
        end
        if specialSample
            if showLorentzian.Value == 1
                pv = popupSampleNameButton.Value;
                [ ...
                    hand(pv).layerNumber,  ...
                    hand(pv).layersPossible,  ...
                    hand(pv).indLayers,  ...
                    hand(pv).numOfLayers,  ...
                    hand(pv).maximum_2D,  ...
                    hand(pv).maxIndex_2D,  ...
                    hand(pv).fwhm_2D,  ...
                    hand(pv).x0_2D] = getIndexAndValuesOf2DFWHM(x,y);
                hwaitbar = waitbar(0,'Initializing waitbar...');
                pause(0.1);
                tic;
                sizey = size(y,2);
                for n = 1:sizey
                    [hand(pv).maximum_G(n), hand(pv).maxIndex_G(n), hand(pv).fwhm_G(n), hand(pv).x0_G(n)] = getLorentzianParameters([1550,1650],y(:,n),x);
                    time_elapsed = toc;
                    time_left = time_elapsed*sizey/n - time_elapsed;
                    hwaitbar = waitbar(n/sizey, hwaitbar,['Time left: ' sprintf('%.2d',floor(time_left/60)) ':' sprintf('%.2d',floor(mod(time_left,60))) ]);
                end
                close(hwaitbar);
            end
        else
            if showLorentzian.Value == 1
                pv = popupSampleNameButton.Value;
                [ ...
                    hand(pv).layerNumber,  ...
                    hand(pv).layersPossible,  ...
                    hand(pv).indLayers,  ...
                    hand(pv).numOfLayers,  ...
                    hand(pv).maximum_2D,  ...
                    hand(pv).maxIndex_2D,  ...
                    hand(pv).fwhm_2D,  ...
                    hand(pv).x0_2D] = getIndexAndValuesOf2DFWHM(x,y);
                hwaitbar = waitbar(0,'Initializing waitbar...');
                pause(0.1);
                tic;
                sizey = size(y,2);
                for n = 1:sizey
                    [hand(pv).maximum_G(n), hand(pv).maxIndex_G(n), hand(pv).fwhm_G(n), hand(pv).x0_G(n)] = getLorentzianParameters([1550,1650],y(:,n),x);
                    [hand(pv).maximum_Dp(n), hand(pv).maxIndex_Dp(n), hand(pv).fwhm_Dp(n), hand(pv).x0_Dp(n)] = getLorentzianParameters([hand(pv).x0_G(n)+5,hand(pv).x0_G(n)+105],y(:,n),x);
                    [hand(pv).maximum_D(n), hand(pv).maxIndex_D(n), hand(pv).fwhm_D(n), hand(pv).x0_D(n)] = getLorentzianParameters([1300,1450],y(:,n),x);
                    [hand(pv).maximum_DDp(n), hand(pv).maxIndex_DDp(n), hand(pv).fwhm_DDp(n), hand(pv).x0_DDp(n)] = getLorentzianParameters([2800,3050],y(:,n),x);
                    time_elapsed = toc;
                    time_left = time_elapsed*sizey/n - time_elapsed;
                    hwaitbar = waitbar(n/sizey, hwaitbar,['Time left: ' sprintf('%.2d',floor(time_left/60)) ':' sprintf('%.2d',floor(mod(time_left,60))) ]);
                end
                close(hwaitbar);
%                 [ x_0,maximum,fwhm,numLayers,layer0,layer1,layer2,layer3,layer4,ind0,ind1,ind2,ind3,ind4,NLayers] = peakFitFunc(x, y);
                if isequal(source.Tag,'showLorentzian') && showLorentzian.Value
                    sliderHandle.Enable = 'on';
                end
            end
        end
    end

    function adjustSliderStep(yO)
        numSteps = size(yO,2);
        if numSteps == 1
            set(sliderHandle,'Min',1,...
                'Max',numSteps,...
                'Value',1,...
                'Enable','off');
        else
            set(sliderHandle,'Min',1,...
                'Max',numSteps,...
                'Value',1,...
                'Enable','on',...
                'SliderStep',[1/(numSteps-1) , 1/(numSteps-1) ]);
        end
    end

    function saveToWorkspaceCallback(source,eventdata)
        pv = popupSampleNameButton.Value;
        sampleName      = strrep(hand(pv).sampleName,'_','');
        layerNumber 	= hand(pv).layerNumber;
        layersPossible  = hand(pv).layersPossible;
        indLayers 		= hand(pv).indLayers;
        numOfLayers 	= hand(pv).numOfLayers;
        maximum_2D 		= hand(pv).maximum_2D;
        maxIndex_2D 	= hand(pv).maxIndex_2D;
        fwhm_2D 		= hand(pv).fwhm_2D;
        x0_2D 			= hand(pv).x0_2D;
        maximum_G  		= hand(pv).maximum_G;
        maxIndex_G  	= hand(pv).maxIndex_G;
        fwhm_G  		= hand(pv).fwhm_G;
        x0_G  			= hand(pv).x0_G;
        maximum_D  		= hand(pv).maximum_D;
        maxIndex_D  	= hand(pv).maxIndex_D;
        fwhm_D  		= hand(pv).fwhm_D;
        x0_D  			= hand(pv).x0_D;
        maximum_DDp  	= hand(pv).maximum_DDp;
        maxIndex_DDp  	= hand(pv).maxIndex_DDp;
        fwhm_DDp  		= hand(pv).fwhm_DDp;
        x0_DDp  		= hand(pv).x0_DDp;
        maximum_Dp 		= hand(pv).maximum_Dp;
        maxIndex_Dp		= hand(pv).maxIndex_Dp;
        fwhm_Dp  		= hand(pv).fwhm_Dp;
        x0_Dp  			= hand(pv).x0_Dp;
        perc = round(numOfLayers/sum(numOfLayers)*100,2);
        putvar('layerNumber','layersPossible','indLayers', ...
            'numOfLayers','maximum_2D','maxIndex_2D','fwhm_2D',  ...
            'x0_2D','maximum_G','maxIndex_G','fwhm_G','x0_G', ...
            'maximum_D','maxIndex_D','fwhm_D','x0_D', ...
            'maximum_DDp','maxIndex_DDp','fwhm_DDp','x0_DDp', ...
            'maximum_Dp','maxIndex_Dp','fwhm_Dp','x0_Dp', ...
            'perc','yflat','y','x', 'sampleName');
    end % function

    function plotRamanContourForPresentation(source,eventdata)
        pv = popupSampleNameButton.Value;
        n = regexp(popupSampleNameButton.String{pv},'.txt');
        fwhm2d = hand(pv).fwhm_2D;
        n45 = 55;
        fwhmLimit = @(N) 88-n45./N;
        fwhm2N = @(fwhm) -n45./(fwhm-88);
        nn = ceil(sqrt(length(fwhm2d)));
        cfwhmLimit = fwhmLimit([.7,1.5,2.5,3.5,4.5,5.5,6.5,7.5]);
        fwhm2d = padarray(fwhm2d,[0,ceil(nn)^2-length(fwhm2d)],0,'post'); % if there isn't Z data for the whole map, fill it with average value of Z
        nfwhm2d = reshape(fwhm2d,[nn,nn]);
        transformedfwhm2d = fwhm2N(fwhm2d);
        ntfwhm2d = reshape(transformedfwhm2d,[nn,nn]);
        figure2D = figure(25);
        clf;
        map = [    0.3333         0         0
            0.6667         0         0
            1.0000    0.6667         0
            1.0000    1.0000         0];
        xfake=linspace(0,10,nn); % 0 to 10 s, 1000 samples
        yfake=linspace(0,10,nn);
        P2D = imagesc(xfake,yfake,flipud(transpose(nfwhm2d)),'ButtonDownFcn',@displaySomething);
        contourf(transpose(nfwhm2d),'EdgeColor','none');
        
        %         caxis([30 76])
        colormap(map)
        title('2D FWHM');
        colorbar
        axis('tight')
        figure(1)
        if isequal(saveAutomatically.Value,1)
            saveFigure(fig,[popupSampleNameButton.String{pv}(1:n-1) '_2D_FWHM'])
        end
    end

    function plotRamanContourVariable(source,eventdata)
        pv = popupSampleNameButton.Value;
        n = regexp(popupSampleNameButton.String{pv},'.txt');
        switch source.Tag
            case 'plotContourG'
                varToPlot = hand(pv).fwhm_G;
                fignum = 20;
                cmin = 15;
                cmax = 37;
                cmin = 60;
                cmax = 80;
                titlename = 'G FWHM';
                savename = 'G_FWHM';
            case 'plotContourD'
                varToPlot = hand(pv).fwhm_D;
                fignum = 21;
                cmin = 20;
                cmax = 40;
                titlename = 'D FWHM';
                savename = 'D_FWHM';
            case 'plotContourDDp'
                varToPlot = hand(pv).fwhm_DDp;
                fignum = 22;
                titlename = 'D+D'' FWHM';
                savename = 'DDp_FWHM';
            case 'plotContourx0G'
                varToPlot = hand(pv).x0_G;
                fignum = 23;
                cmin = 1585;
                cmax = 1610;
                titlename = 'G Position';
                savename = 'G_POS';
            case 'plotContourx0D'
                varToPlot = hand(pv).x0_D;
                fignum = 24;
                cmin = 1350;
                cmax = 1400;
                titlename = 'D Position';
                savename = 'D_POS';
            case 'plotContourx02D'
                varToPlot = hand(pv).x0_2D;
                fignum = 25;
                cmin = 2700;
                cmax = 2750;
                titlename = '2D Position';
                savename = '2D_POS';
        end
        nn = ceil(sqrt(length(varToPlot)));
        varToPlot = padarray(varToPlot,[0,ceil(nn)^2-length(varToPlot)],0,'post'); % if there isn't Z data for the whole map, fill it with average value of Z
        varToPlot = reshape(varToPlot,[nn,nn]);
        fig = figure(fignum);
        clf;
        map = [    0.3333         0         0
            0.6667         0         0
            1.0000    0.6667         0
            1.0000    1.0000         0];
        xfake=linspace(0,10,nn); % 0 to 10 s, 1000 samples
        yfake=linspace(0,10,nn);
        P2D = imagesc(xfake,yfake,flipud(transpose(varToPlot)));
        contourf(transpose(varToPlot),'EdgeColor','none');
        colorbar
        colormap(map)
        %         caxis([cmin cmax])
        axis('tight')
        title(titlename);
        if isequal(saveAutomatically.Value,1)
            saveFigure(fig,[popupSampleNameButton.String{pv}(1:n-1) '_' savename])
        end
        figure(1)
    end

    function filteredData = filterSpikesFromData(data)
        filteredData = medfilt1(data,6);
    end

    function loadReflectionMap(source,eventdata)
        fileDspot = reflectionSelection.String{reflectionSelection.Value};
        filegridpoints = strrep(fileDspot,'pwr_foc_Dspot','grid_pnts');
        handlegrid.gridpoints = importdata(filegridpoints);
        Dspot = importdata(fileDspot);
        xM = handlegrid.gridpoints(:,1);
        yM = handlegrid.gridpoints(:,2);
        zM = Dspot.data(:,2);
        
        %% Buffer Values computation
        carbonBufferLayer = str2double(carbonBufferLayerTextControl.String);
        if isequal(source.Tag,'carbonBufferLayerTag') % if input is base layer
            % if user changes range, then it doesn't adjust automatically
            layerRange = carbonBufferLayer*.017;
            rangeOfBufferLayer.String = sprintf('%3f',layerRange/2);
        elseif isequal(source.Tag,'carbonBufferLayerRange')
            layerRange = str2double(source.String) * 2; % get range value typed by user and multiply by 2
            source.String = sprintf(source.String); % redisplay it with +/-
        else
            layerRange = str2double(rangeOfBufferLayer.String) * 2;
        end
        % But if we have saved values, use these instead
        if useMyControlledBufferValuesCheckbox.Value
            switch fileDspot
                case 'ReflMap_xx22Ra_c-pwr_foc_Dspot.txt'
                    carbonBufferLayer = 629.1;
                    layerRange = 5.34735*2;
                case 'ReflMap_xx23Ra_c-pwr_foc_Dspot.txt'
                    carbonBufferLayer = 629.15;
                    layerRange = 5.34*2;
                case 'ReflMap_xx23Re_c-pwr_foc_Dspot.txt'
                    carbonBufferLayer = 629.15;
                    layerRange = 5.34*2;
                otherwise
            end
            carbonBufferLayerTextControl.String = sprintf('%.4g',carbonBufferLayer);
            rangeOfBufferLayer.String = sprintf('%.3g',layerRange/2);
            
        end
        %%
        minOutlier = carbonBufferLayer-layerRange*2;
        %         putvar('minOutlier');
        maxOutlier = 750;
        %         minOutlier = 620;
        numberOfHighOutliers = length(zM(zM>maxOutlier));
        numberOfLowOutliers = length(zM(zM<minOutlier));
        if numberOfHighOutliers > 0
            disp([int2str(numberOfHighOutliers) ' values were too high'])
        end
        if numberOfLowOutliers > 0
            disp([int2str(numberOfLowOutliers) ' values were too low'])
        end
        zM(zM>maxOutlier) = 610; % replace outliers with 600, below substrate power level
        zM(zM<minOutlier) = 610; % replace outliers with 600
        zOriginal = zM; % keep orignal z data before filling empty spots with the average
        disbpoints = abs(xM(2)-xM(1));
        nXsteps = (max(xM)-min(xM))/disbpoints;
        nYsteps = (max(yM)-min(yM))/disbpoints;
        if ~isequal(nXsteps,nYsteps)
            bigSteps = max([nXsteps,nYsteps]);
            [X, Y] = meshgrid(linspace(min(xM),max(xM),bigSteps+1), linspace(min(yM),max(yM),bigSteps+1));
            yM = reshape(Y',[length(Y)^2,1]);
            xM = reshape(X',[length(X)^2,1]);
        end
        sM = ceil(sqrt(length(xM)));
        
        %         x = padarray(x,[s-x,0],610,'post');
        zM = padarray(zM,[sM^2-length(zM),0],610,'post'); % if there isn't Z data for the whole map, fill it with average value of Z
        %         putvar('z');
        totalOutliers = numberOfHighOutliers + numberOfLowOutliers;
        sizeOfMatrix = ceil(sqrt(length(xM)));
        xMatrix = reshape(xM,[sizeOfMatrix,sizeOfMatrix]);
        %         xMatrix = flipud(xMatrix);
        yMatrix = reshape(yM,[sizeOfMatrix,sizeOfMatrix]);
        %         yMatrix = fliplr(yMatrix);
        zMatrix = reshape(zM,[sizeOfMatrix,sizeOfMatrix]);
        %         zMatrix = flipud(zMatrix);
        zM = zOriginal;
        stepSize = 0.3*(sizeOfMatrix-1); % 0.3E-6 * steps taken
        % Organizing layer minimums and maximums
        layer1 			= carbonBufferLayer + layerRange;
        layer2 			= layer1 + layerRange;
        layer3 			= layer2 + layerRange;
        nothingMin = carbonBufferLayer-layerRange*2;
        carbonBufferMin = carbonBufferLayer;
        carbonBufferMax = carbonBufferLayer + layerRange;
        layer1Min = carbonBufferMax;
        layer1Max = layer1 + layerRange;
        layer2Min = layer1Max;
        layer2Max = layer2 + layerRange;
        layer3Min = layer2Max;
        layer3Max = layer3 + layerRange;
        % Getting percentage of power levels within ranges to determine how
        % many layers it corresponds to
        percNone = percentInRange2(zM,nothingMin,carbonBufferMin,totalOutliers); % percent lower than buffer layer
        percZero = percentInRange2(zM,carbonBufferMin,carbonBufferMax,totalOutliers);
        percSingle = percentInRange2(zM,layer1Min,layer1Max,totalOutliers);
        percDouble = percentInRange2(zM,layer2Min,layer2Max,totalOutliers);
        percTriple = percentInRange2(zM,layer3Min,layer3Max,totalOutliers);
        percHOPG = percentInRange2(zM,layer3Max,1000,totalOutliers);
        cc = contourf(reflectionAxes,xMatrix,yMatrix,zMatrix,'EdgeColor', 'none');
        percentText = {sprintf([...
            'No Layers: %.3g%%\n',...
            '0 Layers: %.3g%%\n',...
            '1 Layer: %.3g%%\n',...
            '2 Layers: %.3g%%\n',...
            '3 Layers: %.3g%%\n',...
            'More than 3:  %.3g%%'],...
            percNone, percZero, percSingle, percDouble, percTriple, percHOPG)};
        hTitle = title(reflectionAxes,percentText);
        %         map = [    0.3333         0         0
        %             0.6667         0         0
        %             1.0000    0.6667         0
        %             1.0000    1.0000         0];
        %         colormap(map)
        colormap(hot)
        contourmap = get(reflectionAxes,'Children');
        set(reflectionAxes,'XTickLabel','','YTickLabel','');
        set(contourmap,'PickableParts','all','ButtonDownFcn',@getMouseDownPosition);
        set(reflectionAxes, ...
            'Box'         , 'off'     , ...
            'CLim', [nothingMin,max(zMatrix(:))],...
            'TickDir'     , 'out'     , ...
            'xtick'       , []        , ...
            'ytick'       , []        , ...
            'TickLength'  , [.02 .02] , ...
            'XMinorTick'  , 'on'      , ...
            'YMinorTick'  , 'on'      , ...
            'YGrid'       , 'on'      , ...
            'XColor'      , [.3 .3 .3], ...
            'YColor'      , [.3 .3 .3], ...
            'LineWidth'   , 1         );
    end

    function percentage = percentInRange2(matrix,min,max,outliers)
        numbers = matrix(matrix > min & matrix < max);
        count = length(numbers);
        tot = length(matrix)-outliers;
        percentage = count/tot*100;
    end

    function getMouseDownPosition(source,eventdata)
        [eventdata.IntersectionPoint(1), eventdata.IntersectionPoint(2)];
        %         xgrid = abs(handlegrid.gridpoints(:,1) - eventdata.IntersectionPoint(1));
        therep = repmat(eventdata.IntersectionPoint(1:2),[length(handlegrid.gridpoints(:,1)),1]);
        [aa, bb] = min(abs(handlegrid.gridpoints-therep));
        %         [c1 indexX] = min(xgrid);
        %         ygrid = abs(handlegrid.gridpoints(:,1) - eventdata.IntersectionPoint(2));
        %         [c2 indexY] = min(ygrid);
        try
            sliderHandle.Value = bb(1)+bb(2)-1;
            pause(0.1);
            plotValues;
            loadReflectionMap(source,eventdata);
        end
    end

    function enableDisableBufferTextBox(source,eventdata)
        if useMyControlledBufferValuesCheckbox.Value
            carbonBufferLayerTextControl.Enable = 'off';
            rangeOfBufferLayer.Enable = 'off';
        else
            carbonBufferLayerTextControl.Enable = 'on';
            rangeOfBufferLayer.Enable = 'on';
        end
    end

end
