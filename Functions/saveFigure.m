function saveFigure(figure_handle,file_name,type,PathName)
%%
% saveFigure(figure_handle,file_name)
% help
% file_name => 'filename.png' or 'filename.eps'
% type => '-dpng' or '-depsc'
% PathName = '/Users/Kevin/Documents/OneDrive/Linkoping/PhD/Raman maps/Figures/pngFigures/'
if nargin < 4
   PathName = '/Users/kevme20/Documents/OneDrive/Linkoping/PhD/Raman maps/Figures/pngFigures/'; 
end
if nargin < 3
    type = '-dpng';
end
if nargin < 2
    file_name = 'default';
    type = '-dpng';
end
set(figure_handle, 'PaperPositionMode', 'auto');
if isequal(type,'-dpng')
    [FileName,PathName,FilterIndex] = uiputfile('*.png','Pick file name',[PathName file_name]);
elseif isequal(type,'-depsc')
    [FileName,PathName,FilterIndex] = uiputfile('*.eps','Pick file name',[PathName file_name]);

end
if isequal(FileName,0)
    disp('Cancelled save figure');
else
    print(figure_handle, type,  [PathName FileName])

end