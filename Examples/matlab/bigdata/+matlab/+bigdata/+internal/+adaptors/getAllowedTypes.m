function t = getAllowedTypes()
%getAllowedTypes Get a list of types allowed to be contained by a tall array.

% Copyright 2016-2017 The MathWorks, Inc.

integerTypeNames = strsplit(strtrim(sprintf('int%d uint%d ', ...
                                            repmat([8, 16, 32, 64], 2, 1))));
t = ['double', 'single', integerTypeNames, ...
     'logical', 'char', 'cell', ...
     matlab.bigdata.internal.adaptors.getStrongTypes()];
end
