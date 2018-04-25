%STRUCT2CELL Convert structure array to cell array.
%   C = STRUCT2CELL(S) converts the M-by-N structure S (with P fields)
%   into a P-by-M-by-N cell array C.
%
%   If S is N-D, C will have size [P SIZE(S)].
%
%   Example:
%     clear s, s.category = 'tree'; s.height = 37.4; s.name = 'birch';
%     c = struct2cell(s); f = fieldnames(s);
%
%   See also CELL2STRUCT, FIELDNAMES.

%   Copyright 1984-2005 The MathWorks, Inc.
%   Built-in function.

