dbstop if error
clear;
clc;
foldDir = '../../../../Documents/Jawad Raman Data/xx*';
% foldDir = ['../../Data/Raman/',...
%     'D*'];
% thefiles = dir(foldDir);
% foldname = {...
%     '930','933','934','935','936', ...
%     '937','938','939','941', ...
%     '942','943','946','949','960', ...
%     '984','993','995','999_xx20'};
% foldname = {'946_xx20','947_xx20','949_xx20','951_xx20'};
% foldname = {'2_xx21','5_xx20','6_xx20','7_xx20','10',...
%     '10_xx20','14','15','17_xx20','18','19','22','116','23'};
foldname = {'55(O)Ra_c2','56(G)Ra_c','56(G)Ra_c2','56(G)Ra_cc','56(L)Ra_c1', ...
    '56(M)Ra_c','56(T)Ra_c','56(V)Ra_c2','57(J)Ra_c','57(Y)Ra_c','58(5)Ra_c', ...
    '58(B)Ra_c2','58(H)Ra_c','58(R)Ra_c','59(I)Ra_c22','60(P)Ra_c','61(O)Ra_c'};
thefiles = 1:size(foldname,2);

for i = 1:length(thefiles)
%     foldname = thefiles(i).name(3:end);
    spcFolder = [foldDir(1:(end-1)) foldname{i}];
    [xData,yData] = loadSPCfolder(spcFolder);
%     xData = double(xData);
    yData = double(yData);
    foldname{i} = strrep(foldname{i},'(','_');
    foldname{i} = strrep(foldname{i},')','_');

%     textfilenamex = ['./Original Raman Data/x' foldname '.txt'];
    textfilenamey = ['../../DataAnalysis/RamanTextFiles/y' foldname{i} '.txt'];
%     save(textfilenamex, 'xData', '-ASCII')
    save(textfilenamey, 'yData', '-ASCII');
    disp([foldname{i} ' done']);
    pause(0.1);
end

% y = importdata('y941.txt');
