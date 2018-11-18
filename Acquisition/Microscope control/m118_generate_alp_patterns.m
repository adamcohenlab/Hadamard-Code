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
function alp_patterns = m118_generate_alp_patterns(device,roirows,roicols,hadamard_mode)
%             roirows = 19*10+0:57*10+3; % extended central quad 2017-03-17
%             roicols = 32*10+0:69*10+5;
%             hadamard_mode = 'activity';
%             device = [];
ncols = device.height;
nrows = device.width;

super_mask = zeros(1,nrows,ncols);
superstim_mask = super_mask;
stim0_mask = ones(nrows,ncols);

switch hadamard_mode
    case 'structural'
        sequence_mode = 'shorter_63c14'; % structural
    case 'activity'
        sequence_mode = 'hadamard_11c3_spotonly_once'; % activity
end

% % stim0_mask = zeros(nrows,ncols);
% sequence_mode = 'hadamard_11c3_sprinkledstim'; % had sync
% roirows = 19*10+0:57*10+3; % extended central quad 2017-03-17
% roicols = 32*10+0:69*10+5;

% stimroirows = 33*10+0:57*10+3; % LTP stim roi 2017-04-07
% stimroicols = 32*10+0:69*10+5;


if true
    % full ROI
    super_mask(1,roirows,roicols) = 1;
    superstim_mask(1,roirows,roicols) = 1;
else
    % quadrants 
    roirowslime = roirows(1:ceil(end/2));
    super_mask(1,roirowslime,roicols) = 1;
    roicolsblue = roicols(1:ceil(end/2));
    superstim_mask(1,roirows,roicolsblue) = 1;
end
%% stim params

