function y = bitconcat(u,v,varargin)
% BITCONCAT Concatenate stored integer bits of fixed-point words
%
% SYNTAX
%   Y = BITCONCAT(A, B, ...)
%   Y = BITCONCAT(A)
%
% DESCRIPTION:
%   Y = BITCONCAT(A, B, ...) returns a new fixed-point unsigned integer value
%       with a concatenated bit representation of input operands 'A', 'B', ...
%
%   Y = BITCONCAT(A) returns a new fixed-point unsigned integer value with a
%       concatenated bit representation of all elements of the input array 'A'.
%
%   1)	Output type is always unsigned with wordlength equal to sum of
%       input fixed point word lengths.
%   2)	Scaling has no bearing on the result type and value.
%   3)	The two's complement representation of inputs are concatenated to
%       form the stored integer value of the output.
%   4)	Mix and match of signed and unsigned inputs are allowed. Signed bit
%       is treated like any other bit.
%   5)	Input operands 'A' and 'B' can be vectors but should be of same
%       size. If the operands are vectors then concatenation will be
%       performed element-wise.
%   6)  complex inputs are not supported.
%   7)  Accepts varargin number of inputs for concatenation
%
%  See also EMBEDDED.FI/BITSLICEGET, EMBEDDED.FI/BITGET, EMBEDDED.FI/BITSET,
%           EMBEDDED.FI/BITAND, EMBEDDED.FI/BITOR, EMBEDDED.FI/BITXOR
%           EMBEDDED.FI/BITANDREDUCE, EMBEDDED.FI/BITORREDUCE,
%           EMBEDDED.FI/BITXORREDUCE
%

%   Copyright 2007-2014 The MathWorks, Inc.
    
    narginchk(1,Inf);
    
    if (nargin == 1)
        y = bitconcat_unary(u);
    else
        % (nargin >= 2)
        y = bitconcat_binary(u, v);
        if (nargin > 2)
            for ii=1:nargin-2
                nextArg = varargin{ii};
                y = bitconcat_binary(y, nextArg);
            end
        end
    end
end

function y = bitconcat_unary(u)
    if ~isreal(u)
        error(message('fixed:fi:unsupportedComplexArguments', 'BITCONCAT'));
    end
    
    bin_u = bin(reshape(u,numel(u),1));
    bin_u2 = reshape(bin_u',1,numel(bin_u));
    
    if isempty(u)
        outwlen = u.WordLength;
    else
        outwlen = numel(u) * u.WordLength;
    end
    if (outwlen < 1) || (outwlen > 65535)
        error(message('fixed:fi:InvalidWordLength'));
    end
    Ty = fi([],numerictype(0,outwlen,0),fimath(u));
    if isempty(u)
        y = zeros(size(u),'like',Ty);
    else
        y = Ty;
        y.bin = bin_u2;
    end
    y.fimathislocal = isfimathlocal(u);
end

function y = bitconcat_binary(u, v)
    if ~isreal(u) || ~isreal(v)
        error(message('fixed:fi:unsupportedComplexArguments', 'BITCONCAT'));
    end

    if (isfi(u) && isfixed(u)) || (isfi(v) && isfixed(v))
        
        if ~isfi(u) || ~isfi(v)
            error(message('fixed:fi:inputArgsNotFis'));
        end
        
        outwlen = u.WordLength + v.WordLength;
        if (outwlen < 1) || (outwlen > 65535)
            error(message('fixed:fi:InvalidWordLength'));
        end

        % Output type is an unsigned integer with the sum of the
        % wordlengths of the inputs
        Ty = fi([],numerictype(0, outwlen, 0),u.fimath);
        
        bin_u = bin(reshape(u,numel(u),1));
        bin_v = bin(reshape(v,numel(v),1));
        
        % do scalar expansion and also find final size
        final_size = size(u);
        if isempty(u)&&isempty(v)
            % Both u and v are empty
            if ~isequal(size(u), size(v))
                error(message('fixed:fi:DimAgree'));
            else
                y = zeros(final_size,'like',Ty);
            end
        else
            if (isempty(u)||isempty(v))
                error(message('fixed:fi:DimAgree'));
                
            else
                % both u and v are non-empty
                if isscalar(u)
                    final_size = size(v);
                    bin_u = repmat(bin_u, numel(v), 1);
                elseif isscalar(v)
                    final_size = size(u);
                    bin_v = repmat(bin_v, numel(u), 1);
                elseif ~isequal(size(u), size(v))
                    error(message('fixed:fi:DimAgree'));
                end
                
                bin_y = [bin_u, bin_v];
            end
            
            y = Ty;
            y.bin = bin_y;
            
            y = reshape(y, final_size);
        end
        y.fimathislocal = isfimathlocal(u);
        
    else
        % non fi-fixedpoint not supported
        if isfi(u)
            dt = u.DataType;
            error(message('fixed:fi:unsupportedDataType',dt));
        else
            error(message('fixed:fi:inputArgsNotFis'));
        end
    end
end
