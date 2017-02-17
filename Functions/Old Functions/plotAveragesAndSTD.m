clear;
clc;
close all;

load 930average.mat
load 933average.mat
load 936average.mat
load 937average.mat
load 938average.mat
load 941average.mat
load 942average.mat
load 984average.mat
load 993average.mat
load 995average.mat
load intRatios.mat

dbstop if error
A = 1:3;
B = 1:4;
A933 = 1:5;
A993 = [1,2,4];
A938 = [1,3,4];
fig5 = figure(5);
clf;
hold on;
ss = 45;

av2DFWHM933(find(av2DFWHM933==0)) = -ss./find(av2DFWHM933==0)+88;
av2DFWHM930(find(av2DFWHM930==0)) = -ss./find(av2DFWHM930==0)+88;
av2DFWHM984(find(av2DFWHM984==0)) = -ss./find(av2DFWHM984==0)+88;
av2DFWHM938(find(av2DFWHM938==0)) = -ss./find(av2DFWHM938==0)+88;
xAxis942 = -ss./(av2DFWHM942-88);
xAxis933 = -ss./(av2DFWHM933-88);
xAxis930 = -ss./(av2DFWHM930-88);
xAxis941 = -ss./(av2DFWHM941(A)-88);
xAxis936 = -ss./(av2DFWHM936(A)-88);
xAxis993 = -ss./(av2DFWHM993(A993)-88);
xAxis984 = -ss./(av2DFWHM984(B)-88);
xAxis937 = -ss./(av2DFWHM937(A)-88);
xAxis938 = -ss./(av2DFWHM938-88);
xAxis993 = -ss./(av2DFWHM993(A993)-88);
xAxis995 = -ss./(av2DFWHM995(B)-88);





%% 2D FWHM
errorbar(xAxis930,av2DFWHM930,std2DFWHM930,'o');
errorbar(xAxis933(A933),av2DFWHM933(A933),std2DFWHM933(A933),'o');
errorbar(xAxis936,av2DFWHM936(A),std2DFWHM936(A),'o');
errorbar(xAxis937,av2DFWHM937(A),std2DFWHM937(A),'o');
errorbar(xAxis938(A938),av2DFWHM938(A938),std2DFWHM938(A938),'o');
errorbar(xAxis941,av2DFWHM941(A),std2DFWHM941(A),'o');
errorbar(xAxis942,av2DFWHM942,std2DFWHM942,'o');
errorbar(xAxis984,av2DFWHM984(B),std2DFWHM984(B),'^');
errorbar(xAxis993,av2DFWHM993(A993),std2DFWHM993(A993),'^');
errorbar(xAxis995,av2DFWHM995(B),std2DFWHM995(B),'^');

title('2D FWHM');
xlabel('Number of layers');
ylabel('\omega (cm^{-1})');
legend('930','933','936','937','938','941','942','984','993','995');
prettyPlotLoop(fig5,14,'yes');
hold off;
%% 2D POS
fig2 = figure(2);
clf;
hold on;
errorbar(xAxis930,av2DPOS930,std2DPOS930,'o');
errorbar(xAxis933(A933),av2DPOS933(A933),std2DPOS933(A933),'o');
errorbar(xAxis936,av2DPOS936(A),std2DFWHM936(A),'o');
errorbar(xAxis937,av2DPOS937(A),std2DFWHM937(A),'o');
errorbar(xAxis938(A938),av2DPOS938(A938),std2DFWHM938(A938),'o');
errorbar(xAxis941,av2DPOS941(A),std2DFWHM941(A),'o');
errorbar(xAxis942,av2DPOS942,std2DPOS942,'o');
errorbar(xAxis984,av2DPOS984(B),std2DFWHM984(B),'^');
errorbar(xAxis993,av2DPOS993(A993),std2DFWHM993(A993),'^');
errorbar(xAxis995,av2DPOS995(B),std2DFWHM995(B),'^');

