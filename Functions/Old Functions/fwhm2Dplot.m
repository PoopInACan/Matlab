
x = .7:.01:4;
fwhmeq = @(x) 88-45./x;
fwhm = fwhmeq(x);
myfig = figure(2);clf;
x1 = .7:.01:1.5;
y1 = fwhmeq(x1);
x2 = 1.5:.01:2.5;
y2 = fwhmeq(x2);
x3 = 2.5:.01:3.5;
y3 = fwhmeq(x3);
x4 = 3.5:.01:4.5;
y4 = fwhmeq(x4);
plot(x1,y1,x2,y2,x3,y3,x4,y4,...
    x1(end),y1(end),'ko',x2(end),y2(end),'ko',x3(end),y3(end),'ko',x4(end),y4(end),'ko')
legend('One Layer','Two Layers','Three Layers','Four Layers')
ylabel('FWHM (2D) cm^{-1}')
xlabel('Number of Graphene Layers')
title('2D FWHM vs Number of Graphene layers');
text(2.7,60,'$\Gamma_{2D} = 88-\frac{45}{N}$','Interpreter','latex');
axis('tight')
prettyPlotLoop(myfig,14,'yes')
saveFigure(myfig,'fwhm2Dplot')
%% save adjusted figure
x = .7:.01:4;
orig45 = 45;
new45 = 60;
fwhmeq = @(x,y) 88-y./x;
fwhm = fwhmeq(x,orig45);
myfig2 = figure(3);clf;
x1 = .7:.01:1.5;
x4 = 3.5:.01:4.5;
x3 = 2.5:.01:3.5;
x2 = 1.5:.01:2.5;
y1 = fwhmeq(x1,orig45);
y2 = fwhmeq(x2,orig45);
y3 = fwhmeq(x3,orig45);
y4 = fwhmeq(x4,orig45);
y5 = fwhmeq(x1,new45);
y6 = fwhmeq(x2,new45);
y7 = fwhmeq(x3,new45);
y8 = fwhmeq(x4,new45);
theplot = plot( ...
    x1,y1, ...
    x2,y2, ...
    x3,y3, ...
    x4,y4, ...
    x1(end),y1(end),'ko', ...
    x2(end),y2(end),'ko', ...
    x3(end),y3(end),'ko', ...
    x4(end),y4(end),'ko', ...
    x1,y5, ...
    x2,y6, ...
    x3,y7, ...
    x4,y8, ...
    x1(end),y5(end),'ko', ...
    x2(end),y6(end),'ko', ...
    x3(end),y7(end),'ko', ...
    x4(end),y8(end),'ko')
colorsP = get(theplot,'Color');
n = length(colorsP);
colorsP = cell2mat(colorsP);
count = 1;
for i = (n/2+1):n
    set(theplot(i),'Color',colorsP(count,:));
    count = count + 1;
end
axis('tight')
legend('One Layer','Two Layers','Three Layers','Four Layers')
ylabel('FWHM (2D) cm^{-1}')
xlabel('Number of Graphene Layers')
title('2D FWHM vs Number of Graphene layers');
text(1.,70,'$\Gamma_{2D} = 88-\frac{45}{N}$','Interpreter','latex');
text(1.5,40,['$\Gamma_{2D} = 88-\frac{' int2str(new45) '}{N}$'],'Interpreter','latex');
txarrow = annotation(myfig2,'arrow',[0.293 0.293],...
    [0.695 0.619]);
prettyPlotLoop(myfig2,14,'yes');
% saveFigure(myfig2,'fwhm2Dadjusted')
