function createAppCopy(serializer)
%CREATEAPPCOPY function to create a copy of an app.
%
%This is a separate standalone function to allow us the opportunity to
%differentiate between calls to copy an app vs. copy for an older release
%DO NOT CONSOLIDATE

    % save the app data
    serializer.save();
end