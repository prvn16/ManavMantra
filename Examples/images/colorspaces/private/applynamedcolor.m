function out = applynamedcolor(in, nametable, space)
%APPLYNAMEDCOLOR maps color names to color-space coordinates
%   OUT = APPLYNAMEDCOLOR(IN, NAMETABLE, SPACE) associates
%   a character string IN with the coordinates of SPACE, through
%   the use of NAMETABLE.  NAMETABLE is a cell array, typically
%   taken from the NamedColor2.NameTable field of a profile
%   structure corresponding to an ICC Named Color profile.
%   The first column of this array contains color names, as
%   character strings.  The second column contains the associated
%   coordinates in the Profile Connection Space (which may be
%   Lab or XYZ), in 'double' notation.  The third column is
%   optional; if present, it contains the associated device
%   coordinates in 'double' notation.  SPACE must be either
%   'PCS' or 'Device' and is used to select the 2nd or 3rd
%   column of NAMETABLE for output.
%
%   Copyright 2005-2015 The MathWorks, Inc.
%      Poe
%   Original author:  Robert Poe 10/16/05

validateattributes(in, {'char'}, {'vector'}, 'applynamedcolor', 'IN', 1);
validateattributes(nametable, {'cell'}, {'2d'}, 'applynamedcolor', ...
              'NAMETABLE', 2);
validateattributes(space, {'char'}, {'vector'}, 'applynamedcolor', 'SPACE', 3);

if strcmpi(space, 'pcs')
    column = 2;
elseif strcmpi(space, 'device')
    column = 3;
else
    error(message('images:applynamedcolor:unrecognizedSpace'))
end

idx = strmatch(in, nametable(:, 1), 'exact');
if isempty(idx)
    warning(message('images:applynamedcolor:nameNotFound'))
    out = [];
elseif column == 3 && size(nametable, 2) < 3
    warning(message('images:applynamedcolor:unavailableDeviceCoords'))
    out = [];
else
    out = nametable{idx, column};
end
