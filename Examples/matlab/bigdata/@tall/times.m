function C = times(A,B)
%.* Array multiply.
%
%   See also tall/mtimes, tall.

% Copyright 2016 The MathWorks, Inc.

allowedTypes = {'numeric', 'char', 'logical', 'categorical', ...
                'duration', 'calendarDuration', 'cellstr'}; % 'cellstr' for combination with categorical
A = tall.validateType(A, mfilename, allowedTypes, 1);
B = tall.validateType(B, mfilename, allowedTypes, 2);

C = elementfun(@times, A, B);

% Calculate output type and size
unsizedAdaptor = multiplicationOutputAdaptor(A, B);
C.Adaptor = copySizeInformation(unsizedAdaptor, C.Adaptor);
end
