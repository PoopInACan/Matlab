clear;
clc;
% %%
subtractedFolder = '/Users/Kevin/Google Drive/Linkoping/Master Thesis/Data/Raman/x946_xx20/Subtracted/';
regularFolder = '/Users/Kevin/Google Drive/Linkoping/Master Thesis/Data/Raman/x946_xx20/';
[xData,yData] = loadSPCfolder(subtractedFolder);
out = tgspcread([regularFolder 'x946_xx20Ra_c-1.spc']);
textYValues = importdata('/Users/Kevin/Documents/OneDrive/Linkoping/Master Thesis/Data/Raman/x946_xx20/x946_xx20Ra_c-1.prn');
plot(textYValues(:,1),textYValues(:,2),'.',textYValues(:,1),flipud(out.Y),'.')
legend('text','spc')
%%
x = xData(:,1);
y = yData;
plot(x,y(:,1))
%%
xnew = flipud(x);
% [ ...
%     layerNumber,  ...
%     layersPossible,  ...
%     indLayers,  ...
%     numOfLayers,  ...
%     maximum_2D,  ...
%     maxIndex_2D,  ...
%     fwhm_2D,  ...
%     x0_2D] = getIndexAndValuesOf2DFWHM(x,y);

for n = 1:size(y,2)
%     [maximum_G(n), maxIndex_G(n), fwhm_G(n), x0_G(n)] = getLorentzianParameters([1550,1650],y(:,n),x);
%     [maximum_Dp(n), maxIndex_Dp(n), fwhm_Dp(n), x0_Dp(n)] = getLorentzianParameters([x0_G(n)+5,x0_G(n)+105],y(:,n),x);
%     [maximum_D(n), maxIndex_D(n), fwhm_D(n), x0_D(n)] = getLorentzianParameters([1300,1400],y(:,n),x);
    [maximum_DDp(n), maxIndex_DDp(n), fwhm_DDp(n), x0_DDp(n)] = getLorentzianParameters([2800,3050],y(:,n),x,200);
end
%%
val = 1;
r = 10:1900;
lor2d 	= maximum_2D(val)*(1/2*fwhm_2D(val)).^2./( (x-x0_2D(val)-1).^2 + (1/2*fwhm_2D(val))^2);
lorG 	= maximum_G(val)*(1/2*fwhm_G(val)).^2./( (x-x0_G(val)-1).^2 + (1/2*fwhm_G(val))^2);
lorDp 	= maximum_D(val)*(1/2*fwhm_D(val)).^2./( (x-x0_D(val)-1).^2 + (1/2*fwhm_D(val))^2);
lorD 	= maximum_Dp(val)*(1/2*fwhm_Dp(val)).^2./( (x-x0_Dp(val)-1).^2 + (1/2*fwhm_Dp(val))^2);
lorDDp 	= maximum_DDp(val)*(1/2*fwhm_DDp(val)).^2./( (x-x0_DDp(val)-1).^2 + (1/2*fwhm_DDp(val))^2);



figure(1);clf;
plot(x(r),y(r,val),x(r),lor2d(r),x(r),lorG(r),x(r),lorD(r),x(r),lorDp(r),x(r),lorDDp(r)); % ,xBuffer,yBuffer*15000,xOxide,yOxide*15000
axis('tight');
ylim([-100 max(y(r,val))*1.1]);
legendString = {'Subtracted','2D Fit','G Fit','D Fit','D''','D+D'' Fit'};
legend(legendString)
%%
figure(2);clf;
plot(maximum_D,maximum_DDp,'.')
