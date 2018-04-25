classdef id < handle
%HDF5ID An identifier class for HDF5 files.
%   This identifier class contains an HDF5 identifier.  When it is
%   destroyed, it will automatically call the appropriate HDF5 'close'
%   method, thus ensuring that it is not left in an open state.

%   Copyright 2009-2013 The MathWorks, Inc.
    
  properties (GetAccess = public)
    identifier; 
  end   
  properties (Access = private)
    callback;
  end   
  
  methods       
    %------------------------------------------------------------------
    function obj = id(identifier, callback)    
        
        if nargin == 0
            % This is required since Matlab can call this constructor when
            % accounting for unassigned elements within an array of H5ML.ids
            obj.identifier = -1;
            obj.callback   = '';
            return;
        end
        if identifier < 0
            error(message('MATLAB:imagesci:H5:invalidID'));
        end
        obj.identifier = identifier;
        obj.callback   = callback;
    end
    
    %------------------------------------------------------------------
    function delete(obj) 
        obj.close();
    end
    
    %------------------------------------------------------------------
    function close(obj, varargin) 
    %H5ML.id.close Close the contained HDF5 identifier.
    %   This function will call the appropriate HDF5 close function when 
    %   the object goes out of scope.  It should not be called directly.

        if obj.identifier > -1
            try
                H5ML.hdf5lib2(obj.callback, obj.identifier);
            catch ME
                if ~strcmp(obj.callback,'H5Tclose') || ...
                        isempty(strfind(ME.message,'immutable datatype'))
                    rethrow(ME);
                end
            end
        end
        obj.identifier = -1;

    end
    
    %------------------------------------------------------------------
    function disp(obj) 
    %H5ML.id.disp Display the contained HDF5 identifier.
    %   This function will display the enclosed HDF5 identifier.
    %
    
        for j = 1:numel(obj)
            disp(obj(j).identifier);   
        end
    end
    
    %------------------------------------------------------------------
    function sobj = saveobj(obj) 
        % We do not allow the object to be saved and loaded in a valid 
        % state.
        sobj.identifier = -1;
        sobj.callback = obj.callback;
    end  
    
    %------------------------------------------------------------------
    function id = double(obj) 
    %H5ML.id.double Return the contained HDF5 identifier as a double.
    %   This method returns the enclosed HDF5 identifier as a double.
    %
    
        id = double(obj.identifier);        
    end
    
  end
    methods(Static)
        function obj = loadobj(a)

            % We do not allow a H5ML.id object to be reloaded.  We call the 
            % default constructor, which creates an invalid object, and 
            % then just load the .
            obj = H5ML.id;
            obj.callback = a.callback;
            warning(message('MATLAB:imagesci:H5:saveLoad'));
        end

    end % Static methods
end
