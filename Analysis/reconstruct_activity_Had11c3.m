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

% while true, reconstruct_activity_Had11c3, pause(.5), end

recdir = 'R:\rec\';

% tissuedir = cd;
tissuedir = 'R:\';
% tissuedir = 'X:\Lab\Labmembers\Vicente Parot\Data\2017-01-18 CaP44 thalamocortical\'

% caldir = 'X:\Lab\Labmembers\Vicente Parot\Data\2017-03-29 CaP55 rbp4 synaptic blockers';
calroot = 'R:'; % 
% caldir = cd;

save_images = true;
save_traces = false;
save_activity_maps = true;
hadamard_recs = true;

if hadamard_recs
    recs = {'ref','had'};
else
    recs = {'ref'};
end

clear opts
opts.overwrite = true;

hadtraces = hadamard_bincode_nopermutation(11)'*2-1;
hadidx = bsxfun(@plus,[6:137 166:297]',300*(0:5));
if ~exist('scorr_11c3','var')
    corrpath = dir(fullfile(calroot,'*scorr_11c3.mat'));
    if ~isempty(corrpath)
        disp(['loading cal from ' fullfile(calroot,corrpath(1).name)])
        load(fullfile(calroot,corrpath(1).name))
    else
        allcals = dir(fullfile(calroot,'*RCaMP_Had11c3'));
        allcals = {allcals.name}';
%         allcals = {
%             '113016_cal_RCaMP_Had11c3'
%             '113206_cal_RCaMP_Had11c3'
%             '113349_cal_RCaMP_Had11c3'
%             };
    %     clf 
    %     hold on
        for it = 1:numel(allcals)
            disp(fullfile(calroot,allcals{it}))
            mov = vm(fullfile(calroot,allcals{it}),hadidx(:));
    %         figure
    %         plot(mean(mov.tovec.data))
    %         drawnow
            mov = reshape(mov.data,mov.rows,mov.cols,12,[]);
            mov = vm(mean(mov,4)) - 100;
            switch it
                case 1
                    m_11c3 =     mov; %%% !!! $$$ ~_~
                otherwise
                    m_11c3 = m_11c3 + mov;
            end
        end
        clear mov 
    %     m_11c3 = m_11c3(:,ceil(end/4+1):ceil(3*end/4),:);
        ccorr = m_11c3*hadtraces;
        clear m_11c3
        ccorr = (ccorr)./(imgaussfilt(max(abs(ccorr)),1.5));    
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
        save(fullfile(calroot,[prefix 'scorr_11c3.mat']),'scorr_11c3','allcals','rpattern','-v7.3')
    %     scorr_11c3 = scorr_11c3(:,ceil(end/4+1):ceil(3*end/4),:);
    end
    figure windowstyle docked
    imshow(scorr_11c3.std,[])
end

%%
pd = dir([tissuedir '\*Had11c3']);
pd = pd(cell2mat({pd.isdir}));
pd = pd(arrayfun(@(x)~isequal(x.name,'.'),pd));
pd = pd(arrayfun(@(x)~isequal(x.name,'..'),pd));
pd = pd(arrayfun(@(x)~isequal(x.name,'Temp'),pd));
[d,ix] = sort(arrayfun(@(x)x.datenum,pd));
for sel = 1:numel(ix) % numel(ix):-1:1 % ix(end) % 
    avoidname = fullfile(tissuedir,pd(ix(sel)).name,'rec_ref.tif');
    if exist(avoidname,'file')
        disp(['skip ' avoidname])
        continue
    end
    rname = fullfile(tissuedir,pd(ix(sel)).name,'rec_had.tif');
    if exist(rname,'file')
        fprintf('loading recs from %s ...\n',rname)
        ref = vm(loadtiff(fullfile(tissuedir,pd(ix(sel)).name,'rec_ref.tif')));
        had = vm(loadtiff(fullfile(tissuedir,pd(ix(sel)).name,'rec_had.tif')));
    else
        binname = fullfile(tissuedir,pd(ix(sel)).name,'Sq_camera.bin');
        dcimgname = fullfile(tissuedir,pd(ix(sel)).name,'Sq_camera.dcimg');
        if ~exist(binname,'file')
            continue
        end
        if exist(dcimgname,'file')
            continue
        end
        disp(pd(ix(sel)).name)
        mov = vm(fullfile(tissuedir,pd(ix(sel)).name),hadidx(:));
        ref = vm(squeeze(mean(reshape(mov.data,mov.rows,mov.cols,12,[]),3)));
        ref = ref.correct_blank_marker - 100;
        nframes = ref.frames;
        if hadamard_recs
            had = zeros(ref.rows,ref.cols,nframes);
            addpath 'X:\Lab\Labmembers\Vicente Parot\Code\2013\2013-10-21 include'
            cal11 = blur(scorr_11c3*hadtraces',2);
%             cal11 = vm(circshift(cal11.data,[4 0]));
            my_loop_tic = tls;
            for it = 1:nframes
                tdata = mov((1:12)+(it-1)*12).correct_blank_marker - 100;
                had(:,:,it) = sum(tdata.blur(.5).*cal11)*2;
%                 %%
%                 imshow(sum(tdata.blur(.5).*vm(circshift(cal11.data,[4 0]))),[]), colorbar
%                 %%
                tlp(it/nframes,my_loop_tic);
            end
            tle(my_loop_tic);
            had = vm(had);
        end
        tic
        fprintf('saving %s ...\n',rname)
        refq = uint16(ref.data);
		saveastiff(refq,fullfile(tissuedir,pd(ix(sel)).name,'rec_ref.tif'),opts);
        if any(refq(:) == intmax('uint16'))
            imwrite(1,fullfile(tissuedir,pd(ix(sel)).name,'rec_ref.saturated.tif'))
            system(sprintf('move "%s" "%s"',...
                fullfile(tissuedir,pd(ix(sel)).name,'rec_ref.saturated.tif'),...
                fullfile(tissuedir,pd(ix(sel)).name,'rec_ref.saturated')));
        end
        disp(['saving took ' num2str(toc) ' s']);
        if hadamard_recs
            hadq = uint16(had.data);
            saveastiff(hadq,fullfile(tissuedir,pd(ix(sel)).name,'rec_had.tif'),opts);
            if any(hadq(:) == intmax('uint16'))
                imwrite(1,fullfile(tissuedir,pd(ix(sel)).name,'rec_had.saturated.tif'))
                system(sprintf('move "%s" "%s"',...
                    fullfile(tissuedir,pd(ix(sel)).name,'rec_had.saturated.tif'),...
                    fullfile(tissuedir,pd(ix(sel)).name,'rec_had.saturated')));
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
                saveastiff(single(mean(mmm)),   fullfile(tissuedir,pd(ix(sel)).name,[recs{it} '_mean.tif']));
                saveastiff(single(var(mmm)),    fullfile(tissuedir,pd(ix(sel)).name,[recs{it} '_var.tif']));
            catch me
                warning(getReport(me,'extended','hyperlinks','on'))
            end
        end
        stimidx = bsxfun(@plus,[139:164]',300*(0:5));
        stimmov = (vm(fullfile(tissuedir,pd(ix(sel)).name),stimidx(:)));
        disp(['saving stimulus pattern ...'])
        saveastiff(single(mean(stimmov)),   fullfile(tissuedir,pd(ix(sel)).name,'stim_all_mean.tif'),opts);
    end

    if save_activity_maps
        for it = 1:numel(recs)
            try
                disp(['saving ' recs{it} ' activity maps ...'])
%%
                evalc(['mmm = ' recs{it} ';']);
                mmm = vm(squeeze(mean(reshape(mmm.data,mmm.cols,mmm.rows,mmm.frames/12,12),3)));
                saveastiff(single(mmm.data),   fullfile(tissuedir,pd(ix(sel)).name,['pre_post_' recs{it} '.tif']),opts);
                mmm = mmm(2:2:end) - mmm(1:2:end);
                saveastiff(single(mmm.data),   fullfile(tissuedir,pd(ix(sel)).name,['pre_post_df' recs{it} '.tif']),opts);
                on_all = mean(mmm);
%                 on_2 = mean(mmm([2 5]));
%                 on_3 = mean(mmm([3 6]));
%                 imga = imsat(onspotbg,99.9);
%                 imgb = imsat(onspot+onbg ,99.9);
%                 imgspotbg = imblend(imga,imgb);
% %                 imshow(imgspotbg)
%                 imwrite(imgspotbg,fullfile(p,pd(ix(sel)).name,['map_spotbg_df_' recs{it} '.tif']))
                saveastiff(single(on_all),fullfile(tissuedir,pd(ix(sel)).name,['on_all_' recs{it} '.tif']),opts);
%                 saveastiff(single(on_2),fullfile(tissuedir,pd(ix(sel)).name,['on_2_' recs{it} '.tif']),opts);
%                 saveastiff(single(on_3),fullfile(tissuedir,pd(ix(sel)).name,['on_3_' recs{it} '.tif']),opts);

                disp(['saving ' recs{it} ' corr_clicky ...'])
                evalc(['mmm = ' recs{it} ';']);
                mindistance = 5;
                maxpeaks = 10;
                roiradius = 2;
                img = imtophat(imgaussfilt(on_all,1),strel('disk',15));
                [~, rois1] = findpeaks2D(img,mindistance,maxpeaks,roiradius);
%                 img = imtophat(imgaussfilt(on_2,1),strel('disk',15));
%                 [~, rois2] = findpeaks2D(img,mindistance,maxpeaks,roiradius);
%                 img = imtophat(imgaussfilt(on_3,1),strel('disk',15));
%                 [~, rois3] = findpeaks2D(img,mindistance,maxpeaks,roiradius);
                intens = apply_clicky_faster(eval(recs{it}),[rois1]);
                title([strrep(pd(ix(sel)).name,'_','\_') ' ' recs{it}])
                drawnow
                saveas(gcf,fullfile(tissuedir,pd(ix(sel)).name,['corr_clicky_' recs{it} '.fig']))
            catch me
                warning(getReport(me,'extended','hyperlinks','on'))
            end
        end
    end
    
    if save_traces && hadamard_recs
        clicky_rois_img = imgaussfilt(had.blur(1).var./(ref.blur(1.5).mean+100),.5);
        mindistance = 20;
        maxpeaks = 30;
        roiradius = 2;
        img = imtophat(clicky_rois_img,strel('disk',15));
        [~, rois] = findpeaks2D(img,mindistance,maxpeaks,roiradius);
        for it = 1:numel(recs)
            try
                disp(['saving ' recs{it} ' auto_clicky ...'])
                evalc(['mmm = ' recs{it} ';']);
                intens = apply_clicky(mmm,rois);
                title([strrep(pd(ix(sel)).name,'_','\_') ' ' recs{it}])
                drawnow
                saveas(gcf,fullfile(tissuedir,pd(ix(sel)).name,['auto_clicky_' recs{it} '.fig']))
            catch me
                warning(getReport(me,'extended','hyperlinks','on'))
            end
        end
    end
    if ~exist(recdir,'dir'), mkdir(recdir); end
    movefile(fullfile(tissuedir,pd(ix(sel)).name),fullfile(recdir,pd(ix(sel)).name));
    mkdir(fullfile(recdir,pd(ix(sel)).name,'canmove'))
    disp 'done. moved to recdir.' 
end
% disp(pd(ix(sel)).name)
% disp done
% pause(.5)
