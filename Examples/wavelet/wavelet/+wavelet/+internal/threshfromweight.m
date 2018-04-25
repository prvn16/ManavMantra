function [thr,delta] = threshfromweight(weight,maxiter)
% This function is for internal use only. It may change in a future
% release.
fun = @wavelet.internal.cauchythreshzero;
zz = zeros(size(weight));
highthresh = 20;
[thr,delta] = wavelet.internal.intervalsolve(zz,fun,0,highthresh,maxiter,weight); 
