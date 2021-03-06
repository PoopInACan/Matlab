%% a
clear;
clc;
load textfile
[value_of_max,index_of_max] = max(y_anneal_buffer(1:800));
[value_,index_] = max(yvar(1:800));
multiplication_factor = 5.3164e+03/value_;
multiplication_factor2 = 5.3164e+03/value_of_max;

%% Plot
figure1 = figure('Position',[680   314   907   784]);clf;
plot(x_anneal_buffer,multiplication_factor2*y_anneal_buffer+5100,xvar,multiplication_factor*yvar)
axis('tight')
legend('As-grown buffer layer','Exposed to hydrogen')
xlabel('Raman Shift [cm^{-1}]')
%%
annotation(figure1,'textbox',...
    [0.175635049723275 0.869524159278102 0.0272277227722772 0.0295629820051413],...
    'String','D',...
    'FontSize',26,...
    'FitBoxToText','off',...
    'EdgeColor','none');
annotation(figure1,'textbox',...
    [0.305734277948192 0.885204081632651 0.0272277227722771 0.0304646923036539],...
    'String',{'G'},...
    'FontSize',26,...
    'FitBoxToText','off',...
    'EdgeColor','none');
annotation(figure1,'textbox',...
    [0.175635049723275 0.360969387755101 0.0272277227722772 0.0381177535281448],...
    'String','D',...
    'FontSize',26,...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(figure1,'textbox',...
    [0.271555667143341 0.392483342951573 0.0294366151058317 0.0295629820051414],...
    'String',{'G'},...
    'FontSize',26,...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(figure1,'textbox',...
    [0.507166482910696 0.177571428571422 0.0760749724366031 0.0293367346938773],...
    'String','D+D''''',...
    'FontSize',26,...
    'FitBoxToText','off',...
    'EdgeColor','none');
annotation(figure1,'textbox',...
    [0.610804851157663 0.344663265306121 0.035832414553473 0.0293367346938775],...
    'String',{'2D'},...
    'FontSize',26,...
    'FitBoxToText','off',...
    'EdgeColor','none');
annotation(figure1,'textbox',...
    [0.648291069459759 0.187775510204075 0.0760749724366032 0.0293367346938773],...
    'String','D+D''',...
    'FontSize',26,...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(figure1,'textarrow',[0.332965821389195 0.303197353914002],...
    [0.274510204081633 0.201530612244898],'String',{'D'''},'FontSize',26);

prettyPlotLoop(figure1,26,'no')
%%
%% Save Figures
theChoice = questdlg('Save Figures?','Save Figures?','Yes','No','No');
switch theChoice
    case 'Yes'
        saveFigure(figure1,'buffer_hydrogen_exposed.png','-dpng','/Users/kevme20/Downloads/')
    otherwise
end
