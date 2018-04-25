%NET.disableAutoRelease locks a .NET object representing a RunTime Callable 
% Wrapper (COM Wrapper) so that MATLAB does not release the COM object. 
%  A = NET.disableAutoRelease(OBJ) 
%
%  OBJ - .NET object representing a COM Wrapper.
%
%  Before passing a .NET object representing a COM  Wrapper to another 
%  process, lock the object using this function so that MATLAB does not 
%  release it. After using the object, call NET.enableAutoRelease 
%  to release the COM object.
%
%  Examples:
%     function comtest()
%       a = NET.addAssembly('C:\Work\COM_NET_WRAPPER.exe');
%       obj = COM_NET_WRAPPER.excelTest;
%       func1(obj);
%       books = obj.myObject.Workbooks;
%       NET.enableAutoRelease(obj.myObject); 
%     end
% 
%     function func1(obj)
%       NET.addAssembly('microsoft.office.interop.excel');
%       app = Microsoft.Office.Interop.Excel.ApplicationClass;
%       obj.myObject = app;
%       NET.disableAutoRelease(app);
%     end
%
%   See also: NET.enableAutoRelease
 
% Copyright 2009-2010 The MathWorks, Inc.
%  $Date $
