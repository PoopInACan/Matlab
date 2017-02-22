clear;
clc;
close all force;
%%
load ../../Data/mat/19_1.mat
%%
subfolder = '/Users/kevme20/Downloads/xx19_sub/';
files = dir([subfolder '*.sub']);
files = {files.name}.';
files = sort_nat(files);
%%
xv = zeros(2000,length(files));
yv = zeros(2000,length(files));
for i = 1:length(files)
    fileID = fopen([subfolder files{i}],'r');
    a = fscanf(fileID,'%f\t%f\n');
    fclose(fileID);
    xv(:,i) = a(1:2:end);
    yv(:,i) = a(2:2:end);
end
%%
n=11;
figure(1);clf;
plot(xv(:,n),yv(:,n))
hold on;
plot(x,y(:,n))
xlim([1400 1700])
prettyPlotLoop(figure(1),14,'yes')
legend('vallery','mine')
hold off;