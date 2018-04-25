% This class is undocumented.

% The IgnoringWhitespaceMixin can be included as a part of any class that can
% ignore whitespace differences. See NameValueMixin.m for details on the process
% to utilize this mixin.

%  Copyright 2012-2016 The MathWorks, Inc.
classdef (Hidden) IgnoringWhitespaceMixin < matlab.unittest.internal.mixin.NameValueMixin
    properties (SetAccess=private)
        % IgnoreWhitespace - Boolean indicating whether this instance is insensitive to whitespace
        %
        %   When this value is true, the instance is insensitive to
        %   whitespace differences. When it is false, the instance is
        %   sensitive to whitespace. Whitespace characters are space, form
        %   feed, new line, carriage return, horizontal tab, and vertical tab.
        %
        %   The IgnoreWhitespace property is false by default, but can be
        %   specified to be true during construction of the instance by
        %   utilizing the (..., 'IgnoringWhitespace', true) parameter value pair.
        IgnoreWhitespace (1,1) = false;
    end
       
    methods (Hidden, Access=protected)
        function mixin = IgnoringWhitespaceMixin
            mixin = mixin.addNameValue('IgnoringWhitespace', ...
                @setIgnoreWhitespace,...
                @ignoringWhitespacePreSet,...
                @ignoringWhitespacePostSet);
        end
        
        function [mixin,value] = ignoringWhitespacePreSet(mixin,value)
            validateattributes(value,{'logical'},{},'','IgnoringWhitespace');
        end
        
        function mixin = ignoringWhitespacePostSet(mixin)
        end
        
        function whitespaceFreeStr = removeWhitespaceFrom(~, txt)
            % removeWhitespaceFrom - Remove whitespace characters from a string array or character vector
            %
            %   This method is provided for convenience because most subclasses will
            %   need to remove whitespace from text.
            whitespaceFreeStr = regexprep(txt, '\s', '');
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = ignoringWhitespace(mixin)
            mixin = mixin.setIgnoreWhitespace(true);
            mixin = mixin.ignoringWhitespacePostSet();
        end
    end
    
    methods (Access=private)
        function mixin = setIgnoreWhitespace(mixin, value)
            mixin.IgnoreWhitespace = value;
        end
    end
end