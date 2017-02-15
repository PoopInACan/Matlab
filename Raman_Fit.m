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
figure(1);clf;
plot(x,y_sample(:,1),x,y_reference(:,1))
legend('Data','Reference')
prettyPlotLoop(figure(1),14,'yes')
%% Interpolate points
tot = length(y_reference);
y_reference = y_reference(tot:-1:1);
y_sample = y_sample(tot:-1:1,:);
xnew = linspace(x(1),x(end),5000);
y_reference = interp1(x,y_reference,xnew,'spline');
y_reference = y_reference';
y_sample = interp1(x,y_sample,xnew,'spline');
x = xnew;
%% Plot after Interpolation of data points and reversal of x
figure(2);clf;
plot(xnew,y_sample(:,1),xnew,y_reference(:,1))
axis('tight')
legend('Data','Reference')
prettyPlotLoop(figure(2),14,'yes')

%%
[~,ind] = find( x > 1150 & x < 1950);
xfit = x(ind);
for i = 1:size(y_sample,2)
    for j = 1:60
        sums(j) = sum((y_reference(ind+j-31)-y_sample(ind,i)).^2);
    end
    [val,ind2]=min(sums);
    shiftnumber(i) = -1*(ind2-31);
end
y_reference = circshift(repmat(y_reference,[1,size(y_sample,2)]),shiftnumber);
maxshift = max(abs(shiftnumber));
tlength = length(y_reference);
y_reference = y_reference(1:(tlength-maxshift),:);
x = x(1:(tlength-maxshift));
y_sample = y_sample(1:(tlength-maxshift),:);
%% Find sections where graphene spectra isn't present
sameIndex = find(x < 1400 & x > 1100);
sameIndex2 = find(x > 1700 & x < 2400);
sameIndex3 = find(x > 3370 & x < 3500);
sameIndexTotal = [sameIndex sameIndex2 sameIndex3];
x2 = x(sameIndexTotal);
%% Plot sections of non-graphene spectra
figure(3);clf;
plot(x2,y_sample(sameIndexTotal),'.',x2,y_reference(sameIndexTotal),'.')
axis('tight')
legend('Data','Reference')
prettyPlotLoop(figure(2),14,'yes')
%% open vallery
subfolder = '/Users/kevme20/Downloads/xx19_sub/';
ls(subfolder);
files = dir([subfolder '*.sub']);
files = {files.name}.';
files = sort_nat(files);
for i = 1:length(files)
    fileID = fopen([subfolder files{i}],'r');
    av = fscanf(fileID,'%f\t%f\n');
    fclose(fileID);
    xv(:,i) = av(1:2:end);
    yv(:,i) = av(2:2:end);
end
%% Plot my spectrum vs vallery
n = 1;
X = [ones(length(x2),1) x2' x2'.^2 y_reference(sameIndexTotal,n)];
X2 = [ones(length(x),1) x' x'.^2 y_reference(:,n)];
a = X\y_sample(sameIndexTotal,n);
figure(5);clf;
plot(x,y_sample(:,n)-X2*a,xv(:,n),yv(:,n))
legend('mine','vallery')
% xlim([1400 1800])
prettyPlotLoop(figure(5),14,'yes')
%%
sigma = ones(1,length(x2));
%%
[a_fit, sig_a, yy, chisqr] = pollsf(x2, y_sample(sameIndexTotal,n)', sigma, 3)
%%