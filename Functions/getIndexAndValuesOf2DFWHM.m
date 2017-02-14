function [layerNumber, layersPossible, indLayers, numOfLayers, maximum,maxIndex, fwhm2Deq, x0] = getIndexAndValuesOf2DFWHM(xData,yData)
numOfPoints = size(yData,2);
if size(xData,1)>1
    xData = mean(xData,2);
end
n45 = 45;
endof2D = 2800;
if max(xData)< 2800
    endof2D = max(xData);
end
[maximum, maxIndex, fwhm2D, x0] = deal(zeros(1,numOfPoints));
for i = 1:numOfPoints
    [maximum(i), maxIndex(i), fwhm2D(i), x0(i)] = ...
        getLorentzianParameters([2600,endof2D],yData(:,i),xData);
end
maxfwhm = max(fwhm2D(fwhm2D<200));
if maxfwhm < 88
    maxLayer = round(-n45./(maxfwhm-88)) + 1;
else
    maxLayer = 15;
end
maxfwhm = -n45/maxLayer+88;
% disp(sprintf('Max layer set to %g',maxLayer));
fwhm2Deq = fwhm2D;
fwhm2Deq(fwhm2D>88 | fwhm2D <=10) = maxfwhm; %  replace with layer number 9
layerNumber = round(-n45./(fwhm2Deq-88));
layersPossible = unique(layerNumber);
indLayers = zeros(max(layersPossible),length(fwhm2D));
numOfLayers = zeros(1,length(layersPossible));
for i = layersPossible;
    indexes = find(layerNumber == i);
    indLayers(i,1:length(indexes)) = indexes;
    numOfLayers(i) = length(indexes);
end
end
