clear;
clc;
startingFolder = '../../Documents/Google Drive/Linkoping/Master Thesis/Data/Raman/';
spcFolder = uigetdir(startingFolder,['Pick Subtracted Folder with ".spc" files']);
if isequal(spcFolder,0)
    disp('you didnt choose a folder');
    return;
end
subtractedFolder = fileparts(spcFolder);
[~,sampleName] = fileparts(subtractedFolder);
[xData,yData] = loadSPCfolder(spcFolder);
% clearvars -except xData yData

n = size(yData,2);
grapheneOxide = [];
mixOfGrapheneAndGrapheneOxide = [];
nothing = [];
graphene = [];
for i = 1:n
    [maximum.goD(i), maxIndex.goD(i), fwhm.goD(i), x0.goD(i)] = getLorentzianParameters(1200:1400,yData(:,i),xData(:,i));
    [maximum.goG(i), maxIndex.goG(i), fwhm.goG(i), x0.goG(i)] = getLorentzianParameters(1450:1650,yData(:,i),xData(:,i));
    [maximum.go2D(i), maxIndex.go2D(i), fwhm.go2D(i), x0.go2D(i)] = getLorentzianParameters(2800:3000,yData(:,i),xData(:,i));
    [maximum.g2D(i), maxIndex.g2D(i), fwhm.g2D(i), x0.g2D(i)] = getLorentzianParameters(2600:3000,yData(:,i),xData(:,i));
    maxOfPeaks = max([maximum.goD(i),maximum.goG(i)]);
    if abs(maximum.goD(i)-maximum.goG(i)) < 0.3 * maxOfPeaks...
            & ~isequal(fwhm.goD(i),200)  & ~isequal(fwhm.goG(i),200)
        grapheneOxide = horzcat(grapheneOxide,i);
    elseif x0.g2D(i) > 2675 & x0.g2D(i) < 2750
        if x0.go2D(i)> 2890 & x0.go2D(i) < 2940
            mixOfGrapheneAndGrapheneOxide = horzcat(mixOfGrapheneAndGrapheneOxide,i);
        else
            graphene = horzcat(graphene,i);
        end
    else
        nothing = horzcat(nothing,i);
    end
end

% for i = nographeneOxideIndex
%     figure(1);
%     clf;
%     plot(xData(:,i),yData(:,i),'.',x0.goD(i),maximum.goD(i),'.',x0.goG(i),maximum.goG(i),'.')
%     legend('data','max','max2')
%     prettyPlotLoop(figure(1));
% end
for i = grapheneOxide
    figure(1);
    clf;
    plot(xData(:,i),yData(:,i),'.', ...
        x0.goD(i),maximum.goD(i),'.', ...
        x0.goG(i),maximum.goG(i),'.', ...
        x0.g2D(i),maximum.g2D(i),'.', ...
        x0.go2D(i),maximum.go2D(i),'m.')
    text(2900 ,500,sprintf('%3f',x0.go2D(i)));
    legend('data','D','G','2D','GO');
    axis([1200 3000 -inf inf]);
    prettyPlotLoop(figure(1));
    disp('hi');
end
goLayers/n*100

