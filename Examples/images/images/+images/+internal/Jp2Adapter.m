% This undocumented internal class may be removed in a future release.

% Jp2Adapter JPEG2000 Adapter.
%   Jp2Adapter reads and writes regions from JPEG2000 files.

%   Copyright 2010 The MathWorks, Inc.

classdef Jp2Adapter < ImageAdapter
    
    properties (Access = private)
        id
    end  % properties
    
    methods
        
        %--------------------------------------------------
        function obj = Jp2Adapter(filename, mode, varargin)
            
            validatestring(mode,{'r','w'},'Jp2Adapter','Mode',2);
            readOnly = strcmpi(mode, 'r');

            % Expand ~ in file name.
            [fid fmessage] = fopen(filename,mode);
            if fid == -1 
                exceptionMessageObj = message('images:jp2adapter:fileopen', filename, fmessage);
                exceptionMessage    = exceptionMessageObj.getString();
                fopenException = MException('images:jp2adapter:fileopen',...
                    exceptionMessage);
                throw(fopenException);
            end     
            % This will return the absolute file name.
            filename = fopen(fid);
            fclose(fid);   
            
            obj.id = images.internal.jp2.jp2dispatcher('create', ...
                             filename, readOnly, varargin{:});
            obj.ImageSize = obj.getSize();
        end % Jp2Adapter
        
        %--------------------------------------------------
        function close(obj)
            images.internal.jp2.jp2dispatcher('destroy', obj.id);
        end % close
        
        %--------------------------------------------------
        function result = readRegion(obj, start, count)
            result = images.internal.jp2.jp2dispatcher('readRegion', ...
                        obj.id, start, count);
        end % readRegion
        
        %--------------------------------------------------
        function [] = writeRegion(obj, start, data)
            images.internal.jp2.jp2dispatcher('writeRegion', ...
                obj.id, start, data);
        end % writeRegion
        
        %--------------------------------------------------
        function result = getSize(obj)
            result = images.internal.jp2.jp2dispatcher('getSize', obj.id);
        end % getSize
        
    end % methods
    
end % class

