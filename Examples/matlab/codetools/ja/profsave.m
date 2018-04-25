%PROFSAVE  プロファイルレポートを HTML 形式で保存
%
%   PROFSAVE(PROFINFO) は、プロファイラデータ構造体の FunctionTable の
%   各ファイルに対応する HTML ファイルを保存します。
%   PROFSAVE(PROFINFO, DIRNAME) は、指定したディレクトリPROFSAVE のファイルを
%   保存し、PROFILE('INFO') の呼び出しからの結果を使用します。
%
%   例:
%   profile on
%   plot(magic(5))
%   profile off
%   profsave(profile('info'),'profile_results')
%
%   参考 PROFILE, PROFVIEW.


%   Copyright 1984-2009 The MathWorks, Inc.
