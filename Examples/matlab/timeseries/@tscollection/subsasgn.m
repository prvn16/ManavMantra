function hout = subsasgn(h, S, input)

% Copyright 2005-2012 The MathWorks, Inc.

if strcmp(S(1).type,'.') && any(strcmp(S(1).subs,gettimeseriesnames(h)))  
     if length(S)>=2 % .Member.Prop = 
         thists = getts(h,S(1).subs);
         thists = subsasgn(thists,S(2:end),input);
         hout = setts(h,thists,S(1).subs);
     else % .Member =
         hout = setts(h,input,S(1).subs);
     end
% Modify timeInfo prop
elseif strcmpi(S(1).subs,'timeinfo')
     if length(S)>=2
         timeInfo = h.TimeInfo;
         input = subsasgn(timeInfo,S(2:end),input);
     end
     if ~h.BeingBuilt && input.Length ~= h.TimeInfo.Length
         error(message('MATLAB:tscollection:subsasgn:noLengthChange'));
     end
     h.TimeInfo = input;
     hout = h;
% Modify name prop
elseif strcmpi(S(1).subs,'name') || strcmpi(S(1).subs,'time') || ...
        strcmpi(S(1).subs,'beingbuilt')
     hout = builtin('subsasgn',h,S,input);
% New member timeseries
elseif length(S)== 1 && strcmp(S.type,'.') && ischar(S.subs) && ...
        isa(input,'timeseries')
     input.Name = S.subs;
     hout = addts(h,input);
else
    error(message('MATLAB:tscollection:subsasgn:badsyntax'))
end
    
