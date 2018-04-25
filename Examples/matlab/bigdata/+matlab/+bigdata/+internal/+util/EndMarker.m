%EndMarker Helper class for tall indexing expressions involving 'end'.

% Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed, Hidden) EndMarker
    properties (SetAccess = immutable)
        % Offset can be a scalar or vector indicating the number of elements away from
        % the actual end to select. Typically this value will be <= 0. Values >=
        % 0 imply indexing off the end of the array.
        Offset = 0
        % ColonForm holds information about the beginning and end of the range, and the
        % offset. If present, it is 2x3 where the first row represents absolute
        % values, or NaN, and the second row represents relative values, or
        % NaN. In other words,
        % "2:2:end" --> [2, 2, NaN; NaN, NaN, 0]
        % "end - 3:end" --> [NaN, 1, NaN; -3, NaN, 0]
        % Note that the increment is always only present in the first row.
        ColonForm = []

        % AbsoluteValue is used when concatenating EndMarkers with numeric values.
        AbsoluteValue = []
    end
    methods
        function obj = EndMarker(offset, colonForm, absValue)
            if nargin > 0
                obj.Offset = offset;
            end
            if nargin > 1
                obj.ColonForm = colonForm;
            end
            if nargin > 2
                obj.AbsoluteValue = absValue;
            end
            % We must have exactly one non-empty field.
            assert(sum(cellfun(@isempty, ...
                               {obj.Offset, obj.ColonForm, obj.AbsoluteValue})) == 2);
        end
        function disp(obj)
            if isscalar(obj)
                if ~isempty(obj.Offset)
                    fprintf('%s\n', iFormatEndOffset(obj.Offset));
                elseif ~isempty(obj.ColonForm)
                    cf = obj.ColonForm;
                    Astr = iFormatOffsetOrNumber(cf(:,1));
                    if cf(1,2) == 1
                        Dstr = '';
                    else
                        Dstr = sprintf('%d:', cf(1,2));
                    end
                    Bstr = iFormatOffsetOrNumber(cf(:,3));
                    fprintf('%s:%s%s\n', Astr, Dstr, Bstr);
                else
                    disp(obj.AbsoluteValue)
                end
            else
                builtin('disp', obj);
            end
        end
        function obj = uminus(varargin) %#ok<STOUT>
            error(message('MATLAB:bigdata:array:InvalidIndexingWithEnd', 'UMINUS'));
        end
        function obj = times(varargin) %#ok<STOUT>
            error(message('MATLAB:bigdata:array:InvalidIndexingWithEnd', 'TIMES'));
        end
        function obj = mtimes(varargin) %#ok<STOUT>
            error(message('MATLAB:bigdata:array:InvalidIndexingWithEnd', 'MTIMES'));
        end
        function obj = rdivide(varargin) %#ok<STOUT>
            error(message('MATLAB:bigdata:array:InvalidIndexingWithEnd', 'RDIVIDE'));
        end
        function obj = mrdivide(varargin) %#ok<STOUT>
            error(message('MATLAB:bigdata:array:InvalidIndexingWithEnd', 'MRDIVIDE'));
        end
        
        function obj = horzcat(varargin)
            obj = cat(2, varargin{:});
        end
        function obj = vertcat(varargin)
            obj = cat(1, varargin{:});
        end
        function obj = cat(dim, varargin)
            import matlab.bigdata.internal.util.EndMarker;
            args = varargin;
            for idx = 1:numel(args)
                if ~iIsEndMarker(args{idx})
                    args{idx} = EndMarker([], [], args{idx});
                end
            end
            obj = builtin('cat', dim, args{:});
        end
        
        
        function obj = plus(A, B)
            import matlab.bigdata.internal.util.EndMarker;

            % Ensure numeric args are 'double' - g1372212
            A = iMaybeDouble(A);
            B = iMaybeDouble(B);
            
            if iIsEndMarker(A) && iIsEndMarker(B)
                % No good can come of this - no way to create a valid index by adding together
                % two indexing expressions that involve END. Of course, for
                % ordinary MATLAB arrays, you can do this. 
                error(message('MATLAB:bigdata:array:InvalidEndPlusEnd'));
            else
                if iIsEndMarker(A)
                    obj = A;
                    incr = B;
                else
                    obj = B;
                    incr = A;
                end
                
                if ~isscalar(incr)
                    error(message('MATLAB:bigdata:array:InvalidEndPlusNonScalar'));
                end
                
                % Update Offset/ColonForm/AbsoluteValue as appropriate
                for idx = 1:numel(obj)
                    offset = obj(idx).Offset;
                    colonForm = obj(idx).ColonForm;
                    absValue = obj(idx).AbsoluteValue;
                    if ~isempty(offset)
                        offset = offset + incr;
                    end
                    if ~isempty(colonForm)
                        colonForm(:,[1,3]) = colonForm(:,[1,3]) + incr;
                    end
                    if ~isempty(absValue)
                        absValue = absValue + incr;
                    end
                    obj(idx) = EndMarker(offset, colonForm, absValue);
                end
            end
        end
        function obj = minus(A, B)
        % Ensure numeric args are 'double' - g1372212
            A = iMaybeDouble(A);
            B = iMaybeDouble(B);
            obj = plus(A, uminus(B));
        end
        function obj = colon(A, D, B)
            if nargin == 2
                B = D;
                D = 1;
            end
            
            if islogical(D)
                % Mimic the warning issued by MATLAB
                warning(message('MATLAB:colon:logicalInput'));
                D = double(D);
            else
                D = iMaybeDouble(D);
            end
            
            A = iMaybeDouble(A);
            B = iMaybeDouble(B);
            
            if ~isnumeric(D)
                error(message('MATLAB:bigdata:array:EndNumericIncrement'));
            end
            
            % Resolve args - this might throw
            rangeStart = iResolveColonEndpoint(A);
            % Note that we do simpy extract the first value from D in the case where the
            % user specified a non-scalar D.
            rangeIncr  = [D(1); NaN];
            rangeEnd   = iResolveColonEndpoint(B);
            range = [rangeStart, rangeIncr, rangeEnd];
            obj = matlab.bigdata.internal.util.EndMarker([], range);
        end

        function tf = isEquivalentToLiteralColon(objs)
        %TRUE if objs is scalar, and represents '1:end'.
            tf = false;
            if isscalar(objs)
                oneColonEndForm = [1,   1,   NaN; 
                                   NaN, NaN, 0];
                tf = isequaln(objs.ColonForm, oneColonEndForm);
            end
        end
        
        function [tf, n, reverse] = isValidTallEndExpression(objs)
        % Must represent end-k:end, or end:-1:end-k.

            n = 0;
            reverse = false;
            % First off, check that we don't have any absolute values - they cannot be valid
            % in combination with END.
            for idx = 1:numel(objs)
                if ~isempty(objs(idx).AbsoluteValue)
                    tf = false;
                    return
                elseif ~isempty(objs(idx).ColonForm)
                    cf = objs(idx).ColonForm;
                    if ~all(isnan(cf(1,[1,3])))
                        tf = false;
                        return
                    end
                end
            end

            % Use 'resolve' to compute *relative* offsets from the END by feeding it a size
            % of zero.
            szVec = [0 0];
            dim   = 1;
            relIdxVec = resolve(objs, szVec, dim);
            relIdxVec = relIdxVec(:);

            % Now check that it's unit offset ending/beginning at the END.
            if isempty(relIdxVec)
                tf = true;
                reverse = false;
                n = 0;
            else
                d  = diff(relIdxVec);
                tf = (all(d == 1) || all(d == -1)) && max(relIdxVec) == 0;
                reverse = all(d == -1);
                n = numel(relIdxVec);
            end
        end
        
        function [n, reverse] = getTrailingNumRows(obj)
            [tf, n, reverse] = isValidTallEndExpression(obj);
            assert(tf);
        end
        
        function computedSz = computeResultingSize(objs)
        %computeResultingSize resolve the resulting size of this subscript if possible
        %   Returns the number of elements that would be selected in a dimension
        %   corresponding to this EndMarker when used as a subscript. This
        %   method operates independently of the size of the underlying array to
        %   which it will be applied, and therefore can only resolve elements
        %   that are either purely absolute, or purely relative.
        %
        %   If the result cannot be computed, NaN is returned.
            
            computedSz = 0;
            for idx = 1:numel(objs)
                obj = objs(idx);
                if ~isempty(obj.ColonForm)
                    if all(isnan(obj.ColonForm(1, [1 3])))
                        % purely relative colon - OK
                        A = obj.ColonForm(2, 1);
                        D = obj.ColonForm(1, 2);
                        B = obj.ColonForm(2, 3);
                        % number of elements in A:D:B is computed using
                        % A + (n-1)*B <= D - but result cannot be negative.
                        increment = max(0, 1 + floor((B-A)/D));
                    else
                        % absolute values involved - cannot resolve, bail out.
                        computedSz = NaN;
                        return
                    end
                elseif ~isempty(obj.Offset)
                    increment = numel(obj.Offset);
                elseif ~isempty(obj.AbsoluteValue)
                    increment = numel(obj.AbsoluteValue);
                end
                computedSz = computedSz + increment;
            end
        end
        
        function absIdxVec = resolve(objs, sz, dim)
        %RESOLVE resolve an EndMarker into an index vector for the provided chunkSize.
            resultCell = cell(size(objs));
            for idx = 1:numel(objs)
                obj = objs(idx);
                szInDim = sz(dim);
                if ~isempty(obj.ColonForm)
                    cf = obj.ColonForm;
                    
                    if ~isnan(cf(1,1))
                        A = cf(1,1);
                    else
                        A = szInDim + cf(2,1);
                    end
                    D = cf(1,2);
                    if ~isnan(cf(1,3))
                        B = cf(1,3);
                    else
                        B = szInDim + cf(2,3);
                    end
                    absIdxVec = A:D:B;
                elseif ~isempty(obj.Offset)
                    % Simple offset
                    absIdxVec = szInDim + obj.Offset;
                else
                    absIdxVec = obj.AbsoluteValue;
                end
                resultCell{idx} = absIdxVec;
            end
            try
                absIdxVec = cell2mat(resultCell);
            catch E
                % Get here if the sizes didn't conform
                error(message('MATLAB:bigdata:array:SizeMismatchIndexingWithEnd'));
            end
        end
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Resolve all numeric and logical inputs to double.
function x = iMaybeDouble(x)
    if isnumeric(x) || islogical(x)
        x = double(x);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Resolve end-point values for colon operations. Reject all cases where the
