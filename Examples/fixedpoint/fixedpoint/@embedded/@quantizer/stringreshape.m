function y = stringreshape(q,x,siz)
%STRINGRESHAPE Reshape "column" of strings to "matrix" of strings
%
%   STRINGRESHAPE(Q,S,SIZ) reshapes "column" of strings S to a "matrix" of
%   strings of size SIZ = [M N] of M rows and N columns.  Q is a
%   quantizer object.
%
%   Example:
%     s = ['8'
%          '3'
%          '4'
%          '1'
%          '5'
%          '9'
%          '6'
%          '7'
%          '2'];
%
%     q = quantizer;
%     stringreshape(q,s,[3 3])
%   % returns
%   %  ['8  1  6'
%   %   '3  5  7'  
%   %   '4  9  2']
%
%   See also QUANTIZER

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

m = siz(1); n = siz(2);
space = '  ';
tony = ones(m,1);
y = '';
for k = 1:n
  y = [y, x(((k-1)*m+1):k*m,:), space(tony,1:end)];
end
