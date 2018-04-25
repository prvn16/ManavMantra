function [muhat,delta] = postmedcauchy(data,weight,maxiter)
%   This function is for internal use only. It may change in a future
%   release.
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

%   muhat will be a column vector or matrix.
%   The input weight is a scalar or a row vector of weights

muhat = zeros(size(data));
[M,N] = size(muhat);
% Make weight a matrix the same size as muhat
weight = repmat(weight,M,1);
magdata = abs(data);
% Make a copy of magdata
magdatatmp = magdata;
% posterior median estimates start to deviate from actual value. From this
% point on, we replace by shrinkage estimates x-2/x 
idx = magdata < 20;
magdata(~idx) = NaN;
lo = zeros(1,N);

[muhat,delta] = wavelet.internal.intervalsolve(zeros(size(magdata)),...
        @wavelet.internal.cauchymedzero,lo,max(magdata),maxiter,...
        magdata,weight);
muhat(~idx) = magdatatmp(~idx)-2./magdatatmp(~idx);


muhat(muhat < 1e-7) = 0;
muhat = sign(data).*muhat;

hugeMuInds = (abs(muhat) > abs(data));
muhat(hugeMuInds) = data(hugeMuInds);


 


