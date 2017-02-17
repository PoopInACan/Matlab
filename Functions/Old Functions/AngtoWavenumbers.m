function [ ramanShift ] = AngtoWavenumbers( lambda_i, lambda_r )
%ANGTORAMANSHIFT Angstroms to wavenumbers (inverse cm)
%   lambda_i = wavelength of incident laser in angstroms
%   lambda_r = wavelength of reflected laser in angstroms
ramanShift = (10/lambda_i - 10./lambda_r)*1e7;

end

