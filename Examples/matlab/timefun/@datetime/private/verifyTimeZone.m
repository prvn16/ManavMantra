function tz = verifyTimeZone(tz,warn)

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.internal.datetime.getCanonicalTZ
import matlab.internal.datatypes.stringToLegacyText


% Keep track of whether this is the first time 'local' has been asked for,
% so any warning given about a non-standard system setting is only given once.
% If this function gets cleared, the warning may get thrown (once) again.
persistent warnedOnceForLocal
if isempty(warnedOnceForLocal)
    warnedOnceForLocal = false;
end

if nargin < 2, warn = true; end

try %#ok<ALIGN>
    
    if strcmpi(tz,'local')
        % Check for and warn about a non-standard system/session local time zone
        % setting, but only if asked to, and only if this is the first time 'local' has
        % been used. This isn't foolproof for contexts where datetime.setLocalTimeZone
        % is used: setLocalTimeZone should always be called at the start of a session,
        % but if 'local' is used before that, the new local time zone setting won't ever
        % be checked or warned about if non-standard.
        if warn && ~warnedOnceForLocal
            % Call getCanonicalTZ with 'local' so it will throw the "system" version
            % of its warnings. Give it the uncanonicalized value we already have, which
            % might be from the system, or the client override, or the UTC failsafe.
            % getCanonicalTZ won't error, because the uncanonicalized value is at worst
            % non-standard, datetime.getsetLocalTimeZone has already recognized it.
            tz = getCanonicalTZ(tz,true,datetime.getsetLocalTimeZone('uncanonical'));
            warnedOnceForLocal = true;
        else
            % datetime.getsetLocalTimeZone's output can always be assumed valid
            % (and in fact canonical). If we don't need to warn for a non-standard
            % local time zone, just return one of those.
            tz = datetime.getsetLocalTimeZone();
        end
        
    else
        tz = getCanonicalTZ(tz,warn);
    end
catch ME, throwAsCaller(ME); end
