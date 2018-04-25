classdef appinstaller < handle
%   Creates the appinstaller object.
%   This class installs the MLAPP file in the specified install directory.
%   The install process involves creation of the install directory,
%   exploding the MLAPP file and retrieving the meta data from the
%   appProperties xml file.
%
%   appinstaller Properties
%   AppInfo   - This property contains all the metadata about the MATLAB
%               App which is retrieved from the appProperties XML file.
%
%   appinstaller Methods
%   extractAppPackage   - This method explodes the MLAPP file in the install 
%                      directory.
%   genWrapper       - This method generates a wrapper MATLAB class which
%                      has the capability of running the app.
%
%   Copyright 2012 - 2015 The MathWorks, Inc.
%
    properties (SetAccess = private)
        AppInfo;
        EntryPoint;
    end 
    
    methods
        %-------------------------------------
        %   appinstaller class public methods
        %-------------------------------------
        function obj = appinstaller(mlappfile)
            try
               obj.AppInfo = appinstall.internal.getappmetadata(mlappfile);
               [~, obj.EntryPoint, ~] = fileparts(obj.AppInfo.entryPoint);
            catch err
                exception = MException(err.identifier, err.message);
                throw(exception);
            end
        end  
        
        function extractAppPackage(obj, appfilename, appextractlocation)    
            mlappinstall(appfilename, appextractlocation);   
            genWrapper(obj, appextractlocation)
        end
        
    end
    methods (Access = 'private')
        %---------------------------------------
        %   appinstaller class private methods
        %---------------------------------------
        function genWrapper(obj, appinstalldir)
            apptbdir = ([matlabroot filesep 'toolbox' filesep 'matlab' filesep 'apps' filesep '+appinstall' filesep '+internal' filesep '@appinstaller' filesep]);
            templatefile = ([apptbdir 'appcls.template']);
            wrapperclass = matlab.internal.apputil.AppUtil.genwrapperfilename(appinstalldir);
            wrapperclassfile = fullfile([wrapperclass 'App.m']);             
            templatefid = fopen(templatefile);
            wrapperfid = fopen([appinstalldir filesep wrapperclassfile], 'w');
            
            %strip off the isntall specific portion of the path
            appview = com.mathworks.appmanagement.AppManagementViewSilent;
            appAPI = com.mathworks.appmanagement.AppManagementApiBuilder.getAppManagementApiCustomView(appview);
           
            myAppsLocation = char(appAPI.getMyAppsLocation);
            
            if ~isempty(strfind(appinstalldir, myAppsLocation)) && size(appinstalldir, 2) > size(myAppsLocation,2);
                appinstalldir = appcreate.internal.appbuilder.normalizeFileSep(appinstalldir(1, size(myAppsLocation,2) + 1 : end));
            end
            
            while ~feof(templatefid)                
                line = fgetl(templatefid);
                line=strrep(line,'#appClass', [wrapperclass 'App']);
                line=strrep(line,'#appMain', obj.EntryPoint);
                line=strrep(line,'#appPath', appinstalldir);
                fprintf(wrapperfid,'%s\n',line);
            end
            fclose(templatefid);
            fclose(wrapperfid);
        end
    end
    methods(Static)
        % Helper function to pull out screenshot and icon data
        function appinfo = extractImageContents(mlappfile, appinfo)
            iconImage = mlappGetAppIcon(mlappfile);
            if(~isempty(iconImage))
                iconStream = java.io.ByteArrayInputStream(iconImage);
                iconData = javax.imageio.ImageIO.read(iconStream);
                appinfo.appIcon = javax.swing.ImageIcon(iconData);
            end 
            
            iconImages = cell(1,3);
            for i=1:3
                iconImages{i} = mlappGetSizedAppIcons(mlappfile,i-1);
            end
            if(~isempty(iconImages{1}))
                for i=1:3
                    iconStream = java.io.ByteArrayInputStream(iconImages{i});
                    iconData = javax.imageio.ImageIO.read(iconStream);
                    iconImages{i} = javax.swing.ImageIcon(iconData);
                end
                appinfo.appScaledIcons = iconImages;
            end
            
            screenshotImage = mlappGetAppScreenshot(mlappfile);
            if(~isempty(screenshotImage))
                % g858601 - BMP files are not directly supported by ImageIcon, so
                % we must first wrap the byte stream
                screenshotStream = java.io.ByteArrayInputStream(screenshotImage);
                screenshotData = javax.imageio.ImageIO.read(screenshotStream);
                appinfo.appScreenShot = javax.swing.ImageIcon(screenshotData);
            end 
        end
    end
end