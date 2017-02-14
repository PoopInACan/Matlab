function v = velocityRMS(T_Celcius,molar_Mass)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
R = 8.314; % gas constant cm^3*atm/(mol*K)
v = sqrt( 3 * R * (T_Celcius + 273.15) / molar_Mass );

end

