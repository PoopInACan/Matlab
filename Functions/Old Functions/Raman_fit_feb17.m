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
xnew = linspace(x(1),x(end),4000);

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
sameIndex = find(x < 1200 & x > 1100);
sameIndex2 = find(x > 1700 & x < 2350);
sameIndex3 = find(x > 3370 & x < 3600);
sameIndexTotal = [sameIndex sameIndex2 sameIndex3];


x_nonGrapheneSpectra = x(sameIndexTotal);
y_shifted_reference = zeros(length(sameIndexTotal),k);
y_reference_new_nongraphene = zeros(length(sameIndexTotal),k);
y_sample_new_nongraphene = zeros(length(sameIndexTotal),k);
a = zeros(4,k);
%% Create Matrices for fitting
forX = [ones(length(x_nonGrapheneSpectra),1) x_nonGrapheneSpectra' x_nonGrapheneSpectra'.^2]; % a0 + a1*x + a2*x^2 + a3*reference
forX2 = [ones(length(x),1) x' x'.^2];
y_sample_new = zeros(size(y_sample));
%% Shift reference and subtract and find best combination of the two

shiftn = 31;
ind = find( x > 1442 & x < 1532); % indices of special spot we want to fit
for i = 1:size(y_sample,2)
    for j = 1:k
        y_shifted_reference(:,j) = y_reference(sameIndexTotal-shiftn+j);
        X = [forX y_shifted_reference(:,j)]; % matrix of non graphene spectra
        a(:,j) = X\y_sample(sameIndexTotal,i);
        y_reference_new_nongraphene(:,j) = X*a(:,j);
        y_sample_new_nongraphene(:,j) = y_sample(sameIndexTotal,i) - y_reference_new_nongraphene(:,j); % minimize this
    end
    [val,indOfMinShift] = min(sum(abs(y_sample_new_nongraphene)));
    yrr=circshift(y_reference,-1*indOfMinShift+shiftn); % circshift yref
    X2 = [forX2 yrr]; % matrix of total graphene spectra
    y_reference_new = X2*a(:,indOfMinShift);
    y_sample_new(:,i) = y_sample(:,i) - y_reference_new;
end
y_sample = y_sample_new;
% y_reference = circshift(repmat(y_reference,[1,size(y_sample,2)]),shiftnumber);
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
n = 2;
figure(5);clf;
plot(x,y_sample_new(:,n))
hold on;
% plot(xv(:,n),yv(:,n))
legend('mine1','vallery')
xlim([1400 1800])
hold off;
prettyPlotLoop(figure(5),14,'yes')
