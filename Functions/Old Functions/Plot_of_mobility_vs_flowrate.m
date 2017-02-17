clear;
clc;
x = [10,7,4.2,2];
mux = [1662  1986 2127 1386];
muy = [1859 1889 1915 1560];
figure1 = figure(1);
clf;
p1 = plot(x,mux,'ro')
p1.MarkerFaceColor = 'red';
hold on;
p2 = plot(x,muy,'bo')
p2.MarkerFaceColor = 'blue';
legend('\mu_x','\mu_y');
hylabel = ylabel('Charge carrier mobility [cm^2 (Vs)^{-1}]');
hxlabel = xlabel('Argon flow rate [Liter/min]');
prettyPlotLoop(figure1,22,'no')
set([hxlabel hylabel],'FontSize',24)
%% Save Figures
theChoice = questdlg('Save Figures?','Save Figures?','Yes','No','No');
switch theChoice
    case 'Yes'
        saveFigure(figure1,'ChargeCarrierMobility.png','-dpng','/Users/kevme20/Downloads/')
    otherwise
end