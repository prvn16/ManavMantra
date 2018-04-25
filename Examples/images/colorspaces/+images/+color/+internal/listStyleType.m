function type = listStyleType(level)
% listStyleType HTML ordered list style
%
%    type = images.color.internal.listStyleType(level)
%
%    Returns a style string ('decimal', 'upper-alpha', 'lower-alpha', or 'lower-roman') for an HTML
%    ordered list based on the nesting level of the list.
%
%    The styles returned would produce nested lists using these styles:
%
%    1. Item
%    2. Item
%      A. Item
%      B. Item
%        a. Item
%        b. Item
%          i. Item
%          ii. Item
%            1. Item
%            2. Item
%              A. Item
%              B. Item
%    3. Item

%    Copyright 2014 The MathWorks, Inc.

types = {'decimal', 'upper-alpha', 'lower-alpha', 'lower-roman'};
index = mod(level - 1, numel(types)) + 1;
type = types{index};
end
