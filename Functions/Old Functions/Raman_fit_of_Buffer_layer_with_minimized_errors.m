function Raman_fit_of_Buffer_layer_with_minimized_errors(filename,refN,fitsquest,saveFile,layerNumber)
%% Reference file
if nargin < 3
    fitsquest = questdlg('Fit Peaks?','Fit Peaks?','Yes','No','No');
    saveFile = questdlg('Save to mat?','Save to mat?','Yes','No','Yes');
    layerNumber = questdlg('Buffer or Mono','Buffer or Mono?','Yes','No','Yes');
    refN = 1;
end

refFiles = {'../../DataAnalysis/RamanTextFiles/yRef6H_20151008.txt', ... % 1
    '../../DataAnalysis/RamanTextFiles/yref.txt', ... % 2
    '../../DataAnalysis/RamanTextFiles/y6HRef.txt',... % 3
    '../../DataAnalysis/RamanTextFiles/y4Href160628.txt', ... % 4
    };
yref =  importfile(refFiles{refN}); % Import reference
yrefOriginal = yref;
yref = mean(yrefOriginal,2); % Take average of reference

%% Data file
if nargin < 1
    [filename, pathname] = uigetfile({'*.*','All Files' },'mytitle',...
        '/Users/kevme20/Box Sync/PhD/Experiment/DataAnalysis/RamanTextFiles/y941.txt');
    %     pathname = '/Users/kevme20/Box Sync/PhD/Experiment/DataAnalysis/RamanTextFiles/';
    %     filename = 'y934.txt';
    if isequal(filename,0)
        disp('User selected Cancel')
        return;
    else
        disp(['User selected ', fullfile(pathname, filename)])
        yoriginal = importfile(fullfile(pathname,filename));
    end
else
    yoriginal = importfile(filename);
end
disp(['Importing file: ' filename ]);
 sz = size(yoriginal,2); 
 %%
 datetime
 estimatedSecondsToCompletion = sz*1.4739 - 28;
 minutesToCompletion = floor(estimatedSecondsToCompletion/60);
 secondsToCompletion = floor(rem(estimatedSecondsToCompletion/60,minutesToCompletion)*60);
 disp(sprintf('Estimated Completion in: %d min and %d seconds',minutesToCompletion,secondsToCompletion));
 currentTime = clock;
 minToComp = currentTime(5) + minutesToCompletion;
 secToComp = floor(currentTime(6) + secondsToCompletion);
 hourToComp = currentTime(4);

 if floor(currentTime(6) + secondsToCompletion) >= 60
     minToComp = currentTime(5) + minutesToCompletion + 1;
     secToComp = floor(currentTime(6) + secondsToCompletion) - 60;
 end
 if minToComp >= 60
     minToComp = minToComp - 60;
     hourToComp = hourToComp + 1;
 end
 if hourToComp >= 12
     hourToComp = hourToComp - 12;
 end
 disp(sprintf('Estimated Completion at: %2d:%2d:%2d',hourToComp,minToComp,secToComp));
 %% x-axis
x = importdata('../../DataAnalysis/RamanTextFiles/xAxis.txt');
x = AngtoWavenumbers(5318,x);
disp('Import data')
%% Before anything
figure(1);clf;
plot(x,yoriginal(:,1),x,yref(:,1))
legend('Data','Reference')

%% Interpolate
[yoriginal,yref,x] = interp_points(yoriginal,yref,x);
disp('Interpolate data')

%% Shift reference on x-axis
[yref_shifted, y_shifted,x,shiftnumber] = shiftReference(yoriginal,yref,x);
disp('Shift reference')

%% After shift
figure(2);clf;
num =find(x>1189 & x < 3144);
plot(x(num),y_shifted(num,1),x(num),yref_shifted(num,1))
plot(x,y_shifted(:,1),x,yref_shifted(:,1))

%% Flatten data
[y_shifted_flattened, yref_shifted_flattened] = flattenData(y_shifted,yref_shifted,x);
disp('Flatten data and reference')

%% After flatten
figure(3);clf;
num =find(x>1189 & x < 3144);
plot(x(num),y_shifted_flattened(num,1),x(num),yref_shifted_flattened(num,1))

%% Multiply height of reference
[yref_shifted_flattened_multiply,multiplyFactor] = multiplyHeightOfReference(y_shifted_flattened,yref_shifted_flattened,x);
disp('Multiply height of reference')

