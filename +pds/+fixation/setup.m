function p = setup(p)
% pds.fixation.setup(p)   create fixation spot and setup keys
%
% wolf zinke, april 2017
% Nate Faber, May 2017

% Allow using the numpad to set the fixation point:
%
%  -------------
%  | 7 | 8 | 9 |
%  -------------
%  | 4 | 5 | 6 |
%  -------------
%  | 1 | 2 | 3 |
%  -------------

grdX = p.defaultParameters.behavior.fixation.FixGridStp(1);
grdY = p.defaultParameters.behavior.fixation.FixGridStp(2);

X = [-grdX;     0;  grdX; -grdX; 0; grdX; -grdX;    0; grdX];
Y = [-grdY; -grdY; -grdY;     0; 0;    0;  grdY; grdY; grdY];

p.defaultParameters.eyeCalib.Grid_XY = [X, Y];

% define keys used for moving the fixation spot
KbName('UnifyKeyNames');
p.defaultParameters.key.GridKey       = KbName(arrayfun(@num2str, 1:9, 'unif', 0));
p.defaultParameters.key.GridKeyCell   = num2cell(p.defaultParameters.key.GridKey);






