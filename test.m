% clear;
% clc;
% load('test')
% %%
% [~,ind] = find( x > 1450 & x < 1950);
% xfit = x(ind);
% %%
% figure(1);
% plot(xfit,yref(ind),xfit,data(ind,1))
% %%
% 
% for i = 1:60
%     sums(i) = sum((yref(ind+i-31)-data(ind,1)).^2);
% end
% [val,ind2]=min(sums);
% newind = ind2-31;
% B = circshift(yref,-newind);
% %%
% figure(2);
% plot(xfit,B(ind),xfit,data(ind,1))
% ls '/Users/kevme20/Box Sync/PhD/Experiment/DataAnalysis/RamanTextFiles/*';
% ls '/Users/kevme20/Box Sync/PhD/Experiment/Data/ReflectionMaps/*Ra*'
%%
% clear;
% clc;
% % Find filename
% samplename = '19';
% totalname = ['/Users/kevme20/Box Sync/PhD/Experiment/DataAnalysis/RamanTextFiles/*' samplename '*.txt'];
% %
% f = dir(totalname); % to find
% %
% 
% if length(f) > 1
%     f(1).name = questdlg(['Which reflection file do you want to open with ' samplename '?'],'',f(1).name,f(2).name,f(1).name);
%     if isequal(f(1).name,'')
%         disp('No sample was chosen');
%         close all force;
%         return;
%     end
% end
% if isempty(f)
%     disp(['There is no sample ' samplename]);
%     return;
% end
% [pathstr,name,ext] = fileparts(['/Users/kevme20/Box Sync/PhD/Experiment/DataAnalysis/RamanTextFiles/' f(1).name]);
% %
% filename = [pathstr '/' name ext];
% refN = 1;
% fitsquest = 'Yes1';
% saveFile = 'Yes1';
% layerNumber = 0;
% 
% %
% Raman_fit_of_Buffer_layer_with_minimized_errors(filename,refN,fitsquest,saveFile,layerNumber)
%%
n = 11;
figure(1);
clf;
plot(x,y_sample_new(:,n))
hold on;
plot(x,y_sample_new2(:,n))
plot(x,y_sample_new3(:,n))
xlim([1450 1750]);
legend('+1','0','-1')
%%
figure(2);
clf;

plot(x_nonGrapheneSpectra(ind),y_sample_new_nongraphene_filtered(:,48),'.')
hold on;
plot(x_nonGrapheneSpectra(ind),y_sample_new_nongraphene_filtered(:,47),'.')
plot(x_nonGrapheneSpectra(ind),y_sample_new_nongraphene_filtered(:,46),'.')
hold off;
legend('+1','0','-1')


