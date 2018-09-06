%----------
% @file DispImage.m
% @brief Create and output image stimulus. 静止画像刺激の作成、出力。
%
% Create and output image stimulus. 静止画像刺激の作成、出力。
% 
% @author	T.Higashi
% @date		2008/01/24
%
% @par Change log
% - 2008/02/06	T.Higashi	:Add processing to free memory. メモリ開放処理追加。
% - 2008/01/25	T.Higashi	:Support image data input. ファイルパスでなくデータ自体の読み込みにも対応。
% - 2008/01/24	T.Higashi	:New. 新規作成。
% 
%%
%----------
% varargout = DispImage(iselector, varargin)
% @param	iselector	:Selector to change process('init', 'draw', 'clear' or 'get'). 処理の切り替え('init', 'draw', 'clear','get')。
% @param	varargin	:Input argments related to selector. 処理に応じた入力引数。
% @retval	varargout	:Onput argments related to selector. 処理に応じた出力引数。
% 
% imgp = DispImage('init', wpt, 'flPath', pntImg, scl, sclAll)
% DispImage('draw', wpt, imgp)
% DispImage('clear', imgp)
% DispImage('get', imgp)
% wpt		:Window pointer. ウィンドウポインタ。
% imgp		:Image pointer. イメージポインタ。
% flPath	:Path to image file. 静止画像ファイルへのパス。
% pntImg	:Point setting. 画像表示位置設定。
% scl		:Scale setting. 画像スケール設定。
% sclAll	:Entire scale setting. 全体スケール設定。
% 
%%
function varargout = DispImage(iselector, varargin)

	persistent SETTING

	switch iselector

	case 'init'
		% Initialize image data.
		% 画像用データの初期化。
		if length(varargin) == 5

			[wpt, flPath, pntImg, scl, sclAll] = deal(varargin{:});
			[SETTING, imgp] = CreateSetting(SETTING, wpt, flPath, pntImg, scl, sclAll);
			varargout = {imgp};

		else

			error('DispImage(''init'', wpt, ''flPath'', pntImg, scl, sclAll)');

		end


	case 'draw'

		% Draw image.
		% 画像データの描画。
		if length(varargin) == 2

			[wpt, imgp] = deal(varargin{:});
			TEX = SETTING{imgp, 1};
			RECT = SETTING{imgp, 2};
			Screen('DrawTexture', wpt, TEX, [], RECT );

		else

			error('DispImage(''draw'', wpt, imgp)');

		end


	case 'clear'

		% clear image data.
		% 画像データの削除。
		if length(varargin) == 1

			[imgp] = deal(varargin{:});
			TEX = SETTING{imgp, 1};
			if ~isempty(TEX)
				Screen('Close', TEX);
			end
			if imgp == size(SETTING, 1);
				SETTING(imgp,:) = [];
			else
				SETTING(imgp,:) = repmat({[]}, 1, size(SETTING, 2));
			end

		else

			error('DispImage(''clear'', imgp)');

		end


	case 'get'

		% Get image data.
		% 画像データの取得。
		if length(varargin) == 1

			[imgp] = deal(varargin{:});
			if isempty(imgp)
				varargout = {SETTING};
			else
				varargout = {SETTING(imgp,:)};
			end

		else

			error('DispImage(''get'', imgp)');

		end

	end


function [oSETTING, oidx] = CreateSetting(iSETTING, iwpt, iflPath, ipntImg, iscl, isclAll)

	% Make texture.
	% テクスチャを作成。
	if ischar(iflPath)
		imgDat = imread(iflPath);
	else
		imgDat = iflPath;
	end
	TEX = Screen('MakeTexture', iwpt, imgDat );

	if isequal(ipntImg, [0, 0]) && isequal(iscl, 100) && (isequal(isclAll, [100, 100]) || isempty(isclAll))
		% No need to convert shape.
		% 形状を変更する必要なし。

		RECT = [];

	else

		% Coordinate transform.
		% 座標系をあわせる。
		[sizW, sizH] = Screen('WindowSize', iwpt);
		pntO = round([sizW, sizH] / 2);
		ipntImginW = ipntImg + pntO;

		% Transesate to display position and zoom.
		% 表示位置への移動と拡大縮小。
		sizImg = size(imgDat);
		RECT = [0, 0, sizImg(2), sizImg(1)];
		RECT = CenterRectOnPoint(RECT, ipntImginW(1), ipntImginW(2));
		RECT = ZoomRect(RECT, iscl, ipntImginW);

		% Adjust image size.
		% サイズを調節。
		if ~isempty(isclAll)
			RECT = ZoomRect(RECT, isclAll, pntO);
		end

	end

	if isempty(iSETTING)
		oidx = [];
	else
		oidx = min(find(cellfun('isempty', iSETTING(:,1))));
	end

	if isempty(oidx)
		% Append new data.
		% 新しいデータを追加。
		oSETTING = [iSETTING; {TEX, RECT}];
		oidx = size(oSETTING, 1);
	else
		% Assign new data to empty place.
		% 新しいデータを開いている場所に追加。
		oSETTING = iSETTING;
		oSETTING(oidx, :) = {TEX, RECT};
	end