title('2D Peak Position');
xlabel('Number of layers')
ylabel('\omega (cm^{-1})');
legend('930','933','936','937','938','941','942','984','993','995');
prettyPlotLoop(fig2,14,'yes');
hold off
%% G POS
fig3 = figure(3);
clf;
hold on;
errorbar(xAxis930,avGPOS930,stdGPOS930,'o');
errorbar(xAxis933(A933),avGPOS933(A933),stdGPOS933(A933),'o');
errorbar(xAxis936,avGPOS936(A),stdGPOS936(A),'o');
errorbar(xAxis937,avGPOS937(A),stdGPOS937(A),'o');
errorbar(xAxis938(A938),avGPOS938(A938),stdGPOS938(A938),'o');
errorbar(xAxis941,avGPOS941(A),stdGPOS941(A),'o');
errorbar(xAxis942,avGPOS942,stdGPOS942,'o');
errorbar(xAxis984,avGPOS984(B),stdGPOS984(B),'^');
errorbar(xAxis993(2:end),avGPOS993(A993(2:end)),stdGPOS993(A993(2:end)),'^');
errorbar(xAxis995,avGPOS995(B),stdGPOS995(B),'^');

legend('930','933','936','937','938','941','942','984','993','995');
title('G Peak Position');
xlabel('Number of layers')
ylabel('\omega (cm^{-1})');
prettyPlotLoop(fig3,14,'yes');
hold off;
%% G FWHM
fig4 = figure(4);
clf;
hold on;
errorbar(xAxis930,avGFWHM930,stdGFWHM930,'o');
errorbar(xAxis933(A933),avGFWHM933(A933),stdGFWHM933(A933),'o');
errorbar(xAxis936([1,3]),avGFWHM936([1,3]),stdGFWHM936([1,3]),'o');
errorbar(xAxis937,avGFWHM937(A),stdGFWHM937(A),'o');
errorbar(xAxis938(1),avGFWHM938(1),stdGFWHM938(1),'o');
errorbar(xAxis941,avGFWHM941(A),stdGFWHM941(A),'o');
errorbar(xAxis942,avGFWHM942,stdGFWHM942,'o');
errorbar(xAxis984,avGFWHM984(B),stdGFWHM984(B),'^');
errorbar(xAxis993,avGFWHM993(A993),stdGFWHM993(A993),'^');
errorbar(xAxis995,avGFWHM995(B),stdGFWHM995(B),'^');


title('G FWHM');
xlabel('Number of layers')
ylabel('\omega (cm^{-1})');
legend('930','933','936','937','938','941','942','984','993','995');
prettyPlotLoop(fig4,14,'yes');
hold off;
%% INTENSITY
C = 1:5;

intFig = figure(7);
clf;
hold on;
errorbar(xAxis930(C),avIntRatio930(C), stdIntRatio930(C),'o')
errorbar(xAxis933(A933),avIntRatio933(A933), stdIntRatio933(A933),'o')
errorbar(xAxis936(A),avIntRatio936(A), stdIntRatio936(A),'o')
errorbar(xAxis941(A),avIntRatio941(A), stdIntRatio941(A),'o')
errorbar(xAxis942(A),avIntRatio942(A), stdIntRatio942(A),'o')
errorbar(xAxis937(A),avIntRatio937(A), stdIntRatio937(A),'o')
errorbar(xAxis938(A938),avIntRatio938(A938), stdIntRatio938(A938),'o')
errorbar(xAxis984(B),avIntRatio984(B), stdIntRatio984(B),'^')
errorbar(xAxis993,avIntRatio993(A993), stdIntRatio993(A993),'^')
errorbar(xAxis995(B),avIntRatio995(B), stdIntRatio995(B),'^')

xlabel('Number of Layers');
ylabel('I_{2D}/I_{G}');
legend('930','933','936','937','938','941','942','984','993','995');
title('Intensity Ratio of 2D/G vs Number of Layers');
prettyPlotLoop(intFig,14,'yes');
hold off;
%% Save Figures
theChoice = questdlg('Save Figures?','Save Figures?','Yes','No','No');
switch theChoice
    case 'Yes'
        saveFigure(fig2,'2DPOS')
        saveFigure(fig4,'GFWHM')
        saveFigure(fig3,'GPOS')
        saveFigure(fig5,'FWHM2D')
        saveFigure(intFig,'intRatio')
    otherwise
end

