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
%% initialize DMD

% 2016 Vicente Parot
% Cohen Lab - Harvard University

% loads library if needed
assert(~~exist('rig','file'),'no rig')
switch rig
    case 'upright'
        if ~exist('api','var') || ~isa(api,'alpV42x64')
            api = alpload('alpV42x64');
        end
    case {'firefly','adaptive'}
        if ~exist('api','var') || ~isa(api,'alpV43x64')
            api = alpload('alpV43x64');
        end
    otherwise
        error 'unknown rig'
end
% connects to device, resets connection if there already was one
device = alpdevice(api);
alloc_val = device.alloc;
switch alloc_val
    case api.DEFAULT
        disp 'device alloc ok'
    case api.NOT_ONLINE
        disp 'device not online'
    otherwise
        display(['device alloc returned ' num2str(alloc_val)])
end
