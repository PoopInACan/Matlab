%% Loading data
clear;
clc;
filename = '../../Data/Defect Positions on Raman/anisotropy_vs_step_length_values.txt';
formatSpec = '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, Inf);
fclose(fileID);
% distribute variables
[sampleName, ...
N, ...
sigma_N, ...
mu_x, ...
sigma_x, ...
mu_y, ...
sigma_y, ...
intercalationDone, ...
averageMobility, ...
m_eff, ...
t_coll, ...
mean_free_path, ...
terrace_width, ...
mfp_over_width, ...
anisotropy, ...
nothing] = deal(dataArray{:});
ind = find(mean_free_path>0);
%% Plot mean free path vs anisotropy
close all force
fig = figure('Units', 'pixels', ...
    'Position', [100 100 500 375]);
clf;
% errorbar(mean_free_path(ind)*1e9,anisotropy(ind)*100,15*ones(1,length(mean_free_path(ind))),'o')
plot(mean_free_path(ind)*1e9,anisotropy(ind)*100,'o')
xlabel('Mean free path (nm)');
ylabel('Anisotropy (% difference)');
prettyPlotLoop(figure(1),15,'yes')
% saveFigure(figure(1),'mean_free_path_vs_anisotropy2','png','/Users/kevme20/Box Sync/PhD/Experiment/Outputs/Presentationpng/')
% /Users/kevme20/Box Sync/PhD/Experiment/Outputs/Presentationpng/
% print('/Users/kevme20/Box Sync/PhD/Experiment/Outputs/Presentationpng/mean_free_path_vs_anisotropy','-dpng')

%% Plot mean free path over width vs anisotropy
figure(2);clf;
plot(mfp_over_width(ind),anisotropy(ind)*100,'o')
xlabel('mean free path/width');
ylabel('Anisotropy (% difference)');
prettyPlotLoop(figure(2),30,'yes')
% saveFigure(figure(1),'mean_free_path_vs
% print('/Users/kevme20/Box Sync/PhD/Experiment/Outputs/Presentationpng/mean_free_path_over_width_vs_anisotropy','-dpng')

%% Plot terrace width vs anisotropy
figure(3);clf;
plot(terrace_width(ind)*1e6,anisotropy(ind)*100,'o')
xlabel('Terrace width (\mum)');
ylabel('Anisotropy (% difference)');
prettyPlotLoop(figure(3),30,'yes')
% saveFigure(figure(1),'mean_free_path_vs
% print('/Users/kevme20/Box Sync/PhD/Experiment/Outputs/Presentationpng/terrace_width_vs_anisotropy','-dpng')

%% Plot mobility vs step length
close all force
fig = figure('Units', 'pixels', ...
    'Position', [500 100 750 605]);
clf;
% errorbar(mean_free_path(ind)*1e9,anisotropy(ind)*100,15*ones(1,length(mean_free_path(ind))),'o')
he = errorbar(log(mfp_over_width(ind)),mu_x(ind),sigma_x(ind),'o')
hold on;
errorbar(log(mfp_over_width(ind)),mu_y(ind),sigma_y(ind),'o')
ax = he.Parent;
legend('\mu_x','\mu_y')
for i = ind'
    text(log(i),max([mu_y(i),mu_x(i)])+150,num2str(sampleName(i)))
end
% xlabel('terrace width (\mum)');
ylabel('Mobility');
prettyPlotLoop(figure(1),15,'yes')
hold off;
saveFigure(figure(1),'mobility with error bars','png','/Users/kevme20/Box Sync/PhD/Experiment/Outputs/Presentationpng/')
% /Users/kevme20/Box Sync/PhD/Experiment/Outputs/Presentationpng/
% print('/Users/kevme20/Box Sync/PhD/Experiment/Outputs/Presentationpng/mean_free_path_vs_a
%%
ani = abs((mu_x(ind)-mu_y(ind))./((mu_x(ind)+mu_y(ind))/2));
ind = find(ani<.6);
ani = ani(ind);
x = abs(mean_free_path(ind)./(mean_free_path(ind)-terrace_width(ind)));
[a_fit,sig_a,yy,chisqr] = linreg(x',ani',ones(1,length(x)));
figure(1);clf;
plot(abs(mean_free_path(ind)./(mean_free_path(ind)-terrace_width(ind))),ani,'o',x,yy)
ylim([0 .5])