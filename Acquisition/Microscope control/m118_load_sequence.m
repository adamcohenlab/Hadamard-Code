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
clc
device.free;
disp 'device free' 
lab_init_device
% ExposureMilliseconds = 10;
% CameraLines = 2048;
ModeStringSyncOrUninterrupted = 'uninterrupted';
% setup_load_start_sequence
%%
device.stop;
device.halt;

BitPlanes = 1;
PicOffset = 0;
PicNum = size(alp_patterns,3);

% PictureTimeSpacing = ceil(ExposureMilliseconds*128/5); % [us]
TriggerInDelay = api.DEFAULT; % -30 + ceil(9.75*ceil(CameraLines/2)); % [us] only relevant in slave mode
PictureTimeExcess = 25; % [us] % must be > 2 us per instructions. not a dmd parameter, for parameter calculation only

TriggerSynchDelay = api.DEFAULT; % [us] only relevant in master mode
TriggerSynchPulseWidth = api.DEFAULT; % [us]
PictureTime = 44; % api.DEFAULT; % floor(ExposureMilliseconds*1000/1.023)-PictureTimeSpacing; % [us]
IlluminateTime = api.DEFAULT; % PictureTime-TriggerInDelay-PictureTimeExcess-TriggerSynchDelay; % [us]
fprintf('PictureTime: %d us\nIlluminateTime: %d us\n',PictureTime,IlluminateTime)

seq = alpsequence(device);
seq.alloc(BitPlanes,PicNum);
seq.control(api.DATA_FORMAT,api.DATA_BINARY_TOPDOWN);
switch ModeStringSyncOrUninterrupted
    case 'uninterrupted'
        seq.control(api.BIN_MODE,api.BIN_UNINTERRUPTED); % to display the pattern
        % until next trigger, even in slave mode, regardless of IlluminateTime.
        % Watch for bleedthrough into the rolling shutter due to delayed
        % responsivity.  
    case 'sync' % do nothing
    otherwise % do nothing
end
seq.timing(IlluminateTime, PictureTime, TriggerSynchDelay, TriggerSynchPulseWidth, TriggerInDelay);
[~, PictureTime] = seq.inquire(api.PICTURE_TIME);
[~, IlluminateTime] = seq.inquire(api.ILLUMINATE_TIME);
fprintf('PictureTime: %d us\nIlluminateTime: %d us\n',PictureTime,IlluminateTime)
fprintf('Loading %d patterns ...\n',PicNum)
seq.put(PicOffset,PicNum,permute(alp_patterns,[3 1 2]));

device.projcontrol(api.PROJ_MODE,api.SLAVE_VD);
device.startcont(seq);
fprintf('done\n')

