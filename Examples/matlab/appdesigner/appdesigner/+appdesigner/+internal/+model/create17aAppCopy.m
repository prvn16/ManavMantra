function create17aAppCopy(destinationFilename,data)
%CREATE17AAPPCOPY function to create a copy of an app.
%
%This is a separate standalone function to allow us the opportunity to
%differentiate between calls to copy an app vs. copy for an older release
%DO NOT CONSOLIDATE

    % create the converter and convert the data to the new file
    converter = appdesigner.internal.serialization.converter.MLAPPConverter(destinationFilename,data);
    converter.convert();
end