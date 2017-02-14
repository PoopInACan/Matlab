function Raman_fit_with_minimized_errors(filename)
%% Reference file
refN = 4;
refFiles = {'../../DataAnalysis/RamanTextFiles/yRef6H_20151008.txt', ... % 1
    '../../DataAnalysis/RamanTextFiles/yref.txt', ... % 2
    '../../DataAnalysis/RamanTextFiles/y6HRef.txt',... % 3
    '../../DataAnalysis/RamanTextFiles/y4Href160628.txt', ... % 4
    };
yref =  importfile(refFiles{refN}); % import reference
yrefOriginal = yref;
yref = mean(yrefOriginal,2); % Take average of reference

%% Data file
if nargin < 1
%     [filename, pathname] = uigetfile('../../DataAnalysis/RamanTextFiles/*.txt', 'Select a text file');
    pathname = '/Users/kevme20/Box Sync/PhD/Experiment/DataAnalysis/RamanTextFiles/';
    filename = 'y22.txt';
    if isequal(filename,0)
        disp('User selected Cancel')
    else
        disp(['User selected ', fullfile(pathname, filename)])
        yoriginal = importfile(fullfile(pathname,filename));
    end
else
    yoriginal = importfile(filename);
end

%% x-axis
x = importdata('../../DataAnalysis/RamanTextFiles/xAxis.txt');
x = AngtoWavenumbers(5318,x);
disp('Import data')
%% Before anything
% figure(1);clf;
% plot(x,yoriginal(:,1),x,yref(:,1))

%% Interpolate
[yoriginal,yref,x] = interp_points(yoriginal,yref,x);
disp('Interpolate data')

%% Shift reference on x-axis
[yref_shifted, y_shifted,x,shiftnumber] = shiftReference(yoriginal,yref,x);
disp('Shift reference')

%% After shift
% figure(2);clf;
% num =find(x>1189 & x < 3144);
% plot(x(num),y_shifted(num,1),x(num),yref_shifted(num,1))
% plot(x,y_shifted(:,1),x,yref_shifted(:,1))

%% Flatten data
[y_shifted_flattened, yref_shifted_flattened] = flattenData(y_shifted,yref_shifted,x);
disp('Flatten data and reference')

%% After flatten
% figure(3);clf;
% num =find(x>1189 & x < 3144);
% plot(x(num),y_shifted_flattened(num,1),x(num),yref_shifted_flattened(num,1))

%% Multiply height of reference
[yref_shifted_flattened_multiply,multiplyFactor] = multiplyHeightOfReference(y_shifted_flattened,yref_shifted_flattened,x);
disp('Multiply height of reference')

%% After multiply
% figure(4);clf;
% num =find(x>1189 & x < 3144);
% plot(x(num),yref_shifted_flattened_multiply(num,1),x(num),y_shifted_flattened(num,1))
% axis([1670,1740,4950 18000])
% legend('ref','data')
% subtData = subtractRefFromData(yflat,yref);
% yReady = filterSpikesFromData(subtData);

%% Subtraction
y_shifted_flattened_subtracted = y_shifted_flattened - yref_shifted_flattened_multiply;
disp('Subtract background')

%% After subtraction
% datavallery = importfile('/Users/kevme20/Documents/MATLAB/subtracted_xx10/xx10Ra_cc-2.sub');
% figure(8);clf;
% num =find(x>1189 & x < 3444);
% plot(x(num),2*y_shifted_flattened_subtracted(num,2),datavallery(:,1),datavallery(:,2))
% axis([1212 3348 -800 3600])
% hLegend = legend('mine','vallery');
% set(hLegend,'Location','north')
% title('Plus 0');
% prettyPlotLoop(figure(8),14,'no')

%%
disp('Fitting all peaks')

y = y_shifted_flattened_subtracted;
y_shifted_flattened_subtracted = medfilt1(y_shifted_flattened_subtracted,70);
[ ...
    layerNumber,  ...
    layersPossible,  ...
    indLayers,  ...
    numOfLayers,  ...
    maximum_2D,  ...
    maxIndex_2D,  ...
    fwhm_2D,  ...
    x0_2D] = getIndexAndValuesOf2DFWHM(x,y_shifted_flattened_subtracted);
