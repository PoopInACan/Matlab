clear;
clc;
dbstop if error
yData = importdata('Original Raman Data/y938.txt');
x = importdata('xAxis.txt');
x = AngtoRamanShift(5318,x);
x = flipud(x);
xData = repmat(x,[1,size(yData,2)]);
%
[layerNumber, layersPossible, indLayers, numOfLayers, maximum_2D, maxIndex_2D, fwhm_2D, x0_2D] = getIndexAndValuesOf2DFWHM(xData,yData);
%% Plot monolayer with its fit
    figM = figure(5);
for i1 = [24,387,393]
    clf;
    lor2D = maximum_2D(i1)*(1/2*fwhm_2D(i1)).^2./( (x-x0_2D(i1)).^2 + (1/2*fwhm_2D(i1))^2);
    hData = plot(...
        x, yData(:,i1),'o',...
        x,lor2D);
    layer = 'Trilayer';
    titleName = ['2D peak of ' layer];
    xmin = x0_2D(i1) - 2.5*fwhm_2D(i1);
    xmax = x0_2D(i1) + 2.5*fwhm_2D(i1);
    ymin = 0;
    ymax = maximum_2D(i1) * 1.2;
    axis([-inf inf -inf inf])
    axis([xmin xmax ymin ymax]);
    hText = text(xmin*1.005 ,ymax*.75, ...
        sprintf([layer ':\n2D Peak: %.1f cm^{-1}\n2D FWHM: %.1f cm^{-1}'],...
        x(maxIndex_2D(i1)),fwhm_2D(i1)));
    hTitle = title(titleName);
    hXLabel = xlabel('\omega (cm^{-1})');
    hYLabel = ylabel('Intensity');
    hLegend = legend(layer,'Lorentzian Fit');
    prettyPlotLoop(figM)
    disp('hi');
    % saveFigure(figM,'x930_2D_monolayer_fit');
    
end
