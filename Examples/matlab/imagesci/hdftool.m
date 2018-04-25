function h = hdftool(varargin)
%HDFTOOL Browse and import data from HDF or HDF-EOS files
%   HDFTOOL is a graphical user interface to browse the contents of HDF
%   and HDF-EOS files and import data and subsets of data.
%
%   HDFTOOL starts the HDF import tool.
%
%   HDFTOOL(FILENAME) opens the HDF or HDF-EOS file FILENAME in the
%   HDFTOOL.
%
%   H = HDFTOOL(...)  returns a handle H to the tool.  CLOSE(H)
%   will close the tool from the command line.
%
%   Multiple files may be opened in HDFTOOL, by selecting Open from the
%   File menu.
%
%   Example
%   -------
%   hdftool('example.hdf');
%
%   Please read the file hdf4copyright.txt for more information.
%
%   See also HDFINFO, HDFREAD, HDF, MATLAB.IO.HDF4.SD, MATLAB.IO.HDFEOS.GD,
%   MATLAB.IO.HDFEOS.SW, UIIMPORT.

%   Copyright 2001-2013 The MathWorks, Inc.

    narginchk(0, 1);
    
    % Make sure that JAVA is running
    javamsg = javachk('swing');
    if ~isempty(javamsg)
        error(message('MATLAB:imagesci:hdftool:noJVM'));
    end
    
    % Create the main frame
    frame = hdftool.fileframe();

    % Open a file
    if nargin==1
        errorStruct = frame.openFile(varargin{1});
        if ~isempty(errorStruct)
            frame.close();
            frame = [];
            if ~strcmp(errorStruct.identifier, 'MATLAB:imagesci:hdftool:incorrectFormat')
                rethrow(errorStruct);
            end
        end
    end

    % Store the output
    if nargout==1
        h = frame;
    end

    % Issue a redraw to fix any artifacts.
    drawnow;



end