hwaitbar = waitbar(0,'Initializing waitbar...');
pause(0.1);
tic;
sizey = size(yoriginal,2);
for n = 1:sizey
    [ maximum_G(n),  maxIndex_G(n),  fwhm_G(n),  x0_G(n)] = getLorentzianParameters([1550,1650],y_shifted_flattened_subtracted(:,n),x);
    [ maximum_Dp(n),  maxIndex_Dp(n),  fwhm_Dp(n),  x0_Dp(n)] = getLorentzianParameters([ x0_G(n)+5, x0_G(n)+105],y_shifted_flattened_subtracted(:,n),x);
    [ maximum_D(n),  maxIndex_D(n),  fwhm_D(n),  x0_D(n)] = getLorentzianParameters([1300,1450],y_shifted_flattened_subtracted(:,n),x);
    [ maximum_DDp(n),  maxIndex_DDp(n),  fwhm_DDp(n),  x0_DDp(n)] = getLorentzianParameters([2800,3050],y_shifted_flattened_subtracted(:,n),x);
    time_elapsed = toc;
    time_left = time_elapsed*sizey/n - time_elapsed;
    hwaitbar = waitbar(n/sizey, hwaitbar,['Time left: ' sprintf('%.2d',floor(time_left/60)) ':' sprintf('%.2d',floor(mod(time_left,60))) ]);
end
close(hwaitbar);
%% Functions

    function [data,yref,xnew] = interp_points(data,yref,x)
        tot = length(yref);
        yref = yref(tot:-1:1);
        data = data(tot:-1:1,:);
        xnew = linspace(x(1),x(end),20000);
        yref = interp1(x,yref,xnew,'spline');
        yref = yref';
        data = interp1(x,data,xnew,'spline');
    end

    function [yref,data,x,shiftnumber] = shiftReference(data,yref,x)
        
        gmax = find(x>1675 & x<1900);
        [~, index_yref] = max(yref(gmax));
        [~, index_y] = max(data(gmax,:));
        shiftnumber = index_y - index_yref-1;
        yref = circshift(repmat(yref,[1,size(data,2)]),shiftnumber);
        %         yref = yref(1:end-max(abs(shiftnumber)),:);
        %         x = x(1:end-max(abs(shiftnumber)));
    end

    function [data,yref] = flattenData(data,yref,x)
        %         flatIndex = find(x>2217 & x<2218); % bad
        flatIndex = [];
        %         flatIndex = find(x==2217);
        flatIndex2 = find(x > 2800 & x < 3600);
        flatIndexMonolayer = find(x > 3100 & x < 3150);
        flatIndexMonolayer1 = find(x > 3369 & x < 3600);
        a = [flatIndex,flatIndex2];
        b = [flatIndex,flatIndexMonolayer,flatIndexMonolayer1];
        % yref and data flatten
        sigmaref = ones(length(yref(a,:)),1);
        xfitref = x(a);
        sigmadata = ones(length(data(b,1)),1);
        xfitdata = x(b);
        filteredData = medfilt1(data,100);
        yref_with_subtraction = ones(size(yref));
        data_with_subtraction = yref_with_subtraction;
        yfitref = medfilt1(yref([flatIndex flatIndex2],1),100);
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
        data = data_with_subtraction;
        yref = yref_with_subtraction;
    end

    function [adjref, multiplyFactor] = multiplyHeightOfReference(data,yref,x)
        fitIndex2 = find(x > 1200 & x < 1250); % this area should be the same on
        fitIndex2 = find(x > 3100 & x < 3150); % this area should be the same on
        fitIndex3 = find(x > 1650 & x < 2400); % this area should be the same on
        fitIndex = [fitIndex2 fitIndex3];
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

    function [ x_0,maximum,fwhm,numLayers,layer0,layer1,layer2,layer3,layer4,ind0,ind1,ind2,ind3,ind4,NLayers] = calculateLorentzianParameters(x,y,answer)
        if isequal(answer, 1)
            [ x_0,maximum,fwhm,numLayers,layer0,layer1,layer2,layer3,layer4,ind0,ind1,ind2,ind3,ind4,NLayers] = peakFitFunc( x,y );
        end
    end

%% Put var in workspace
putvar('y','yref','y_shifted','yref_shifted','x','shiftnumber','y_shifted_flattened','yref_shifted_flattened','yref_shifted_flattened_multiply','multiplyFactor','y_shifted_flattened_subtracted', 'layerNumber', 'layersPossible', 'indLayers', 'numOfLayers', 'maximum_2D', 'maxIndex_2D', 'fwhm_2D', 'x0_2D', 'maximum_G', 'maxIndex_G', 'fwhm_G', 'x0_G', 'maximum_Dp', 'maxIndex_Dp', 'fwhm_Dp', 'x0_Dp', 'maximum_D', 'maxIndex_D', 'fwhm_D', 'x0_D', 'maximum_DDp', 'maxIndex_DDp', 'fwhm_DDp', 'x0_DDp' );
end