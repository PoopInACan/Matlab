% correct current folders thz data
clear;
clc;
foldername = '../x997_xx21/';
addpath(foldername)
files = dir([foldername '*.dat']);
%%
for i = 1:length(files)
   correct_Thz_file(files(i).name) 
end