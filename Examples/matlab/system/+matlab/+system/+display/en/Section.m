classdef Section< matlab.system.display.PropertyGroup
%matlab.system.display.Section   System object display section
%   S = matlab.system.display.Section(P1,V1,...,PN,VN) creates a property
%   group section used for displaying a System object.  You use 
%   matlab.system.display.Section to define property groups in 
%   getPropertyGroupsImpl.
%
%   Inputs P1,V1,...,PN,VN are optional property name-value pair arguments 
%   that you can specify in any order.  
%
%  Section properties:
%
%      Title        - Section title
%      TitleSource  - Section title source
%      Description  - Section description
%      PropertyList - Section property list
%      Actions      - Section actions
%
%   S = matlab.system.display.Section(SYSTEM, ...) creates a default 
%   property group section for System object name SYSTEM with the following
%   preset property values:
%
%      TitleSource  - Set to 'Auto'
%      PropertyList - Set to list of all properties in SYSTEM that are
%          publically accessible
%
%   Inputs P1,V1,...,PN,VN override the values defined above when used with 
%   the SYSTEM input.
% 
%   See also matlab.system.display.SectionGroup.

     
    %   Copyright 2012-2016 The MathWorks, Inc.

    methods
        function out=Section
            % Get defaults
        end

    end
    methods (Abstract)
    end
end
