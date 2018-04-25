function [phidft,phi] = morsescalingfunction(ga,be,omega,scale)
% MATLAB scales incomplete gamma function by 1/\gamma(\alpha)
% phidft = morsescalingfunction(ga,be,omega,scale)
%Abg = wavelet.internal.morsenormconstant(ga,be);
%cpsi = wavelet.internal.admConstant('morse',[ga be]);
%factor = Abg*gamma(2*be/ga)*1/(2*ga)*(1/2)^((2*be/ga)-1);
omega = 2*(scale*omega).^ga;
phidft = zeros(size(omega));
phidft(omega>=0) = gammainc(omega(omega>=0),2*be/ga,'upper');
phi = ifftshift(ifft(phidft));


