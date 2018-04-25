function options = snlsFixedVarWrapOutputAndPlotFcns(options, ...
    idxEqual, l, initGradFixed)
 
%SNLSFIXEDVARWRAPOUTPUTORPLOTFCN Wrap output or plot function
%
%   STOP = SNLSFIXEDVARWRAPOUTPUTORPLOTFCN(X, OPTIMVALUES, STATE, OUTFCN,
%   IDX, LB) provides a wrapper for the user's output or plot function,
%   OUTFCN, so the fixed variables can be inserted back before the user's
%   function is evaluated,
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

% Wrap up any output functions
if isfield(options, 'OutputFcn') && ~isempty(options.OutputFcn)
    % Ensure we have a cell array of functions
    options.OutputFcn = createCellArrayOfFunctions(options.OutputFcn,'OutputFcn');
    % Wrap each output function
    for i = 1:numel(options.OutputFcn)
        options.OutputFcn{i} = @(x, ov, s, varargin)snlsFixedVarEvalOutputOrPlotFcn(...
            x, ov, s, options.OutputFcn{i}, idxEqual, l, initGradFixed, varargin{:});
    end
end

% Wrap up any plot functions
if isfield(options, 'PlotFcns') && ~isempty(options.PlotFcns)
    % Ensure we have a cell array of functions
    options.PlotFcns = createCellArrayOfFunctions(options.PlotFcns,'PlotFcns');
    % Wrap each plot function
    for i = 1:numel(options.PlotFcns)
        options.PlotFcns{i} = @(x, ov, s, varargin)snlsFixedVarEvalOutputOrPlotFcn(...
            x, ov, s, options.PlotFcns{i}, idxEqual, l, initGradFixed, varargin{:});
    end
end
    



