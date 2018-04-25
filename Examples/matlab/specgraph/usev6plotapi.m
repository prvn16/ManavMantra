function [res,args]=usev6plotapi(varargin)
% This undocumented function may be removed in a future release

%USEV6PLOTAPI determine plotting version
%  [V6,ARGS] = USEV6PLOTAPI(ARG1,ARG2,...) checks to see if the V6-compatible
%  plotting API should be used and return true or false in V6 and any
%  remaining arguments in ARGS.

%  if ARG1 is 'v6' then strip it off, issue warning, and return false
%  if ARG1 is 'group' then strip it off and return false
%  else return false
%  if ARG1 is 'defaultv6', then strip it off, issue warning, and return false
%  unless ARG2 is 'group', then strip it off too and return false.

%   Copyright 1984-2014 The MathWorks, Inc.

% defaults
res = ~isempty(getappdata(0,'UseV6PlotAPI'));
args = varargin;
narg = nargin;
filename = '';

% strip off mfilename arguments if necessary.
if (narg>1 && isa(args{end-1},'char')) && ...
        strcmp(args{end-1},'-mfilename') && ...
        isa(args{end},'char')
    filename = args{end};
    args = args(1:end-2);
    narg = narg-2;
end

% Parse the remaining arguments
if narg>0 && isa(args{1},'char')
    if strcmp(args{1},'group')
        res = false;
        args = args(2:end);
    elseif strcmp(args{1},'v6')
        res = false;
        args = args(2:end);
        warnv6args(filename);
    elseif strcmp(args{1},'defaultv6')
        if narg>1 && isa(args{2},'char')
            if strcmp(args{2},'group')
                res = false;
                args = args(3:end);
            elseif strcmp(args{2},'v6')
                res = false;
                args = args(3:end);
                warnv6args(filename);
            else
                res = false;
                args = args(2:end);
                warnv6args(filename);
            end
        else
            res = false;
            args = args(2:end);
            warnv6args(filename);
        end
    elseif (narg == 1) && strcmp(args{1},'on')
        if isempty(getappdata(0,'UseV6PlotAPI'))
            warning(message('MATLAB:usev6plotapi:DeprecatedV6Compatibility'))
            setappdata(0,'UseV6PlotAPI','on');
        end
    elseif (narg == 1) && strcmp(args{1},'off')
        if isappdata(0,'UseV6PlotAPI')
            rmappdata(0,'UseV6PlotAPI');
        end
    end
end

%--------------------------------------------------------------------%
function warnv6args(filename)
if isempty(filename)
    warning(message('MATLAB:usev6plotapiIgnoringV6Argument'));
else
    warning(message('MATLAB:usev6plotapi:IgnoringV6ArgumentForFilename', upper(filename)));
end
