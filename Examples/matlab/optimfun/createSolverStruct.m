function solverStruct = createSolverStruct(product)

%CREATESOLVERSTRUCT Create solver structure
%
%   SOLVERSTRUCT = CREATESOLVERSTRUCT(PRODUCT) creates a structure
%   containing solvers for the required products. PRODUCT is a cell array
%   containing any of the following strings; 'matlab', 'optim' or 'global'
%
%   SOLVERSTRUCT = CREATESOLVERSTRUCT(ENABLEALLSOLVERS) creates a structure
%   containing solvers for the following products:
%
%   * ENABLEALLSOLVERS = false: 'matlab' and 'optim'
%   * ENABLEALLSOLVERS = true: 'matlab', 'optim' and 'global'

%   Copyright 2013-2014 The MathWorks, Inc.

if islogical(product)
    if product
        product = {'matlab', 'optim', 'global'};
    else
        product = {'matlab', 'optim'};
    end
end

solverStruct = struct;
if any(strcmpi(product, 'matlab'))
    solverStruct.fminsearch = [];
    solverStruct.fzero = [];
    solverStruct.fminbnd = [];
    solverStruct.lsqnonneg = [];
end

if any(strcmpi(product, 'optim'))
    solverStruct.fmincon = [];
    solverStruct.fminunc = [];
    solverStruct.lsqnonlin = [];
    solverStruct.lsqcurvefit = [];
    solverStruct.linprog = [];
    solverStruct.quadprog = [];
    solverStruct.fgoalattain = [];
    solverStruct.fminimax = [];
    solverStruct.fseminf = [];
    solverStruct.fsolve = [];
    solverStruct.lsqlin = [];
    solverStruct.intlinprog = [];
end

if any(strcmpi(product, 'global'))
    solverStruct.ga = [];
    solverStruct.patternsearch = [];
    solverStruct.simulannealbnd = [];
    solverStruct.gamultiobj = [];
    solverStruct.particleswarm = [];
end