% end-point is non-scalar (this is different to MATLAB which uses the first
% value - but we cannot be sure we know the first value in all cases).
%
% The return value is a 2-element column vector of [absoluteValue;
% relativeValue]. One element is NaN, the other is non-NaN.
function x = iResolveColonEndpoint(obj)
    absValue = NaN;
    relValue = NaN;
    if ~isscalar(obj)
        error(message('MATLAB:bigdata:array:EndScalarColonEndpoints'));
    end
    if iIsEndMarker(obj)
        if ~isempty(obj.Offset)
            relValue = obj.Offset;
        elseif ~isempty(obj.AbsoluteValue)
            absValue = obj.AbsoluteValue;
        else
            error(message('MATLAB:bigdata:array:EndScalarColonEndpoints'));
        end
    else
        absValue = obj;
    end
    if ~isscalar(absValue) || ~isscalar(relValue)
        error(message('MATLAB:bigdata:array:EndScalarColonEndpoints'));
    else
        x = [absValue; relValue];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = iIsEndMarker(x)
    tf = isa(x, 'matlab.bigdata.internal.util.EndMarker');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = iFormatEndOffset(offset)
    if isscalar(offset)
        if offset > 0
            s = sprintf('end+%d', offset);
        elseif offset < 0
            s = sprintf('end%d', offset);
        else
            s = 'end';
        end
    else
        strs = arrayfun(@iFormatEndOffset, offset, ...
                        'UniformOutput', false);
        s = ['[', strjoin(strs, ','), ']'];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = iFormatOffsetOrNumber(col)
    if ~isnan(col(1))
        s = sprintf('%d', col(1));
    else
        s = iFormatEndOffset(col(2));
    end
end
