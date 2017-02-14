function [maximum, maxIndex, fwhm, x0] = getLorentzianParameters(searchRange,data,xi,minForPeak)
if nargin < 4
    minForPeak = 400;
end

index = find(xi > searchRange(1) & xi < searchRange(end));
[pks,locs,widths,proms] = findpeaks(...
    data(index),xi(index),...
    'MinPeakHeight',minForPeak,...
    'WidthReference','halfprom',...
    'MinPeakWidth',10);

if isempty(proms)
    maximum = 0;
    fwhm = 200;
    maxIndex = min(index);
    x0 = xi(maxIndex);
    return;
else
    [~,number] = max(pks);
    maximum = pks(number);
    maxIndex = find(xi==locs(number));
    fwhm = widths(number);
    x0 = locs(number);
end
end
