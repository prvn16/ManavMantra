function [c, varargout] = unique(A, varargin) %#ok<STOUT> for error messages
%UNIQUE Set unique.
%   C = UNIQUE(A) for vector A
%   C = UNIQUE(A,'rows') for matrix A
%
%   See also tall, unique.

% Copyright 2015-2017 The MathWorks, Inc.

if nargout > 1
    error(message('MATLAB:bigdata:array:UniqueSortSingleOutput', upper(mfilename)));
end

A = tall.validateType(A, mfilename, {'~calendarDuration'}, 1);
isTabularInput = any(strcmp(tall.getClass(A), {'table', 'timetable'}));
% Starting point for the output adaptor - retain type information from input.
outAdaptor = resetSizeInformation(A.Adaptor);

if nargin == 1
    if ~isTabularInput
        % Non-table inputs without 'rows' specifier must be vectors.
        A = tall.validateVector(A, 'MATLAB:bigdata:array:UniqueRequiresVector');
    end
    fcn = @unique;
else
    tall.checkNotTall(upper(mfilename), 1, varargin{:});
    if all(cellfun(@(x) strcmpi(x, 'rows'), varargin))
        if numel(varargin) > 1
            error(message('MATLAB:UNIQUE:RepeatedFlag','rows'));
        end
    else
        error(message('MATLAB:bigdata:array:UniqueUnsupportedSyntax'));
    end

    % If we get here, the flag must have been 'rows'.
    % Here we simply defer to MATLAB's UNIQUE with 'rows' specified. This will throw
    % an appropriate error if A is not a matrix.
    fcn = @(a) unique(a, 'rows');
    
    % In this case, we want to copy only the small sizes
    outAdaptor = copySizeInformation(outAdaptor, A.Adaptor);
    outAdaptor = resetTallSize(outAdaptor);
end

c = reducefun(fcn, A);
c.Adaptor = outAdaptor;
end
