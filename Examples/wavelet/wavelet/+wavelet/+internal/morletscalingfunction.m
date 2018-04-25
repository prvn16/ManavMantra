function [phidft,phi] = morletscalingfunction(omega,scale)
% MATLAB scales incomplete gamma function by 1/\gamma(\alpha)
% phidft = morsescalingfunction(ga,be,omega,scale)
fun = @(om)exp(-(om-6).^2)./om;
phidft = zeros(size(omega));
posfreq = scale.*omega(omega>0);
for kk = 1:numel(posfreq)
    phidft(kk) = morletintegral(fun,posfreq(kk));
end
ampdc = phidft(1);
phidft = phidft./ampdc;

phi = ifftshift(ifft(phidft));




%-------------------------------------------------------------------------
function val = morletintegral(fun,omega)
val = integral(fun,omega,Inf);
