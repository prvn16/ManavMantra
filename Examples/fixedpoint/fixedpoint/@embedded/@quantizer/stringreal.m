function s = stringreal(q,s)
%STRINGREAL Real part of string
%
%   STRINGREAL(S) returns the real part of string S.
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
%   %  18 + 1ci  0c + 10i  16 + 1ai
%   %  12 + 16i  15 + 19i  17 + 1bi
%   %  14 + 18i  18 + 1ci  10 + 14i
%     
%
%     sr = stringreal(s)
%
%   % returns
%   %
%   %  sr = 
%   %
%   %  18   0c   16
%   %  12   15   17
%   %  14   18   10
%
%   See also QUANTIZER

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

[ri,ci] = find(s == 'i');
if ~isempty(ci)
  % Remove out everything between each + and i
  [rp,cp] = find(s == '+');
  ci = unique(ci);
  cp = unique(cp);
  for k=length(ci):-1:1
    s(:,cp(k):ci(k)) = '';
  end
end  
s = deblank(s);
