function removeMLFBVariantCreationListener(this)
% REMOVEMLFBVARIANTCREATIONLISTENER Remove the listener created on the model containing the SUD to update the tree when
% a MLFB variant is created when applying data types to the model.

% Copyright 2016 The MathWorks, Inc.

for i = 1:length(this.MLFBVariantCreationListener)
    delete(this.MLFBVariantCreationListener(i));
end
this.MLFBVariantCreationListener = [];
this.VariantSubsystems = [];