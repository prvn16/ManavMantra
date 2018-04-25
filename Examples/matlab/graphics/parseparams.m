function [regargs, proppairs]=parseparams(args)
%PARSEPARAMS Finds first string argument.
%   [REG, PROP]=PARSEPARAMS(ARGS) takes cell array ARGS and
%   separates it into two argument sets:
%      REG being all arguments up to, but excluding, the
%   first string argument encountered in ARGS.
%      PROP contains all other arguments after, and including,
%   the first string argument encountered.
%
%   PARSEPARAMS is intended to isolate possible property
%   value pairs in functions using VARARGIN as the input
%   argument.

%   Chris Portal 2-17-98
%   Copyright 1984-2017 The MathWorks, Inc. 

charsrch=[];

for i=1:length(args)
   charsrch=[charsrch matlab.graphics.internal.isCharOrString(args{i})];
end

charindx=find(charsrch);

if isempty(charindx)
   regargs=args;
   proppairs=args(1:0);
else
   regargs=args(1:charindx(1)-1);
   proppairs=args(charindx(1):end);
end