%% After multiply
figure(4);clf;
num =find(x>1189 & x < 3144);
plot(x(num),yref_shifted_flattened_multiply(num,1),x(num),y_shifted_flattened(num,1))
axis([1670,1740,4950 18000])
legend('ref','data')
% subtData = subtractRefFromData(yflat,yref);
% yReady = filterSpikesFromData(subtData);

%% Subtraction
y_shifted_flattened_subtracted = y_shifted_flattened - yref_shifted_flattened_multiply;
disp('Subtract background')

%% After subtraction
figure(8);clf;
num =find(x>1189 & x < 3444);
plot(x(num),y_shifted_flattened_subtracted(num,3))
hLegend = legend('mine');
set(hLegend,'Location','north')
title('Plus 0');
prettyPlotLoop(figure(8),14,'no')
tsum = sum(sum(abs(y_shifted_flattened_subtracted)));

%% Fitting peaks

y = y_shifted_flattened_subtracted;

switch fitsquest
    case 'Yes'
        disp('Fitting all peaks')
        [ x_01,maximum1,fwhm1, ...
            x_02,maximum2,fwhm2, ...
            x_03,maximum3,fwhm3, ...
            x_0D,maximumD,fwhmD, ...
            x_0G,maximumG,fwhmG, ...
            x_0Dp,maximumDp,fwhmDp] = peakFitFuncBufferx3( x,y,layerNumber);
    otherwise
        disp('Not fitting peaks')

end

