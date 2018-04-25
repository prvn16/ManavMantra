function [varargout]=parseArgs(pnames,dflts,varargin)
%PARSEARGS Process parameter name/value pairs for table methods/functions
%   [A,B,...] = parseArgs(PNAMES,DFLTS,'NAME1',VAL1,'NAME2',VAL2,...)
%   In typical use there are N output values, where PNAMES is a cell array
%   of N valid parameter names, and DFLTS is a cell array of N default
%   values for these parameters. The remaining arguments are parameter
%   name/value pairs that were passed into the caller. The N outputs
%   [A,B,...] are assigned in the same order as the names in PNAMES.
%   Outputs corresponding to entries in PNAMES that are not specified
%   in the name/value pairs are set to the corresponding value from DFLTS. 
%   Unrecognized name/value pairs are an error.
%
%   [A,B,...,SETFLAG] = parseArgs(...), where SETFLAG is the N+1 output
%   argument, also returns a structure with a field for each parameter
%   name. The value of the field indicates whether that parameter was
%   specified in the name/value pairs (true) or taken from the defaults
%   (false).
%
%   [A,B,...,SETFLAG,EXTRA] = parseArgs(...), where EXTRA is the N+2 output
%   argument, accepts parameter names that are not listed in PNAMES. These
%   are returned in the output EXTRA as a cell array.
%
%   Example:
%       pnames = {'color' 'linestyle', 'linewidth'}
%       dflts  = {    'r'         '_'          '1'}
%       varargin = {'linew' 2 'linestyle' ':'}
%       [c,ls,lw] = matlab.internal.datatypes.parseArgs(pnames,dflts,varargin{:})
%       % On return, c='r', ls=':', lw=2
%
%       [c,ls,lw,sf] = matlab.internal.datatypes.parseArgs(pnames,dflts,varargin{:})
%       % On return, sf = [false true true]
%
%       varargin = {'linew' 2 'linestyle' ':' 'special' 99}
%       [c,ls,lw,sf,ex] = matlab.internal.datatypes.parseArgs(pnames,dflts,varargin{:})
%       % On return, ex = {'special' 99}

%   Copyright 2012-2017 The MathWorks, Inc.


% Initialize some variables
nparams = length(pnames);
varargout = dflts;
setflag = false(1,nparams);
unrecog = {};
nargs = length(varargin);

SuppliedRequested = nargout > nparams;
UnrecognizedRequested = nargout > (nparams+1);

% Must have name/value pairs
if mod(nargs,2)~=0
    m = message('MATLAB:table:parseArgs:WrongNumberArgs');
    throwAsCaller(MException(m.Identifier, '%s', getString(m)));
end
ischars = false(1,nargs);
for i = 1:2:numel(varargin)
    ischars(i) = ischar(varargin{i});
end
[varargin{ischars}] = convertCharsToStrings(varargin{ischars});
% Process name/value pairs
for j=1:2:nargs
    pname = varargin{j};
    if ~isstring(pname)
        throwAsCaller(MException(message('MATLAB:table:parseArgs:IllegalParamName')));
    end
    
    if ismissing(pname), pname = ""; end
    mask = strncmpi(pname,pnames,strlength(pname)); % look for partial match
    if ~any(mask)
        if UnrecognizedRequested
            % if they've asked to get back unrecognized names/values, add this
            % one to the list
            unrecog((end+1):(end+2)) = {char(varargin{j}) varargin{j+1}};
            continue
        else % otherwise, it's an error
            throwAsCaller(MException(message('MATLAB:table:parseArgs:BadParamName',pname)));
        end
    elseif sum(mask) > 1
        mask = strcmpi(pname,pnames); % use exact match to resolve ambiguity
        if sum(mask) ~= 1
            throwAsCaller(MException(message('MATLAB:table:parseArgs:AmbiguousParamName',pname)));
        end
    end
    varargout{mask} = varargin{j+1};
    setflag(mask) = true;
end

% Return extra stuff if requested
if SuppliedRequested
    for kk = 1:numel(pnames)
        supplied.(pnames{kk}) = setflag(kk);
    end
    varargout{nparams+1} = supplied;
    if UnrecognizedRequested
        varargout{nparams+2} = unrecog;
    end
end

