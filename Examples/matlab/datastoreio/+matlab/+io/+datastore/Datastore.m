classdef (AllowedSubclasses = {?matlab.io.datastore.SplittableDatastore, ?matlab.io.datastore.DatabaseDatastore, ?matlab.io.datastore.AbstractDatastoreTestBase, ?matlab.io.datastore.TabularDatastore}) ...
        Datastore < handle
%Datastore   Declares the interface expected of datastores.
%   This class captures the interface expected of datastores. Datastores
%   are a way to access collections of data via iteration.
%   
%   See also datastore, matlab.io.datastore.SplittableDatastore

%   Copyright 2014-2016 The MathWorks, Inc.

    %
    % Datastores that want to support auto-selection of their class through
    % the datastore gateway function, should define the following method.
    %
    % methods (Access = 'public', Static = true, Abstract = true)
    %     %supportsLocation Return true if the location is supported.
    %     %   Returns true if the location can be read by this datastore
    %     %   type, else returns false.
    %     tf = supportsLocation(loc);
    % end
    %

    methods (Access = 'public', Abstract = true)
        %hasdata   Returns true if more data is available.
        %   Return logical scalar indicating availability of data. This
        %   method should be called before calling read.
        tf = hasdata(ds);
        
        %read   Read data and information about the extracted data.
        %   Return the data extracted from the datastore in the appropriate
        %   form for this datastore. Also return information about where
        %   the data was extracted from in the datastore.
        [data, info] = read(ds);
        
        %readall   Attempt to read all data from the datastore.
        %   Returns all the data in the datastore and resets it.
        data = readall(ds);
        
        %preview   Preview the data contained in the datastore.
        %   Returns a small amount of data from the start of the datastore.
        data = preview(ds);
        
        %reset   Reset to the start of the data.
        %   Reset the datastore to the state where no data has been read
        %   from it.
        reset(ds);

    end

    methods (Access = 'public', Abstract = true, Hidden = true)

        %progress   Percentage of consumed data between 0.0 and 1.0.
        %   Return fraction between 0.0 and 1.0 indicating progress.
        frac = progress(ds);

    end
    
end
