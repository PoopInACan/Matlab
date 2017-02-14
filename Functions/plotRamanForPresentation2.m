function plotRamanForPresentation2(source,eventdata)
fwhmLimit = @(N) 88-45./N;
fwhm2N = @(fwhm) -45./(fwhm-88)
cfwhmLimit = fwhmLimit([.7,1.5,2.5,3.5,4.5,5.5,6.5,7.5]);
nfwhm2d = reshape(fwhm2d,[sqrt(length(fwhm2d)),sqrt(length(fwhm2d))]);
transformedfwhm2d = fwhm2N(fwhm2d);
ntfwhm2d = reshape(transformedfwhm2d,[sqrt(length(fwhm2d)),sqrt(length(fwhm2d))]);

fig=figure(5);clf;
map = [    0.3333         0         0
    0.6667         0         0
    1.0000    0.6667         0
    1.0000    1.0000         0];
contourf(nfwhm2d,cfwhmLimit,'EdgeColor','none')
colormap(map)
mytext  = text(27,23,'1 Layer','Color',[1 1 1],'FontSize',14)
mytext2 = text(15,30,'2 Layers','Color',[1 1 1],'FontSize',14)
mytext3 = text(27,30,'3 Layers','Color',[1 1 1],'FontSize',14)
myarrow = annotation(figure(5),'arrow',[0.625 0.575],...
    [0.7 0.74],'Color',[1 1 1]);
annotation(figure(5),'arrow',[0.505 0.55],...
    [0.7 0.7],'Color',[1 1 1]);
colorbar
theaxes = gca;
theaxes.XTick = [];
theaxes.YTick = [];
axis('tight')
% saveFigure(fig,'ramanMapForNumberOfLayers')
end


