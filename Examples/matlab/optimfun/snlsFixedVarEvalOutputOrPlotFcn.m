function stop = snlsFixedVarEvalOutputOrPlotFcn(x, optimValues, state, ...
    outFcn, idx, lb, initGradFixed, varargin)

%SNLSFIXEDVAREVALOUTPUTORPLOTFCN Evaluate output or plot function
%
%   STOP = SNLSFIXEDVAREVALOUTPUTORPLOTFCN(X, OPTIMVALUES, STATE, OUTFCN,
%   IDX, LB) evaluates the user's output or plot function, OUTFCN, at the
%   free variable point, X. Before the function is called, the fixed
%   variables are inserted back into X.
%
%   This function is intended for use by snlsFixedVar only. 

% *************************************************************************
%     Background as to why this function lives in matlab/optimfun 
%
% This function evaluates the user's output or plot functions when they
% have been called by lsqnonlin/curvefit and the problem has fixed
% variables. To perform this evaluation, this function is called from
% either matlab/optimfun/callAllOptimOutputFcns or
% matlab/optimfun/callAllOptimPlotFcns. 
% 
% It is possible that this function is called without an Optimization
% Toolbox license being available, e.g. when lsqcurvefit is called from the
% Curve Fitting Toolbox. In such cases, if this function lived in
% shared/optimlib, a call to this function from callAllOptimOutput/PlotFcns
% would attempt to check out a license of Optimization Toolbox and would
% subsequently error.
%
% As such, this function must live in matlab/optimfun so it can be called
% without an Optimization Toolbox license being checked out.
% *************************************************************************

%   Copyright 2014 The MathWorks, Inc.

% Create x with fixed variables
Nvars = numel(lb);
xin = i_createFullX(x, idx, Nvars, lb);

% Add gradient with respect to the fixed variables back to the optimValues
% structure
if ~strcmp(state, 'init')
    fullGrad = zeros(Nvars, 1);
    fullGrad(idx) = initGradFixed;
    fullGrad(~idx) = optimValues.gradient;
    optimValues.gradient = fullGrad;
end

% Call the user's output or plot function
stop = outFcn(xin, optimValues, state, varargin{:});

function xin = i_createFullX(x, idx, Nvars, lb)
%I_CREATEFULLX Insert fixed variables back into X
%
%    XIN = I_CREATEFULLX(X, IDXFIXED, NVARS, LB) creates a 1-by-NVARS
%    vector for all the variables in the original problem. For the free
%    variables, XIN(~IDXFIXED) = X. For the fixed variables, XIN(IDXFIXED)
%    = LB.

xin = zeros(1, Nvars);
xin(idx) = lb(idx);
xin(~idx) = x;

