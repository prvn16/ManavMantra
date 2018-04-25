classdef StructuringElementHelper < handle %#codegen
    % Copyright 2015-2016 The MathWorks, Inc.
    %STRUCTURINGELEMENTHELPER Create morphological structuring element.
    
    properties
       Neighborhood
       Dimensionality
    end
    
    properties(Access=private)
        % Store input parameters of strel in params
        params
    end
    
    methods(Access=public)
        function obj = StructuringElementHelper(varargin)
            eml_assert_all_constant(varargin{:});
            coder.internal.prefer_const(varargin{:});
            obj.params = varargin;
            % The input values in varargin are stored and not executed. 
            % The following line is required for checking errors in the 
            % constructor syntax. It has no other effect.
            coder.internal.const(feval('strel',varargin{:}));
            obj.Neighborhood = obj.getnhood();
            obj.Dimensionality = ndims(obj.getnhood());
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
        
        function disp(~)
            coder.internal.errorIf(true,'images:strel:methodNotSupportedForCodegen','disp');
        end
        
        function display(~)
            coder.internal.errorIf(true,'images:strel:methodNotSupportedForCodegen','display');
        end
        
        function TF = eq(~, se) %#ok<STOUT>
            coder.internal.errorIf(true,'images:strel:methodNotSupportedForCodegen','eq');
        end
        
        function TF = isequal(~,se) %#ok<STOUT>
            coder.internal.errorIf(true,'images:strel:methodNotSupportedForCodegen','isequal');
        end
        
        function se = loadobj(~) %#ok<STOUT>
            coder.internal.errorIf(true,'images:strel:methodNotSupportedForCodegen','loadobj');
        end
        
        function nhood = getnhood(obj,varargin)
            coder.extrinsic('images.internal.coder.strel.getnhood');            
                
            narginchk(1,2)
            
            if isempty(varargin)
                % apply getnhood() on the strel object
                idx = 0;  
            else
                % apply getnhood() on a decomposed strel object indexed by
                % the input, idx
                idx = varargin{1}; 
            end
            
            nhood = coder.internal.const(...
                    images.internal.coder.strel.getnhood(...
                    idx, obj.params{:}));

        end
        
        function height = getheight(obj, varargin)
            coder.extrinsic('images.internal.coder.strel.getheight');               
            
            narginchk(1,2)            
            
            if isempty(varargin)
                idx = 0;
            else
                idx = varargin{1};
            end            

            height = coder.internal.const(...
                    images.internal.coder.strel.getheight(...
                    idx, obj.params{:}));

        end
        
        function [offsets, heights] = getneighbors(obj, varargin)
            coder.extrinsic('images.internal.coder.strel.getneighbors');
            
            narginchk(1,2)
            
            if isempty(varargin)
                idx = 0;
            else
                idx = varargin{1};
            end
            
            [offsets, heights] = coder.internal.const(...
                    images.internal.coder.strel.getneighbors(...
                    idx, obj.params{:}));
        end
        
        function TF = isflat(obj, varargin)
            coder.extrinsic('images.internal.coder.strel.isflat');
            
            narginchk(1,2)
            
            if isempty(varargin)
                idx = 0;
            else
                idx = varargin{1};
            end

            TF = coder.internal.const(...
                    images.internal.coder.strel.isflat(...
                    idx, obj.params{:}));

        end
        
        function n = getsequencelength(obj)
            coder.extrinsic('images.internal.coder.strel.getsequencelength');          

            n = coder.internal.const(...
                    images.internal.coder.strel.getsequencelength(...
                    obj.params{:}));

        end
        
        function matlab_obj = getMATLABObj(obj)
            
            matlab_obj = coder.internal.const(feval('strel',obj.params{:}));            
            
        end
        
        function TF = isdecompositionorthogonal(obj)
            
            coder.extrinsic('images.internal.coder.strel.isdecompositionorthogonal');            

            TF = coder.internal.const(...
                    images.internal.coder.strel.isdecompositionorthogonal(...
                    obj.params{:}));

        end
        
        function [pad_ul, pad_lr] = getpadsize(obj)
            coder.extrinsic('images.internal.coder.strel.getpadsize');

            [pad_ul, pad_lr] = coder.internal.const(...
                    images.internal.coder.strel.getpadsize(...
                    obj.params{:}));

        end %getpadsize

    end  %methods

    methods (Static)
        function props = matlabCodegenNontunableProperties(~)
            % used for code generation
            props = {'params'};
        end
    end
    
end %classdef