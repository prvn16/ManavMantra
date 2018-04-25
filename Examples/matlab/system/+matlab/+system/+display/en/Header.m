classdef Header
%matlab.system.display.Header   System object display header
%   H = matlab.system.display.Header(P1,V1,...,PN,VN) creates a header used 
%   for displaying a System object.  You use matlab.system.display.Header 
%   to define a header in getHeaderImpl.
%
%   Inputs P1,V1,...,PN,VN are optional property name-value pair arguments 
%   that you can specify in any order.
%
%   Header properties:
%
%      Title          - Header title
%      Text           - Header text
%      ShowSourceLink - Allow link to source code
%
%   H = matlab.system.display.Header(SYSTEM, ...) creates a header for 
%   System object name SYSTEM with the following preset property values:
%
%      Title          - Set to SYSTEM
%      Text           - Set to help summary for SYSTEM
%      ShowSourceLink - Set to true if System object is MATLAB code and
%          false if System object is P-coded
%
%   Inputs P1,V1,...,PN,VN override the values defined above when used with 
%   the SYSTEM input.

     
    %   Copyright 2012-2014 The MathWorks, Inc.

    methods
        function out=Header
            % If odd number of inputs, assume first input is system name
        end

    end
    methods (Abstract)
    end
    properties
        %ShowSourceLink   Allow link to source code
        %   Option to show link to source code as logical.  When set to 
        %   true, a link to the source System object may be displayed. When 
        %   set to false, no link may be displayed.  The default value for 
        %   this property is true.
        ShowSourceLink;

        %Text   Header text
        %   Descriptive text of this header as a string.  The default value  
        %   of this property is an empty string.
        Text;

        %Title   Header title
        %   Title of this header as a string.  The default value of this
        %   property is an empty string.
        Title;

    end
end
