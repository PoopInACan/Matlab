function correct_Thz_file(filename)
%% help
% filename = '/Users/kevme20/Documents/MATLAB/20160526_x999_rotated30degrees_unmarked_x6.dat'
if nargin < 1
    filename = '/Users/kevme20/Documents/MATLAB/20160526_x999_rotated30degrees_unmarked_x6.dat';
end
if isempty(strfind(filename,'.dat'))
    filename = [filename '.dat'];
end
if not(isempty(strfind(filename,'_corrected.dat')))
    return;
end
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
f = b{1,2}(:);
m = 6; % frequency multiplier
x = (f/m-138.66607);
df = 0.044076741*x - 0.00032516402*x.^2 + 3.3283347e-6*x.^3 - 9.3631008e-8*x.^4;
b{1,2}(:) = f + m*df;
% corrected filename
corrected_filename = strrep(filename,'.dat','_corrected.dat');
% outputPath ='/Users/kevme20/Documents/VirtualBox Documents/x997_xx21/' ;
% % only for x997 and others where I don't want to see the original bad
% files
fileID = fopen(corrected_filename,'w');
%% write into corrected file
fprintf(fileID,'%s\n',A{1});
fprintf(fileID,'%s\n',A{2});
fprintf(fileID,'%s\n',A{3});
fprintf(fileID,'%s\n',A{4});
for i = 1:length(b{1,1})
        fprintf(fileID,'%s\t%f\t%f\t%f\t%f\n', b{1,1}{i}, b{1,2}(i), b{1,3}(i), b{1,4}(i), b{1,5}(i));
end

fclose(fileID);