% stim_mode = 'checkerboards';
% period = 1000/9.6; % dmd pixels
% checkerboard = (double(mod(0:nrows-1,period)<period/2)'-.5)*(double(mod(0:ncols-1,period)<period/2)-.5)>0;
% 
% stim_mode = 'bgspots';
bglevel = 0; % 2^-4; % 0; % % 2^-6;
% load 154850_spots_mask
% stim0_mask = spots_masks(:,:,5); % comment for whole field
% stim0_mask = stimpat';

%% pulses
npulses = 8;
pulselength = 5; % pulses
% pulselength = 50; % blocks
pulseperiod = 50;
totallength = 400;
x = (0:.8:totallength);
spotmod = mod(x,pulseperiod)<pulselength & (totallength-pulseperiod*npulses)<=x & x<totallength;  
plot(x,spotmod) % pulses
%%
%         x = (0:.8:400); spotmod = 5<=x&x<385; % plot(x,spotmod) % dc

super_mask = uint8(super_mask);
stim0_mask = permute(uint8(superstim_mask),[2 3 1]).*uint8(stim0_mask);
selective_mask = ones(nrows,ncols,1);
% selective_mask = new_peaks_mask;
super_mask = super_mask.*permute(uint8(selective_mask),[3 1 2]);
switch sequence_mode
    case 'hadamard_11c3_spotonly_once'
        ndatapoints = 11;
        clc
        blocksize = [11 3];
        elementsize = 1;
        alp_patterns = hadamard_patterns_scramble_nopermutation(blocksize,elementsize,permute(super_mask,[3 2 1]));
%         stimmask = permute(super_mask,[2 3 1]);
        npatsblue = 501;
        stim_spot_only = false(nrows,ncols,npatsblue);
        stim_spot_only(roirows,roicols,:) = bsxfun(@or,stim0_mask(roirows,roicols),stim_spot_only(roirows,roicols,:));
        stim_spot_only(roirows,roicols,:) = bsxfun(@and,permute(spotmod,[1 3 2]),stim_spot_only(roirows,roicols,:));
        stim_spot_only(:,:,end) = false;
        close all
        figure windowstyle docked
        imshow([mean(stim_spot_only,3)],[])
        title({'randonly randspot'})
        stim_spot_only = alp_logical_to_btd(stim_spot_only);
        alp_patterns_pre = cat(3,...
            false(size(alp_patterns(:,:,ones(4,1)))),...
            repmat(alp_patterns,[1 1 ndatapoints]));
        alp_patterns_pre = reshape([alp_patterns_pre alp_patterns_pre*0],size(alp_patterns_pre).*[1 1 2]);
        alp_patterns_post = cat(3,...
            repmat(alp_patterns,[1 1 ndatapoints]),...
            false(size(alp_patterns(:,:,ones(4,1)))));
        alp_patterns_post = reshape([alp_patterns_post alp_patterns_post*0],size(alp_patterns_post).*[1 1 2]);
                alp_patterns = cat(3,alp_patterns_pre,stim_spot_only,alp_patterns_post);
%         a02_load_seq_firefly
%         clear alp_patterns selective_mask stim0_mask stim1_mask stim2_mask stim_bg_nospot stim_spot_only check1 check2 alp_patterns_pre alp_patterns_post
        disp([sequence_mode  ' loaded'])
    case 'hadamard_11c3_sprinkledstim'
%         nstims = 5;
        ndatapoints = 11;
        clc
        blocksize = [11 3];
        elementsize = 1;
        alp_patterns = hadamard_patterns_scramble_nopermutation(blocksize,elementsize,permute(super_mask,[3 2 1]));
        stimmask = permute(super_mask,[2 3 1]);
        npatsblue = 501;
        stim_bg_nospot = false(nrows,ncols,npatsblue);
        stim_spot_only = false(nrows,ncols,npatsblue);
        stim_bg_nospot(roirows,roicols,:) = rand(numel(roirows),numel(roicols),npatsblue) <= bglevel;
        stim_bg_nospot(roirows,roicols,:) = bsxfun(@and,~stim0_mask(roirows,roicols),stim_bg_nospot(roirows,roicols,:));
        stim_spot_only(roirows,roicols,:) = bsxfun(@or,stim0_mask(roirows,roicols),stim_spot_only(roirows,roicols,:));
        stim_spot_only(roirows,roicols,:) = bsxfun(@and,permute(spotmod,[1 3 2]),stim_spot_only(roirows,roicols,:));
        stim_bg_nospot(:,:,end) = false;
        stim_spot_only(:,:,end) = false;
        close all
        figure windowstyle docked
        imshow([mean(stim_bg_nospot,3) mean(stim_spot_only,3)],[])
        title({'randonly randspot'})
%         check1 = bsxfun(@or, checkerboard & permute(super_mask,[2 3 1]),false(size(stim_bg_nospot)));
%         check1 = bsxfun(@and,permute(spotmod,[1 3 2]),check1);
%         check1 = alp_logical_to_btd(check1);
%         check2 = bsxfun(@or,~checkerboard & permute(super_mask,[2 3 1]),false(size(stim_bg_nospot)));
%         check2 = bsxfun(@and,permute(spotmod,[1 3 2]),check2);
%         check2 = alp_logical_to_btd(check2);
%         check1(:,:,end) = false;
%         check2(:,:,end) = false;
%         check1(:,:,end-12:end) = false;
%         check2(:,:,end-12:end) = false;
        stim_bg_nospot = alp_logical_to_btd(stim_bg_nospot);
        stim_spot_only = alp_logical_to_btd(stim_spot_only);
        alp_patterns_pre = cat(3,...
            false(size(alp_patterns(:,:,ones(4,1)))),...
            repmat(alp_patterns,[1 1 ndatapoints]));
        alp_patterns_pre = reshape([alp_patterns_pre alp_patterns_pre*0],size(alp_patterns_pre).*[1 1 2]);
        alp_patterns_post = cat(3,...
            repmat(alp_patterns,[1 1 ndatapoints]),...
            false(size(alp_patterns(:,:,ones(4,1)))));
        alp_patterns_post = reshape([alp_patterns_post alp_patterns_post*0],size(alp_patterns_post).*[1 1 2]);
%         switch stim_mode
%             case 'checkerboards'
%                 alp_patterns = cat(3,...
%                     false(size(stim_bg_nospot)),...
%                     alp_patterns,...
%                     check1,...
%                     alp_patterns,...
%                     check2,...
%                     alp_patterns,...
%                     check1,...
%                     alp_patterns,...
%                     check2,...
%                     alp_patterns);
%             case 'bgspots' 
                alp_patterns = repmat(cat(3,...
                    alp_patterns_pre,stim_spot_only,alp_patterns_post,...
                    alp_patterns_pre,stim_bg_nospot,alp_patterns_post,...
                    alp_patterns_pre,stim_bg_nospot+stim_spot_only,alp_patterns_post),[1 1 2]);
%         end
%         a02_load_seq_firefly
%         clear alp_patterns selective_mask stim0_mask stim1_mask stim2_mask stim_bg_nospot stim_spot_only check1 check2 alp_patterns_pre alp_patterns_post
        disp([sequence_mode  ' loaded'])
    case 'structural_hadamard_63c14'
        nstims = 3;
        ndatapoints = 22;
        clc
        blocksize = [63 14];
        elementsize = 1;
        alp_patterns = hadamard_patterns_scramble_nopermutation(blocksize,elementsize,permute(super_mask,[3 2 1]));
        alp_patterns = cat(3,...
            0*alp_patterns(:,:,1),...
            alp_patterns,...
            0*alp_patterns(:,:,ones(2,1)));
        alp_patterns = repmat(alp_patterns,[1 1 nstims]);
        alp_patterns = reshape([alp_patterns alp_patterns*0],size(alp_patterns).*[1 1 2]);
        a02_load_seq_firefly
        close all
        clear alp_patterns selective_mask stim0_mask stim1_mask stim2_mask
        disp([sequence_mode  ' loaded'])
    case 'shorter_63c14'
        nstims = 3;
%         ndatapoints = 22;
        clc
        blocksize = [63 14];
        elementsize = 1;
        alp_patterns = hadamard_patterns_scramble_nopermutation(blocksize,elementsize,permute(super_mask,[3 2 1]));
%         alp_patterns = cat(3,...
%             0*alp_patterns(:,:,1),...
%             alp_patterns,...
%             0*alp_patterns(:,:,ones(2,1)));
%         alp_patterns = repmat(alp_patterns,[1 1 nstims]);
        alp_patterns = reshape([alp_patterns alp_patterns*0],size(alp_patterns).*[1 1 2]);
%         a02_load_seq_firefly
        close all
%         clear alp_patterns selective_mask stim0_mask stim1_mask stim2_mask
        disp([sequence_mode  ' loaded'])
end

%     case 'hadamard_11c3'
%         nstims = 5;
%         ndatapoints = 34;
%         clc
%         blocksize = [11 3];
%         elementsize = 1;
%         alp_patterns = hadamard_patterns_scramble_nopermutation(blocksize,elementsize,permute(super_mask,[3 2 1]));
%         alp_patterns = cat(3,alp_logical_to_btd(permute(super_mask,[2 3 1])),repmat(alp_patterns,[1 1 ndatapoints]));
%         alp_patterns = repmat(alp_patterns,[1 1 nstims]);
%         alp_patterns = reshape([alp_patterns alp_patterns*0],size(alp_patterns).*[1 1 2]);
%         alp_patterns(:,:,4090/nstims*2+1) = alp_logical_to_btd(stim0_mask);
%         alp_patterns(:,:,4090/nstims*3+1) = alp_logical_to_btd(stim1_mask);
%         alp_patterns(:,:,4090/nstims*4+1) = alp_logical_to_btd(stim2_mask);
%         a02_load_seq_firefly
%         close all
%         figure windowstyle docked
%         imshow([selective_mask stim0_mask; stim1_mask stim2_mask],[])
%         title({'selective   stim0','   stim1     stim2'})
%         clear alp_patterns selective_mask stim0_mask stim1_mask stim2_mask
%         disp([sequence_mode  ' loaded'])



end
