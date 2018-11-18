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
%% initialize projector
lab_init_device
%%
device.free;
disp 'device free' 
%% switch back to master mode and Illuminate
% roirows = 1:768; % extended full fov 2017-03-29
% roicols = 14*10+0:87*10+1;
% roirows = 19*10+9:57*10+9; % extended central half 2017-02-09
% roicols = 13*10+0:87*10+1;
roirows = 19*10+0:57*10+3; % extended central quad 2017-03-17
roicols = 32*10+0:69*10+5;
roirows = 33*10+0:57*10+3; % stim roi
roicols = 32*10+0:69*10+5;
% roirows = 19*10+9:57*10+9; % extended central half 2017-02-13
% roicols = 13*10+0:87*10+1;

pat = zeros(device.height,device.width);

pat(roicols,roirows) = 1;
% pat(:) = 1;
% rng(142857)
% pat = pat.*(rand(size(pat))<.005);
% pat(407*1000+10*100+(1:100)) = 1;
% nnz(pat)
% litidx = find(pat);
% save reg09 litidx

% device.halt;
% device.projcontrol(api.PROJ_MODE,api.MASTER);
device.put(pat*255)

%% switch back to master mode and project selective mask
device.halt;
device.projcontrol(api.PROJ_MODE,api.MASTER);
% new_peaks_mask = circshift(peaks_mask2,[0 0]);
device.put(spots_masks(:,:,3)'*255)
% device.put((checkerboard')*255)

%% switch back to master mode and FLASH
device.halt;
device.projcontrol(api.PROJ_MODE,api.MASTER);
% simple test. set to white, wait 1/4 s, set to black.
device.put(ones(device.height,device.width)*255)
% pause(.25)
device.put(zeros(device.height,device.width))

