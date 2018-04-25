function [psihat,psi] = morsewavelet(omega,k,ga,be)
% Find the time domain, psi, and frequency domain, psihat
% k-th order Morse wavelet
% N is the length of the signal
% k is the order of the Morse wavelet, k=1,etc.
% be is the \beta paramater, be = 8;
% ga = the \gamma parameter, ga = 3;
% [psi,psihat] = morsewavelet(omega,k,be,ga);
%
% This function is for internal use only, it may change in a future
% release.
%
% Algorithms due to JM Lilly
% 
% Lilly, J. M. (2015), jLab: A data analysis package for Matlab, v. 1.6.1, 
% http://www.jmlilly.net/jmlsoft.html.”


fo = wavelet.internal.morsepeakfreq(ga,be);
basicmorse =2*exp(-be.*log(fo)+fo.^ga+be.*log(abs(omega))-abs(omega).^ga).*(omega>0);
%basicmorse = 2*exp(be/ga)*(ga/be)^(be/ga)*omega.^be.*exp(-abs(omega).^ga).*(omega>0);
Akbg = morsenormconstant(be,ga,k);
% Laguerre polynomials only needed for higher-order eigenfunctions
% We are not supporting this in R2016b
%Lkc = zeros(size(omega));
%Lkc(1:fix(N/2)) = wlaguerrepoly(2*abs(omega(1:fix(N/2))).^ga,k,(2*be+1)/ga-1);
psihat = Akbg*basicmorse;



% Only invert if the second output is requested
if nargout == 2
    psi = ifftshift(ifft(psihat));
end



%-------------------------------------------------------------
function Akbg = morsenormconstant(be,ga,k)
% Returns the Morse wavelet normalization constant for the k-th order
% Morse wavelet based on the parameters, \beta and \gamma
% In R2016b, we are just supporting k=0, accordingly, this is just equal
% to 1.
r = (2*be+1)/ga;
Akbg =sqrt(exp(gammaln(r)+gammaln(k+1)-gammaln(k+r)));

%-------------------------------------------------------------------

%-------------------------------------------------------------------
%function Lkc = wlaguerrepoly(x,k,c)
% Returns the k-th generalized Laguerre polynomial
% c = r-1
% r = (2*be+1)/ga; May be better to just pass ga and be
% the input is a vector of radian frequencies 2*omega^ga
%Lkc = zeros(size(x)); % allocate an array of zeros the size of x
%for m = 0:k
%    gammaexp = exp(gammaln(k+c+1)-gammaln(c+m+1)-gammaln(k-m+1));
%    Lkc = Lkc+(-1)^m*gammaexp.*((x.^m)/gamma(m+1));
%end
%-----------------------------------------------------------------