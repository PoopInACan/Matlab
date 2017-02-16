clear;
clc;
filename = '../../Data/Defect Positions on Raman/anisotropy_vs_step_length_values.txt';
formatSpec = '%f\t%f\t%f\t%f\t%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, Inf);
fclose(fileID);
% distribute variables
[sampleName, ...
N, ...
mu_x, ...
mu_y, ...
intercalationDone, ...
averageMobility, ...
m_eff, ...
t_coll, ...
mean_free_path, ...
terrace_width, ...
mfp_over_width, ...
anisotropy, ...
nothing] = deal(dataArray{:});
%%
ind = find(mean_free_path>0);
%% Plot mean free path vs anisotropy
figure(1);clf;
plot(mean_free_path(ind)*1e9,anisotropy(ind)*100,'o')
xlabel('Mean free path (nm)');
ylabel('Anisotropy (% difference)');
prettyPlotLoop(figure(1),30,'yes')
saveFigure(figure(1),'mean_free_path_vs_anisotropy2','png','/Users/kevme20/Box Sync/PhD/Experiment/Outputs/Presentationpng/')
% /Users/kevme20/Box Sync/PhD/Experiment/Outputs/Presentationpng/
% print('/Users/kevme20/Box Sync/PhD/Experiment/Outputs/Presentationpng/mean_free_path_vs_anisotropy','-dpng')

%% Plot mean free path vs anisotropy
figure(2);clf;
plot(mfp_over_width(ind),anisotropy(ind)*100,'o')
xlabel('mean free path/width');
ylabel('Anisotropy (% difference)');
prettyPlotLoop(figure(2),30,'yes')
% saveFigure(figure(1),'mean_free_path_vs
% print('/Users/kevme20/Box Sync/PhD/Experiment/Outputs/Presentationpng/mean_free_path_over_width_vs_anisotropy','-dpng')

%% Plot terrace width vs anisotropy
figure(1);clf;
plot(terrace_width(ind)*1e6,anisotropy(ind)*100,'o')
xlabel('Terrace width (\mum)');
ylabel('Anisotropy (% difference)');
prettyPlotLoop(figure(2),30,'yes')
% saveFigure(figure(1),'mean_free_path_vs
% print('/Users/kevme20/Box Sync/PhD/Experiment/Outputs/Presentationpng/terrace_width_vs_anisotropy','-dpng')

