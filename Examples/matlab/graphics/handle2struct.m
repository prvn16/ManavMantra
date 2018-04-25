%HANDLE2STRUCT Convert Handle Graphics hierarchy to structure array.
%   hgS = HANDLE2STRUCT(H) converts the vector of handles in H into
%   the structure array hgS having the following fields:
%      type:       the object type
%      properties: a structure containing property values
%      children:   a structure array with an element for each child
%      handle:     the object's handle at the time of conversion
%
%   See also STRUCT2HANDLE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   D. Foti  11/19/97
%   Built-in function.

