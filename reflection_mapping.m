function reflection_mapping
% Plots Reflection Maps in folder 'ReflectionMaps/'
close all;
dbstop if error % Stop execution if an error occurs for debugging
mypath = mfilename('fullpath'); % get full path of this function
% close all force % close all figures forcefully
cd(fileparts(mypath)); % automatically change folder to this functions folder
titleExpression = '[Xx][0-9]+[-,a-z,A-Z]'; % expression to look for in string
pathToReflectionMaps = '../../Data/ReflectionMaps/';
addpath(genpath(pathToReflectionMaps)); % Add reflection maps folder to workspace
fileNamePrefix = 'ReflMap_*.txt';
theFiles = dir([pathToReflectionMaps fileNamePrefix]); % all the files in reflection maps folder
fig = figure(... % Create Figure, name it, position it
    'NumberTitle','off',...
    'name','Reflection Mapping',...
    'Units','normalized',...
    'Position',[0.3734 0.2600 0.6211 0.6200]);
%     'Position', [360   278   650   500]);
% set(fig,'Position','West');
ax1 = axes('Units', 'normalized',... % Create an axes to draw on
    'Position', [0.0626 0.0488 0.4824 0.6901]);
ax2 = axes('Units', 'normalized',... % Create an axes to draw on
    'Position', [0.6 0.3 0.3824 0.501]);
%% Import names of files
popupName = cell(1,length(theFiles)/2); % Initialize space for variable
titleName = cell(1,length(theFiles)/2); % Initialize space for variable
for i = 1:2:length(theFiles)
    str =  theFiles(i).name;
    titleName{:,(i+1)/2} = extractFromString(str,titleExpression); % x928, x929 - not used yet
    popupName{:,(i+1)/2} = str; % full file name - ReflMap_x942Ra-b-grid_pnts
end

% putvar('titleName','popupName','theFiles','titleExpression');
%% Create UI Controls
popupMenuButton = uicontrol('Style', 'popupmenu',...
    'Tag', 'popupTag',...
    'String', popupName,...
    'units', 'normalized',...
    'Position', [0.0239 0.8448 0.2638 0.1008],...
    'Callback', @plotMap);

bufferLayerValue = uicontrol('Style', 'edit',...
    'Tag', 'carbonBufferLayerValue',...
    'String', {'645'},...
    'units','normalized',...
    'Position', [0.4133 0.8548 0.1256 0.0403],...
    'Callback', @plotMap);

rangeOfBufferLayer = uicontrol('Style', 'edit',...
    'Tag', 'carbonBufferLayerRange',...
    'String', sprintf('%3g',str2double(bufferLayerValue.String)*.017),...
    'units','normalized',...
    'Position', [.5389 0.8548 0.1256 0.0403],...
    'Callback', @plotMap);

bufferLayerText = uicontrol('Style', 'text',...
    'String', {'Carbon Buffer Layer Power Level'},...
    'units','normalized',...
    'Position', [.4133 0.8952 0.1256 0.0504]);

rangeText = uicontrol('Style', 'text',...
    'String', 'Range ',...
    'units','normalized',...
    'Position', [0.5389 0.8952 0.1256 0.0504]);

saveButton = uicontrol('Style', 'pushbutton',...
    'String', {'Save Plot'},...
    'units','normalized',...
    'Tag', 'saveButtonTag',...
    'Position', [0.6646 0.8548 0.1256 0.0403],...
    'Callback', @savePlot);
plotMap(bufferLayerValue); % Plot map for first selected file
%% Functions
    function string = extractFromString(str,expression)
        %Extracts string from str using expression and adds x to beginning
        % string = extractFromString('ReflMap_X928-prm1-grid_pnts.txt','[Xx][0-9]+-');
        % string => 'x928'
        [startIndex,endIndex] = regexp(str,expression);
        string = ['x' str(startIndex+1:endIndex-1)];
    end
	
    function [x,y,z,zOriginal,totalOutliers,minX,maxX,minY,maxY,disbpoints] = getXYZFromFileNumber(i)
        xandyData = importdata([pathToReflectionMaps theFiles(i).name]);
        zData = importdata([pathToReflectionMaps theFiles(i+1).name]);
        x = xandyData(:,1); 
        y = xandyData(:,2); 
        z = zData.data(:,2);
        lz = length(z);
        minX = min(x(1:lz));
        maxX = max(x(1:lz));
        minY = min(y(1:lz));
        maxY = max(y(1:lz));
        carbonBufferLayer = str2double(bufferLayerValue.String);
        layerRange = str2double(rangeOfBufferLayer.String) * 2;
        minOutlier = carbonBufferLayer-layerRange*2;
%         putvar('minOutlier');
        maxOutlier = 750;
