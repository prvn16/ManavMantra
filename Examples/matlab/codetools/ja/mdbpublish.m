%MDBPUBLISH  Codepad の publish 関数を呼び出す MATLAB Editor/Debugger の
%            ための補助関数
%
%   FILE           変換するファイル名
%   FORMAT         サポートする形式 (html, xml, doc, ppt) のいずれか
%   EVALCODE       コードを評価する必要がある場合 true
%   NEWFIGURE      新しい Figure を作成する必要がある場合 true
%   DISPLAYCODE    コードを出力に表示する必要がある場合 true
%   STYLESHEET     カスタムスタイルシートに対するパス、または、デフォルトを
%                  使用する必要がある場合、空です。
%   LOCATION       出力を保存するためのパス、または、デフォルトを使用する
%                  必要がある場合、空です。
%   IMAGETYPE      イメージファイルタイプ。変換で指定されるデフォルトのイメージ
%                  タイプを使用するために、IMWRITE または デフォルトでサポート
%                  される選択の 1 つ。
%   SCREENCAPTURE  スクリーンキャプチャを使用する必要がある場合、true。
%                  印刷する場合、false
%   MAXHEIGHT      高さの制限が必要ない場合、-1，そうでない場合、最大の高さ
%   MAXWIDTH       幅の制限が必要ない場合 -1、そうでない場合は最大幅
%   THUMBNAILON    サムネイルイメージを出力ディレクトリ内に作成する必要が
%                  ある場合は true
%   MAXOUTPUTLINES 出力行の制限が必要ない場合は -1、そうでない場合は出力を
%                  打ち切る前に出力の最大行数を指定する整数
%   CODETOEVALUATE 変換で評価されるコード


%   Copyright 1984-2008 The MathWorks, Inc.
