clear;
clc;
A = 1;
x = -5:.01:5;
x0 = 0;
tau = 2; 
L = A * (.5*tau)^2./((x-x0).^2+(.5*tau)^2);
lorfig = figure(5);
clf;
xtau = [-1:.01:1];
plot(x,L,xtau,repmat(.5,[1,length(xtau)]),'-.')
text(1.2,.53,'FWHM (\Gamma)','Interpreter','tex');
text(.45,.9,'$L(x)=A\,\frac{(1/2\Gamma)^2}{(x-x_0)^2+(1/2\Gamma)^2}$','Interpreter','latex');
var1 = text(1.2,.75,'$A=1$','Interpreter','latex');
var2 = text(1.2,.68,'$x_0=0$','Interpreter','latex');

% axis([-5 5 -inf 1.3])
title('Lorentzian Function');
xlabel('x')
ylabel('Intensity');
prettyPlotLoop(figure(5),14,'Yes')
% set([var1,var2],'FontSize', 16);
saveFigure(lorfig,'lorentzianFigure')
