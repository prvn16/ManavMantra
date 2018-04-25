classdef SectionGroup< matlab.system.display.PropertyGroup
%matlab.system.display.SectionGroup   System object display section group
%   S = matlab.system.display.SectionGroup(P1,V1,...,PN,VN) creates a 
%   section group used for displaying a System object.  A section group can 
%   contain both properties and sections.  You use
%   matlab.system.display.SectionGroup to define property groups in 
%   getPropertyGroupsImpl.
%
%   Inputs P1,V1,...,PN,VN are optional property name-value pair arguments 
%   that you can specify in any order.
%
%   SectionGroup properties:
%
%      Title        - Group title
%      TitleSource  - Group title source
%      Description  - Group description
%      PropertyList - Group property list
%      Sections     - Group sections
%      Actions      - Group actions
%
%   S = matlab.system.display.SectionGroup(SYSTEM, ...) creates a default
%   section group for System object name SYSTEM with the following preset 
%   property values:
%
%      TitleSource - Set to 'Auto'
%      Sections    - Set to matlab.system.display.Section object for SYSTEM
%
%   Inputs P1,V1,...,PN,VN override the values defined above when used with
%   the SYSTEM input.

 
    %   Copyright 2012-2016 The MathWorks, Inc.

    methods
        function out=SectionGroup
            % If odd number of inputs, assume first input is system name
        end

    end
    methods (Abstract)
    end
    properties
        %Sections   Group sections   
        %   Sections in this group as an array of matlab.system.display.Section 
        %   objects.  The default value of this property is an empty array.
        Sections;

    end
end
