clear all;
clc;
filename = '/Users/kevme20/Documents/VirtualBox Documents/x941/20161024_x941_unmarked_0degrees_corrected.dat';

fid = fopen(filename,'r');
for i=1:4
    tline = fgetl(fid);
    A{i} = tline;
end
% Define the format of the data to read and the shape of the output array.
formatSpec = '%s%f%f%f%f%f%f%[^\n\r]';
delimiter = '\t';
startRow = 1;
b = textscan(fid, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fid);
% Math
f = b{2};
corrected_filename = strrep(filename,'.dat','_interp.dat');
fileID = fopen(corrected_filename,'w');
%% Interpolate
muellerMatrixElements = {'mm12','mm13','mm21','mm22','mm23','mm31','mm32','mm33'};
for i = 1:length(muellerMatrixElements)
    a = strfind(b{1},muellerMatrixElements(i));
    ind = find(not(cellfun('isempty', a)));
    xq = 750:3:948;
    newy = interp1(b{2}(ind),b{4}(ind),xq);
    b{4}(ind) = newy;
    b{2}(ind) = xq;
end
%% write into corrected file
fprintf(fileID,'%s\n',A{1});
fprintf(fileID,'%s\n',A{2});
fprintf(fileID,'%s\n',A{3});
fprintf(fileID,'%s\n',A{4});
for i = 1:length(b{1,1})
        fprintf(fileID,'%s\t%f\t%f\t%f\t%f\n', b{1,1}{i}, b{1,2}(i), b{1,3}(i), b{1,4}(i), b{1,5}(i));
end

fclose(fileID);