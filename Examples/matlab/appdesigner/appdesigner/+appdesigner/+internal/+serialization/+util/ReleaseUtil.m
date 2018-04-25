classdef (Sealed) ReleaseUtil
    % RELEASEUTIL  A collection of utility methods related to a matlab
    % release.
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods(Access=private)
        function obj = ReleaseUtil
            % do not allow this class to be instantiated. It should remain
            % static
        end
    end
    
    methods (Static, Access=public)
        
        function currentRelease = getCurrentRelease()
            currentRelease = ['R' version('-release')];
        end
        
        function isEarlier = isEarlierThanCurrentRelease(release)
            % release is of the format 'R" + release.  For example,
            % 'R2016b'
            import appdesigner.internal.serialization.util.ReleaseUtil;
            
            currentYear = ReleaseUtil.getReleaseYear(ReleaseUtil.getCurrentRelease());
            year = ReleaseUtil.getReleaseYear(release);
            
            if currentYear == year
                isEarlier = ReleaseUtil.getReleaseLetter(release) < ReleaseUtil.getReleaseLetter(ReleaseUtil.getCurrentRelease());
            else
                isEarlier = year < currentYear;
            end
        end
        
        function isLater = isLaterThanCurrentRelease(release)
            % release is of the format 'R" + release.  For example,
            % 'R2016b'
            import appdesigner.internal.serialization.util.ReleaseUtil;
            
            yearToCheckAgainst = ReleaseUtil.getReleaseYear(ReleaseUtil.getCurrentRelease());
            year = ReleaseUtil.getReleaseYear(release);
            
            if yearToCheckAgainst == year
                isLater = ReleaseUtil.getReleaseLetter(release) > ReleaseUtil.getReleaseLetter(ReleaseUtil.getCurrentRelease());
            else
                isLater = year > yearToCheckAgainst;
            end
        end
        
        function isSame = isCurrentRelease(release)
            % release is of the format 'R" + release.  For example,
            % 'R2016b'
            import appdesigner.internal.serialization.util.ReleaseUtil;
            isSame = strcmpi(ReleaseUtil.findRelease(release), ReleaseUtil.getCurrentRelease());
        end
        
        function isSupported = isSupportedRelease(minSupportedRelease)
            % minSupportedRelease is of the format 'R" + release.  For example,
            % 'R2016b'
            import appdesigner.internal.serialization.util.ReleaseUtil;
            
            % isSupportedRelease means its the current release or the min
            % supported version is earlier than the current release
            minSupportedRelease = ReleaseUtil.findRelease(minSupportedRelease);
            isSupported = (ReleaseUtil.isEarlierThanCurrentRelease(minSupportedRelease) || ...
                ReleaseUtil.isCurrentRelease(minSupportedRelease));
        end
        
        function is16a = is16aRelease(release)
            % release is of the format 'R" + release.  For example,
            % 'R2016b'
            import appdesigner.internal.serialization.util.ReleaseUtil;
            
            is16a = strcmpi(ReleaseUtil.findRelease(release),'R2016a');
        end
        
        function is16b = is16bRelease(release)
            % release is of the format 'R" + release.  For example,
            % 'R2016b'
            import appdesigner.internal.serialization.util.ReleaseUtil;
            
            is16b = strcmpi(ReleaseUtil.findRelease(release),'R2016b');
        end
        
        function is17a = is17aRelease(release)
            % release is of the format 'R" + release.  For example,
            % 'R2016b'
            import appdesigner.internal.serialization.util.ReleaseUtil;
            
            is17a = strcmpi(ReleaseUtil.findRelease(release),'R2017a');
        end
        
        function is17b = is17bRelease(release)
            % release is of the format 'R" + release.  For example,
            % 'R2016b'
            import appdesigner.internal.serialization.util.ReleaseUtil;
            
            is17b = strcmpi(ReleaseUtil.findRelease(release),'R2017b');
        end
        
        function is18a = is18aRelease(release)
            % release is of the format 'R" + release.  For example,
            % 'R2016b'
            import appdesigner.internal.serialization.util.ReleaseUtil;
            
            is18a = strcmpi(ReleaseUtil.findRelease(release),'R2018a');
        end
        
        function compatibilityType = getCompatibilityType(versionOfLoadedApp)
            % versionOfLoadedApp is of the format 'R" + release.  For example,
            % 'R2016b'
            import appdesigner.internal.serialization.util.ReleaseUtil;
            import appdesigner.internal.serialization.app.*
            
            if (ReleaseUtil.isCurrentRelease(versionOfLoadedApp))
                % opening the same version
                compatibilityType = CompatibilityTypes.SAME;
            elseif (ReleaseUtil.isEarlierThanCurrentRelease(versionOfLoadedApp))
                % opening a past version
                compatibilityType = CompatibilityTypes.BACKWARD;
            else
                % opening a future version
                compatibilityType = CompatibilityTypes.FORWARD;
            end
        end
        
    end
    
    methods(Static,Access=private)
        
        function ab = getReleaseLetter(release)
            % extracts the letter part of the release (e.g. a or b)
            import appdesigner.internal.serialization.util.ReleaseUtil;
            
            [~, ~, ab] = ReleaseUtil.findRelease(release);
        end
        
        function year = getReleaseYear(release)
            % extracts the year part from a release (e.g. 2016) and returns a numeric
            import appdesigner.internal.serialization.util.ReleaseUtil;
            
            [~, year] = ReleaseUtil.findRelease(release);
        end
        
        function [release, year, ab] = findRelease(rel)
            % extracts the release, year, and letter part from a release
            ab = '';
            year = NaN;
            release = '';
            foundRelease = cell2mat(regexp(rel, '(\d{4,}[AaBb])', 'tokens', 'once'));
            if (~isempty(foundRelease) && str2double(foundRelease(1:4)) >= 2016)
                year = str2double(foundRelease(1:4));
                ab = foundRelease(end);
                release = ['R' foundRelease];
            end
        end
        
    end
end
