%----------
% @file ZoomRect.m
% @brief Zoom rectangle with input coordinates. 入力領域を入力座標を中心として拡大縮小する。
%
% Zoom rectangle with input coordinates. 入力領域を入力座標を中心として拡大縮小する。
% 
% @author	T.Higashi
% @date		2008/01/20
%
% @par Change log
% - 2008/01/20	T.Higashi	:New. 新規作成。
% 
%%
%----------
% orect = ZoomRect(irect, iscl, ipntC)
% @param	irect		:Rectangle. 長方形領域。
% @param	iscl		:Scale(%). 長方形の拡大縮小の%。
% @param	ipntC		:Center point for zoom. 拡大縮小の中心点。
% @retval	orectStr	:Rectangle after zoom. 拡大縮小後の長方形領域。
% 
%%
function orect = ZoomRect(irect, iscl, ipntC)

	if isequal(size(iscl), [1, 1])
		iscl = [iscl, iscl];
	end

	sclX = iscl(1) / 100;
	sclY = iscl(2) / 100;

	% Distance.
	% 移動量。
	qttZoom = irect - [ipntC, ipntC];
	qttZoom = qttZoom .* [sclX, sclY, sclX, sclY];

	orect = round([ipntC, ipntC] + qttZoom);
