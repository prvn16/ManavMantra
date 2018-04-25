% Commands for creating and debugging code
% MATLAB Version 9.4 (R2018a) 06-Feb-2018 
%
% Editing and publishing
%   edit                   - Edit or create a file
%   grabcode               - Copy MATLAB code from published HTML
%   mlint                  - Check files for possible problems
%   publish                - Publish file containing cells to output file
%   snapnow                - Force snapshot of image for published document
% 
% Directory tools
%   mlintrpt               - Run mlint for file or folder, reporting results in browser
%   visdiff                - Compare two files (text, MAT, or binary) or folders
%
% Profiling
%   profile                - Profile execution time for function
%   profsave               - Save profile report in HTML format
%
% Debugging
%   dbclear                - Clear breakpoints
%   dbcont                 - Resume execution
%   dbdown                 - Reverse workspace shift performed by DBUP, while in debug mode
%   dbmex                  - Enable MEX-file debugging (on UNIX platforms)
%   dbquit                 - Quit debug mode
%   dbstack                - Function call stack
%   dbstatus               - List all breakpoints
%   dbstep                 - Execute one or more lines from current breakpoint
%   dbstop                 - Set breakpoints
%   dbtype                 - Display program file with line numbers
%   dbup                   - Shift current workspace to workspace of caller, while in debug mode
%   debug                  - List debugging functions
%
% Managing, watching, and editing variables
%   openvar                - Open workspace variable in tool for graphical editing
%   workspace              - Open Workspace browser to manage workspace
%
% Managing the file system and search path
%   filebrowser            - Open Current Folder browser, or select it if already open
%   pathtool               - Open Set Path dialog box to view and change search path
%
% Command Window and history
%   commandhistory         - Open Command History window, or select it if already open
%   commandwindow          - Open Command Window, or select it if already open
%
% GUI utilities
%   datatipinfo            - Produce short description of input variable
%
% Importing data
%   uiimport               - Open Import Wizard to import data

%
% Unsupported functions (helper functions for internal use)
%   These functions are unsupported and might change or be removed without
%   notice in a future version.
%
% Directory tools (helper functions)
%   auditcontents          - Audit the Contents.m for the given folder
%   code2html              - Prepare MATLAB code for display in HTML
%   contentsrpt            - Audit the Contents.m for the given folder
%   coveragerpt            - Audit a folder for profiler line coverage
%   deprpt                 - Audit a file or folder for dependencies
%   diff2asv               - Compare file to autosaved version, if it exists
%   diffcode               - Global alignment algorithm applied to file diffs
%   diffline               - Highlight differences within a line of text
%   difftemplate           - Return an HTML template for displaying reports
%   dofixrpt               - Audit a file or folder for all TODO, FIXME, or NOTE messages
%   fixcontents            - Helper function for CONTENTSRPT
%   fixquote               - Double up any single quotes appearing in a folder name
%   getcallinfo            - Returns called functions and their first and last lines
%   helprpt                - Audit a file or folder for help
%   makecontentsfile       - Make a new Contents.m file
%   matdiff                - Compare similarity of two MAT-files
%   matview                - Display a variable from a MAT-file in the Variable Editor
%   profreport             - Generate profile report
%   profview               - Display HTML profiler interface
%   profviewgateway        - Profiler HTML gateway function
%   runreport              - Run the specified report
%   urldecode              - Replace URL-escaped strings with their original characters
%   urlencode              - Replace special characters with escape characters URLs need
%
% Profiling files (helper functions)
%   stripanchors           - Remove anchors that evaluate MATLAB code from Profiler HTML
%
% Editing and publishing MATLAB code (helper functions)
%   indentcode            - Helper function for internal use that indents MATLAB code
%   m2struct               - Break code into cells
%   mdbfileonpath          - Helper function for the Editor/Debugger
%   mdbpublish             - Helper function for the MATLAB Editor/Debugger that calls 
%   mdbstatus              - dbstatus for the Editor/Debugger
%   opentoline             - Open to specified line in function file in Editor
%
% Managing the file system and search path (helper files)
%   editpath               - Modify the search path
%
% Managing, watching, and editing variables (helper files)
%   arrayviewfunc          - Support function for the Variable Editor component
%   commonplotfunc         - Support function for Plot Picker component
%   plotpickerfunc         - Support function for Plot Picker component
%   sharedplotfunc         - Support function for Plot Picker component
%   workspacefunc          - Support function for Workspace browser component
%
% Other files (helper functions)
%   codetoolsswitchyard    - This function will be removed in a future release
%   functionhintsfunc      - This undocumented function may be removed in a future release
%   initdesktoputils       - Initialize the MATLAB path for the desktop and desktop tools
%   makemcode              - Generate readable function based on input object(s)
%   projdumpmat            - Helper function for MATLAB Projects

%   Copyright 1984-2018 The MathWorks, Inc. 