%% Functions

    function [data,yref,xnew] = interp_points(data,yref,x)
        tot = length(yref);
        yref = yref(tot:-1:1);
        data = data(tot:-1:1,:);
        xnew = linspace(x(1),x(end),5000);
        yref = interp1(x,yref,xnew,'spline');
        yref = yref';
        data = interp1(x,data,xnew,'spline');
    end

    function [yref,data,x,shiftnumber] = shiftReference(data,yref,x)
        
        %          gmax = find(x>1500 & x<1530);
        %          [~, index_yref] = max(yref(gmax));
        %          [~, index_y] = max(data(gmax,:));
        %          shiftnumber = index_y - index_yref;
        [~,ind] = find( x > 1450 & x < 1950);
        xfit = x(ind);
        for i = 1:size(data,2)
            for j = 1:60
                sums(j) = sum((yref(ind+j-31)-data(ind,i)).^2);
            end
            [val,ind2]=min(sums);
            shiftnumber(i) = -1*(ind2-31);
        end
        yref = circshift(repmat(yref,[1,size(data,2)]),shiftnumber);
        maxshift = max(abs(shiftnumber));
        tlength = length(yref);
        yref = yref(1:(tlength-maxshift),:);
        x = x(1:(tlength-maxshift));
        data = data(1:(tlength-maxshift),:);
        
        %         yref = yref(1:end-max(abs(shiftnumber)),:);
        %         x = x(1:end-max(abs(shiftnumber)));
    end

    function [data,yref] = flattenData(data,yref,x)
        %         flatIndex = find(x>2217 & x<2218); % bad
        flatIndex = find(x > 2800 & x < 3600);;
        %         flatIndex = find(x==2217);
        flatIndex2 = find(x > 2800 & x < 3600);
        flatIndexMonolayer = find(x > 2198 & x < 2200);
        flatIndexMonolayer1 = find(x > 3369 & x < 3600);
        a = [flatIndex,flatIndex2];
        b = [flatIndexMonolayer flatIndexMonolayer1];
        % yref and data flatten
        sigmaref = ones(length(a),1);
        xfitref = x(a);
        sigmadata = ones(length(b),1);
        xfitdata = x(b);
        filteredData = medfilt1(data,100);
        yref_with_subtraction = ones(size(yref));
        data_with_subtraction = yref_with_subtraction;
        yfitref = medfilt1(yref([flatIndex flatIndex2],1),100);
        [a_fit, sig_a, yy, chisqr] = pollsf(xfitref, yfitref', sigmaref', 3)
        [a_fitref, ~, ~, ~] = linreg(xfitref',yfitref,sigmaref);
        %         yyref = a_fitref(1) + a_fitref(2)*x;
        yyref =  a_fitref(2)*x;
        
        yref_with_subtraction = yref - repmat(yyref',[1,size(data,2)]);
        yydata = zeros(size(data));
        for k = 1:size(data,2) %[498 565 1275 1279] %
            yfitdata = filteredData(b,k);
            [a_fitdata, ~, ~, ~] = linreg(xfitdata',yfitdata, sigmadata);
            %             yydata(:,k) = a_fitdata(1) + a_fitdata(2)*x;
            yydata(:,k) = a_fitdata(2)*x;
            data_with_subtraction(:,k) = data(:,k) - yydata(:,k);
        end
        data = data_with_subtraction; % Comment out for not flatten
        yref = yref_with_subtraction; % Comment out for not flatten
        
    end

    function [adjref, multiplyFactor] = multiplyHeightOfReference(data,yref,x)
        fitIndex2 = find(x > 1200 & x < 1250); % this area should be the same on
        fitIndex2 = find(x > 3100 & x < 3150); % this area should be the same on
        fitIndex3 = find(x > 1700 & x < 2300); % this area should be the same on
        fitIndex = [ fitIndex3];
        %         both graphs...there is only a SiC signal here
        % Fit with a constant
        %         figure(1);clf;plot(x,data(:,1),x(fitIndex3),data(fitIndex3,1),x(fitIndex3),yref(fitIndex3,1))
        A = [yref(fitIndex,:)  ones(size(yref(fitIndex,:)))];
        b = data(fitIndex,:);
        xsolution = A\b;
        adjref = [yref ones(size(yref))] * xsolution;
        multiplyFactor = mean(mean(xsolution));
        %         putvar('xsolution','adjref','x','yref','data');
        return;
    end



%% Put var in workspace
switch fitsquest
    case 'Yes'
        clearvars -except 'y' 'yref' 'y_shifted' 'yref_shifted' 'x' 'shiftnumber' 'y_shifted_flattened' ...
            'yref_shifted_flattened' 'yref_shifted_flattened_multiply' 'multiplyFactor' ...
            'y_shifted_flattened_subtracted' ...
            'maximum_G'  'maxIndex_G'  'fwhm_G'  'x0_G' ...
            'maximum_D'  'maxIndex_D'  'fwhm_D'  'x0_D' ...
            'x_0D' 'maximumD' 'fwhmD' 'x_0G' 'maximumG' 'fwhmG' ...
            'x_01' 'maximum1' 'fwhm1' ...
            'x_02' 'maximum2' 'fwhm2' ...
            'x_03' 'maximum3' 'fwhm3' ...
            'x_0D' 'maximumD' 'fwhmD' ...
            'x_0Dp' 'maximumDp' 'fwhmDp' ...
            'x_0G' 'maximumG' 'fwhmG' 'fitsquest' 'filename' 'refN' 'tsum' 'saveFile' 'layerNumber';
        
        putvar('y','yref','y_shifted','yref_shifted','x','shiftnumber','y_shifted_flattened',...
            'yref_shifted_flattened','yref_shifted_flattened_multiply','multiplyFactor', ...
            'y_shifted_flattened_subtracted',...
            'maximum_G', 'maxIndex_G', 'fwhm_G', 'x0_G',...
            'maximum_D', 'maxIndex_D', 'fwhm_D', 'x0_D',...
            'x_0D','maximumD','fwhmD','x_0G','maximumG','fwhmG',...
            'x_01','maximum1','fwhm1',...
            'x_02','maximum2','fwhm2',...
            'x_03','maximum3','fwhm3',...
            'x_0D','maximumD','fwhmD',...
            'x_0Dp','maximumDp','fwhmDp',...
            'x_0G','maximumG','fwhmG','fitsquest','filename','refN','tsum', 'layerNumber');
    otherwise
        clearvars -except 'y' 'yref' 'y_shifted' 'yref_shifted' 'x' 'shiftnumber' 'y_shifted_flattened' ...
            'yref_shifted_flattened' 'yref_shifted_flattened_multiply' 'multiplyFactor'  ...
            'y_shifted_flattened_subtracted' 'fitsquest' 'filename' 'refN' 'tsum' 'saveFile' 'layerNumber';
        
        putvar('y','yref','y_shifted','yref_shifted','x','shiftnumber','y_shifted_flattened',...
            'yref_shifted_flattened','yref_shifted_flattened_multiply','multiplyFactor', ...
            'y_shifted_flattened_subtracted','fitsquest','filename','refN','tsum', 'layerNumber');
end

switch saveFile
    case 'Yes'
        [pathstr,name,ext] = fileparts(filename)
        saveName = strrep(name,'y','');
        addpath('../../Data/mat/');
        save(['../../Data/mat/' saveName '_' num2str(refN)]);
end
close all force;
disp('Done');
%     'maximum_2D', 'maxIndex_2D', 'fwhm_2D', 'x0_2D',...
%    'maximum_DDp', 'maxIndex_DDp', 'fwhm_DDp', 'x0_DDp','maximum_Dp', 'maxIndex_Dp', 'fwhm_Dp', 'x0_Dp',...
end