% PROFVIEW   HTML プロファイラインタフェースの表示
%
% PROFVIEW(FUNCTIONNAME, PROFILEINFO)
% FUNCTIONNAME は、プロファイルへの名前またはインデックス番号のいずれかです。
% PROFILEINFO は、
%    PROFILEINFO = PROFILE('INFO')
% で出力されるプロファイル統計量の構造体です。
% 渡された FUNCTIONNAME 引数が 0 の場合、profview は、プロファイルを
% まとめたページを表示します。
%
% PROFVIEW に対する出力は、プロファイラウィンドウの HTML ファイルです。
% 関数プロファイルページの下にリストされているファイルは、コードの各行
% の左の列です。
%  * 列 1 (赤) は、その行に費やされた時間の合計 (s) です。
%  * 列 2 (青) は、その行への呼び出し番号です。
%  * 列 3 は、行番号です。
%
%  参考 PROFILE.


%   Copyright 1984-2006 The MathWorks, Inc.
