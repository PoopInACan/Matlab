function gasVelocity
clc
% Constants
R = 8.314; % gas constant cm^3*atm/(mol*K)
r = .1; % radius of quartz cylinder
flow_area = pi*r^2;

% Pressures
P_mbar = 1013.25; % mbar
P_pascal = P_mbar / .01; % Pascals
P_h2 = 10;
P_Ar = 100;

% Temperatures
T_h2 = 1400 + 273.15;
T_C = 0; % celcius
T_K = T_C;
T_Ar = 1600 + 273.15;

% Masses
m_oxygen = 15.9994 * 2 * 1e-3; % kg/mol
m_krypton = 83.798 * 1e-3; % kg/mol
m_nitrogen = 14.007 * 2 * 1e-3; % kg/mol
m_h2 = 1.00794 * 2; % grams/mol
m_air = 28.949; % grams/mol
m_Ar = 39.948; % grams/mol


% Root mean square velocity
v_o2 = velocityRMS( 31, m_oxygen ); % m/s
v_krypton = velocityRMS( T_K, m_krypton ); % m/s
v_n2 = velocityRMS( T_K, m_nitrogen ); % m/s
v_h2 = velocityRMS( 1400, m_h2 );
v_Ar = velocityRMS( 1600, m_Ar);

% Volume Flow Rate
vfr_Ar = 10; % liters/min
vfr_air = 0.2; % liters/min
vfr_h2 = 5; % liters/min

% g/mol
n_air = 1;
n_h2 = 1;
n_Ar = 1;

% 
flow_velocity_H2 = flow_velocity(vfr_h2);
flow_velocity_Ar = flow_velocity(vfr_Ar); 

% Mass flow
mf_air = mass_flow(m_air,P_mbar,n_air,T_K,vfr_air); % g/min    
mf_H2 = mass_flow(m_h2, P_h2,n_h2,T_h2,vfr_h2);
mf_Ar = mass_flow(m_Ar, P_Ar,n_Ar,T_Ar,vfr_Ar);


%% Functions
    function mf = mass_flow(m,P_pa,n,T_Kelvin,volume_flow_rate)
        P_pa = P_pa * 100; % mbar to Pa
        volume_flow_rate = volume_flow_rate * .001; % L to cm^3
        V = n * R * T_Kelvin / P_pa; % from ideal gas law
        density = m / V;
        mf = density * volume_flow_rate; % g/min or kg/min
    end

    function fv = flow_velocity(volume_flow_rate)
        mintosec = 60;
        litertom3 = 0.001;
        volume_flow_rate = volume_flow_rate * litertom3 / mintosec; 
        fv = volume_flow_rate / flow_area;
    end




% a = who;
% a = strrep(a,'ans','');
% a(~cellfun(@isempty,a));
% putvar(a{:});
putvar('v_h2','v_Ar','m_Ar','m_h2');
end
