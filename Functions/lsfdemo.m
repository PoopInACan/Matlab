% lsfdemo - Program for demonstrating least squares fit routines
clc;
clear all; help lsfdemo; % Clear memory and print header

%* Initialize data to be fit. Data is quadratic plus random number.
out1 = tgspcread('../../Data/Raman/xx10_xx20/xx10_xx20Ra_c-1.spc','Verbose','false');
yReady = out1.Y;
out2 = importdata('../../DataAnalysis/RamanTextFiles/y6HRef.txt');
y = mean(out2,2)';

x = importdata('../../DataAnalysis/RamanTextFiles/xAxis.txt');

%%
N = 2000;                 % Number of data points
x = AngtoRamanShift(5318,x)'; % x = [1, 2, ..., N]
alpha = 1;
sigma = alpha*ones(1,N);    % Constant error bar

%* Fit the data to a straight line or a more general polynomial
M = 2;
if( M == 2 )  
  %* Linear regression (Straight line) fit
  [a_fit sig_a yy chisqr] = linreg(x,y,sigma);
else          
  %* Polynomial fit
  [a_fit sig_a yy chisqr] = pollsf(x,y,sigma,M);
end

%* Print out the fit parameters, including their error bars.
fprintf('Fit parameters:\n');
for i=1:M
  fprintf(' a(%g) = %g +/- %g \n',i,a_fit(i),sig_a(i));
end

%* Graph the data, with error bars, and fitting function.
figure(1); clf;           % Bring figure 1 window forward
errorbar(x,y,sigma,'o');  % Graph data with error bars
hold on;                  % Freeze the plot to add the fit
plot(x,yy,'-');           % Plot the fit on same graph as data
xlabel('x_i'); ylabel('y_i and Y(x)');
title(['\chi^2 = ',num2str(chisqr),'    N-M = ',num2str(N-M)]);