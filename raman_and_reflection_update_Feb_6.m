function raman_and_reflection_update_Feb_6
fig = figure(... % Create Figure, name it, position it
    'NumberTitle','off', ...
    'name','Reflection Mapping', ...
    'Units','normalized', ...
    'Position',[0.0153    0.0588    0.9766    0.8037]);
fileload = '2';
matFile = dir(['../../Data/mat/*' fileload '*']);
if length(matFile) > 1
    names1 = struct2cell(matFile);
    [s,v] = listdlg('PromptString','Select a file:',...
        'SelectionMode','single',...
        'ListString',names1(1,:)')
    if isempty(s)
        disp('No Reflection was chosen');
        close all force;
        return;
    end
    fileload = names1{1,s};
else
    fileload = matFile(1).name;
end
theVariables = load(['../../Data/mat/' fileload]);
defect_filename = 'bad_fit.txt';
fitsquest = theVariables.fitsquest;
a = regexp(fileload,'_','split');
addpath('../../Data/ReflectionMaps/')
f = dir(['../../Data/ReflectionMaps/*' a{1} '*Ra*Dspot.txt']); % to find

if length(f) > 1
    names = struct2cell(f);
    [s,v] = listdlg('PromptString','Select a file to load',...
        'SelectionMode','single',...
        'ListString',names(1,:)')
    if isempty(s)
        disp('No Reflection was chosen');
        close all force;
        return;
    end
end
if isempty(f)
    allreflectionmaps = dir(['../../Data/ReflectionMaps/*Ra*Dspot.txt']);
    names = struct2cell(allreflectionmaps);
    [s,v] = listdlg('PromptString','Select a file to load',...
        'SelectionMode','single',...
        'ListString',names(1,:)')
    disp('There are no reflection maps')
    return;
else
    fileDspot = f(s).name;
    filegridpoints = strrep(fileDspot,'pwr_foc_Dspot','grid_pnts');
end

switch fitsquest
    case 'Yes'
        fwhm1 = theVariables.fwhm1;
        fwhmD = theVariables.fwhmD;
        fwhmG = theVariables.fwhmG;
        maximum1 = theVariables.maximum1;
        maximumD = theVariables.maximumD;
        maximumG = theVariables.maximumG;
        x_01 = theVariables.x_01;
        x_0D = theVariables.x_0D;
        x_0G = theVariables.x_0G;
end
theChoice = questdlg('Show D'' peak?','Show D'' peak?','Yes','No','No');
switch theChoice
    case 'Yes'
        x_0Dp = theVariables.x_0Dp;
        maximumDp = theVariables.maximumDp;
        fwhmDp = theVariables.fwhmDp;
    otherwise
end
%% open vallery's sample

% theChoice2 = questdlg('Compare to Vallery''s sample?','Compare to Vallery''s sample?','Yes','No','No');
% files = dir('./subtracted/*.sub');
% files = {files.name}.'
% files = sort_nat(files);
% switch theChoice2
%     case 'Yes'
%         for k = 1:length(files)
%             fileIDv = fopen(files{k},'r');
%             a = fscanf(fileIDv,'%f\t%f\n');
%             fclose(fileIDv);
%             xv(:,k) = a(1:2:end);
%             yv(:,k) = a(2:2:end);
%         end
%     otherwise
% end



%% Load variables from mat file
x = theVariables.x;
y = theVariables.y;
y_shifted = theVariables.y_shifted;
y_shifted_flattened = theVariables.y_shifted_flattened;
y_shifted_flattened_subtracted = theVariables.y_shifted_flattened_subtracted;
yref = theVariables.yref;
yref_shifted  = theVariables.yref_shifted;
yref_shifted_flattened  = theVariables.yref_shifted_flattened;
yref_shifted_flattened_multiply = theVariables.yref_shifted_flattened_multiply;
numSteps = size(y,2);

%% uicontrols
sliderHandle = uicontrol('Style', 'slider',...
    'Units', 'normalized',...
    'Tag','slidertag',...
    'Min',1,...
    'Max',numSteps,...
    'KeyPressFcn',@fig_Callback, ...
    'Value',1,...
    'SliderStep',[1/(numSteps-1) , 1/(numSteps-1) ],...
    'Callback', @plotValueInTextBox,...
    'Position',[0.1276    0.9200    0.3577    0.0568]);
reflectionAxes = axes('Units', 'normalized',... % Create an axes to draw on
    'Position', [0.68    0.300    0.3    0.45], ...
    'Tag','axesForContour','PickableParts','all','ButtonDownFcn',@getMouseDownPosition);
ramanAxes = axes('Units', 'normalized', ... % Create an axes to draw on
    'Position', [0.0839    0.0800    0.5389    0.7300]);
plotValueInTextBox(sliderHandle)
loadReflectionMap;
disp('hi')

set(fig,'KeyPressFcn',@fig_Callback)

%% Functions
    function getMouseDownPosition(source,eventdata)
        handlegrid.gridpoints = importdata(filegridpoints);
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
            plotValueInTextBox(sliderHandle);
            loadReflectionMap;
        end
    end

    function loadReflectionMap(source,eventdata)
        handlegrid.gridpoints = importdata(filegridpoints);
        Dspot = importdata(fileDspot);
        xM = handlegrid.gridpoints(:,1);
        yM = handlegrid.gridpoints(:,2);
        zM = Dspot.data(:,2);
        sizeOfMatrix = ceil(sqrt(length(xM)));
        xMatrix = reshape(xM,[sizeOfMatrix,sizeOfMatrix]);
        %         xMatrix = flipud(xMatrix);
        yMatrix = reshape(yM,[sizeOfMatrix,sizeOfMatrix]);
        %         yMatrix = fliplr(yMatrix);
        zMatrix = reshape(zM,[sizeOfMatrix,sizeOfMatrix]);
        %         zMatrix = flipud(zMatrix);
        cc = contourf(reflectionAxes,xMatrix,yMatrix,zMatrix,'EdgeColor', 'none');
        contourmap = get(reflectionAxes,'Children');
        colorbar(reflectionAxes);
        cmin = 600;
        cmax = 690;
        set(reflectionAxes,'XTickLabel','','YTickLabel','');
        set(contourmap,'PickableParts','all','ButtonDownFcn',@getMouseDownPosition);
        %         %% Buffer Values computation
        %         carbonBufferLayer = str2double(carbonBufferLayerTextControl.String);
        %         if isequal(source.Tag,'carbonBufferLayerTag') % if input is base layer
        %             % if user changes range, then it doesn't adjust automatically
        %             layerRange = carbonBufferLayer*.017;
        %             rangeOfBufferLayer.String = sprintf('%3f',layerRange/2);
        %         elseif isequal(source.Tag,'carbonBufferLayerRange')
        %             layerRange = str2double(source.String) * 2; % get range value typed by user and multiply by 2
        %             source.String = sprintf(source.String); % redisplay it with +/-
        %         else
        %             layerRange = str2double(rangeOfBufferLayer.String) * 2;
        %         end
        %         % But if we have saved values, use these instead
        %         if useMyControlledBufferValuesCheckbox.Value
        %             switch fileDspot
        %                 case 'ReflMap_xx22Ra_c-pwr_foc_Dspot.txt'
        %                     carbonBufferLayer = 629.1;
        %                     layerRange = 5.34735*2;
        %                 case 'ReflMap_xx23Ra_c-pwr_foc_Dspot.txt'
        %                     carbonBufferLayer = 629.15;
        %                     layerRange = 5.34*2;
        %                 case 'ReflMap_xx23Re_c-pwr_foc_Dspot.txt'
        %                     carbonBufferLayer = 629.15;
        %                     layerRange = 5.34*2;
        %                 otherwise
        %             end
        %             carbonBufferLayerTextControl.String = sprintf('%.4g',carbonBufferLayer);
        %             rangeOfBufferLayer.String = sprintf('%.3g',layerRange/2);
        %
        %         end
        %         %%
        %         minOutlier = carbonBufferLayer-layerRange*2;
        %         %         putvar('minOutlier');
        %         maxOutlier = 750;
        %         %         minOutlier = 620;
        %         numberOfHighOutliers = length(zM(zM>maxOutlier));
        %         numberOfLowOutliers = length(zM(zM<minOutlier));
        %         if numberOfHighOutliers > 0
        %             disp([int2str(numberOfHighOutliers) ' values were too high'])
        %         end
        %         if numberOfLowOutliers > 0
        %             disp([int2str(numberOfLowOutliers) ' values were too low'])
        %         end
        %         zM(zM>maxOutlier) = 610; % replace outliers with 600, below substrate power level
        %         zM(zM<minOutlier) = 610; % replace outliers with 600
        %         zOriginal = zM; % keep orignal z data before filling empty spots with the average
        %         disbpoints = abs(xM(2)-xM(1));
        %         nXsteps = (max(xM)-min(xM))/disbpoints;
        %         nYsteps = (max(yM)-min(yM))/disbpoints;
        %         if ~isequal(nXsteps,nYsteps)
        %             bigSteps = max([nXsteps,nYsteps]);
        %             [X, Y] = meshgrid(linspace(min(xM),max(xM),bigSteps+1), linspace(min(yM),max(yM),bigSteps+1));
        %             yM = reshape(Y',[length(Y)^2,1]);
        %             xM = reshape(X',[length(X)^2,1]);
        %         end
        %         sM = ceil(sqrt(length(xM)));
        %
        %         %         x = padarray(x,[s-x,0],610,'post');
        %         zM = padarray(zM,[sM^2-length(zM),0],610,'post'); % if there isn't Z data for the whole map, fill it with average value of Z
        %         %         putvar('z');
        %         totalOutliers = numberOfHighOutliers + numberOfLowOutliers;
        %         sizeOfMatrix = ceil(sqrt(length(xM)));
        %         xMatrix = reshape(xM,[sizeOfMatrix,sizeOfMatrix]);
        %         %         xMatrix = flipud(xMatrix);
        %         yMatrix = reshape(yM,[sizeOfMatrix,sizeOfMatrix]);
        %         %         yMatrix = fliplr(yMatrix);
        %         zMatrix = reshape(zM,[sizeOfMatrix,sizeOfMatrix]);
        %         %         zMatrix = flipud(zMatrix);
        %         zM = zOriginal;
        %         stepSize = 0.3*(sizeOfMatrix-1); % 0.3E-6 * steps taken
        %         % Organizing layer minimums and maximums
        %         layer1 			= carbonBufferLayer + layerRange;
        %         layer2 			= layer1 + layerRange;
        %         layer3 			= layer2 + layerRange;
        %         nothingMin = carbonBufferLayer-layerRange*2;
        %         carbonBufferMin = carbonBufferLayer;
        %         carbonBufferMax = carbonBufferLayer + layerRange;
        %         layer1Min = carbonBufferMax;
        %         layer1Max = layer1 + layerRange;
        %         layer2Min = layer1Max;
        %         layer2Max = layer2 + layerRange;
        %         layer3Min = layer2Max;
        %         layer3Max = layer3 + layerRange;
        %         % Getting percentage of power levels within ranges to determine how
        %         % many layers it corresponds to
        %         percNone = percentInRange2(zM,nothingMin,carbonBufferMin,totalOutliers); % percent lower than buffer layer
        %         percZero = percentInRange2(zM,carbonBufferMin,carbonBufferMax,totalOutliers);
        %         percSingle = percentInRange2(zM,layer1Min,layer1Max,totalOutliers);
        %         percDouble = percentInRange2(zM,layer2Min,layer2Max,totalOutliers);
        %         percTriple = percentInRange2(zM,layer3Min,layer3Max,totalOutliers);
        %         percHOPG = percentInRange2(zM,layer3Max,1000,totalOutliers);
        %         cc = contourf(reflectionAxes,xMatrix,yMatrix,zMatrix,'EdgeColor', 'none');
        %         percentText = {sprintf([...
        %             'No Layers: %.3g%%\n',...
        %             '0 Layers: %.3g%%\n',...
        %             '1 Layer: %.3g%%\n',...
        %             '2 Layers: %.3g%%\n',...
        %             '3 Layers: %.3g%%\n',...
        %             'More than 3:  %.3g%%'],...
        %             percNone, percZero, percSingle, percDouble, percTriple, percHOPG)};
        %         hTitle = title(reflectionAxes,percentText);
%         map = [    0.3333         0         0
%             0.6667         0         0
%             1.0000    0.6667         0
%             1.0000    1.0000         0];
%         colormap(map)
        %                 colormap(hot)
        %         contourmap = get(reflectionAxes,'Children');
        %         set(reflectionAxes,'XTickLabel','','YTickLabel','');
        %         set(contourmap,'PickableParts','all','ButtonDownFcn',@getMouseDownPosition);
        set(reflectionAxes, ...
            'Box'         , 'off'     , ...
            'CLim'        , [cmin cmax] , ...
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

    function plotValueInTextBox(source,eventdata)
        i = floor(get(source,'Value'));
        num =find( x > 1189 & x < 3444 );
        switch fitsquest
            case 'Yes'
                lorG = maximumG(i)*(1/2*fwhmG(i)).^2./( (x-x_0G(i)).^2 + (1/2*fwhmG(i))^2);
                lorD = maximumD(i)*(1/2*fwhmD(i)).^2./( (x-x_0D(i)).^2 + (1/2*fwhmD(i))^2);
                lor2D = maximum1(i)*(1/2*fwhm1(i)).^2./( (x-x_01(i)).^2 + (1/2*fwhm1(i))^2);
        end
        switch theChoice
            case 'Yes'
                lorDp = maximumDp(i)*(1/2*fwhmDp(i)).^2./( (x-x_0Dp(i)).^2 + (1/2*fwhmDp(i))^2);
                switch fitsquest
                    case 'Yes'
                        plot(ramanAxes,x(num),y_shifted_flattened_subtracted(num,i), ...
                            x(num),lorG(num), ...
                            x(num),lorD(num), ...
                            x(num),lorDp(num), ...
                            x(num),lor2D(num), ...
                            x(num),lorG(num)+lorD(num)+lorDp(num)+lor2D(num));
                    otherwise
                        plot(ramanAxes,x(num),y_shifted_flattened_subtracted(num,i), ...
                            x(num),lorDp(num));
                end
            otherwise
                switch fitsquest
                    case 'Yes'
                        plot(ramanAxes,x(num),y_shifted_flattened_subtracted(num,i), ...
                            x(num),lorG(num), ...
                            x(num),lorD(num), ...
                            x(num),lor2D(num), ...
                            x(num),lorG(num)+lorD(num)+lor2D(num));
                    otherwise
                        plot(ramanAxes,x(num),y_shifted_flattened_subtracted(num,i));
                end
        end
        % axis([1212 3348 -800 3600])
        %                 xlim([1200 2000]);
        %         hLegend = legend('Data','G','D','Dp','2D','Total');
        %         text(1500,maximumG(i)/2,sprintf('%f',maximumD(i)/maximumG(i)));
        %         set(hLegend,'Location','north')
        title(ramanAxes,sprintf('%d',i));
        ylim(ramanAxes,[-1000,12000]);
        prettyPlotLoop(fig,14,'no')
    end

    function fig_Callback(source,eventdata)
        i = floor(get(sliderHandle,'Value'));
        if isequal(eventdata.Character,' ')
            %% Append new plot position to text file
            fileID = fopen(defect_filename,'a+');
            fmt = '%5d,\n';
            frewind(fileID);
            values1 = fscanf(fileID,'%f,\n');
            l = length(values1);
            fprintf(fileID,fmt,i);
            frewind(fileID);
            values = fscanf(fileID,'%f,\n');
            nl = length(values);
            fclose(fileID);
            %% Eliminate duplicates and sort numbers
            fileID = fopen(defect_filename,'w+');
            values = unique(values);
            fprintf(fileID,fmt,values);
            if l < nl
                disp(sprintf('Added: %2.0f',values(end)));
            end
            fclose(fileID);
        end
    end

end
