function [xss,yss] = importDataThiefTextFile(filename,doNorm)
    %% Initialize variables.
    dbstop if error
if nargin < 1
    filename = uigetfile('*.txt');
    if filename==0
        return;
    end
end
delimiter = ',';
startRow = 2;

%% Format string for each line of text:
%   column1: double (%f)
%	column2: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
xss = dataArray{:, 1};
yss = dataArray{:, 2};
% yss = yss/sum(yss);
% yss = yss-min(yss); % subtract height
if nargin < 2
    yss = yss/norm(yss); % then normalize
end
end
