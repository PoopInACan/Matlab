function multipleLorentzianFit
a = load('lorentzianSample930.mat');
v2struct(a); % loads in variables
clear a;
tLength = 1:length(fwhm2D);
xMin = 800;
xMax = 3500;
index_of_monolayers = find(fwhm2D < 54.25);
index_of_bilayers = find(fwhm2D > 54.25 & fwhm2D < 69.25);
for i = 1:1681
%     range_of_2D_peak = find(xi > xMin & xi < xMax);
range_of_2D_peak = 1:4000;
    lorentzianFit = maxValue2D(i).*(1/2*fwhm2D(i)).^2./( (xi-x0_2D(i)).^2 + (1/2*fwhm2D(i)).^2);
    square_of_errors = (intY(range_of_2D_peak,i)'-lorentzianFit(range_of_2D_peak)).^2;
    sumsq = sum(square_of_errors);
    sumtot = sum(lorentzianFit(range_of_2D_peak));
    figure(2);
    clf;
    plot(xi(range_of_2D_peak),intY(range_of_2D_peak,i))
    title(sampleName);
    text(2600,maxValue2D(i),sprintf('FWHM: %.3f\nindex: %4.0f\n%:%.3f',fwhm2D(i),i,sumsq/sumtot));
%     axis([xMin xMax 0 maxValue2D(i)*1.2]);
    axis([min(xi), max(xi) 0 inf]);
%     hLegend = legend('Data','Fit');
    pause(1);
end
putvar('range_of_2D_peak','index_of_bilayers');

%% Show contour plot
if isempty(fwhm2D)
    disp('Fit Lorentzian first');
else
    prompt = {'Enter matrix size:'};
    dlg_title = 'Number of points along one side';
    num_lines = 1;
    def =  {sprintf('%3d',floor(sqrt(length(fwhm2D))))};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    newanswer = cell2mat(answer);
    sizeOfRaman = str2double(newanswer);
    %% 2D peaks
    % FWHM(2D) = -45(1/N)+88 cm^-1 from Raman Spectra of Epitaxial Graphene on SiC and of Epitaxial Graphene Transferred to SiO2
    % FWHM(1-4 layers) = [43   65.5   73   76.75]
    rFWHM = [fwhm2D; fwhmG];
    peakP = [xi(maxIndex2D); xi(maxIndexG)];
    fwhm = [fwhm2D; fwhmG; xi(maxIndex2D); xi(maxIndexG)];
    titleD = {'2D FWHM of '; 'G FWHM of '; '2D Peak Position of '; 'G Peak Position of '};
    fileD = {'2DRamanPeaks'; 'GRamanPeaks'; '2DPeakPosition'; 'GPeakPosition'};
    layer1middleMatrix = [43; 31.3; 2743; 1607];
    layerPeakInputs = [-45./(1:4)+88; 0 0 0 0; 2744 2724 2711 2705; 1607 1585 1583 1578]; % 1, 2, 6, HOPG
    layerRangeMatrix = [10; 5; 5; 3];
    for i = 1:length(fwhm(:,1))
        z = fwhm(i,:);
        a = padarray(z,[0, sizeOfRaman^2-length(z)],'post');
        fwhmReshaped = reshape(a,[sizeOfRaman,sizeOfRaman]);
        if i == 1 % 2D FWHM is fit with parameters in layerPeakInputs
            maxFWHM = 150;
            layer1middle = layerPeakInputs(i,1);
            layer2middle = layerPeakInputs(i,2);
            layer3middle = layerPeakInputs(i,3);
            hopgMiddle = layerPeakInputs(i,4);
            layer1Max = (layer1middle+layer2middle)/2;
            layer2Min = layer1Max;
            layer2Max = (layer2middle+layer3middle)/2;
            layer3Min = layer2Max;
            layer3Max = (layer3middle+hopgMiddle)/2;
            layer4Min = layer3Max;
            percentZero = percentInRange(z,maxFWHM,maxFWHM*1000); % determine zero layers by large z instead of peak position
            percentSingle = percentInRange(z,0,layer1Max); % peak is above halfway point between 1 and 2 layers
            percentDouble = percentInRange(z,layer2Min,layer2Max);
            percentTriple = percentInRange(z,layer3Min,layer3Max);
            percenthopg = percentInRange(z,layer4Min,maxFWHM);
        elseif i == 2 % G FWHM is fit with user parameters
            layer1middle = layer1middleMatrix(i);
            layerRange = layerRangeMatrix(i)*2;
            layer2middle = layer1middle+layerRange;
            layer3middle = layer2middle+layerRange;
            numberOfZeroLayers = length(z(z>layer3middle+layerRange/2 | z<layer1middle-layerRange/2));
            numberOfSingleLayers = length(z(z<layer1middle+layerRange/2 & z>layer1middle-layerRange/2));
            numberOf2Layers = length(z(z<layer2middle+layerRange/2 & z>layer2middle-layerRange/2));
            numberOf3Layers = length(z(z<layer3middle+layerRange/2 & z>layer3middle-layerRange/2));
            percentZero = numberOfZeroLayers/length(z);
            percentSingle = numberOfSingleLayers/length(z);
            percentDouble = numberOf2Layers/length(z);
            percentTriple = numberOf3Layers/length(z);
            percenthopg = 0;
        else % fitting positions of 2D and G peak
            maxFWHM = 150;
            layer1middle = layerPeakInputs(i,1);
            layer2middle = layerPeakInputs(i,2);
            layer3middle = layerPeakInputs(i,3);
            hopgMiddle = layerPeakInputs(i,4);
            numberOfZeroLayers = length(fwhm(fwhm(i-2,:) > maxFWHM)); % determine zero layers by large fwhm instead of peak position
            numberOfSingleLayers = length(z(z > layer1Max & fwhm(i-2,:) < maxFWHM)); % peak is above halfway point between 1 and 2 layers
            numberOf2Layers = length(z(z > layer2Max & z < layer1Max & fwhm(i-2,:) < maxFWHM));
            numberOf3Layers = length(z(z > layer3Max & z < layer2Max & fwhm(i-2,:) < maxFWHM));
            numberOfhopgLayers = length(z(z < layer3Max & fwhm(i-2,:) < maxFWHM));
            percentZero = numberOfZeroLayers/length(z);
            percentSingle = numberOfSingleLayers/length(z);
            percentDouble = numberOf2Layers/length(z);
            percentTriple = numberOf3Layers/length(z);
            percenthopg = numberOfhopgLayers/length(z);
        end
        name = sampleName;
        contourFigure = figure(2); % create new figure
        subplot(2,2,i) % first subplot
        contourf(fwhmReshaped,'EdgeColor', 'none');
        colorbar;
        colormap('Hot');
        title(sprintf([titleD{i} name '\n0Layer: %.3g%%\n 1 Layer: %.3g%%\n2 Layers: %.3g%%\n3 Layers: %.3g%%\nHOPG: %.3g%%'],percentZero*100,percentSingle*100,percentDouble*100,percentTriple*100,percenthopg*100));
    end
    set(contourFigure,'Units','normalized','Position',[0.2891    0.0675    0.7109    0.8125]);
    
    
end


