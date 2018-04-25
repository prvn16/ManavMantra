classdef OffsetStructuringElementHelper < handle %#codegen
	% Copyright 2015 The MathWorks, Inc.
    %OFFSETSTRUCTURINGELEMENTHELPER Create non-flat morphological structuring element.
    properties
       
        Offset
        Dimensionality
        
    end
    
    properties(Access=private)
        % Store input parameters of strel in params
        OffsetSEHolder
        params
    end
    
    methods
        
        function obj = OffsetStructuringElementHelper(varargin)
            narginchk(1,3);
            eml_assert_all_constant(varargin{:});
            coder.internal.prefer_const(varargin{:});
            obj.params = coder.internal.cell(varargin{:});
            % The input values in varargin are stored and not executed. 
            % The following line is required for checking errors in the 
            % constructor syntax. It has no other effect.
            coder.const(feval('offsetstrel',varargin{:}));
            if coder.internal.const(isnumeric(varargin{1}))
            	nhood = coder.internal.const(isfinite(varargin{1}));
                obj.OffsetSEHolder = images.internal.coder.strel.StructuringElementHelper('arbitrary', nhood, varargin{1});
            else
                if coder.internal.const(strncmpi('ball', varargin{1}, numel(varargin{1})))
                    obj.OffsetSEHolder = images.internal.coder.strel.StructuringElementHelper(varargin{:});
                else
                    nhood = coder.internal.const(isfinite(varargin{2}));
                    obj.OffsetSEHolder = images.internal.coder.strel.StructuringElementHelper('arbitrary', nhood, varargin{2});
                end
            end
            obj.Offset = obj.OffsetSEHolder.getheight();
            obj.Dimensionality = ndims(obj.OffsetSEHolder.getnhood());
            
        end
        
        function seq = decompose(~) %#ok<STOUT>
            coder.internal.errorIf(true,'images:strel:methodNotSupportedForCodegen','decompose');
        end        
        
        function seq = getsequence(~) %#ok<STOUT>
            coder.internal.errorIf(true,'images:strel:methodNotSupportedForCodegen','getsequence');
        end
        
        function se2 = reflect(~) %#ok<STOUT>
            coder.internal.errorIf(true,'images:strel:methodNotSupportedForCodegen','reflect');
        end
        
        function se1 = translate(~,displacement) %#ok<STOUT>
            coder.internal.errorIf(true,'images:strel:methodNotSupportedForCodegen','translate');
        end
        
        function TF = isequal(~,se) %#ok<STOUT>
            coder.internal.errorIf(true,'images:strel:methodNotSupportedForCodegen','isequal');
        end
        
        function se = loadobj(~) %#ok<STOUT>
            coder.internal.errorIf(true,'images:strel:methodNotSupportedForCodegen','loadobj');
        end
        
        function nhood = getnhood(obj,varargin) 
            narginchk(1,2)
            
            if isempty(varargin)
                % apply getnhood() on the strel object
                idx = 0;
            else
                % apply getnhood() on a decomposed strel object indexed by
                % the input, idx
                idx = varargin{1};
            end
            nhood = coder.internal.const(obj.OffsetSEHolder.getnhood(idx));
        end
        
        function height = getheight(obj,varargin)
            narginchk(1,2)
            
            if isempty(varargin)
                % apply getnhood() on the strel object
                idx = 0;
            else
                % apply getnhood() on a decomposed strel object indexed by
                % the input, idx
                idx = varargin{1};
            end
            height = coder.internal.const(obj.OffsetSEHolder.getheight(idx));
        end
        
        function len = getsequencelength(obj)
            len = coder.internal.const(obj.OffsetSEHolder.getsequencelength());
        end
        
        function TF = isdecompositionorthogonal(obj)
            TF = coder.internal.const(obj.OffsetSEHolder.isdecompositionorthogonal());
        end
        
        function TF = isflat(~,varargin)
            narginchk(1,2)
            TF = false;
        end

        function [pad_ul, pad_lr] = getpadsize(obj)
            [pad_ul, pad_lr] = coder.internal.const(obj.OffsetSEHolder.getpadsize());
        end
        
    end
    
end
