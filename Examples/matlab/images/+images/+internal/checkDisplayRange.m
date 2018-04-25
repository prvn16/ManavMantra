function display_range = checkDisplayRange(display_range,fcnName)
%checkDisplayRange display range check function

%   Copyright 2006-2014 The MathWorks, Inc.  

if isempty(display_range)
    return
end

validateattributes(display_range, {'numeric'},...
              {'real' 'nonsparse' 'vector','nonnan'}, ...
              fcnName, '[LOW HIGH]', 2);
          
if numel(display_range) ~= 2
  error('images:checkDisplayRange:not2ElementVector', '%s',getString(message('MATLAB:images:checkDisplayRange:not2ElementVector')))
end

if display_range(2) <= display_range(1)
  error('images:checkDisplayRange:badDisplayRangeValues', '%s',getString(message('MATLAB:images:checkDisplayRange:badDisplayRangeValues')))
end

display_range = double(display_range);
