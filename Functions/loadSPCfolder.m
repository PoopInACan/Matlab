function [xData,yData] = loadSPCfolder(spcFolder,dontFilter)
dbstop if error
%         delete([spcFolder '/*).spc']); % deletes duplicates
fnames = dir(fullfile(spcFolder, '*.spc'));
fnames = {fnames.name}.';
if nargin < 2
    ind1 = cellfun(@isempty, regexp(fnames, '\w*sigma\w*'));
    ind2 = cellfun(@isempty, regexp(fnames, '\w*sum\w*'));
    ind3 = cellfun(@isempty, regexp(fnames, '\w*av\w*'));
    ind4 = cellfun(@isempty, regexp(fnames, '[0-9]+)'));
    ind = ind1 & ind2 & ind3 & ind4; % index of all files without sigma or av
else
    ind = ones(1,length(fnames));
end
if isempty(find(ind))
    ind = 1:length(fnames);
end
fnames_subset = fnames(ind);
fnames_subset = sort_nat(fnames_subset); % sort ascending
h = waitbar(0,'Initializing waitbar...');
loopLength = length(fnames_subset);
yData = zeros(2000,loopLength);
xData = zeros(2000,loopLength);
for i = 1:loopLength
    out = tgspcread([spcFolder '/' fnames_subset{i}],'Verbose','false');
    yData(:,i) = out.Y;
    xData(:,i) = out.X;
    waitbar(i/loopLength,h,sprintf('%g%% done...',floor(100*i/loopLength)));
end
close(h);
pause(.1);
end
