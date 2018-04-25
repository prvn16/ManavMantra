classdef (Hidden = true, Abstract = true, HandleCompatible = true) ...
          HadoopFileBasedSupport
%HadoopFileBasedSupport Initialize existing datastore from Hadoop split.

% Copyright 2015 The MathWorks, Inc.
      
    methods (Hidden = true)
    
        function initFromHadoopSplit(ds, hadoopFileSplit)
            [iri,off,len] = ...
                matlab.io.datastore.internal.getHadoopInfoFromSplit(hadoopFileSplit);
            initFromFileSplit(ds, iri, off, len);
        end
        
        % Method to implement to enable support.
        %
        %   Initialize an existing datastore instance
        %   with a filename, offset and size provided
        %   by a Hadoop split.
        %
        initFromFileSplit(ds, filename, offset, len);
        
    end

    methods (Access = 'public', Abstract = true, Hidden = true)
        
        %ARESPLITSWHOLEFILE Return logical scalar indicating if the splits are 
        %                   file at a time.
        tf = areSplitsWholeFile(ds);

        % ARESPLITSOVERCOMPLETEFILES
        % return true if the splits of this datastore span the all files
        % in the Files property in their entirety (non-paritioned)
        tf = areSplitsOverCompleteFiles(ds);

    end
      
end

