function bin = bin2dec(str)
%BIN2DEC Convert text representation of binary number to decimal integer
%   X = BIN2DEC(B) interprets B, text that represents a binary number, and
%   returns in X the equivalent decimal number. B must represent a
%   non-negative integer value smaller than or equal to flintmax.
%
%   B can be a character array, a cell array of character vectors, or a
%   string array. If B is a character array, then each row is taken to
%   represent a binary number.
%
%   Embedded, significant spaces are removed. Leading spaces are converted
%   to zeros.
%
%   Example
%       bin2dec('010111') returns 23
%       bin2dec('010 111') also returns 23
%       bin2dec(' 010111') also returns 23
%
%   See also DEC2BIN, HEX2DEC, BASE2DEC, FLINTMAX.

%   Copyright 1984-2016 The MathWorks, Inc.

    if ischar(str)
        bin = bin2decImpl(str);
    elseif iscellstr(str)
        bin = bin2decImpl(char(str));
    elseif isstring(str)
        if any(ismissing(str(:)))
            error(message('MATLAB:string:MissingNotSupported'));
        end
        bin = zeros(size(str));
        for i = 1:numel(str)
           bin(i) = bin2decImpl(str{i});
        end
    else
        error(message('MATLAB:bin2dec:InvalidInputClass'));
    end
end

function x=bin2decImpl(s)

    if isempty(s)
        x = [];
        return,
    end

    % remove significant spaces
    for i = 1:size(s,1)
        spacesHere = (s(i,:)==' '|s(i,:)==0);
        if any(spacesHere)
            stmp = s(i,:);                                  % copy this row
            nrOfZeros=sum(spacesHere);                      % number zeros to prepend
            stmp(spacesHere)='';                            % remove significant spaces
            s(i,:) = [repmat('0',1,nrOfZeros) stmp];        % prepend '0' to pad this row
        else
            continue;
        end
    end

    % check for illegal binary strings
    if any(any(~(s == '0' | s == '1')))
        error(message('MATLAB:bin2dec:IllegalBinaryString'))
    end

    [m,n] = size(s);

    % Convert to numbers
    v = s - '0';

    if nnz(v(:, 1:end-53))
        error(message('MATLAB:bin2dec:InputOutOfRange'));
    end

    twos = pow2(n-1:-1:0);
    x = sum(v .* twos(ones(m,1),:),2);
end