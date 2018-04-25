classdef (Hidden) IconableComponent < appdesservices.internal.interfaces.model.AbstractModelMixin
    % This undocumented class may be removed in a future release.
    
    % This is a mixin parent class for all visual components that have the
    % 'Icon' properties
    %
    % This class provides all implementation and storage for 'Icon'
    
    % Copyright 2014-2015 The MathWorks, Inc.
    
    properties(Dependent)
        Icon = '';
 
    end
    
    properties(Access = {?matlab.ui.control.internal.model.mixin.IconableComponent, ...
            ?matlab.ui.control.internal.controller.mixin.IconableComponentController})
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateIcon = '';
    end
    
    properties(Transient, Access = {?matlab.ui.control.internal.model.mixin.IconableComponent, ...
            ?matlab.ui.control.internal.controller.mixin.IconableComponentController})
        % Internal properties
        %
        % Store the Icon data on the model, so if the controller is deleted
        % and recreated, the data does not have to be re-read from disk.
        % Reasons that the controller may be recreated:
        %      Reordering of children
        %      Reparenting of component
        %
        % This is transient so it does not get serialized, the file
        % information must reload when coming from a MAT file. 
        
        PrivateCachedImageFileInfo = [];
        PrivateCachedImageContent = [];
                        
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        
        function set.Icon(obj, newValue)
            % Error Checking for valid and readable file
             [obj, newValue] = obj.processIcon(obj, newValue);
            
            % Store the value
            obj.PrivateIcon = newValue;
            
            % Update View
            markPropertiesDirty(obj, {'Icon'});
        end
        
        function value = get.Icon(obj)
            value = obj.PrivateIcon;
        end
        
    end
    
    methods(Access='private', Static=true, Hidden=true)
        function [obj, newValue] = processIcon(obj, newValue)
            % Error Checking for valid and readable file
            try
                % validate the input value
                newValue = matlab.ui.control.internal.model.PropertyHandling.validateText(newValue);          

                if strcmp(newValue, '')
                    % Stop processing immediately if 
                    obj.PrivateCachedImageFileInfo = [];                    
                    obj.PrivateCachedImageContent = [];
                    return
                else
                    % Get file information
                    % (this throws an error on non-image files as well)
                    imageFileInfoStruct = imfinfo(newValue);
                    % If the file is a gif, use the first frame
                    imageFileInfoStruct= imageFileInfoStruct(1);
                end

            catch
                messageObj = message('MATLAB:ui:components:invalidIconFile');

                % MnemonicField is last section of error id
                mnemonicField = 'invalidIconFile';

                % Use string from object
                messageText = getString(messageObj);

                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, '%s', messageText);
                throwAsCaller(exceptionObject);
            end
            
            % Error Checking for supported format
            %
            % Note that this relies on the format returned by imfinfo,
            % not the actual file extension on disk.
           	try

                matlab.ui.control.internal.model.PropertyHandling.processEnumeratedString(...
                    obj, ...
                    imageFileInfoStruct.Format, ...
                    {'png', 'jpg', 'jpeg', 'gif'});

            catch
                messageObj = message('MATLAB:ui:components:invalidIconFormat');

                % MnemonicField is last section of error id
                mnemonicField = 'invalidIconFormat';

                % Use string from object
                messageText = getString(messageObj);

                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, '%s', messageText);
                throwAsCaller(exceptionObject);

            end
            
            % Store image data for performance reasons.  Reading the file
            % in the controller creation requires the same information

                
            % Create file to validate readability
            imFile = java.io.File(imageFileInfoStruct.Filename);
                
            if imFile.canRead()
                % Cache image to be read in controller construction
                obj.PrivateCachedImageFileInfo = imageFileInfoStruct;
                obj.PrivateCachedImageFileInfo.FileObject = imFile;
                obj.PrivateCachedImageContent = [];
            else
                                
                % This case is when the file extension is correct, the file
                % is on the path (or a full path), but the image cannot be 
                % read.  One known reason this might get hit is a file 
                % without read access
                messageObj = message('MATLAB:ui:components:cannotReadIconFile', imageFileInfoStruct.Filename);

                % MnemonicField is last section of error id
                mnemonicField = 'cannotReadIconFile';

                % Use string from object
                messageText = getString(messageObj);

                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, '%s', messageText);
                throwAsCaller(exceptionObject);		
            
			end	
        end
    end
    
     methods(Access='public', Static=true, Hidden=true)
      function hObj = doloadobj( hObj) 

          
         % Restore Icon on load
         % 1. The model (as opposed to the controller) owns loading the 
         % Icon 
         %    a. to get the end user the most responsive error message
         %    b. because sometimes the controller is destroyed in
         %    restructuring workflows where loading the icon in the
         %    controller is wasteful
         % 2. Pre 17b - The Icon data wasn't read in the model.  Older
         % components loaded into 17b+ won't have icon data stored in them
         % 
         % Thus, the whole workflow of reading and storing the icon is
         % completely transient.
         
        % hObj may be an Iconable Object or struct
        if (isstruct(hObj) && isfield(hObj, 'Icon')) ||...
            (isgraphics(hObj) && isprop(hObj, 'Icon'))
        
            [hObj, ~] = matlab.ui.control.internal.model.mixin.IconableComponent.processIcon(hObj, hObj.Icon);
        end

      end
   end
end
