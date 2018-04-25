%ISFIELD True if field is in structure array.
%   ISFIELD(S,FIELD) returns true if FIELD is the name of a field in the
%   structure array S. FIELD can be a character vector or a string.
%
%   TF = ISFIELD(S,FIELDNAMES) returns a logical array, TF, the same size
%   as that of FIELDNAMES.  FIELDNAMES can be a string array or cell array of
%   character vectors. TF contains true for the elements of FIELDNAMES that
%   are the names of fields in the structure array S and false otherwise.
%
%   NOTE: TF is false when FIELD or FIELDNAMES are empty.
%
%   Example:
%      s = struct('one',1,'two',2);
%      fields = isfield(s,{'two','pi','One',3.14})
%
%   See also GETFIELD, SETFIELD, FIELDNAMES, ORDERFIELDS, RMFIELD,
%   ISSTRUCT, STRUCT. 

%   Copyright 1984-2017 The MathWorks, Inc.


