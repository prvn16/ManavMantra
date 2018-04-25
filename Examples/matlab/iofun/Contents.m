% File input and output.
%
% File import/export functions.
%   matfile       - Load or save parts of variables in MAT-files.
%   dlmread       - Read ASCII delimited file.
%   dlmwrite      - Write ASCII delimited file.
%   csvread       - Read a comma separated value file.
%   csvwrite      - Write a comma separated value file.
%   importdata    - Load data from a file into MATLAB.
%   daqread       - Read Data Acquisition Toolbox (.daq) data file.
%   matfinfo      - Text description of MAT-file contents.
%   fileread      - Return contents of file as string vector.
%
% Table functions.	 
%   readtable     - Create a table by reading from a file.	 
%   writetable    - Write a table to a file.	 
%
% Spreadsheet support.
%   xlsread       - Get data and text from a spreadsheet in an Excel workbook.
%   xlswrite      - Stores numeric array or cell array in Excel workbook.
%   xlsfinfo      - Determine if file contains Microsoft Excel spreadsheet.
%
% Internet resource.
%   urlread       - Returns the contents of a URL as a string.
%   urlwrite      - Save the contents of a URL to a file.
%   ftp           - Create an FTP object.
%   sendmail      - Send e-mail.
%
% Zip file access.
%   zip           - Compress files into zip file.
%   unzip         - Extract contents of zip file.
%
% Tar file access.
%   tar           - Compress files into tar file.
%   untar         - Extract contents of tar file.
%
% Gzip file access.
%   gzip          - Compress files into GNU zip files.
%   gunzip        - Uncompress GNU zip files.
%
% Formatted file I/O.
%   fgetl         - Read line from file, discard newline character.
%   fgets         - Read line from file, keep newline character. 
%   fprintf       - Write formatted data to file.
%   fscanf        - Read formatted data from file.
%   textscan      - Read formatted data from text file.
%
% File opening and closing.
%   fopen         - Open file.
%   fclose        - Close file.
%
% Binary file I/O.
%   fread         - Read binary data from file.
%   fwrite        - Write binary data to file.
%
% File positioning.
%   feof          - Test for end-of-file.
%   ferror        - Inquire file error status. 
%   frewind       - Rewind file.
%   fseek         - Set file position indicator. 
%   ftell         - Get file position indicator. 
%
% Memory-mapped file support.
%   memmapfile    -  Construct memory-mapped file object.
%
% File name handling.
%   fileparts     - Filename parts.
%   filesep       - Directory separator for this platform.
%   filemarker    - Character that separates a file and a within-file function name.
%   fullfile      - Build full filename from parts.
%   matlabroot    - Root directory of MATLAB installation.
%   mexext        - MEX filename extension for this platform. 
%   partialpath   - Partial pathnames.
%   pathsep       - Path separator for this platform.
%   prefdir       - Preference directory name.
%   tempdir       - Get temporary directory.
%   tempname      - Get temporary file.
%
% XML file handling.
%   xmlread       - Parse an XML document and return a Document Object Model node.
%   xmlwrite      - Serialize an XML Document Object Model node.
%   xslt          - Transform an XML document using an XSLT engine.
%
% Serial port support.
%   serial        - Construct serial port object.
%   instrfindall  - Find all serial port objects with specified property values.
%   instrfind     - Find serial port objects with specified property values.
%
% Timer support.
%   timer         - Construct timer object.
%   timerfindall  - Find all timer objects with specified property values.
%   timerfind     - Find visible timer objects with specified property values.
%
% Command window I/O.
%   clc           - Clear command window.
%   home          - Send the cursor home.
%
% SOAP support.
%   createClassFromWsdl - Create a MATLAB object based on a WSDL-file.
%   callSoapService     - Send a SOAP message off to an endpoint.
%   createSoapMessage   - Create the SOAP message, ready to send to the server.
%   parseSoapResponse   - Convert the response from a SOAP server into MATLAB types.
%
% See also GENERAL, LANG, AUDIOVIDEO, IMAGESCI, GRAPHICS, UITOOLS.

% Obsolete functions.
%   dataread    - Read formatted data from string or file.
%   textread      - Read formatted data from text file.

%   Copyright 1984-2018 The MathWorks, Inc.
