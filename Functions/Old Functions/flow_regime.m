clear;
clc;
k = 1.38e-23; % J/K
T = 1600 + 273.15; % K
d = 1.88*2 * 1e-10; % Angstrom
L = 0.3048; % diameter of pipe [m]
p = 500; % mbar
lambda = k*T/(sqrt(2)*pi*d^2*p*100);
% lambda2 = k*T/(sqrt(2)*pi*d^2*Na*P)
Kn = lambda/L;
if Kn > 0.5
    flowregime = 'Molecular flow';
elseif 0.5 > Kn && Kn > 0.01
    flowregime = 'Transitional flow';
elseif Kn < 0.01
    flowregime = 'Viscous flow';
end
fprintf(sprintf([flowregime '\nKn = %.3d\nmean free path = %.3d\n\n'],Kn,lambda));
%%
volume_flow_rate = 10; % Liters/min
dynamic_viscocity = 20.96e-6; % Pascals * s of Argon
density = 1.784 * 1e-3 * 1e3; % kg/m^3
v = volume_flow_rate * 0.001/60 * pi * L; % 10 L/min * .001m^3/L * 1min/60sec * Cross sectional area
Re = density/dynamic_viscocity * v*L;
if Re > 2200
    flowregime2 = 'Turbulent flow';
elseif 2200 > Re && Re > 1200
    flowregime2 = 'Transitional flow';
elseif Re < 1200
    flowregime2 = 'Laminar flow';
end
fprintf(sprintf([flowregime2 '\nRe = %.3f\n'],Re));



