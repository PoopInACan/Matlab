function correct_Thz_file_phillip(filename)
%% help
% filename = '/Users/kevme20/Documents/MATLAB/20160526_x999_rotated30degrees_unmarked_x6.dat'
if nargin < 1
    filename = '20160913_inrt-si-1mm_x6.dat';
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
%% Math
for i = 1:length(b{1})
   ind(i) = isempty(str2num(cell2mat(b{1}(i)))); % empty means not a number, so you change second number
end
[~,empty_index] = find( ind > 0 ); % change second number
filled_index = setdiff(1:length(b{1}),empty_index); % change first number
a = strfind(filename,'x'); % after x is the multiplier
m = str2num(filename(a + 1)); % frequency multiplier
% first
f = b{1}(filled_index);
for i = 1:length(f)
    newf(i) = str2num(f{i});
end
f = newf';
x = (f/m-138.66607);
df = 0.044076741*x - 0.00032516402*x.^2 + 3.3283347e-6*x.^3 - 9.3631008e-8*x.^4;
correctf = f + m*df;
for i = 1:length(f)
    strf{i} = num2str(correctf(i));
end
b{1}(filled_index) = strf;
% second
f = b{2}(empty_index);
x = (f/m-138.66607);
df = 0.044076741*x - 0.00032516402*x.^2 + 3.3283347e-6*x.^3 - 9.3631008e-8*x.^4;
b{2}(empty_index) = f + m*df;

% corrected filename
corrected_filename = strrep(filename,'.dat','_corrected.dat');
fileID = fopen(corrected_filename,'w');
%% write into corrected file
fprintf(fileID,'%s\n',A{1});
fprintf(fileID,'%s\n',A{2});
fprintf(fileID,'%s\n',A{3});
fprintf(fileID,'%s\n',A{4});
for i = filled_index
        fprintf(fileID,'%s\t%f\t%f\t%f\t%f\t%f\n', b{1,1}{i}, b{1,2}(i), b{1,3}(i), b{1,4}(i), b{1,5}(i),b{1,6}(i));
end
for i = empty_index
        fprintf(fileID,'%s\t%f\t%f\t%f\t%f\n', b{1,1}{i}, b{1,2}(i), b{1,3}(i), b{1,4}(i), b{1,5}(i));
end
fclose(fileID);