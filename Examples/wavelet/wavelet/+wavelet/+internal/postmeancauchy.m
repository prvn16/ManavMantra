function muhat = postmeancauchy(data,weight)
% This function is for internal use only and may change in a future
% release.
%
%   The empirical Bayes method used here is a MATLAB implementation of the
%   R package.
%
%   Silverman, B. (2012) EbayesThresh: Empirical Bayes Thresholding and
%   Related Methods, http://CRAN.R-project.org/package=EbayesThresh.
%
%   References:
%   Johnstone, I. & Silverman, B. (2005). EbayesThresh: R Programs for
%   Empirical Bayes Thresholding, Journal of Statistical Software, 12,1,
%   pp. 1-38.

ExpX = exp(-data.^2./2);
z = weight.*(data-(2*(1-ExpX))./data);
z = z./(weight.*(1-ExpX)+(1-weight).*ExpX.*data.^2);
muhat = z;

% small values of data cause explosions in value of mu so limit to value of
% data
muhat(data==0) = 0;
hugeMuInds = (abs(muhat) > abs(data));
muhat(hugeMuInds) = data(hugeMuInds);

