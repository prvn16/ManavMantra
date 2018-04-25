%TaggedArrayFunction
% Function handle wrapper that manages all TaggedArray inputs.
%
% This will unwrap tagged array types prior to calling the function handle
% and if necessary, wrap the output. TaggedArray types include:
%  * BroadcastArray: Complete arrays that have been explicitly broadcasted
%  to all partitions and all chunks
%  * UnknownEmptyArray: Chunks of height 0 where either the type or small
%  size is not known.

% Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) TaggedArrayFunction < matlab.mixin.Copyable
    properties (SetAccess = immutable)
        % The underlying function handle to be invoked. This is public so
        % that debug and log utilities can unwrap this TaggedArrayFunction.
        Handle;
    end
    
    methods (Static)
        function fh = wrap(fh, options)
            % Wrap a FunctionHandle object in a FunctionHandle that will
            % handle tagged input types. This will handle both broadcasts
            % and unknown empty inputs, converting each to their respective
            % non-tagged representations for the function handle.
            import matlab.bigdata.internal.FunctionHandle;
            import matlab.bigdata.internal.lazyeval.TaggedArrayFunction;
            if nargin < 2 || isempty(options) || ~options.PassTaggedInputs
                fh = fh.copyWithNewHandle(TaggedArrayFunction(fh.Handle));
            end
        end
    end
    
    methods
        function varargout = feval(obj, varargin)
            hasUnknownTypes = false;
            hasUnknownSizes = false;
            for ii = 1:numel(varargin)
                if isa(varargin{ii}, 'matlab.bigdata.internal.BroadcastArray')
                    varargin{ii} = varargin{ii}.Value;
                end
                if matlab.bigdata.internal.UnknownEmptyArray.isUnknown(varargin{ii})
                    hasUnknownTypes = hasUnknownTypes || ~hasType(varargin{ii});
                    hasUnknownSizes = hasUnknownSizes || ~hasSize(varargin{ii});
                    varargin{ii} = getSample(varargin{ii});
                end
            end
            
            % This trick ensures MATLAB can use emplace optimization if there are no
            % other copies of the input.
            [varargin, varargout{2:nargout}] = feval(obj.Handle, varargin{:});
            varargout{1} = varargin;
            
            % If any input has unknown size and or type, we propagate that information
            % forward to anything that matches the default empty representation. This
            % is because type/size propagates through all functions and we do not want
            % to move from a position of uncertainty to a position of certainty without
            % good reason.
            if hasUnknownTypes || hasUnknownSizes
                for ii = 1 : numel(varargout)
                    if size(varargout{ii}, 1) == 0
                        
                        sz = size(varargout{ii});
                        if hasUnknownSizes && isequal(sz, [0,0])
                            sz = [];
                        end
                        
                        type = class(varargout{ii});
                        if hasUnknownTypes && type == "double"
                            type = '';
                        end
                        if isempty(sz) || isempty(type)
                            varargout{ii} = matlab.bigdata.internal.UnknownEmptyArray.build(sz, type);
                        end
                    end
                end
            end
        end
    end
    
    methods (Access = private)
        function obj = TaggedArrayFunction(handle)
            % Private constructor for the static wrap function.
            obj.Handle = handle;
        end
    end
    
    methods (Access = protected)
        function obj = copyElement(obj)
            % Override of copy to ensure underlying array is copied.
            import matlab.bigdata.internal.lazyeval.TaggedArrayFunction;
            if isa(obj.Handle, 'matlab.mixin.Copyable')
                obj = TaggedArrayFunction(copy(obj.Handle));
            else
                obj = TaggedArrayFunction(obj.Handle);
            end
        end
    end
end
