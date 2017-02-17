clear;
clc;
r = 1:1900;
x = importdata('xAxis.txt');
[xhyd,yhyd] = importDataThiefTextFile('hydrogenatedFreeStandingGraphene.txt','no');
x = flipud(x);
xn = AngtoRamanShift(5318,x);
xn = xn(r);
ref = importdata('yRef6H_20151008.txt');
mref = mean(ref,2);
mref = mref(r);
out1 = tgspcread('./Raman Maps/xx14/xx14_01.SPC');
out2 = tgspcread('./Raman Maps/xx14/xx14_02.SPC');
out3 = tgspcread('./Raman Maps/xx15/xx15_01.SPC');
out4 = tgspcread('./Raman Maps/xx15/xx15_02.SPC');
sam(:,1) = out1.Y(r);
sam(:,2) = out2.Y(r);
sam15(:,1) = out3.Y(r);
sam15(:,2) = out4.Y(r);
sam2 = sam([2:1900,1],:);
flatdata = find(xn>2049 & xn<2300);
% mref = mref-mean(mref(flatdata));
% sam2 = sam-repmat(mean(sam(flatdata,:)),[1900,1]);
multiplybythis = max(sam2(:,1))/max(mref);
multiplybythis2 = max(sam2(:,2))/max(mref);
multiplybythis3 = max(sam15(:,1))/max(mref);
multiplybythis4 = max(sam15(:,2))/max(mref);
subtracted1 = sam2(:,1)-mref*multiplybythis;
subtracted2 = sam2(:,2)-mref*multiplybythis2;
subtracted3 = sam15(:,1)-mref*multiplybythis3;
subtracted4 = sam15(:,2)-mref*multiplybythis4;
% subtracted1 = medfilt1(subtracted1,7);
% subtracted2 = medfilt1(subtracted2,7);

figure(1);clf;
plot(xn,sam2,xn,mref*multiplybythis,xn,subtracted1,xn,subtracted2,...
    xn,subtracted3,...
    xn, subtracted4)
legend('sam1','sam2','ref','subtracted1','subtracted2','sub15','sub152')
axis('tight')
[maximum, maxIndex, fwhm, x0] = getLorentzianParameters([2500,2800],subtracted1,xn);
lor2d = maximum*(1/2*fwhm)^2./( (xn-x0-1).^2 + (1/2*fwhm)^2);
[maximumd, maxIndexd, fwhmd, x0d] = getLorentzianParameters([1200,1450],subtracted1,xn);
lord = maximumd*(1/2*fwhmd)^2./( (xn-x0d-1).^2 + (1/2*fwhmd)^2);
%%
figure(2);clf;
plot(xn,subtracted1,xn,subtracted2,xn,subtracted3,xn,subtracted4 )
% ,xn,lor2d,xn,lord,xhyd,(-48+yhyd)*300,'.'
axis('tight')
legend('xx14_1','xx14_2','xx15_1','xx15_2')
prettyPlotLoop(figure(1));
prettyPlotLoop(figure(2));
%%
figure(3);
clf;
plot(xn,subtracted1,xn,lord)
axis('tight')
legend('xx14_1','xx15_1')
prettyPlotLoop(figure(1));
prettyPlotLoop(figure(2));
prettyPlotLoop(figure(3),14,'hi');
s = (1250:1450);

