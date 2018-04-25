function [classname,varargout] = argclass(arg_inds,classname,varargin)
%ARGCLASS   Convert arguments to appropriate class.
%   [CLASSNAME,VARARGOUT] = ARGCLASS(ARG_INDS,CLASSNAME,VARARGIN)
%   converts the arguments in VARARGIN having indices ARG_INDS to a
%   class determined by those arguments and CLASSNAME
%   (which will be passed to this function as empty if the user
%   did not specify it when calling GALLERY).
%   This function is called by GALLERY only.
%
%   The logic used for the conversion is described in the table
%   below, which shows the class of the matrix A formed by GALLERY.
%   Any arguments in VARARGIN with indices not in ARG_INDS are converted
%   to double.
%
%                                    CLASSNAME
%                                    ---------
%                  Not specified       Single           Double
%               ----------------------------------------------------
%    Arguments  |
%    ---------- |
%    all        |   Single A          Single A          Double A
%    single     |                                       Cast args to
%               |                                       double.
%               |
%    all        |   Double A          Single A          Double A
%    double     |                     Cast args to
%               |                     single.
%               |
%    mix of     |   Single A          Single A          Double A
%    single &   |   Cast args to      Cast args to      Cast args to
%    double     |   single.           single.           double.

%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.

if isempty(classname)
   if length(arg_inds) == 0
      % No arguments present to determine class, so set to double.
      classname = 'double';
   else
      % Use arguments in indices arg_ind to determine class.
      indv = arg_inds( arg_inds <= length(varargin) );
      if length(indv)
         classname = superiorfloat( varargin{indv} );
      else
         % None of the arguments that can determine CLASSNAME were
         % supplied, so use default.
         classname = 'double';
      end
   end
end
varargout = varargin;
for i=1:length(varargin)
    if ismember(i,arg_inds)
       varargout{i} = cast( varargin{i}, classname );
    else
       % Ensure any dimensions and option selectors are double.
       varargout{i} = cast( varargin{i}, 'double' );
    end
end
