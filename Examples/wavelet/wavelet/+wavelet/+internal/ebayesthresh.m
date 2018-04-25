function muhat = ebayesthresh(x,vscale,thresholdrule,transformtype)
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

% Set maximum interations for intervalsolve() binary search routine.
maxiter = 50;
minstd = 1e-9;
m = size(x,1);
% normfac = 1/norminv(0.75,0,1);
normfac = 1/(-sqrt(2)*erfcinv(2*0.75));
if strcmpi(vscale,'leveldependent')
    stdest = normfac*median(abs(x-median(x)));
    stdest = repmat(stdest,m,1);
else
    stdest = vscale;
    stdest = repmat(stdest,m,1);
end
% Guard against zero standard deviation
stdest(stdest<minstd) = minstd;
% Vectors have unit standard deviation
x = x./stdest;
% weight can be a scalar or row vector
weight = wavelet.internal.weightfromdata(x,30,transformtype);
if strcmpi(thresholdrule,'median')
    muhat = wavelet.internal.postmedcauchy(x,weight,maxiter);
elseif strcmpi(thresholdrule,'mean')
    muhat = wavelet.internal.postmeancauchy(x,weight);
elseif any(strcmpi(thresholdrule,{'soft','hard'}))
    % Change weight to a column vector for threshfromweight
    weight = weight(:);
    thr = wavelet.internal.threshfromweight(weight,maxiter);
    thr = thr';
    thr = repmat(thr,size(x,1),1);
    muhat = wthresh(x,lower(thresholdrule(1)),thr);
end
muhat = muhat.*stdest;
