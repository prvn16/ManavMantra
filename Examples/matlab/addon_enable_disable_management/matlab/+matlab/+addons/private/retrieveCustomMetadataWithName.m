function customMetadata = retrieveCustomMetadataWithName(installedAddon, attributeName)

% Copyright 2017 The MathWorks Inc.
customMetadata = [];

if (installedAddon.hasCustomMetadataWithAttributeName(attributeName))
    customMetadata = installedAddon.getCustomMetadataWithAttributeName(attributeName);
    customMetadata = customMetadata.getValue();
end
end