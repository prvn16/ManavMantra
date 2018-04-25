function [cspec, msg] = cspecchk(varargin) 
%
%   CSPECCHK(VARARGIN) returns an RGB triple if VARARGIN is part of the
%   ColorSpec or a valid RGB triple
%
%   CSPECCHK is a helper function for LABEL2RGB and any other function that
%   is creating a color image.
%
%   [CSPEC, MSG] = CSPECCHK(varargin) returns an empty string in MSG if
%   VARARGIN is part of the ColorSpec.  Otherwise, CSPECCHK returns an error
%   message string in MSG.
%
%   Copyright 1993-2011 The MathWorks, Inc.
%

% error checking for nargin and setting defaults 

narginchk(1,1)
cspec = varargin{1};
msg = '';

% assigning colors to RGB triples.
yellow = [1 1 0];
magenta = [1 0 1];
cyan = [0 1 1];
red = [1 0 0];
green = [0 1 0];
blue = [0 0 1];
white = [1 1 1];
black = [0 0 0];

% making a table of cspec elements
cspec_el = {'yellow', yellow; 'magenta', magenta; 'cyan', cyan; 'red', ...
            red; 'green', green; 'blue', blue; 'white', white; 'k', black; ...
            'black', black};

if ~ischar(cspec)
    % check if cspec is a RGB triple
    if ~isreal(cspec) || ~isequal(size(cspec),[1 3]) || any(cspec > 1) || ...
            any(cspec < 0)
        msgObj = message('images:cspecchk:invalidRGB');
        msg = msgObj.getString();
    end
else
    % check if cspec is part of cspec_el that defines the ColorSpec
    idx = strmatch(lower(cspec),cspec_el(:, 1));
    if isempty(idx)
        msgObj = message('images:cspecchk:invalidNamedRGB',cspec);
        msg = msgObj.getString();
    elseif length(idx) > 1
        % check if cspec equals 'b'. If yes then the cspec is blue.
        % Otherwise, cspec is ambiguous.
        if isequal(cspec, 'b')
            cspec = blue;
        else
            msgObj = message('images:cspecchk:ambiguousColorSpec', cspec);
            msg = msgObj.getString();
        end    
    else
        cspec = cspec_el{idx, 2};
    end
end    



