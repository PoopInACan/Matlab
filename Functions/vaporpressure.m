%% vapor pressure for Si
A = 12.72;
B = 2.13e4;
T = 1000:1893;
Pv = 10.^(A - B./T);
loglog(T,Pv)
%% vapor pressure for C
A = 15.73;
B = 4e4;
Tc = 1000:1893;
Pvc = 10.^(A - B./T);
loglog(T,Pv,Tc,Pvc)
legend('Silicon','Carbon')
log10(.000001)
1e4/2.5e3