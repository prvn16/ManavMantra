classdef (Hidden) ProfileFactory < handle
    %ProfileFactory Utility class for dealing with VideoWriter profiles.
    %   Profiles are a central element to VideoWriter.  This class has methods
    %   to centralize the logic about dealing with profiles.
    %
    %   This class is an internal class and should not be used in customer
    %   code.
    
    % Copyright 2009-2013 The MathWorks, Inc.
    
    properties (Constant, GetAccess=private)
        % ProfilePackage The package name for all profiles. 
        ProfilePackage = 'audiovideo.writer.profile';
    end
    
    methods (Static)
        function profile = createProfile(profileName, varargin)
            %createProfile Instantiate a profile given the base name.
            %   obj = createProfile(profileName) will create a profile
            %   given the profile name in the profileName argument.  The
            %   profileName is the user visible name, such as
            %   'Uncompressed AVI' or 'Presentation', it is not the fully
            %   qualified profile name.
            import audiovideo.internal.writer.profile.ProfileFactory;

            % Validate that the specified profile is known
            className = ProfileFactory.checkIsKnownProfile(profileName);
            
            profile = feval(className, varargin{:});
        end
        
        function extensions = getFileExtensions(profileName)
            %getFileExtensions Return the acceptable file extensions for the specified profile.
            %   exts = getFileExtensions(profileName) will return the
            %   allowable file extensions for the profile specified by
            %   profileName.  Note that profileName is the user visible
            %   name of the profile, not the class name.  The return
            %   variable, exts, will be a cell array of file extensions.
            %   The file extensions will include the '.' character.
            import audiovideo.internal.writer.profile.ProfileFactory;
            profile = ProfileFactory.createProfile(profileName);

            extensions = profile.FileExtensions;
        end
        
        function className = getProfileClass(profileName)
            %getProfileClass returns a profile's class name from the profile name.
            %   className = getProfileClass(profileName) where profileName
            %   is the user visible profile name returns className the
            %   fully qualified class name for the specified profile.
            import audiovideo.internal.writer.profile.ProfileFactory;

            className = [ProfileFactory.ProfilePackage '.' profileName];
        end
        
        function profiles = getKnownProfiles
            %getKnownProfiles Returns the names of all known VideoWriter profiles.
            %   profiles = getKnownProfiles will return a cell array of all
            %   of the currently visible VideoWriter profiles.  The profiles
            %   IProfile and Default are filtered out since they are not
            %   explicitly visible to the user.
            
            import audiovideo.internal.writer.profile.ProfileFactory;
            
            profilePackage = meta.package.fromName(ProfileFactory.ProfilePackage);
            knownProfiles = profilePackage.Classes;
            
            profiles = audiovideo.writer.profile.Default.empty;
            for ii = 1:length(knownProfiles)       
                if knownProfiles{ii}.Hidden
                    continue; % skip hidden profiles
                end
                
                if ~feval([knownProfiles{ii}.Name '.isValid'])
                    continue; % skip invalid profiles
                end
                
                profiles(end + 1) = feval(knownProfiles{ii}.Name); %#ok<AGROW>
            end
        end
        
        function profileInfos = getKnownProfileInfos
            import audiovideo.internal.writer.profile.ProfileFactory;
               
            knownProfiles = ProfileFactory.getKnownProfiles;
            
            for ii = 1:length(knownProfiles)
                profileInfos(ii) = audiovideo.writer.ProfileInfo(knownProfiles(ii)); %#ok<AGROW>
            end
        end
        
        function profClass = checkIsKnownProfile(profile)
            %checkIsKnownProfile Error if the specified profile is not valid.
            %   checkIsKnownProfile(profileName) checks if profileName is a
            %   known profile and errors if it is not.  The profileName
            %   argument is the display name of the profile, as it would be
            %   passed to the VideoWriter constructor.
            %
            %   If the profile is known, the corresponding class name is
            %   returned.
            import audiovideo.internal.writer.profile.ProfileFactory;

            if strcmp(profile, 'Default')
                profClass = ProfileFactory.getProfileClass('Default');
                return;
            end
            
            % The Default profile is removed by getKnownProfiles, but it is
            % a valid profile, so add it back in.
            knownProfiles = ProfileFactory.getKnownProfiles();
            
            for ii = 1:length(knownProfiles)
                if strcmpi(knownProfiles(ii).Name, profile)
                    profClass = class(knownProfiles(ii));
                    return;
                end
            end
            
            error(message('MATLAB:audiovideo:VideoWriter:profileNotFound'));
        end            
    end    
end