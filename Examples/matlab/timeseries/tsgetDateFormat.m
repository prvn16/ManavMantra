function [strs,absstatus] = tsgetDateFormat
%
% tstool utility function

%TSISDATEFORMAT Utility to detect if a string is a valid data format
%
%   Copyright 2004-2015 The MathWorks, Inc.

datestrs = {...
  'dd-mmm-yyyy HH:MM:SS',true;
  'dd-mmm-yyyy HH:MM:SS.FFF',true;
  'dd-mmm-yyyy',true;
  'mm/dd/yy',true;
  'HH:MM:SS',false;
  'HH:MM:SS.FFF',false;
  'HH:MM:SS PM',false;
  'HH:MM:SS.FFF PM',false;
  'HH:MM',false;
  'HH:MM PM',false;
  'mmm.dd,yyyy HH:MM:SS',true;
  'mmm.dd,yyyy HH:MM:SS.FFF',true;
  'mmm.dd,yyyy',true;
  'mm/dd/yyyy',true};

strs = datestrs(:,1);
absstatus = datestrs(:,2);
