function t = empty(varargin)
%TALL.EMPTY Create empty array of class TALL
%   A = TALL.EMPTY returns an empty 0-by-0 tall array.
%   
%   A = TALL.EMPTY(M,N,P,...) returns an empty tall array of doubles with the
%   specified dimensions. At least one of the dimensions must be 0.
%   
%   A = TALL.EMPTY([M,N,P,...]) returns an empty tall array of doubles with the
%   specified dimensions. At least one of the dimensions must be 0.
%   
%   A = TALL.EMPTY(...,CLASSNAME) returns an empty tall array with the specified
%   dimensions and underlying type.
%
%  See also TALL.

% Copyright 2016-2017 The MathWorks, Inc.

tall.checkNotTall(upper(mfilename), 0, varargin{:});
[args, flags] = splitArgsAndFlags(varargin{:});
if numel(flags) > 1
    % only a single flag is permitted - the classname
    error(message('MATLAB:bigdata:array:EmptySingleFlag'));
end

try
    % args must be either a series of scalars, or a vector.
    switch numel(args)
      case 0
        szVec = [0 0];
      case 1
        validateattributes(args{1}, {'numeric'}, {'integer', 'row'}, mfilename);
        szVec = args{1};
      otherwise
        for idx = 1:numel(args)
            validateattributes(args{idx}, {'numeric'}, {'integer', 'scalar'}, mfilename);
        end
        szVec = [args{:}];
    end

    if prod(szVec) ~= 0
        error(message('MATLAB:class:emptyMustBeZero'));
    end

    t = tall.createGathered(zeros(szVec, flags{:}));
catch E
    throw(E);
end
end
