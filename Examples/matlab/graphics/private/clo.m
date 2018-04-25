function clo(obj, in1, in2)
%CLO Clear object
%   CLO(H) deletes all children of the object with visible handles.
%
%   CLO(..., 'reset') deletes all children (including ones with hidden
%   handles) and also resets all object properties to their default
%   values.
%
%   CLO(..., HSAVE) deletes all children except those specified in
%   HSAVE.
%
%   See also CLF, CLA, RESET, HOLD.

%   Copyright 1984-2016 The MathWorks, Inc.

% decode input args:
hsave    = [];
do_reset = '';

narginchk(1, 3);

if nargin > 1
    if ischar(in1)
        do_reset = in1;
    else
        hsave = in1;
    end
    if nargin > 2
        if ischar(in2)
            do_reset = in2;
        else
            hsave = in2;
        end
    end
end

% error-check input args
if ~isempty(do_reset)
  if ~strcmp(do_reset, 'reset')
    error(message('MATLAB:clo:unknownOption'))
  else
    do_reset = 1;
  end
else
  do_reset = 0;
end

if any(~isgraphics(hsave))
  error(message('MATLAB:clo:invalidHandle'))
end

obj = handle(obj); % In case of double handle
obj.clo(hsave, (do_reset == 1)); % Call clo method on graphics class
