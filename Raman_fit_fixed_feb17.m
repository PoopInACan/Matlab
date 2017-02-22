clear
close all force
clc;
%% Load Reference File
% y_reference
refN = 1;
refFiles = {'../../DataAnalysis/RamanTextFiles/yRef6H_20151008.txt', ... % 1
    '../../DataAnalysis/RamanTextFiles/yref.txt', ... % 2
    '../../DataAnalysis/RamanTextFiles/y6HRef.txt',... % 3
    '../../DataAnalysis/RamanTextFiles/y4Href160628.txt', ... % 4
    };
y_reference =  importfile(refFiles{refN}); % Import reference
yrefOriginal = y_reference;
y_reference = mean(yrefOriginal,2); % Take average of reference

%% Load Data File
% y_sample
[filename, pathname] = uigetfile({'*.*','All Files' },'mytitle',...
    '/Users/kevme20/Box Sync/PhD/Experiment/DataAnalysis/RamanTextFiles/y19.txt');
%     pathname = '/Users/kevme20/Box Sync/PhD/Experiment/DataAnalysis/RamanTextFiles/';
%     filename = 'y934.txt';
switch filename
    case 0 % User selected nothing
        disp('User selected Cancel')
        return;
    otherwise
        disp(['User selected ', fullfile(pathname, filename)])
        y_sample = importfile(fullfile(pathname,filename));
