function phix = gausscdf(x,mu,sigma,tail)
% This function returns the value of the Gaussian cumulative probability
% distribution function at the value x. x can be a vector, or scalar. 
% tail = 'upper' provides 1-normcdf(x,mu,sigma)
% tail = 'lower' provides normcdf(x,mu,sigma)
% The Gaussian
% PDF is parameterized by \mu and \sigma.
%
% This function is for internal use only. It may change in a future
% release.

% Create standard normal RVs
Z = (x-mu)./sigma;

if strcmpi(tail,'upper')
    Z = -Z;
end

phix = 1/2*erfc(-Z./sqrt(2));