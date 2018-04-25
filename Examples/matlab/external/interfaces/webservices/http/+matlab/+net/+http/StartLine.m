classdef (Abstract, AllowedSubclasses={?matlab.net.http.RequestLine, ...
                                       ?matlab.net.http.StatusLine}) ...
     StartLine < matlab.mixin.CustomDisplay
% StartLine Start line of an HTTP request
%   A StartLine is the first line of an HTTP request or response message,
%   containing 3 space-separated parts.  This class has no public properties
%   or methods except string and char.  It is the base class of
%   matlab.net.http.StatusLine and matlab.net.http.RequestLine.
%
%   StartLine methods:
%     string, char  - return the line as a string or character vector
%
% See also RequestLine, StatusLine

%   Copyright 2015-2016 The MathWorks, Inc.

%   Subclasses define the three parts of the status line as separate dependent
%   properties of whatever type is desired.  The actual values of the parts
%   are stored in the 3-element cell vector Parts.  Elements of Parts may be
%   strings or objects of the desired type.  Subclasses implement set methods
%   for the properties that that take either a string that they will convert
%   to the required type, or an object of the required type that they don't
%   need to convert, and then call setPart() to store the value.
%
%   The get methods of the properties in the subclasses call getPart() to obtain
%   the part.

    properties (Access=protected, Hidden)
        % Parts - cell array of 3 parts; may be different types
        Parts cell
    end
    
    methods (Access=protected, Hidden)
        function obj = StartLine(varargin)
        % StartLine constructor
        %   StartLine(PART1,PART2,PART3) - construct a line with the 1-3 parts.
        %     The parameters are copied into the Parts array unchanged.
        %   StartLine(STR) - construct from string, separated into 1-3 parts at
        %     whitespace and copied into the Parts array as strings.
            obj.Parts = cell(1,3);
            if nargin == 1 
                % This path is only taken when the user constructs one of these
                arg = varargin{1};
                if (ischar(arg) || isstring(arg))
                    % input is a single string
                    arg = matlab.net.internal.getString(arg, mfilename);
                    % Split at whitespace and treat substrings as if they were args
                    parts = strsplit(arg);
                    if length(parts) > 3
                        error(message('MATLAB:http:TooManyPartsInStartLine', ...
                            char(arg), length(parts)));
                    end
                    % hack to convert array of strings to cell array of strings
                    % don't want cellstr
                    obj.Parts(1:length(parts)) = arrayfun(@(s) s, parts, 'UniformOutput', false);
                else
                    obj.Parts{1} = arg;
                end
            else
                obj.Parts(1:length(varargin)) = varargin;
            end
        end
    end
    
    methods
        function str = string(obj)
        % string returns the start line as a string
        %   The result is the string as it would appear in the first line of an HTTP
        %   message.
            strs = cellfun(@string, obj.Parts, 'UniformOutput', false);
            str = strjoin([strs{:}], ' ');
        end
        
        function str = char(obj)
        % char returns the start line as a character vector
        %   The result is the string as it would appear in the first line of an HTTP
        %   message.
            str = char(string(obj));
        end
    end
    
    methods (Access=protected)
        function group = getPropertyGroups(obj)
        % Provide a custom display that displays the target and protocol stringified
            if isscalar(obj)
                group = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
                group.PropertyList.ProtocolVersion = string(group.PropertyList.ProtocolVersion);
            end
        end
    end
end

