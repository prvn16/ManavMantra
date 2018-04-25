%Optimizer Base class for Closure graph optimizers

% Copyright 2016-2017 The MathWorks, Inc.
classdef (Abstract) Optimizer < handle
    methods (Abstract)
        % Optimize the execution graphs for a series of tall arrays. Inputs are
        % partitioned arrays whose underlying execution graphs are modified
        % in-place. Returns a RAII guard that undoes any optimization for
        % use to revert changes in case of error.
        undoGuard = optimize(obj, varargin);
    end
    methods (Static)
        function out = default(in)
        %DEFAULT get or set the default optimizer.
        %   op = Optimizer.default() retrieves the current default
        %
        %   old = Optimizer.default(new) sets a new default, returning the old
        %   default.
            
            persistent DEFAULT
            if isempty(DEFAULT)
                % The order of optimizers is important. This is because
                % SlicewiseFusingOptimizer only fuses connected components
                % and FusingOptimizer can connect two components if each
                % originates from a fusable reduction.
                DEFAULT = matlab.bigdata.internal.optimizer.CompositeOptimizer(...
                    matlab.bigdata.internal.optimizer.FusingOptimizer(), ...
                    matlab.bigdata.internal.optimizer.SlicewiseFusingOptimizer());
            end
            
            if nargout
                out = DEFAULT;
            end
            
            if nargin && ~isempty(in)
                assert(isa(in, 'matlab.bigdata.internal.Optimizer'));
                DEFAULT = in;
            end
        end
        
    end
end
