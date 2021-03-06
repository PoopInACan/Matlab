function raman_and_reflection_update_Feb_6
close all force
fig = figure(... % Create Figure, name it, position it
    'NumberTitle','off', ...
    'name','Reflection Mapping', ...
    'Units','normalized', ...
    'Position',[0.0153    0.0588    0.9766    0.8037]);
ramanFileName = '';
matFile = dir(['../../Data/mat/*' ramanFileName '*.mat']);
if length(matFile) > 1
    names1 = struct2cell(matFile);
    [s,didSelectFile] = listdlg('PromptString','Select a Raman file:',...
        'SelectionMode','single',...
        'ListString',names1(1,:)')
    if isequal(didSelectFile,0)
        disp('No Raman file was chosen');
        close all force;
        return;
    end
    ramanFileName = names1{1,s};
else
    ramanFileName = matFile(1).name;
end
theVariables = load(['../../Data/mat/' ramanFileName]);
defect_filename = 'bad_fit.txt';
fitsquest = theVariables.fitsquest;
a = regexp(ramanFileName,'_','split');
addpath('../../Data/ReflectionMaps/')
f = dir(['../../Data/ReflectionMaps/*' a{1} '*Ra*Dspot.txt']); % to find

if length(f) > 1 % if there is more then one map related to title, allow user to pick the correct one
    names = struct2cell(f);
    [s,didSelectFile] = listdlg('PromptString','Select a Reflection file',...
        'SelectionMode','single',...
        'ListString',names(1,:)');
    if isequal(didSelectFile,0)
        disp('loading default map')
        fileDspot = 'ReflMap_xx19Ra_c-pwr_foc_Dspot.txt';
        filegridpoints = strrep(fileDspot,'pwr_foc_Dspot','grid_pnts');
    else
        fileDspot = f(s).name;
        filegridpoints = strrep(fileDspot,'pwr_foc_Dspot','grid_pnts');
    end
else
    s = 1;
end

if isempty(f) % if no reflection map related to title was found, allow user to pick a map
    allreflectionmaps = dir(['../../Data/ReflectionMaps/*Ra*Dspot.txt']);
    names = struct2cell(allreflectionmaps);
    [s,v] = listdlg('PromptString','Select a file to load',...
        'SelectionMode','single',...
        'ListString',names(1,:)')
    disp('There are no reflection maps')
    disp('loading default map')
    fileDspot = 'ReflMap_xx2_xx21Ra_c-pwr_foc_Dspot.txt';
    filegridpoints = strrep(fileDspot,'pwr_foc_Dspot','grid_pnts');
end

if isequal(length(f),1)
    fileDspot = f(s).name;
    filegridpoints = strrep(fileDspot,'pwr_foc_Dspot','grid_pnts');
end

switch fitsquest
    case {'Yes','yes'}
        fwhm1 = theVariables.fwhm1;
        fwhmD = theVariables.fwhmD;
        fwhmG = theVariables.fwhmG;
        maximum1 = theVariables.maximum1;
        maximumD = theVariables.maximumD;
        maximumG = theVariables.maximumG;
        x_01 = theVariables.x_01;
        x_0D = theVariables.x_0D;
        x_0G = theVariables.x_0G;
        layerNumber = theVariables.layerNumber;
        switch layerNumber
            case {'Yes','yes',0, 'Buffer','buffer'} % means that it is buffer layer
                fwhm2 = theVariables.fwhm2;
                maximum2 = theVariables.maximum2;
                x_02 = theVariables.x_02;
                fwhm3 = theVariables.fwhm3;
                maximum3 = theVariables.maximum3;
                x_03 = theVariables.x_03;
        end
end

x_0Dp = theVariables.x_0Dp;
maximumDp = theVariables.maximumDp;
fwhmDp = theVariables.fwhmDp;
if isequal(x_0Dp,ones(1,length(x_0Dp)))
    showDprimePeak = 'No';
else
    showDprimePeak = 'Yes';
end


%% Load variables from mat file
x = theVariables.x;
y = theVariables.y;
y_shifted_flattened_subtracted = y;
% y_shifted = theVariables.y_shifted;
% y_shifted_flattened = theVariables.y_shifted_flattened;
% y_shifted_flattened_subtracted = theVariables.y_shifted_flattened_subtracted;
% yref = theVariables.yref;
% yref_shifted  = theVariables.yref_shifted;
% yref_shifted_flattened  = theVariables.yref_shifted_flattened;
% yref_shifted_flattened_multiply = theVariables.yref_shifted_flattened_multiply;
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
        therep = repmat(eventdata.IntersectionPoint(1:2),[length(handlegrid.gridpoints(:,1)),1]);
        [aa, bb] = min(abs(handlegrid.gridpoints-therep));
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
        yMatrix = reshape(yM,[sizeOfMatrix,sizeOfMatrix]);
        zMatrix = reshape(zM,[sizeOfMatrix,sizeOfMatrix]);
        cc = contourf(reflectionAxes,xMatrix,yMatrix,zMatrix,'EdgeColor', 'none');
        contourmap = get(reflectionAxes,'Children');
        colorbar(reflectionAxes);
        cmin = 600;
        cmax = 690;
        set(reflectionAxes,'XTickLabel','','YTickLabel','');
        set(contourmap,'PickableParts','all','ButtonDownFcn',@getMouseDownPosition);
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
            case {'Yes','yes'}
                lorG = maximumG(i)*(1/2*fwhmG(i)).^2./( (x-x_0G(i)).^2 + (1/2*fwhmG(i))^2);
                lorD = maximumD(i)*(1/2*fwhmD(i)).^2./( (x-x_0D(i)).^2 + (1/2*fwhmD(i))^2);
                lor2D = maximum1(i)*(1/2*fwhm1(i)).^2./( (x-x_01(i)).^2 + (1/2*fwhm1(i))^2);
                switch layerNumber
                    case {'Yes','yes',0, 'Buffer','buffer'} 
                        lor2D2 = maximum2(i)*(1/2*fwhm2(i)).^2./( (x-x_02(i)).^2 + (1/2*fwhm2(i))^2);
                        lor2D3 = maximum3(i)*(1/2*fwhm3(i)).^2./( (x-x_03(i)).^2 + (1/2*fwhm3(i))^2);
                end
        end
        switch showDprimePeak
            case 'Yes' % D prime peaks
                lorDp = maximumDp(i)*(1/2*fwhmDp(i)).^2./( (x-x_0Dp(i)).^2 + (1/2*fwhmDp(i))^2);
                switch fitsquest
                    case {'Yes','yes'} % Lorentzian fits and D prime peak
                        plot(ramanAxes,x(num),y_shifted_flattened_subtracted(num,i), ...
                            x(num),lorG(num), ...
                            x(num),lorD(num), ...
                            x(num),lorDp(num), ...
                            x(num),lor2D(num), ...
                            x(num),lorG(num)+lorD(num)+lorDp(num)+lor2D(num));
                        legend('Original','G','D','Dp','2D','Total');
                end
            otherwise % No D prime peaks
                switch fitsquest
                    case {'Yes','yes'}
                        switch layerNumber
                            case {'Yes','yes',0, 'Buffer','buffer'} % Lorentzian fits and three 2D peaks
                                plot(ramanAxes,x(num),y_shifted_flattened_subtracted(num,i), ...
                                    x(num),lorG(num), ...
                                    x(num),lorD(num), ...
                                    x(num),lor2D(num), ...
                                    x(num),lor2D2(num), ...
                                    x(num),lor2D3(num), ...
                                    x(num),lorG(num)+lorD(num)+lor2D(num)+lor2D2(num)+lor2D3(num));
                                legend('Original','G','D','2D_1','2D_2','2D_3','Total');
                            case {'No','no',1,'Mono','mono'} % Lorentzian fits and one 2D peaks
                                plot(ramanAxes,x(num),y_shifted_flattened_subtracted(num,i), ...
                                    x(num),lorG(num), ...
                                    x(num),lorD(num), ...
                                    x(num),lor2D(num), ...
                                    x(num),lorG(num)+lorD(num)+lor2D(num));
                                legend('Original','G','D','2D','Total');
                        end
                    otherwise % no lorentzian fits
                        plot(ramanAxes,x(num),y_shifted_flattened_subtracted(num,i));
                end
        end
        title(ramanAxes,sprintf('%d',i));
%         xlim([1400 1700])
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
