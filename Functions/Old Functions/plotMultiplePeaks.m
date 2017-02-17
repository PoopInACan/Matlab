clear;
clc;
load x930.mat
try
xi = ramX';
xi = xi';
end
%%
for i = 1:length(maxValue2D)
    lor2D(:,i) = maxValue2D(i)*(1/2*fwhm2D(i)).^2./( (xi-x0_2D(i)).^2 + (1/2*fwhm2D(i))^2);
    lorG(:,i)  = maxValueG(i)*(1/2*fwhmG(i)).^2./( (xi-x0_G(i)).^2 + (1/2*fwhmG(i))^2);
    lorD(:,i)  = maxValueD(i)*(1/2*fwhmD(i)).^2./( (xi-x0_D(i)).^2 + (1/2*fwhmD(i))^2);
end 
% peaks to fit
% newsam = yData;

%% Plot all 3
i1 = 75;
i2 = 4;
i3 = 263;
figS = figure(4);
clf;
hData = plot(...
    x, newsam(:,i1),'o', ...
    x, newsam(:,i2),'o', ...
    x, newsam(:,i3),'o');
titleName = '2D peaks of monolayer, bilayer, trilayer';
xmin = x0_2D(i1) - 2.5*fwhm2D(i1);
xmax = x0_2D(i1) + 2.5*fwhm2D(i1);
ymin = 0;
ymax = maxValue2D(i1) * 1.5;
axis([xmin xmax ymin ymax]);
hText = text(2640 ,ymax*.75, ...
    sprintf('Monolayer:\n2D Peak: %.1f cm^{-1}\n2D FWHM: %.1f cm^{-1}\nBilayer:\n2D Peak: %.1f cm^{-1}\n2D FWHM: %.1f cm^{-1}\nTrilayer:\n2D Peak: %.1f cm^{-1}\n2D FWHM: %.1f cm^{-1}',...
    xi(maxIndex2D(i1)),fwhm2D(i1),xi(maxIndex2D(i2)),fwhm2D(i2),xi(maxIndex2D(i3)),fwhm2D(i3)));
hTitle = title(titleName);
hXLabel = xlabel('Raman Shift (cm^{-1})');
hYLabel = ylabel('Intensity');
hLegend = legend('One Layer','Two Layers','Three Layers');
prettyPlotLoop(figS);
saveFigure(figS,'n');
%% Plot monolayer with its fit

i1 = 75;
i1 = 4;
% i1 = 177;
figM = figure(5);
clf;
hData = plot(...
    x, newsam(:,i1),'o', ...
    xi, lor2D(:,i1));
layer = 'Trilayer';
titleName = ['2D peak of ' layer];
xmin = x0_2D(i1) - 2.5*fwhm2D(i1);
xmax = x0_2D(i1) + 2.5*fwhm2D(i1);
ymin = 0;
ymax = maxValue2D(i1) * 1.2;
axis([-inf inf -inf inf])
axis([xmin xmax ymin ymax]);
hText = text(xmin*1.005 ,ymax*.75, ...
    sprintf([layer ':\n2D Peak: %.1f cm^{-1}\n2D FWHM: %.1f cm^{-1}'],...
    xi(maxIndex2D(i1)),fwhm2D(i1)));
hTitle = title(titleName);
hXLabel = xlabel('\omega (cm^{-1})');
hYLabel = ylabel('Intensity');
hLegend = legend(layer,'Lorentzian Fit');
prettyPlotLoop(figM)
% saveFigure(figM,'x930_2D_monolayer_fit');
