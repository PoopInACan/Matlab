clear;
clc;
close all force;
%%
subfolder = '/Users/kevme20/Downloads/xx19_sub/';
ls(subfolder);
files = dir([subfolder '*.sub']);
files = {files.name}.'
files = sort_nat(files);
%%
for i = 1:length(files)
    fileID = fopen([subfolder files{i}],'r');
    a = fscanf(fileID,'%f\t%f\n');
    fclose(fileID);
    x(:,i) = a(1:2:end);
    y(:,i) = a(2:2:end);
end
%%
figure(1);clf;
plot(x(:,3),y(:,3))
prettyPlotLoop(figure(1),14,'yes')