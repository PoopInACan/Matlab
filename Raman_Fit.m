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
xnew = linspace(x(1),x(end),20000);
for k = 1:21
xnew2 = x+0.15*(k-11);

y_reference = interp1(x,y_reference,xnew,'linear');
y_reference = y_reference';
% y_sample = interp1(x,y_sample,xnew,'linear');
% x = xnew;x
%% Plot after Interpolation of data points and reversal of x
% figure(2);clf;
% plot(xnew,y_sample(:,1),xnew,y_reference(:,1))
% axis('tight')
% legend('Data','Reference')
% prettyPlotLoop(figure(2),14,'yes')
%% Shift reference
<<<<<<< HEAD
shiftn = 27;
[~,ind1] = find( x > 1442 & x < 1532);
% [~,ind2] = find(x > 1700 & x < 2350);
ind3 = ind1 ;
xfit = x(ind3);
=======
shiftn = 28;
[~,ind] = find( x > 1100 & x < 1950);
xfit = x(ind);
>>>>>>> parent of f858f2b... Save before attempt to combine shift and subtraction
for i = 1:size(y_sample,2)
    for j = 1:60
        sums(j) = sum((y_reference(ind+j-31)-y_sample(ind,i)).^2);
    end
<<<<<<< HEAD
    [val,ind2]=min(sums);
    shiftnumber(i) = -1*(ind3-shiftn);
=======
    [val,ind2]=min(abs(sums));
    shiftnumber(i) = -1*(ind2-shiftn);
>>>>>>> parent of f858f2b... Save before attempt to combine shift and subtraction
end
y_reference = circshift(repmat(y_reference,[1,size(y_sample,2)]),shiftnumber);
maxshift = max(abs(shiftnumber));
tlength = length(y_reference);
y_reference = y_reference(1:(tlength-maxshift),:);
x = x(1:(tlength-maxshift));
y_sample = y_sample(1:(tlength-maxshift),:);
%% Find sections where graphene spectra isn't present
<<<<<<< HEAD
sameIndex = find(x < 1000 & x > 1200);
sameIndex2 = find(x > 1650 & x < 2400);
sameIndex3 = find(x > 3370 & x < 3700);
=======
sameIndex = find(x < 1400 & x > 1100);
sameIndex2 = find(x > 1700 & x < 2400);
sameIndex3 = find(x > 3370 & x < 3500);
>>>>>>> parent of f858f2b... Save before attempt to combine shift and subtraction
sameIndexTotal = [sameIndex sameIndex2 sameIndex3];
x_nonGrapheneSpectra = x(sameIndexTotal);
%% Plot sections of non-graphene spectra
figure(3);clf;
plot(x_nonGrapheneSpectra,y_sample(sameIndexTotal),'.',x_nonGrapheneSpectra,y_reference(sameIndexTotal),'.')
axis('tight')
legend('Data','Reference')
prettyPlotLoop(figure(2),14,'yes')
%% Subtract reference from sample
forX = [ones(length(x_nonGrapheneSpectra),1) x_nonGrapheneSpectra' x_nonGrapheneSpectra'.^2]; % a0 + a1*x + a2*x^2 + a3*reference
forX2 = [ones(length(x),1) x' x'.^2];
ynew = zeros(size(y_sample));
y_reference_new = zeros(size(y_reference));
for i = 1:size(y_sample,2)
    X = [forX y_reference(sameIndexTotal,i)];
    X2 = [forX2 y_reference(:,i)];
    a = X\y_sample(sameIndexTotal,i);
    y_reference_new(:,i) = X2*a;
    ynew(:,i) = y_sample(:,i)-X2*a;
end
%% open vallery files
subfolder = '/Users/kevme20/Downloads/xx19_sub/';
ls(subfolder);
files = dir([subfolder '*.sub']);
files = {files.name}.';
files = sort_nat(files);
%
for i = 1:length(files)
    fileID = fopen([subfolder files{i}],'r');
    av = fscanf(fileID,'%f\t%f\n');
    fclose(fileID);
    xv(:,i) = av(1:2:end);
    yv(:,i) = av(2:2:end);
end


end
%% Plot my spectra vs vallery
n = 85;
figure(5);clf;
plot(x,ynew(:,n),xv(:,n),yv(:,n))
legend('mine1','vallery')
xlim([1400 1800])
% prettyPlotLoop(figure(5),14,'yes')
