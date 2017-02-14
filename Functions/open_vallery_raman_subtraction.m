clear;
clc;
close all force;
%%
ls './subtracted/'
files = dir('./subtracted/*.sub');
files = {files.name}.'
files = sort_nat(files);
%%
for i = 1:length(files)
    fileID = fopen(files{i},'r');
    a = fscanf(fileID,'%f\t%f\n');
    fclose(fileID);
    x(:,i) = a(1:2:end);
    y(:,i) = a(2:2:end);
end
%%
figure(1);clf;
plot(x(:,1),y(:,1))
prettyPlotLoop(figure(1),14,'yes')