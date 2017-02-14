% plotSubtractedSPCFiles
clear;
clc;
close all force;
dbstop if error
xData = load('xAxis.txt');
ramX = AngtoRamanShift(5318,xData);
[xBuffer,yBuffer] = importDataThiefTextFile('bufferLayerCorrected.txt');
[xOxide,yOxide] = importDataThiefTextFile('grapheneOxide.txt');
[x,y] = importDataThiefTextFile('pristineGrapheneOxide1L_1200to1750.txt');
[a,b] = importDataThiefTextFile('pristineGrapheneOxide1L_2500to3500.txt');
%% 936 load
spcFolder = '../../Documents/Google Drive/Linkoping/Master Thesis/Data/Raman/x936/Subtracted/';
if isequal(spcFolder,0)
    return; % if cancel was pressed, exit callback
else
    [xData,x936] = loadSPCfolder(spcFolder);
end
if isequal(xData(:,1),[1:2000]')
    ramX = AngtoRamanShift( 5318, x ); % Angstroms to Raman shift
else
    ramX = xData(:,1);
end
%% 946 load
spcFolder = '../../Documents/Google Drive/Linkoping/Master Thesis/Data/Raman/x946/Raman map/Subtracted/';
if isequal(spcFolder,0)
    return; % if cancel was pressed, exit callback
else
%     x946 = loadSPCfolder(spcFolder);
    x946 = importfile('y946.txt');
end
if isequal(xData(:,1),[1:2000]')
    ramX = AngtoRamanShift( 5318, x ); % Angstroms to Raman shift
else
    ramX = xData(:,1);
end
%% 934 load
spcFolder = './Raman Maps/x934_2/Subtracted/';
if isequal(spcFolder,0)
    return; % if cancel was pressed, exit callback
else
    x934 = loadSPCfolder(spcFolder);
end
if isequal(xData(:,1),[1:2000]')
    ramX = AngtoRamanShift( 5318, x ); % Angstroms to Raman shift
else
    ramX = xData(:,1);
end
%% 949 load
spcFolder = '../../Documents/Google Drive/Linkoping/Master Thesis/Data/Raman/x949/Subtracted/';
if isequal(spcFolder,0)
    return; % if cancel was pressed, exit callback
else
    x949 = loadSPCfolder(spcFolder);
end
if isequal(xData(:,1),[1:2000]')
    ramX = AngtoRamanShift( 5318, x ); % Angstroms to Raman shift
else
    ramX = xData(:,1);
end
%% normalize data
for i = 1:length(x946(1,:))
    x946(:,i) = x946(:,i)/sum(x946(:,i));
    x936(:,i) = x936(:,i)/sum(x936(:,i));
    x949(:,i) = x949(:,i)/sum(x949(:,i));
end
for i = 1:size(x934,2)
    x934(:,i) = x934(:,i)/sum(x934(:,i));
end

%% G and D comparison
for i = 1
    myfig = figure(2); clf;
    p1 = 1355;
    p2 = 1597;
    p3 = 1494;
    myData = plot(...
        ramX,x934(:,i)+.004,'.',...
        ramX,x936(:,93)+.0065,'.',...
        ramX,x946(:,i)+.009,'.',...
        ramX,x949(:,i)+.0105,'.',...
        xBuffer,yBuffer/18+.001,'.',...
        x,y/norm(y)/20,'r.',...
        repmat(p1,[1,100]),linspace(0,.25,100),'-.',...
        repmat(p2,[1,100]),linspace(0,.25,100),'-.',...
        repmat(p3,[1,100]),linspace(0,.25,100),'-.');
    hL = legend('x934','x936','x946','x949','Fromm et al.','Graphene Oxide')
    xlabel('Raman shift cm^{-1}');
    ylabel('Intensity');
    ax = gca;
%     GTextBox = text(1700,.06, sprintf('G Peak: %2f cm^{-1}\nG FWHM: %2f cm^{-1}',x0_G(i),fwhmG(i)));
%     TwoDTextBox = text(2650,.06, sprintf('2D Peak: %2f cm^{-1}\n2D FWHM: %2f cm^{-1}',x0_2D(i),fwhm2D(i)));
    axis([1200 1700 0 .016])
%     axis('tight')
    allobj = findobj(myfig);
    title('Buffer Layer Comparison with Graphene Oxide');
    ax.XTick = sort([1100,1200,p1,p3,p2,1700,1800]);
    prettyPlotLoop(myfig);
    disp('hi');
    set(hL,'FontSize',12);
    goColor = get(findobj('DisplayName','Graphene Oxide'),'Color');
end
% saveFigure(myfig,'/Users/Kevin/Documents/Google Drive/Linkoping/Master Thesis/Thesis/Figures/raman/bufferLayerOverlayTotal');
%% 2D spectra comparison
n = 1000:1800;
for i = 1
    grapheneOxideFig = figure(3); clf;
    p1 = 1355;
    p2 = 1597;
    p3 = 1494;
    hp = plot(ramX(n),x934(n,i)+.0005,'.',...
        ramX(n),x936(n,25),'.',...
        ramX(n),x946(n,i)+.00025,'.',...
        ramX(n),x949(n,i)+.0008,'.',...
        a,.0005+b/60,'r.');
    hL = legend('x934','x936','x946','x949','Graphene Oxide');
    xlabel('Raman shift cm^{-1}');
    ylabel('Intensity');
    ax = gca;
    axis([2400 3400 0 inf])
%     GTextBox = text(1700,.06, sprintf('G Peak: %2f cm^{-1}\nG FWHM: %2f cm^{-1}',x0_G(i),fwhmG(i)));
%     TwoDTextBox = text(2650,.06, sprintf('2D Peak: %2f cm^{-1}\n2D FWHM: %2f cm^{-1}',x0_2D(i),fwhm2D(i)));
%     axis([2000,inf,0,.002])
    allobj = findobj(myfig);
    title('2D peaks vs Graphene Oxide');
%     ax.XTick = sort([1100,1200,p1,p3,p2,1700,1800]);
    prettyPlotLoop(grapheneOxideFig);
    disp('hi');
    hL.FontSize = 12;
end
% saveFigure(grapheneOxideFig,'/Users/Kevin/Documents/Google Drive/Linkoping/Master Thesis/Thesis/Figures/raman/grapheneOxideComparison');
