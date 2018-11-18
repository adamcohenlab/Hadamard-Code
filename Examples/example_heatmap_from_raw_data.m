% Supplementary Software and Data
%
% Example: From raw Hadamard data, calculate Hadamard optical section
% functional recordings, extract responsive cells, show heatmat of single
% cell responses.
%
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

addpath(fullfile('..','Acquisition','DMD pattern generation'))
addpath(fullfile('..','Other software'))
addpath(fullfile('..','Other software','Hadamard matrices'))

% the saveastiff package is used to read tif files. It can be downloaded
% from https://www.mathworks.com/matlabcentral/fileexchange/35684 
addpath('saveastiff') 

% comment for selecting example with full (~15GB) or cropped (~50MB) data
datadir = fullfile('Cropped data');
% datadir = fullfile('Data');

%% 1. - reconstruct functional recording of Hadamard optical sections 

% options
save_images = true;
save_activity_maps = true;
hadamard_recs = true;

if hadamard_recs
    recs = {'ref','had'};
else
    recs = {'ref'};
end

clear opts
opts.overwrite = true;
opts.message = false;

% process calibration data
hadtraces = hadamard_bincode_nopermutation(11)'*2-1;
hadidx = bsxfun(@plus,[6:137 166:297]',300*(0:5));
if ~exist('scorr_11c3','var')
    corrpath = dir(fullfile(datadir,'*scorr_11c3.mat'));
    if ~isempty(corrpath)
        disp(['loading cal from ' fullfile(datadir,corrpath(1).name)])
        load(fullfile(datadir,corrpath(1).name))
    else
        allcals = dir(fullfile(datadir,'*cal*RCaMP_Had11c3'));
        allcals = {allcals.name}';
        for it = 1:numel(allcals)
            disp(fullfile(datadir,allcals{it}))
            clear mov
            mov = vm(fullfile(datadir,allcals{it}),hadidx(:));
            mov = reshape(mov.data,mov.rows,mov.cols,12,[]);
            mov = vm(mean(mov,4)) - 100;
            switch it
                case 1
                    m_11c3 = mov;
                otherwise
                    m_11c3 = m_11c3 + mov;
            end
        end
        clear mov 
        ccorr = m_11c3*hadtraces;
        clear m_11c3
        ccorr = (ccorr)./(imgaussfilt(max(abs(ccorr)),1.5));    
        m = whos('ccorr');
        [~, systemview] = memory;
        if systemview.PhysicalMemory.Available < m.bytes*16
            error 'Not enough memory for calibration'
        end
        ccorr = ccorr.blur(1).imresize(4,'bilinear');
        ccorr = cat(3,ccorr,-1.*ccorr);
        [~,ind] = max(ccorr.data,[],3);
        clear ccorr
        rpattern = ones(size(ind));
        rpattern(ind>size(hadtraces,2)) = -1;
        ind(ind>size(hadtraces,2)) = ind(ind>size(hadtraces,2)) - size(hadtraces,2);
        sind = sparse(1:numel(ind),ind,rpattern);
        vmind = vm(full(sind),size(ind));
        clear ind sind % rpattern
        scorr_11c3 = vmind.imresize(.25,'bilinear').blur(.5);
        clear vmind
        prefix = [datestr(now,'HHMMSS') '_'];
        save(fullfile(datadir,[prefix 'scorr_11c3.mat']),'scorr_11c3','allcals','rpattern','-v7.3')
    end
    figure windowstyle docked
    imshow(std(scorr_11c3),[])
    title 'Standard deviation of calibration data'
end

% reconstruct Hadamard optical sections
pd = dir([datadir '\*Had11c3']);
pd = pd(cell2mat({pd.isdir}));
pd = pd(arrayfun(@(x)isempty(strfind(x.name,'.')),pd));
pd = pd(arrayfun(@(x)isempty(strfind(x.name,'..')),pd));
pd = pd(arrayfun(@(x)isempty(strfind(x.name,'Temp')),pd));
pd = pd(arrayfun(@(x)isempty(strfind(x.name,'cal')),pd));
[d,ix] = sort(arrayfun(@(x)x.datenum,pd));
for sel = 1:numel(ix)
    avoidname = fullfile(datadir,pd(ix(sel)).name,'rec_ref.tif');
    if exist(avoidname,'file')
        disp(['skip ' avoidname])
        continue
    end
    rname = fullfile(datadir,pd(ix(sel)).name,'rec_had.tif');
    if exist(rname,'file')
        fprintf('loading recs from %s ...\n',rname)
        clear ref
        ref = vm(loadtiff(fullfile(datadir,pd(ix(sel)).name,'rec_ref.tif')));
        clear had
        had = vm(loadtiff(fullfile(datadir,pd(ix(sel)).name,'rec_had.tif')));
    else
        binname = fullfile(datadir,pd(ix(sel)).name,'Sq_camera.bin');
        dcimgname = fullfile(datadir,pd(ix(sel)).name,'Sq_camera.dcimg');
        if ~exist(binname,'file')
            continue
        end
        if exist(dcimgname,'file')
            continue
        end
        disp(pd(ix(sel)).name)
        clear mov
        mov = vm(fullfile(datadir,pd(ix(sel)).name),hadidx(:));
        ref = vm(squeeze(mean(reshape(mov.data,mov.rows,mov.cols,12,[]),3)));
        ref = ref.correct_blank_marker - 100;
        nframes = ref.frames;
        if hadamard_recs
            had = zeros(ref.rows,ref.cols,nframes);
            cal11 = blur(scorr_11c3*hadtraces',2);
            my_loop_tic = tls;
            for it = 1:nframes
                tdata = mov((1:12)+(it-1)*12).correct_blank_marker - 100;
                had(:,:,it) = sum(tdata.blur(.5).*cal11)*2;
                tlp(it/nframes,my_loop_tic);
            end
            tle(my_loop_tic);
            had = vm(had);
            clear mov
        end
        tic
        fprintf('saving %s ...\n',rname)
        refq = uint16(ref.data);
		saveastiff(refq,fullfile(datadir,pd(ix(sel)).name,'rec_ref.tif'),opts);
        if any(refq(:) == intmax('uint16'))
            imwrite(1,fullfile(datadir,pd(ix(sel)).name,'rec_ref.saturated.tif'))
            system(sprintf('move "%s" "%s"',...
                fullfile(datadir,pd(ix(sel)).name,'rec_ref.saturated.tif'),...
                fullfile(datadir,pd(ix(sel)).name,'rec_ref.saturated')));
        end
        disp(['saving took ' num2str(toc) ' s']);
        if hadamard_recs
            hadq = uint16(had.data);
            saveastiff(hadq,fullfile(datadir,pd(ix(sel)).name,'rec_had.tif'),opts);
            if any(hadq(:) == intmax('uint16'))
                imwrite(1,fullfile(datadir,pd(ix(sel)).name,'rec_had.saturated.tif'))
                system(sprintf('move "%s" "%s"',...
                    fullfile(datadir,pd(ix(sel)).name,'rec_had.saturated.tif'),...
                    fullfile(datadir,pd(ix(sel)).name,'rec_had.saturated')));
            end
        end
        clear refq hadq
    end
    if hadamard_recs
        hadmean = mean(had);
        hadvar = var(had);
    end
    if save_images
        for it = 1:numel(recs)
            try
                disp(['saving ' recs{it} ' mean and var ...'])
                evalc(['mmm = ' recs{it} ';']);
                saveastiff(single(mean(mmm)),   fullfile(datadir,pd(ix(sel)).name,[recs{it} '_mean.tif']),opts);
                saveastiff(single(var(mmm)),    fullfile(datadir,pd(ix(sel)).name,[recs{it} '_var.tif']),opts);
            catch me
                warning(getReport(me,'extended','hyperlinks','on'))
            end
        end
        stimidx = bsxfun(@plus,[139:164]',300*(0:5));
        stimmov = (vm(fullfile(datadir,pd(ix(sel)).name),stimidx(:)));
        disp 'saving stimulus pattern ...'
        saveastiff(single(mean(stimmov)),   fullfile(datadir,pd(ix(sel)).name,'stim_all_mean.tif'),opts);
    end

    if save_activity_maps
        for it = 1:numel(recs)
            try
                disp(['saving ' recs{it} ' activity maps ...'])
                evalc(['mmm = ' recs{it} ';']);
                mmm = vm(squeeze(mean(reshape(mmm.data,mmm.cols,mmm.rows,mmm.frames/12,12),3)));
                saveastiff(single(mmm.data),   fullfile(datadir,pd(ix(sel)).name,['pre_post_' recs{it} '.tif']),opts);
                mmm = mmm(2:2:end) - mmm(1:2:end);
                saveastiff(single(mmm.data),   fullfile(datadir,pd(ix(sel)).name,['pre_post_df' recs{it} '.tif']),opts);
                on_all = mean(mmm);
                saveastiff(single(on_all),fullfile(datadir,pd(ix(sel)).name,['on_all_' recs{it} '.tif']),opts);
            catch me
                warning(getReport(me,'extended','hyperlinks','on'))
            end
        end
    end
end

%% 2. - find peaks 

% read hadamard images
% loads from a series of functional recordings, only one in this example
sliceID = 'S3A';
sliceDirs = dir(fullfile(datadir,['*_' sliceID '*Had11c3']));
sliceDirs = sort({sliceDirs.name})';

% load 12-frame intensity values. if loading registered image file fails, load unregistered one
allRunsRawImgs = vm([]);
for it = 1:numel(sliceDirs)
    allRunsRawImgs((it-1)*12+(1:12)) = vm(fullfile(datadir,sliceDirs{it},'pre_post_had.tif'));
end

% load widefield images from each run to check movement artifacts or to normalize hadamard noise
allRunsRefMean = vm([]);
for it = 1:numel(sliceDirs)
    allRunsRefMean(it) = vm(fullfile(datadir,sliceDirs{it},'ref_mean.tif'));
end

% define reference image for peak finding
% hadamard DF normalized by sqrt of blurred widefield 
mov_sum_df = blnfun(allRunsRawImgs(2:2:end)-allRunsRawImgs(1:2:end),@mean,6);
img_ref_sum_f = mean(allRunsRefMean.blur(8)+100);
img_had_sum_df = mean(mov_sum_df);
img_df_norm = imgaussfilt(img_had_sum_df./sqrt(img_ref_sum_f),.5);
img_df_norm([1 end],:) = 0;
img_df_norm(:,[1 end]) = 0;

figure windowstyle docked
imshow(imsat(img_df_norm,99.9))
title 'Reference for peak finding'

clear mov_sum_df img_ref_sum_f

% find peaks
mindistance = 4;
minamp = 2;
foundPeakMaskImg = findalllocs(img_df_norm,mindistance,minamp);
fprintf('found %5d peaks.\n',nnz(foundPeakMaskImg));

% show peaks mask
figure windowstyle docked
imshow(imdilate(foundPeakMaskImg,ones(3)))
title 'Mask of found peaks'

% show peaks
figure windowstyle docked
imagesc(imsat(img_had_sum_df,99.9,true))
axis tight
colormap gray
hold on
[rr, cc] = find(foundPeakMaskImg);
plot(cc,rr,'o')
axis equal
title 'Location of found peaks'

%% 3. - plot heatmap with single cells

% read Hadamard optical section functional recording
mov = vm(fullfile(datadir,sliceDirs{end},'rec_had.tif'));

% to redefine striatum roi, clear and remove roi_striatum file
if ~exist('roi_striatum','var') && isempty(strfind(lower(datadir),'cropped'))
    roipath = dir(fullfile(datadir,'*_roi_striatum.mat'));
    if ~isempty(roipath)
        disp(['loading striatum roi from ' fullfile(datadir,roipath(1).name)])
        load(fullfile(datadir,roipath(1).name))
    else
        roi_striatum = roipoly(foundPeakMaskImg);
        prefix = [datestr(now,'HHMMSS') '_'];
        save(fullfile(datadir,[prefix 'roi_striatum.mat']),'roi_striatum')
    end
end

% sort into striatum vs cortex
bmov = mov.blur(1);
if ~isempty(strfind(lower(datadir),'cropped'))
    intens = double(bmov(~~foundPeakMaskImg,:))';
else
    intensityStriatum = double(bmov(roi_striatum & foundPeakMaskImg,:))';
    intensityCortex = double(bmov(~roi_striatum & foundPeakMaskImg,:))';
    intens = [intensityStriatum intensityCortex];
end
dFintens = ((intens - mean(intens))./std(intens))';

% show heatmap
figure windowstyle docked; 
imagesc(mat2gray(dFintens, [-2.5 3.5]))
colormap jet
h = colorbar;
g = ylabel(h, 'Normalized calcium fluorescence');
set(h,'YTick',[0 1],'YTickLabel',{'-2.5', '3.5'})
set(g,'Rotation',270)
set(g,'Position',get(g,'Position') + [1 0 0])
set(gca,'FontName','Helvetica','FontSize',14); 
ylabel('Cell ID');
set(gca,'YTick',[1 size(dFintens,1)])
set(gca,'XTick',[])
colormap jet
