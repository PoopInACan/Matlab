clear
clc
prompt = {'Pixel length:', ...
'Total pixel length', ...
'Length in \mu m', ...
'Angle', ...
'Number of Steps'};
dlg_title = 'Input';
num_lines = 1;
defaultans = { ...
    '1600', ... % Pixels from left to right
    '303', ... % Total Pixels from left to right
    '100', ... % Total length in microns
    '16.34', ... % degrees
    '12'}; % number of steps
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
px = str2double(answer{1});
tpx = str2double(answer{2});
realL = str2double(answer{3});
theta = str2double(answer{4});
nSteps = str2double(answer{5});
step_length = px/tpx*realL*sind(theta)/(nSteps-1);
sprintf('step length: %.4f',step_length)