classdef offsetstrel < matlab.mixin.CustomDisplay
%OFFSETSTREL Create offset morphological structuring element.
%   SE = OFFSETSTREL(OFFSET) creates a nonflat structuring element with the
%   specified additive OFFSET.  OFFSET is a matrix containing the values to
%   be added to each pixel location in the neighborhood when performing the
%   morphology operation. OFFSET values that are -Inf are not considered in
%   the computation. OFFSET must strictly be a double precision matrix.
%
%   SE = OFFSETSTREL('ball',R,H) creates a nonflat "ball-shaped"
%   structuring element whose radius in the X-Y plane is R and whose offset
%   height is H.  R must be a nonnegative integer, and H must be a real
%   scalar. This shape is approximated by a sequence of 8 nonflat line
%   shaped structuring elements, for improved performance.
%
%   SE = OFFSETSTREL('ball',R,H,N) creates a nonflat "ball-shaped"
%   structuring element whose radius in the X-Y plane is R and whose offset
%   height is H.  R must be a nonnegative integer, and H must be a real
%   scalar.  N must be an even nonnegative integer.  When N is greater than
%   0, the ball-shaped structuring element is approximated by a sequence of
%   N nonflat line-shaped structuring elements.  When N is 0, no
%   approximation is used, and the structuring element members comprise all
%   pixels whose centers are no greater than R away from the origin, and
%   the corresponding height values are determined from the formula of the
%   ellipsoid specified by R and H.  If N is not specified, the default
%   value is 8. Morphological operations using ball approximations (N>0)
%   run much faster than when N=0.
%
%   Examples
%   --------
%       se1 = offsetstrel(rand(5,5))  % arbitrary shape, nonflat
%       se2 = offsetstrel('ball',15, 6)  % ball shaped, radius 15, height 6
%
%   See also STREL, IMDILATE, IMERODE.

