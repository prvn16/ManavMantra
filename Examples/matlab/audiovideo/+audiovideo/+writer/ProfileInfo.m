classdef (Hidden) ProfileInfo < dynamicprops
    %PROFILEINFO Information about a Profile
    %   PROFILEINFO provides a set of read only attributes of a profile 
    %   used in the VideoWriter object.
    
    %   Authors: NH, DT
    %   Copyright 2010-2013 The MathWorks, Inc.
 
    
    properties(SetAccess=private)
        %Name The name of the profile
        Name
        
        %Description A very brief description of the purpose of the %profile.
        Description
        
        %FileExtensions A cell array of the valid file extension.
        %   This is a cell array of the valid file extensions for the
        %   profile.  The extension should contain the '.' character.
        %
        %   Example:
        %      FileExtensions = {'.avi'};
        FileExtensions
    end
    
    properties(Access=private)
        %ProfileClass string representing the class name of this profile
        %
        ProfileClass
    end
    
    methods
        function obj = ProfileInfo(profile)
            %initialize properties based upon the provided profile
            obj.Name = profile.Name;
            obj.Description = profile.Description;
            obj.FileExtensions = profile.FileExtensions;
            obj.ProfileClass = class(profile);
            obj.initDynamicProperties(profile);
        end
    end
    
    methods(Hidden)
          % Hidden methods from the dynamicprops super class.
        function res = eq(obj, varargin)
            res = eq@dynamicprops(obj, varargin{:});
        end
        function res = ge(obj, varargin)
            res = ge@dynamicprops(obj, varargin{:});
        end
        function res = gt(obj, varargin)
            res = gt@dynamicprops(obj, varargin{:});
        end
        function res = le(obj, varargin)
            res = le@dynamicprops(obj, varargin{:});
        end
        function res = lt(obj, varargin)
            res = lt@dynamicprops(obj, varargin{:});
        end
        function res = ne(obj, varargin)
            res = ne@dynamicprops(obj, varargin{:});
        end
        function res = findobj(obj, varargin)
            res = findobj@dynamicprops(obj, varargin{:});
        end
        function res = findprop(obj, varargin)
            res = findprop@dynamicprops(obj, varargin{:});
        end
        function res = addlistener(obj, varargin)
            res = addlistener@dynamicprops(obj, varargin{:});
        end
        function res = notify(obj, varargin)
            res = notify@dynamicprops(obj, varargin{:});
        end
        function res = addprop(obj, varargin)
            res = addprop@dynamicprops(obj, varargin{:});
        end
    end
    
    methods(Hidden=true, Sealed=true)
        function display(obj)
            disp(obj)
        end
        function disp(obj)
            if numel(obj) == 1
                % If a single object is being displayed,
                % show all of the public, visible properties of the object.
                staticProps = {'Name'; 'Description'; 'FileExtensions'};
                dynamicProps = setxor( staticProps, sort(properties(obj)) );
                propNames = [staticProps; dynamicProps];
                
                fprintf(internal.DisplayFormatter.getDisplayHeader(obj));                                
                
                fprintf(internal.DisplayFormatter.getDisplayCategories(obj, ...
                    getString(message('MATLAB:audiovideo:VideoWriter:ProfileInfoProperties','ProfileInfo')), ...
                    propNames));                    
                
                fprintf(internal.DisplayFormatter.getDisplayFooter(obj));
            else
                % An array of objects was passed in.  In this case display
                % a table showing the name and description of the object.
                % The user can click on the Name value to create, and
                % display, an object of that class which will show the rest
                % of the information.
                import internal.DispTable;
                table = DispTable;
                table.Indent = 4;
                table.addColumn(getString(message('MATLAB:audiovideo:VideoWriter:ProfileInfoColumnName')));
                table.addColumn(getString(message('MATLAB:audiovideo:VideoWriter:ProfileInfoColumnDescription')));
                
                % sort profiles alphabetically
                [~, sortOrder] = sort({obj.Name});
                
                fprintf(['  ',getString(message('MATLAB:audiovideo:VideoWriter:InstalledVideoWriterProfilesSummary'))]);
                for ii = 1:length(sortOrder)
                    curProfile = obj(sortOrder(ii));
                    
                    table.addRow(...
                        DispTable.matlabLink(curProfile.Name, ...
                        sprintf('%s(%s)', class(curProfile), curProfile.ProfileClass)), ...
                        curProfile.Description);
                end
                
                table.disp();
                fprintf('\n');
                
            end
        end
    end
    
    methods(Access=private)
        function initDynamicProperties( obj, profile )
            % Create dynamic properties from our Profile.VideoProperties
            % object
            vidProps = profile.VideoProperties;
            vidPropsMeta = metaclass(vidProps); 
            
            % Call addDynamicProp for each videoProperty in the list
            cellfun(@(metaprop)obj.addDynamicProp(metaprop,profile.VideoProperties), ...
                    vidPropsMeta.Properties);
        end
        
        function addDynamicProp(obj, metaprop, videoProperties)
            % Add given a meta-property, expose the property as a dependent
            % property in this class with custom get/set methods where
            % appropriate.
            if ~strcmpi(metaprop.GetAccess,'public')
                return;
            end

            if (metaprop.Hidden)
                return;
            end
           
            filteredProps = {'FrameCount','Width','Height'};
            if (ismember(metaprop.Name,filteredProps))
                return;
            end
            
            prop = addprop(obj, metaprop.Name);
            prop.GetAccess = 'public';
            prop.SetAccess = 'private';
            
            % set the new properties value
            obj.(metaprop.Name) = videoProperties.(metaprop.Name);
        end
    end
end

