function [alpha, beta_left, beta_right] = estimateAGGDParameters(dat)
% estimateAGGDParameters computes the Assymetric Generalized Gaussian
%   Parameters for a data vector.

% Copyright 2016 The MathWorks, Inc.

persistent alpha_p alpha_r_p

if(isempty(alpha_p))
     alpha_p = 0.2:0.001:10;
end

if(isempty(alpha_r_p))
     alpha_r_p  =  gamma(2./alpha_p).^2./(gamma(1./alpha_p).*gamma(3./alpha_p));
end
           
% Find negetive data points
dat_neg = dat<0;

% Square the data
dat_sq = dat.*dat;
len = length(dat);

% Find sum squared <0 and >=0 data points 
dat_left = (dat_sq'*dat_neg);
dat_right = abs(sum(dat_sq) - dat_left);

% Find number of <0 and >=0 data points 
N_left = sum(dat_neg);
N_right = len - N_left;

% Standard deviation of <0 data 
if(N_left>0)
    std_left = sqrt(dat_left/N_left);
else
    std_left = nan;
end

% Standard deviation of >=0 data 
if(N_right>0)
    std_right = sqrt(dat_right/N_right);
else
    std_right = nan;
end

% Identify the generalized gaussian parameters
gammahat = std_left/std_right;
rhat = sum(abs(dat))^2/(len*(dat_left+dat_right));

Rhat = rhat*(gammahat^3+1)*(gammahat+1)/((gammahat^2+1)^2);
[~,index] = min((alpha_r_p-Rhat).^2);

alpha = alpha_p(index);
t = sqrt(gamma(1/alpha)/gamma(3/alpha)); 
beta_left = std_left * t;
beta_right = std_right * t;


