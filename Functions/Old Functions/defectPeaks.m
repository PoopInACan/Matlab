function defectPeaks(source,eventdata)
global x y hand
thepopupmenu = findobj('Tag','popupTag');
pv = thepopupmenu.Value;
sampleName = hand(pv).sampleName;
sampleName = strrep(sampleName,'_','');
sampleName = strrep(sampleName,'.txt','');



%% Import published data
[xf,yf] = importDataThiefTextFile('fluorinated_peaks.txt','no');
[xh,yh] = importDataThiefTextFile('hydrogenated_peaks.txt','no');
[xo,yo] = importDataThiefTextFile('Oxidized_peaks.txt','no');
[xa,ya] = importDataThiefTextFile('Anodic_bonded_peaks.txt','no');
[xg,yg] = importDataThiefTextFile('graphite_peaks.txt','no');
%% Import our data
r = 10:1900;
xn = flipud(x(r));
yn = flipud(y(r,:));
count = 1;
peakIndex = [];
for n = 1:size(yn,2)
    [pks,locs,w,p] = findpeaks(yn(:,n),xn,'MinPeakHeight',200);
    if length(pks) > 3 && locs(3) < 1700
        try
            IdIg(count)         = pks(1)/pks(2);
            IdpIg(count)        = pks(3)/pks(2);
            IdIdp(count)        = pks(1)/pks(3);
            IgId(count)         = pks(2)/pks(1);
            fwhmDplot(count)    = w(1);
            fwhm2Dplot(count)    = w(3);
            fwhmGplot(count)    = w(2);
            peakIndex(count)    = n;
            count = count + 1;
        end
    end
end
if ~isempty(IdpIg)
    index = (IdpIg < 100 & IdpIg>0);
    IdpIgnew = IdpIg(index);
    IdIdpnew = IdIdp(index);
    IdIgnew = IdIg(index);
    IgIdnew = IgId(index);
    fwhmDplotnew = fwhmDplot(index);
    fwhm2Dplotnew = fwhm2Dplot(index);
    fwhmGplotnew = fwhmGplot(index);
    fig = figure(2);
    clf;
    loglog(xf,yf,'ro',xh,yh,'rsq',xo,yo,'r^',xa,ya,'bsq',xg,yg,'ko',IdpIgnew,IdIgnew,'o')

    axis([.01 2 0.1 7])
    legend('Fluorinated','Hydrogenated','Oxidized','Anodic bonded','Graphite','Our Data','location','best')
    prettyPlotLoop(fig,14,'yes')
    title(sampleName)
    xlabel('I_{D\bf''}/I_G')
    ylabel('I_{D}/I_G')
end
newSampleName = [sampleName '_Intensity_ratio_D_to_Dprime'];
% saveFigure(fig,newSampleName);
%% FWHM D vs Ld

Ld = sqrt(1.8*1e-9*531.8^4*IgIdnew);
figure(7);
clf;
plot(Ld,fwhm2Dplotnew,'o',Ld,fwhmDplotnew,'o')
legend('2D','D')
axis([0 25 0 50])

%% INSET GRAPH
% figure(8);
% clf;
% plot(IdpIgnew,IdIgnew,'.',IdpIgnew,yy,'.')
% axis([0 .2 0 2])
% title(sampleName)

% loglog(IdpIgnew,IdIgnew,'o')
