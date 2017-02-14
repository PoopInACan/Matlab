a = 2;
m_1 = 1.5;
m_2 = 1;
K = 1;
k = linspace(0,pi/a,100);
% w = sqrt(4/m_1*sin(k*a/2).^2);
wa = sqrt((1/m_1 + 1/m_2)-sqrt((1/m_1 + 1/m_2)^2 - 4*sin(k*a/2).^2 / (m_1*m_2)));
wo = sqrt((1/m_1 + 1/m_2)+sqrt((1/m_1 + 1/m_2)^2 - 4*sin(k*a/2).^2 / (m_1*m_2)));
myfig = figure(2);
clf;
plot(k,wa,k,wo)
legend('Acoustical','Optical')
axis([0,pi/a,0,max(wo)])
ax = gca;
ax.XTick = [0 pi/a];
ax.XTickLabel = {'0','\pi/a'};
ylabel('\omega');
xlabel('k');
hTitle = title('Dispersion Relation of 1D diatomic lattice');
allobj = findobj(myfig);
for j = 1:length(allobj)
    prettyPlot(allobj(j))
end
ax.YTick = [min(wa) max(wa) min(wo) max(wo)];
ax.YTickLabel = {'0',['(2c/m_1)^{' char(189) '}'],['(2c/m_2)^{' char(189) '}'],['(2c(1/m_1+1/m_2))^{' char(189) '}']};
set(myfig, 'PaperPositionMode', 'auto');
[FileName,PathName,FilterIndex] = uiputfile('*.eps','Pick file name','../../Documents/Google Drive/Linkoping/Master Thesis/Thesis/Figures/phononModes');
if not(isequal(FileName,0))
    print(myfig, '-depsc', [PathName FileName]); % Saves file
end

