%PUBLISH  セルを含む M-ファイルを出力ファイルに変換
%
%   PUBLISH(FILE) は、ベースワークスペース内のある時間で、M-ファイルの 1 つの
%   セルを実行します。コードとコメントと、同じ名前を持つ HTML-ファイルへの結果を
%   保存します。HTML-ファイルは、そのスクリプトのディレクトリの "html" サブ
%   ディレクトリ内に、他のサポートされる出力ファイルと共に格納されます。
%
%   PUBLISH(FILE,FORMAT) は、指定した形式でスクリプトを実行ます。
%   FORMAT は、以下のいずれかになります。
%
%      'html'  - HTML.
%      'doc'  - Microsoft Word (Microsoft Word が必要)。
%      'ppt'  - Microsoft PowerPoint (Microsoft PowerPoint が必要)。
%      'xml'  - XSLT または他のツールで変換可能な XML ファイル。
%      'latex' - LaTeX.さらに、figureSnapMethod が 'getframe' でない限り、
%                デフォルトの imageFormat を 'epsc2' に変更します。
%
%   PUBLISH(FILE,OPTIONS) は、以下のフィールドのいずれかを含む構造体を与えます。
%   フィールドが指定されない場合、リストの 1 番目の選択が使われます。
%
%       format: 'html' | 'doc' | 'ppt' | 'xml' | 'latex'
%       stylesheet: '' | XSL ファイル名 (format = html または xml でない限り無視)
%       outputDir: '' (そのファイルより下位の html サブフォルダ) | 絶対パス
%       imageFormat: '' (format に基づくデフォルト)  | figureSnapMethod に
%                    依存する PRINT または IMWRITE でサポートされるもの
%       figureSnapMethod: 'entireGUIWindow'| 'print' | 'getframe' | 'entireFigureWindow'
%       useNewFigure: true | false
%       maxHeight: [] (制限なし) | 正の整数 (ピクセル)
%       maxWidth: [] (制限なし) | 正の整数 (ピクセル)
%       showCode: true | false
%       evalCode: true | false
%       catchError: true | false
%       createThumbnail: true | false
%       maxOutputLines: Inf | 非負の整数
%       codeToEvaluate: (変換する M-ファイル) | 有効なコード
%
%   HTML に変換すると、デフォルトのスタイルシートは、"showcode = false" の
%   場合でも、HTML コメントとしてオリジナルのコードを保存します。GRABCODE を
%   使用して抽出してください。
%
%   例:
%
%       opts.outputDir = tempdir;
%       file = publish('intro',opts);
%       web(file)
%
%   参考 NOTEBOOK, GRABCODE.


% Copyright 1984-2009 The MathWorks, Inc.