%         minOutlier = 620;
        numberOfHighOutliers = length(z(z>maxOutlier));
        numberOfLowOutliers = length(z(z<minOutlier));
        if numberOfHighOutliers > 0
            disp([theFiles(i+1).name ': ' int2str(numberOfHighOutliers) ' values were too high']);
        end
        if numberOfLowOutliers > 0
            disp([theFiles(i+1).name ': ' int2str(numberOfLowOutliers) ' values were too low']);
        end
        z(z>maxOutlier) = maxOutlier; % replace outliers with 600, below substrate power level
        z(z<minOutlier) = minOutlier; % replace outliers with 600
        zOriginal = z; % keep orignal z data before filling empty spots with the average
        disbpoints = abs(x(2)-x(1));
        nXsteps = (maxX-minX)/disbpoints;
        nYsteps = (maxY-minY)/disbpoints;
        if ~isequal(nXsteps,nYsteps)
            bigSteps = max([nXsteps,nYsteps]);
            [X,Y] = meshgrid(linspace(min(x),max(x),bigSteps+1), linspace(min(y),max(y),bigSteps+1));
            y = reshape(Y',[length(Y)^2,1]);
            x = reshape(X',[length(X)^2,1]);
        end
        s = ceil(sqrt(length(x)));

%         x = padarray(x,[s-x,0],610,'post'); 
        z = padarray(z,[s^2-length(z),0],610,'post'); % if there isn't Z data for the whole map, fill it with average value of Z
%         putvar('z');
        totalOutliers = numberOfHighOutliers + numberOfLowOutliers;
    end

    function plotMap(source,eventdata)
        if isequal(bufferLayerValue.String,{''}) || isempty(rangeOfBufferLayer.String)
            return;
        end
        valAll = popupMenuButton.Value; % Get selected sample number
        val = 2*valAll-1;
        [x,y,z,zOriginal,totalOutliers,minX,maxX,minY,maxY,disbpoints] = getXYZFromFileNumber(val);
%         putvar('zOriginal');
        sizeOfMatrix = ceil(sqrt(length(x)));
        xMatrix = reshape(x,[sizeOfMatrix,sizeOfMatrix]);
%         xMatrix = flipud(xMatrix);
        yMatrix = reshape(y,[sizeOfMatrix,sizeOfMatrix]);
%         yMatrix = fliplr(yMatrix);
        zMatrix = reshape(z,[sizeOfMatrix,sizeOfMatrix]);
%         zMatrix = flipud(zMatrix);
        z = zOriginal;
        stepSize = (maxX-minX)*1e3; % distance in mm converted to microns
        stepSizeY = (maxY-minY)*1e3; % distance in mm converted to microns
        carbonBufferLayer = str2double(bufferLayerValue.String);
        if isequal(source.Tag,'carbonBufferLayerValue') % if input is base layer
            % if user changes range, then it doesn't adjust automatically
            layerRange = carbonBufferLayer*.017;
            rangeOfBufferLayer.String = sprintf('%3f',layerRange/2);
        elseif isequal(source.Tag,'carbonBufferLayerRange')
            layerRange = str2double(source.String) * 2; % get range value typed by user and multiply by 2
            source.String = sprintf(source.String); % redisplay it with +/-
        elseif isequal(source.Tag,'saveButtonTag')
            layerRange = str2double(rangeOfBufferLayer.String) * 2; % get range value typed by user and multiply by 2
        else
            layerRange = str2double(rangeOfBufferLayer.String) * 2;
        end
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
        
        percNone = percentInRange2(z,nothingMin,carbonBufferMin,totalOutliers); % percent lower than buffer layer
        percZero = percentInRange2(z,carbonBufferMin,carbonBufferMax,totalOutliers);
        percSingle = percentInRange2(z,layer1Min,layer1Max,totalOutliers);
        percDouble = percentInRange2(z,layer2Min,layer2Max,totalOutliers);
        percTriple = percentInRange2(z,layer3Min,layer3Max,totalOutliers);
        percHOPG = percentInRange2(z,layer3Max,1000,totalOutliers);
        if isequal(source.Tag,'saveButtonTag')
            fig2 = figure(2);
            contourf(xMatrix,yMatrix,zMatrix,'EdgeColor', 'none');
            hold on;
            plot([20.3025 20.3125],[31.406 31.406],'-k','LineWidth',10)
            hold off;
            text(20.3075,31.4035,'10 \mum','FontSize',26,'FontWeight','Bold','HorizontalAlignment','center');
            currentAxes = gca;
        else
            plot(ax2,1:length(zOriginal),zOriginal,'.',[1,length(zOriginal)],[mean(zOriginal) mean(zOriginal)],[1,length(zOriginal)],[mode(zOriginal) mode(zOriginal)],[1,length(zOriginal)],[median(zOriginal) median(zOriginal)]);
            axis([0,length(zOriginal),min(zOriginal),max(zOriginal)])
%             legend('data',...
%                 ['mean: ' int2str(mean(zOriginal))],...
%                 ['mode: ' int2str(mode(zOriginal))],...
%                 ['median: ' int2str(median(zOriginal))],...
%                 'location','best');
            contourf(ax1,xMatrix,yMatrix,zMatrix,'EdgeColor', 'none');
            currentAxes = ax1;
        end
        hTitle = title(currentAxes,[titleName{popupMenuButton.Value} ...
            sprintf(', Size in \\mum: %3g x %3g',stepSize, stepSizeY); ]);
        h = colormap(currentAxes,hot)
        h = colorbar(currentAxes,'FontSize',22)
%         percentText = {sprintf([...
%             'No Layers: %.3g%%\n',...
%             '0 Layers: %.3g%%\n',...
%             '1 Layer: %.3g%%\n',...
%             '2 Layers: %.3g%%\n',...
%             '3 Layers: %.3g%%\n',...
%             'More than 3:  %.3g%%'],...
%             percNone, percZero, percSingle, percDouble, percTriple, percHOPG)};
        percentText = {sprintf([...
            '1 Layer: %.3g%%\n',...
            '2 Layers: %.3g%%\n',...
            '3 Layers: %.3g%%',...
            ],...
            percSingle, percDouble, percTriple)};
        if isequal(source.Tag, 'saveButtonTag')
            %             hTitle = title(currentAxes,[titleName{popupMenuButton.Value} ...
            %                 sprintf(', Size in \\mum: %3g x %3g',stepSize, stepSize)]);
            %             axis('square');
            %             currentFigure = gcf;
            %             currentFigure.Position = [607 267 600 420];
            %             currentAxes.Position = [0.0758 .11 .58 .815];
            %             percentBox = uicontrol(...
            %                 'style',      'text',...
            %                 'units','normalized',...
            %                 'Position',   [0.75 0.25 0.2 0.3016],...
            %                 'String',     percentText,...
            %                 'FontName',   'AvantGarde');
            hTitle = title(percentText);
            axis('square');
        else
            percentBox = uicontrol(...
                'style',      'text',...
                'units','normalized',...
                'Position',   [0.56 0.03 0.1256 0.2016],...
                'String',     percentText,...
                'FontName',   'AvantGarde');
        end
        set(currentAxes, ...
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
        set( hTitle                    , ...
            'FontName'   , 'Helvetica',...
            'FontSize'   , 22                );
%         histfig = figure(5);
%         clf;
%         histfig.Position = [0   278   560   420];
%         histogram(zOriginal,'Normalization','Probability');
%         title('Reflectance of Layers');
%         xlabel('Reflectance (mW)');
%         ylabel('Probability');
%         prettyPlotLoop(histfig,14,'Yes');
%         plotFigure = 0;
%         if plotFigure == 1 
%             saveFigure(histfig,'reflectanceSeparation');
%         end
%         axis('square');
        %         children = get(gca,'Children');
        %         set(children,'LevelList',[carbonBufferMin,layer1Min,layer2Min,layer3Min,layer3Max])
        
        %         set(fig3,'Units','normalized','Position',[0 0.4100 0.3734 0.4700]);
    end

    function fileNameEPS = getPreferredFileName(filename)
        % fileNameEPS = getPreferredFileName('ReflMap_X928-prm1-grid_pnts.txt')
        % fileNameEPS => 'x928-prm1.eps'
        [pathstr,name] = fileparts(filename); % separate file parts
        startOfString = '[Xx]';
        endOfString = '-grid_pnts';
        startNumber = regexp(name,startOfString); % start of String X or x
        endNumber = regexp(name,endOfString); % start of String X or x
        saveName = ['x' name(startNumber+1:(endNumber-1))]; % save name with lowercase x
        fileNameEPS = [pathstr,saveName];
    end

    function savePlot(source,eventdata)
        % Print Plot
        figS = figure(2);clf;
        
%         set(figS,    'Units','normalized',...
%             'Position',[0.3734 0.2600 0.5 0.6200]); % extend x for the side text
%         axS = axes('Units', 'normalized',... % Create an axes to draw on
%             'Position', [0.0626 0.0488 0.4824 0.6901]); % position for plot to leave room on right side for text box
        plotMap(source,eventdata); % Plot onto figure(2) and save as '.eps'
        
        set(figS, 'PaperPositionMode', 'auto');
        fileNameEPS = getPreferredFileName(popupName{popupMenuButton.Value}); %
        
        outputFolder = '../../Outputs/Reflection/pngFigures/';
        theChoice = questdlg('Save Figures?','Save Figures?','Yes','No','No');
        switch theChoice
            case 'Yes'
                saveFigure(figS,fileNameEPS,'-dpng',outputFolder)
            otherwise
        end
        %         if not(isequal(FileName,0))
        %             print(figS, '-depsc', [PathName FileName]); % Saves file
%         end
    end

    function percentage = percentInRange2(matrix,min,max,outliers)
        numbers = matrix(matrix > min & matrix < max);
        count = length(numbers);
        tot = length(matrix)-outliers;
        percentage = count/tot*100;
    end
% a = who;
% ans = 1;
% putvar(a{:})
end
