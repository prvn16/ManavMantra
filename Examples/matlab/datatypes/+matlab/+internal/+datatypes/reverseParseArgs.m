function [varargout]=reverseParseArgs(pnames,dflts,priority,varargin)
%REVERSEPARSEARGS Process parameter name/value pairs for table
%methods/functions starting from the end
%   [NUMVARS,A,B,...] = reverseParseArgs(PNAMES,DFLTS,'NAME1',VAL1,'NAME2',VAL2,...)
%   In typical use there are N output values, where PNAMES is a cell array
%   of N valid parameter names, and DFLTS is a cell array of N default
%   values for these parameters. The remaining arguments are parameter
%   name/value pairs that were passed into the caller. The N outputs
%   [NUMVARS,A,B,...] are assigned in the same order as the names in PNAMES.
%   Outputs corresponding to entries in PNAMES that are not specified
%   in the name/value pairs are set to the corresponding value from DFLTS. 
%   Unrecognized name/value pairs are an error.
%
%   [NUMVARS,A,B,...,SETFLAG] = reverseParseArgs(...), where SETFLAG is the N+1 output
%   argument, also returns a structure with a field for each parameter
%   name. The value of the field indicates whether that parameter was
%   specified in the name/value pairs (true) or taken from the defaults
%   (false).
%
%   [NUMVARS,A,B,...,SETFLAG,EXTRA] = reverseParseArgs(...), where EXTRA is the N+2 output
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
values = dflts;
setflag = false(1,nparams);
nargs = length(varargin);
pmask = false(1,nparams);

SuppliedRequested = (nargout > nparams);

npairs = 0; % number of NV pairs parsed, used to calculate variables in given varargin

% Process name/value pairs, starting from the back
% Check every other input to partial match with parameter names
% No match or non-text value means we have gone past the name-value pairs,
% assume data.
for j=nargs-1:-2:1
    pname = varargin{j};

    % No more name-value pairs, treat the rest as data variables.
    if ~matlab.internal.datatypes.isCharString(pname,false)
        break;
    end
    
    mask = strncmpi(pname,pnames,strlength(pname)); % look for partial match
    if ~any(mask)
        % No matching parameter name
        break;
    elseif sum(mask) > 1
        % Ambiguous partial match, check the given mask for priority
        mask_priority = priority(mask);
        if numel(mask_priority(mask_priority == max(mask_priority))) > 1
            % The given priority still has ambiguity for the given
            % matches, throw an error
            throwAsCaller(MException(message('MATLAB:table:parseArgs:AmbiguousParamName',pname)));
        else
            % Priority given solves the ambiguity. Set all mask
            % position not matching max of matched priority to 0.
            mask(priority ~= max(mask_priority)) = 0;
        end
    end
    
    npairs = npairs + 1;
    
    % If there are duplicate NV pairs, we only want to take the last one.
    % Since we are going from the back, keep track of which we update in a
    % boolean mask
    if ~pmask(mask)
        values{mask} = varargin{j+1};
        pmask(mask) = true;
    end
    setflag(mask) = true;
end

nvars = nargs - npairs * 2; % number of leading data variables
varargout = [{nvars} values];
    
% Return extra stuff if requested
if SuppliedRequested
    for kk = 1:numel(pnames)
        supplied.(pnames{kk}) = setflag(kk);
    end
    varargout{end+1} = supplied;
end