end
disp(['Importing file: ' filename ]);
prompt = {'Save to mat?:', ...
'Fit Peaks?', ...
'Mono or Buffer?'};
dlg_title = 'Input';
num_lines = 1;
defaultans = { ...
    'yes', ... % Save File?
    'No', ... % Fit lorentzians?
    'Mono'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
if isempty(answer)
    return;
else
    [saveFile,fitsquest,layerNumber] = deal(answer{:});
end
%% Load X axis points
% x
x = importdata('../../DataAnalysis/RamanTextFiles/xAxis.txt');
x = AngtoWavenumbers(5318,x);
disp('Import data')
%% Plot before manipulation
% figure(1);clf;
% plot(x,y_sample(:,1),x,y_reference(:,1))
% legend('Data','Reference')
% prettyPlotLoop(figure(1),14,'yes')
%% Interpolate points
tot = length(y_reference);
y_reference = y_reference(tot:-1:1);
y_sample = y_sample(tot:-1:1,:);
xnew = linspace(x(1),x(end),20000);

y_reference = interp1(x,y_reference,xnew,'spline');
y_reference = y_reference';
y_sample = interp1(x,y_sample,xnew,'spline');
x = xnew;
%% Plot after Interpolation of data points and reversal of x
% figure(2);clf;
% plot(xnew,y_sample(:,1),xnew,y_reference(:,1))
% axis('tight')
% legend('Data','Reference')
% prettyPlotLoop(figure(2),14,'yes')
%% Find sections where graphene spectra isn't present
k = 60;
sameIndex = find(x > 1100 & x < 1200);
sameIndex2 = find(x > 1700 & x < 2350);
sameIndex3 = find(x > 3370 & x < 3600);
% sameIndex = [];
% sameIndex2 = [];
% sameIndex3 = [];
% sameIndexTotal = [sameIndex sameIndex2 sameIndex3];
sameIndex4 = find(x > 1442 & x < 1532);
% sameIndex4 = [];
sameIndexTotal = [ sameIndex sameIndex4 sameIndex2 sameIndex3  ];

x_nonGrapheneSpectra = x(sameIndexTotal);
y_shifted_reference = zeros(length(sameIndexTotal),k);
y_reference_new_nongraphene = zeros(length(sameIndexTotal),k);
y_sample_new_nongraphene = zeros(length(sameIndexTotal),k);
a = zeros(4,k);
%% Create Matrices for fitting
forX = [ones(length(x_nonGrapheneSpectra),1) x_nonGrapheneSpectra' x_nonGrapheneSpectra'.^2]; % a0 + a1*x + a2*x^2 + a3*reference
forX2 = [ones(length(x),1) x' x'.^2]; % matrix for all points
y_sample_new = zeros(size(y_sample));
y_sample2 = medfilt1(y_sample,10);

%% Shift reference and subtract and find best combination of the two

shiftn = 31;
% ind = find( x > 1442 & x < 1532); % indices of special spot we want to fit
for i =  1:size(y_sample,2)
    for j = -30:29
        y_shifted_reference(:,j+shiftn) = y_reference(sameIndexTotal+j);
        X = [forX y_shifted_reference(:,j+shiftn)]; % matrix of non graphene spectra
        a(:,j+31) = X\y_sample2(sameIndexTotal,i);
        y_reference_new_nongraphene(:,j+shiftn) = X*a(:,j+shiftn);
        y_sample_new_nongraphene(:,j+shiftn) = y_sample2(sameIndexTotal,i) - y_reference_new_nongraphene(:,j+shiftn); % minimize this
    end
    %     ind = find(x > 1442 & x < 1552);
    ind = 1:length(sameIndexTotal);
    deriv1 = diff(y_sample_new_nongraphene(ind,:));
    [~,indOfMinShift] = min(sum(deriv1.^2));
%         [~,indOfMinShift] = min((max(y_sample_new_nongraphene(ind,:))-min(y_sample_new_nongraphene(ind,:))).^2);
    %     [val,indOfMinShift] = min(sum(abs(y_sample_new_nongraphene)));
    yrr = circshift(y_reference,-1*(indOfMinShift-shiftn+1)); % circshift yref
    X1 = [forX2 yrr]; % matrix of total graphene spectra
    y_reference_new = X1*a(:,indOfMinShift);
    y_sample_new(:,i) = y_sample(:,i) - y_reference_new;
%     yrr2 = circshift(y_reference,-1*(indOfMinShift-shiftn)); % circshift yref
%     X2 = [forX2 yrr2]; % matrix of total graphene spectra
%     y_reference_new2 = X2*a(:,indOfMinShift);
%     y_sample_new2(:,i) = y_sample(:,i) - y_reference_new2;
%     yrr3 = circshift(y_reference,-1*(indOfMinShift-shiftn-1)); % circshift yref
%     X3 = [forX2 yrr3]; % matrix of total graphene spectra
%     y_reference_new3 = X3*a(:,indOfMinShift);
%     y_sample_new3(:,i) = y_sample(:,i) - y_reference_new3;
end
y_sample = y_sample_new;

% y_reference = circshift(repmat(y_reference,[1,size(y_s1ample,2)]),shiftnumber);
% maxshift = max(abs(shiftnumber));
% tlength = length(y_reference);
% y_reference = y_reference(1:(tlength-maxshift),:);
% x = x(1:(tlength-maxshift));
% y_sample = y_sample(1:(tlength-maxshift),:);
%% open vallery files
subfolder = '/Users/kevme20/Downloads/xx19_sub/';
files = dir([subfolder '*.sub']);
files = {files.name}.';
files = sort_nat(files);
xv = zeros(2000,length(files));
yv = zeros(2000,length(files));
for i = 1:length(files)
    fileID = fopen([subfolder files{i}],'r');
    av = fscanf(fileID,'%f\t%f\n');
    fclose(fileID);
    xv(:,i) = av(1:2:end);
    yv(:,i) = av(2:2:end);
end
%% Plot my spectra vs vallery
n = 21;
figure(5);clf;
plot(x,y_sample_new(:,n))
hold on;
plot(xv(:,n),yv(:,n))
legend('mine1','vallery')
xlim([1400 1800])
hold off;
prettyPlotLoop(figure(5),14,'yes')
%% fit peaks
switch fitsquest
    case {'Yes','yes'}
        disp('Fitting all peaks')
        [ x_01,maximum1,fwhm1, ...
            x_02,maximum2,fwhm2, ...
            x_03,maximum3,fwhm3, ...
            x_0D,maximumD,fwhmD, ...
            x_0G,maximumG,fwhmG, ...
            x_0Dp,maximumDp,fwhmDp] = peakFitFuncBufferx3( x,y_sample,layerNumber);
    otherwise
        disp('Not fitting peaks')
        [x_0Dp,maximumDp,fwhmDp] = deal(ones(1,size(y_sample,2)));

        
end

%% clear and save file
y = y_sample;
clearvars -except 'y' 'x' ...
    'maximum_G'  'maxIndex_G'  'fwhm_G'  'x0_G' ...
    'maximum_D'  'maxIndex_D'  'fwhm_D'  'x0_D' ...
    'x_0D' 'maximumD' 'fwhmD' ...
    'x_0G' 'maximumG' 'fwhmG' ...
    'x_01' 'maximum1' 'fwhm1' ...
    'x_02' 'maximum2' 'fwhm2' ...
    'x_03' 'maximum3' 'fwhm3' ...
    'x_0D' 'maximumD' 'fwhmD' ...
    'x_0Dp' 'maximumDp' 'fwhmDp' ...
    'fitsquest' 'filename' 'refN' ...
    'saveFile' 'layerNumber';
switch saveFile
    case {'Yes','yes'}
        [pathstr,name,ext] = fileparts(filename);
        saveName = strrep(name,'y','');
        addpath('../../Data/mat/');
        save(['../../Data/mat/' saveName '_' num2str(refN)]);
end
close all force;
disp('Done');
% putvar('y_sample', ...
%     'maximum_G', 'maxIndex_G', 'fwhm_G', 'x0_G',...
%     'maximum_D', 'maxIndex_D', 'fwhm_D', 'x0_D',...
%     'x_0D','maximumD','fwhmD','x_0G','maximumG','fwhmG',...
%     'x_01','maximum1','fwhm1',...
%     'x_02','maximum2','fwhm2',...
%     'x_03','maximum3','fwhm3',...
%     'x_0D','maximumD','fwhmD',...
%     'x_0Dp','maximumDp','fwhmDp',...
%     'x_0G','maximumG','fwhmG','fitsquest','filename','refN','tsum', 'layerNumber');