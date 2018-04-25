function y = emptyLike(sz,like,x)
%EMPTYLIKE Create the equivalent of "class(x).empty(sz)".

%   Copyright 2012 The MathWorks, Inc.

% y = empty(sz,'Like',x);

% y = eval([class(x) '.empty(sz)']);
y = x(zeros(sz));
