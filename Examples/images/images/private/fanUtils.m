function utils = fanUtils
%fanUtils Utility functions for fanbeam projections.
%   UTILS = fanUtils returns a structure of function handles each allowing
%   access to an operation common to multiple fanbeam functions.

%   Copyright 2004 The MathWorks, Inc.
  
utils.formVectorCenteredOnZero = @formVectorCenteredOnZero;
utils.padToOddDim              = @padToOddDim;
utils.setNaNsToZero            = @setNaNsToZero;
utils.repPforCycleCoverage     = @repPforCycleCoverage;  
utils.formMinimalThetaVector   = @formMinimalThetaVector;

%-----------------------------------------------------------
function vec = formVectorCenteredOnZero(delta,minVal,maxVal)

vec = [fliplr(0:-delta:minVal) delta:delta:maxVal];
  
%------------------------------
function [A,m] = padToOddDim(A)

[m,n] = size(A);

% make projections odd m-dimension for symmetry
if mod(m,2) == 0
    A = [zeros(1,n) ; A];
end

% pad to make sure we have a good boundary
A = [zeros(1,n) ; A ; zeros(1,n)];
m = size(A,1);

  
%----------------------------
function A = setNaNsToZero(A)

A(isnan(A)) = 0;


%-----------------------------------------------------------------------
function [PCycle,pthetaCycle] = repPforCycleCoverage(P,ptheta)

PCycle = [P flipud(P)];
pthetaCycle = [ptheta, ptheta+180];

%---------------------------------------------------------------------
function theta = formMinimalThetaVector(n,dthetaDeg,gammaMin,gammaMax)

fudge = n*180*eps;

theta = formVectorCenteredOnZero(dthetaDeg,...
                                 -gammaMax+fudge,...
                                 180-gammaMin-fudge);
theta = [min(theta)-dthetaDeg theta max(theta)+dthetaDeg];