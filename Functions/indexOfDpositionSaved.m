function indexOfDpositionSaved
fig = figure(8);clf;
% set(fig,'KeyPressFcn',@pressSpaceToSaveIndexToFile)
addpath('../../Data/mat/*');
addpath('../../Data/Defect Positions on Raman/');
matFile = dir('../../Data/mat/*.mat');
if length(matFile) > 1
    names1 = struct2cell(matFile);
    [s,didSelectFile] = listdlg('PromptString','Select a Raman file:',...
        'SelectionMode','single',...
        'ListString',names1(1,:)');
    if isequal(didSelectFile,0) % if no mat file was selected, exit program
        disp('No Raman file was chosen');
        close all force;
        return; 
    end
    ramanFileName = names1{1,s};
    theVariables = load(['../../Data/mat/' ramanFileName]);
end
fitsquest = theVariables.fitsquest;
defect_filename = '../../Data/Defect Positions on Raman/x3_defect_positions.txt';
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



%%
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

sliderHandle = uicontrol('Style', 'slider',...
    'Units', 'normalized',...
    'Tag','slidertag',...
    'Min',1,...
    'Max',numSteps,...
    'KeyPressFcn',@pressSpaceToSaveIndexToFile, ...
    'Value',1,...
    'SliderStep',[1/(numSteps-1) , 1/(numSteps-1) ],...
    'Callback', @plotValueInTextBox,...
    'Position',[0.1276    0.9200    0.3577    0.0568]);
% for i = 1:size(y_shifted_flattened_subtracted,2)
plotValueInTextBox(sliderHandle)
disp('hi')
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
                        plot(x(num),y_shifted_flattened_subtracted(num,i), ...
                            x(num),lorG(num), ...
                            x(num),lorD(num), ...
                            x(num),lorDp(num), ...
                            x(num),lor2D(num), ...
                            x(num),lorG(num)+lorD(num)+lorDp(num)+lor2D(num));
                    otherwise
                        plot(x(num),y_shifted_flattened_subtracted(num,i), ...
                            x(num),lorDp(num), ...
                end
            otherwise
                switch fitsquest
                    case 'Yes'
                        plot(x(num),y_shifted_flattened_subtracted(num,i), ...
                            x(num),lorG(num), ...
                            x(num),lorD(num), ...
                            x(num),lor2D(num), ...
                            x(num),lorG(num)+lorD(num)+lor2D(num));
                    otherwise
                        plot(x(num),y_shifted_flattened_subtracted(num,i));
                end
        end
        % axis([1212 3348 -800 3600])
        %                 xlim([1200 2000]);
        %         hLegend = legend('Data','G','D','Dp','2D','Total');
        %         text(1500,maximumG(i)/2,sprintf('%f',maximumD(i)/maximumG(i)));
        %         set(hLegend,'Location','north')
        title(sprintf('%d',i));
        prettyPlotLoop(figure(8),14,'no')
    end

    function pressSpaceToSaveIndexToFile(source,eventdata)
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
        elseif isequal(eventdata.Character,'d')
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
            values = setdiff(values1,i);
            fprintf(fileID,fmt,values);
            if l < nl
                disp(sprintf('Removed: %2.0f',i));
            end
            fclose(fileID);
        end
    end
putvar('xv','yv','x','y')
end