%   Copyright 2015-2017 The MathWorks, Inc.

    properties (Dependent)

        Offset
        Dimensionality
        
    end
    
    properties (Access = private)
        
        OffsetSEHolder
        Type
        
    end
    
    % public
    methods

        function se = offsetstrel(varargin)
            
            if (nargin == 0)
                % No input arguments --- return empty offsetstrel
                se.OffsetSEHolder = strel;
                se.Type = 'arbitrary';
                
            else
                args = matlab.images.internal.stringToChar(varargin);
                [type,params] = ParseInputs(args{:});
                
                switch type
                    case 'arbitrary'
                        nhood = isfinite(params{1});
                        se.OffsetSEHolder = strel('arbitrary', nhood, params{1});
                    case 'ball'
                        se.OffsetSEHolder = strel('ball', params{:});
                    otherwise
                        error(message('images:offsetstrel:unknownStrelType'));
                end
                se.Type = type;
            end
            
        end

        function decomp = decompose(obj)
            %decompose return sequence of decomposed structuring elements.
            %   SEQ = decompose(SE), where SE is an offset structuring
            %   element array, returns another structuring element array
            %   SEQ containing the individual structuring elements that
            %   form the decomposition of SE. SEQ is equivalent to SE, but
            %   the elements of SEQ have no decomposition.
            %
            %   Example 
            %   -------
            %   OFFSETSTREL uses decomposition for ball structuring
            %   elements. Use decompose to extract the decomposed
            %   structuring elements:
            %
            %   se = offsetstrel('ball',5, 6.5) seq = decompose(se)
            
            if ~isempty(obj)
                strelseq = obj.OffsetSEHolder.decompose();
                decomp = repmat(offsetstrel, [1 numel(strelseq)]);
                for k = 1:numel(strelseq)
                    decomp(k).OffsetSEHolder = strelseq(k);
                end
            else
                decomp = offsetstrel;
                decomp(1) = [];
            end

        end

        function ose = reflect(obj)
            %REFLECT Reflect offset structuring element.
            %   SE2 = REFLECT(SE) reflects a structuring element through
            %   its center. The effect is the same as if you rotated the
            %   structuring element's domain 180 degrees around its center
            %   (for a 2-D structuring element). If SE is an array of
            %   structuring element objects, then REFLECT(SE) reflects each
            %   element of SE, and SE2 has the same size as SE.
            %
            %   Example
            %   -------
            %   se = offsetstrel('ball', 5, 6.5);
            %   se2 = se.reflect()
            
            ose = offsetstrel;
            if ~isempty(obj)
                ose.OffsetSEHolder = obj.OffsetSEHolder.reflect();
                ose.Type = obj.Type;
            else
                ose(1) = [];
            end
            
        end

        function ose = translate(obj, displacement)
            %TRANSLATE Translate structuring element.
            %   SE2 = TRANSLATE(SE,V) translates an offset structuring
            %   element SE in N-D space.  V is an N-element vector
            %   containing the offsets of the desired translation in each
            %   dimension.
            
            if ~isa(displacement,'double')
                error(message('images:translate:invalidInputDouble'));
            end
            if any(displacement ~= floor(displacement))
                error(message('images:translate:invalidInput'));
            end
            
            displacement = displacement(:)';
            ose = offsetstrel;
            if ~isempty(obj)
                ose.OffsetSEHolder = obj.OffsetSEHolder.translate(displacement);
            else
                ose(1) = [];
            end
            ose.Type = obj.Type;
        end
        
        function TF = isflat(~)
            TF = false;
        end

    end
    
    % get methods for dependent properties 
    methods 

        function Offset = get.Offset(obj)
           
            Offset = obj.OffsetSEHolder.getheight();
            Offset(~obj.OffsetSEHolder.Neighborhood) = -Inf;
            
        end 

        function dims = get.Dimensionality(obj)
           
            dims = ndims(obj.Offset);
            
        end         

    end

    % Display override
    methods (Access = protected)

        function header = getHeader(obj)
          
            headerStr = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
            if length(obj) == 1            
                headerStr = [headerStr, ' ', getString(message('images:offsetstrel:offsetObjectHeaderInfo',obj.Type))];
                header = sprintf('%s\n',headerStr);
            else
                header = getHeader@matlab.mixin.CustomDisplay(obj);
            end

        end        

        function group = getPropertyGroups(~)

            plist = {'Offset','Dimensionality'};
            group = matlab.mixin.util.PropertyGroup(plist,'');

        end

    end
    
    % morphop compatibility interface
    methods (Hidden = true)

        function nhood = getnhood(obj)
            if length(obj) ~= 1
                error(message('images:offsetstrel:singleOffsetStrelOnly'));
            end
            nhood = obj.OffsetSEHolder.Neighborhood;
        end

        function offset = getheight(obj)
            if length(obj) ~= 1
                error(message('images:offsetstrel:singleOffsetStrelOnly'));
            end
            offset = obj.OffsetSEHolder.getheight();
            offset(~obj.OffsetSEHolder.Neighborhood) = -Inf;
        end

        function [pad_ul, pad_lr] = getpadsize(obj)
            % Required padding 
            
            % Find the array offsets and heights for each structuring element
            % in the sequence.
            num_strels = numel(obj);
            offsets    = cell(1,num_strels);
            for sInd = 1:num_strels
                offsets{sInd} = obj(sInd).OffsetSEHolder.getneighbors();
            end
            
            if isempty(offsets)
                pad_ul = zeros(1,2);
                pad_lr = zeros(1,2);
                
            else
                num_dims = size(offsets{1},2);
                for k = 2:length(offsets)
                    num_dims = max(num_dims, size(offsets{k},2));
                end
                for k = 1:length(offsets)
                    offsets{k} = [offsets{k} zeros(size(offsets{k},1),...
                        num_dims - size(offsets{k},2))];
                end
                
                pad_ul = zeros(1,num_dims);
                pad_lr = zeros(1,num_dims);
                
                for k = 1:length(offsets)
                    offsets_k = offsets{k};
                    if ~isempty(offsets_k)
                        pad_ul = pad_ul + max(0, -min(offsets_k,[],1));
                        pad_lr = pad_lr + max(0, max(offsets_k,[],1));
                    end
                end
                
            end
        end

        function decomp = getsequence(obj)
            decomp = obj.decompose();
        end

        function TF = isdecompositionorthogonal(obj)
            num_strels = numel(obj);
            P = ones(num_strels,2);
            
            for sInd = 1:num_strels
                nhood_size = size(obj(sInd).getnhood);
                P(sInd,1:numel(nhood_size)) = nhood_size;
            end
            
            % Fill in trailing singleton dimensions as needed
            P(P==0) = 1;
            
            TF = any( sum(P~=1,1) == 1);
        end
        
    end
    
    %codegen redirect
   methods(Access=private, Static)
       
       %------------------------------------------------------------------
       function name = matlabCodegenRedirect(~)
         name = 'images.internal.coder.strel.OffsetStructuringElementHelper';
       end
       
   end
    
end

% input parsing
function [type,params] = ParseInputs(varargin)

    default_ball_n = 8;

    narginchk(1, 4);

    if ~ischar(varargin{1})
        type = 'arbitrary';
        params = varargin;
    else
        params = varargin(2:end);

        valid_strings = {'arbitrary'
            'ball'};
        type = validatestring(varargin{1}, valid_strings, 'offsetstrel', ...
            'OFFSETSTREL_TYPE', 1);
    end

    num_params = numel(params);

    switch type
        case 'arbitrary'
            if (num_params < 1)
                error(message('images:offsetstrel:tooFewInputs', type))
            end

            % Check validity of the NHOOD argument.
            height = params{1};
                validateattributes(height, {'double'}, {'real', 'nonnan'}, 'offsetstrel', ...
                    'OFFSET', 1);

            if (num_params > 1)
                error(message('images:offsetstrel:tooManyInputs', type))
            end

        case 'ball'
            if (num_params < 2)
                error(message('images:offsetstrel:tooFewInputs',type))
            end
            if (num_params > 3)
                error(message('images:offsetstrel:tooManyInputs',type))
            end

            r = params{1};
            validateattributes(r, {'double'}, {'scalar' 'real' 'integer' 'nonnegative'}, ...
                'offsetstrel', 'R', 2);

            h = params{2};
            validateattributes(h, {'double'}, {'scalar' 'real'}, 'offsetstrel', 'H', 3);

            if (num_params < 3)
                params{3} = default_ball_n;
            else
                n = params{3};
                validateattributes(n, {'double'}, {'scalar' 'real' 'integer' 'nonnegative' ...
                    'even'}, 'offsetstrel', 'N', 4);
            end

        otherwise
            % This code should be unreachable.
            error(message('images:offsetstrel:unrecognizedStrelType'))
    end

end