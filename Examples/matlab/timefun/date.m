function t = date
%DATE   Current date as character vector.
%   S = DATE returns a character vector containing the date in dd-mmm-yyyy format.
%
%   See also NOW, CLOCK, DATENUM.

%   Copyright 1984-2016 The MathWorks, Inc.

c = clock;
mths = ['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';
        'Aug';'Sep';'Oct';'Nov';'Dec'];
d = sprintf('%.0f',c(3)+100);
t = [d(2:3) '-' mths(c(2),:) '-' sprintf('%.0f',c(1))];
