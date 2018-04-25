function bData = timeZoneAdjustment(aData,fromTZ,toTZ,useFirstRepeatedWalltime)
% Shift a time (milliseconds since epoch) from one time zone to another.

%   Copyright 2014-2015 The MathWorks, Inc.
import matlab.internal.datetime.getDateFields
import matlab.internal.datatypes.stringToLegacyText

ucal = datetime.dateFields;
try 
    % fromTZ is never string, only need to convert toTZ for shallow adoption.
    toTZ = stringToLegacyText(toTZ);
    
    if isequal(fromTZ,datetime.UTCLeapSecsZoneID)
        aData = removeLeapSeconds(aData);
    end

    if isempty(fromTZ) == isempty(toTZ)
        % Don't need to account for any time zone differences, data are either UTC
        % or unzoned, and can stay that way.
        bData = aData;
    else
        if isempty(fromTZ) % && ~isempty(toTz)
            % Recreate the unzoned data in the specified time zone, using
            % its components. This leaves the timestamp unchanged (unless
            % it happens to fall in a "spring ahead" DST gap), but gives a
            % different actual time. First, strip off the fractional
            % seconds and then add them back at the end to avoid
            % sub-millisecond floating point errors.
            aDataToSec = matlab.internal.datetime.datetimeFloor(aData,ucal.SECOND, fromTZ);
            aDataSubSec = matlab.internal.datetime.datetimeSubtract(aData,aDataToSec);
            fieldIDs = [ucal.EXTENDED_YEAR; ucal.MONTH; ucal.DAY_OF_MONTH;
                        ucal.HOUR_OF_DAY; ucal.MINUTE; ucal.SECOND];
            [y,mo,d,h,m,s] = getDateFields(aDataToSec,fieldIDs,'');
            if nargin < 4
                bData = matlab.internal.datetime.createFromDateVec({y,mo,d,h,m,s},toTZ);
            else
                % 'usFirstRepeatedWalltime' flag is only used when datetime is called with
                % 'now'. When the flag is set to true, createFromDateVec will use the first
                % hour of the overlapping hour when DST is ending. Although the default
                % behavior for datetime is to use the second hour, using 'now' makes it
                % clear that the first hour should be used.
                bData = matlab.internal.datetime.createFromDateVec({y,mo,d,h,m,s},toTZ,useFirstRepeatedWalltime);
            end
            
            % Add the sub-second 
            bData = matlab.internal.datetime.datetimeAdd(bData,aDataSubSec);  %add back the sub-second time
        else % ~isempty(fromTz) && isempty(toTz)
            % Convert the zoned input array to an unzoned array, by adding the data's time
            % zone offset (raw offset plus DST) to the internal UTC value. This leaves the
            % timestamp unchanged, but gives a different actual time.
            [zoneOffset,dstOffset] = getDateFields(aData,[ucal.ZONE_OFFSET ucal.DST_OFFSET],fromTZ);
            bData = matlab.internal.datetime.datetimeAdd(aData,(zoneOffset+dstOffset)*1000); % s -> ms
        end

        % Preserve Infs. These have become NaTs from NaNs in either the date/time
        % components or in the tz offsets.
        infs = isinf(aData);
        bData(infs) = aData(infs);
    end
    if isequal(toTZ,datetime.UTCLeapSecsZoneID)
        if isempty(fromTZ)
            % If converting from unzoned, bData was already created in 'UTCLeapSecs', so no
            % need to add in the leap seconds.
        else
            bData = addLeapSeconds(bData);
        end
    end

catch ME
    throwAsCaller(ME);
end
