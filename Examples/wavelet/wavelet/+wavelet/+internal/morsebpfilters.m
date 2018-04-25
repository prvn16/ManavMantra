function [psidft,F] = morsebpfilters(omega,scales,ga,be)
% This function is for internal use. It may change in a future release.
%somega = scales'.*repmat(omega,numel(scales),1);
somega = scales'*omega;
fo = wavelet.internal.morsepeakfreq(ga,be);
%Akbg = morsenormconstant(ga,be,0);
absomega = abs(somega);
% For the case when gamma is 3, this matrix multiply is much faster than
% the element-by-element power operator.
if ga == 3
    powscales = absomega.*absomega.*absomega;
else
    powscales = absomega.^ga;
end
% basicmorse = 2*exp(-be.*log(fo)+fo.^ga+be.*log(absomega)-powscales).*(somega>0);
factor = exp(-be*log(fo)+fo^ga);
psidft = 2*factor*exp(be.*log(absomega)-powscales).*(somega>0);
% psidft = Akbg*basicmorse;
F  = (fo./scales)/(2*pi);



function Akbg = morsenormconstant(ga,be,k)
% Returns the Morse wavelet normalization constant for the k-th order
% Morse wavelet based on the parameters, \beta and \gamma
% In R2016b, we are just supporting k=0, accordingly, this is just equal
% to 1.
r = (2*be+1)/ga;
Akbg =sqrt(exp(gammaln(r)+gammaln(k+1)-gammaln(k+r)));

