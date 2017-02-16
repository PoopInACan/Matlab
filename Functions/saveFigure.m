function saveFigure(figure_handle,file_name,type,PathName)
%%
% saveFigure(figure_handle,file_name)
% help
% file_name => 'filename.png' or 'filename.eps'
% type => '-dpng' or '-depsc'
% PathName = '/Users/Kevin/Documents/OneDrive/Linkoping/PhD/Raman maps/Figures/pngFigures/'
if nargin < 4
   PathName = '/Users/kevme20/Box Sync/PhD/Experiment/Outputs/Presentationpng/'; 
end
if nargin < 3
    type = '-dpng';
end
if nargin < 2
    file_name = 'default';
    type = '-dpng';
end
set(figure_handle, 'PaperPositionMode', 'auto');
switch type
    case {'-dpng','dpng','png'}
    [FileName,PathName,FilterIndex] = uiputfile('*.png','Pick file name',[PathName file_name]);
    type = 'dpng';
    case {'-depsc','eps','epsc','deps','depsc'}
    [FileName,PathName,FilterIndex] = uiputfile('*.eps','Pick file name',[PathName file_name]);
    type = 'depsc';
end
if isequal(FileName,0)
    disp('Cancelled save figure');
else
    print(figure_handle,[PathName FileName], type  )
end