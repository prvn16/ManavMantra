function res = urlencode(str, varargin)
% matlab.net.internal.urlencode Encode vector of strings using URL encoding rules
%   res = urlencode(str)            percent-encodes all characters not in the unreserved set
%   res = urlencode(str,chars)      allows additional chars to pass without encoding
%   res = urlencode(___,space2plus) if space2plus is true, encode space as + instead of %20
%                                   ignores any space in chars
%
%   Input str may be character vector, string array or cellstr.  Returns
%   vector of encoded strings.  If isempty(str), return "".
%
%   Characters in the unreserved set, as per RFC 3986, section 2.3:
%
%   unreserved    = ALPHA / DIGIT / "-" / "." / "_" / "~"
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented and
%   is intended for use only within the scope of functions and classes in
%   toolbox/matlab/external/interfaces/webservices. Its behavior may change,
%   or the function itself may be removed in a future release.

% Copyright 2016, The MathWorks, Inc.
    
    import matlab.net.internal.*
    if isempty(str)
        res = "";
    else
        str = string(str); % stringify is char or cellstr
        if isscalar(str)
            % Handle only scalar case
            % The unreserved set is A-Za-z_0-9-.~ 
            allowed = '-a-zA-Z_0-9.~'; % can't use \w because it includes non-ASCII chars
            if isempty(varargin) 
                chars = [];
                space2plus = false;
            else
                chars = varargin{end};
                if islogical(chars)
                    space2plus = chars;
                    varargin(end) = [];
                    if isempty(varargin)
                        chars = [];
                    else
                        chars = varargin{1};
                    end
                else
                    space2plus = false;
                end
            end
            if ~isempty(chars)
                allowed = [allowed getSafeRegexp(chars)];
            end
            % To encode a string, first convert to utf8 and then replace bytes outside
            % the allowed set with %xx sequences.
            nat = unicode2native(char(str),'utf8');
            if space2plus
                res = regexprep(string(char(nat)), {['([^' allowed ' ])'] ' '}, {'%${dec2hex(char($1),2)}' '+'});
            else
                res = regexprep(string(char(nat)), ['([^' allowed '])'], '%${dec2hex(char($1),2)}');
            end
        else
            % Recursively invoke if input is vector
            res = arrayfun(@(s) urlencode(s, varargin{:}), str, 'UniformOutput', false);
            res = [res{:}];
        end
    end
end

