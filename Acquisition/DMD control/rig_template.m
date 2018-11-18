% Copyright 2016-2017 Vicente Parot
% 
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:      
% 
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.    
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.      
%
function string = rig
% rig identifies a computer in the dmd initialization code.
%
% Instructions:
% - Find this file in
%       X:\Lab\Computer Code\General Matlab\VIALUX control\
% - Add this folder with subfolders to the matlab path.
% - Copy the file rig_template.m to your computer desktop folder.
% - Rename the file in your computer rig_template.m -> rig.m
% - Edit the first line of code and change 'firefly' to other unique word.
% - Cut and paste the file rig.m in your computer into the folder
%       C:\Program Files\MATLAB\R2014a\toolbox\local\
%     or equivalent in your computer.
% - Edit the file lab_init_device.m and add a case for your computer
% - listo! The path should be set correctly after restarting matlab.
% 
% 2016 Vicente Parot
% Cohen Lab - Harvard University
	localstring = 'firefly';
	if nargout
		string = localstring;
	else
		disp(localstring)
	end
end