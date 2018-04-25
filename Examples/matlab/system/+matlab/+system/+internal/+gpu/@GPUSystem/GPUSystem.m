classdef GPUSystem < matlab.system.internal.gpu.GPUBase
%GPUSYSTEM
%  Abstract base class for MATLAB-based System objects which run on the GPU.  
 
%   Copyright 2012 The MathWorks, Inc.
    
    methods (Access = protected)
        %Default setupGPUImpl is a No-op
        function setupGPUImpl(obj, varargin) %#ok<INUSD>
        end
    end

    methods (Access = protected, Abstract)
        varargout = stepGPUImpl(obj, varargin);
    end

    methods (Access = protected, Sealed)
        function setupImpl(obj, varargin)
            detectGPUInputs(obj, varargin{:});
            setupGPUImpl(obj, varargin{:});
        end

        function varargout = stepImpl(obj, varargin)
            [newInputs{1:obj.getNumInputs}] = moveInputsToGPU(obj, varargin{:});
            [varargout{1:obj.getNumOutputs}] = stepGPUImpl(obj, newInputs{:});
            
            % Move all the data back to the CPU 
            if isOutputCPUArray(obj)
                [varargout{1:obj.getNumOutputs}]=moveOutputsToCPU(obj, varargout{:});
            end
        end
    end
end
