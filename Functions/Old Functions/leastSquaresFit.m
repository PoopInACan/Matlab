function leastSquaresFit(x,y,sigma)
if nargin < 3
    p = [15.4, 16.5, 14, 17.8];
    t = [1200, 1250, 1150, 1300];
    x = t;
    y = p;
    N = length(x);                 % Number of data points
    alpha = .1;
    sigma = alpha*ones(1,N);
end
    N = length(x);                 % Number of data points

%% * Initialize data to be fit. Data is quadratic plus random number.
   % Constant error bar

%% * Fit the data to a straight line or a more general polynomial
M = 2;
if( M == 2 )  
  %* Linear regression (Straight line) fit
  [a_fit sig_a yy chisqr] = linreg(x,y,sigma);
else          
  %* Polynomial fit
  [a_fit sig_a yy chisqr] = pollsf(x,y,sigma,M);
end

%% * Print out the fit parameters, including their error bars.
fprintf('Fit parameters:\n');
for i=1:M
  fprintf(' a(%g) = %g +/- %g \n',i,a_fit(i),sig_a(i));
end
if a_fit(1) < 0
    fprintf('y = %gx - %g \n',a_fit(2),-a_fit(1));
else
    fprintf('y = %gx + %g \n',a_fit(2),a_fit(1));
end
T = 1:1500;
P = a_fit(2)*T + a_fit(1);
putvar('P')
%% * Graph the data, with error bars, and fitting function.
figure(1); clf;           % Bring figure 1 window forward
errorbar(x,y,sigma,'o');  % Graph data with error bars
hold on;                  % Freeze the plot to add the fit
plot(x,yy,'-');           % Plot the fit on same graph as data
xlabel('Temperature'); ylabel('Power');
title(['\chi^2 = ',num2str(chisqr),'    N-M = ',num2str(N-M)]);
