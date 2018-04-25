function s1 = stringimag(q,s)
%STRINGIMAG Imaginary part of string
%
%   STRINGIMAG(S) returns the imaginary part of the string matrix S.
%
%   Example:
%     q=quantizer('float',[6 3]);
%     x=magic(3);
%     s = num2hex(q,x+i*2*x)
%
%   % returns
%   % 
%   %  s = 
%   %
%   %      18 + 1ci  0c + 10i  16 + 1ai
%   %      12 + 16i  15 + 19i  17 + 1bi
%   %      14 + 18i  18 + 1ci  10 + 14i
%   %
%     si = stringimag(s)
%
%   % returns
%   %
%   %  si = 
%   %      1c 10 1a
%   %      16 19 1b
%   %      18 1c 14
%
%   See also QUANTIZER

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

[ri,ci] = find(s == 'i');
if isempty(ci)
  % All real
  s1 = s([]);
else
  % Leave everything between each + and i
  [rp,cp] = find(s == '+');
  ci = unique(ci);
  cp = unique(cp);
  s1 = '';
  for k=1:length(ci);
    s1 = [s1,s(:,cp(k)+1:ci(k)-1)];
  end
  % Remove the leading blanks
  s1 = strjust(s1,'left');
end  
