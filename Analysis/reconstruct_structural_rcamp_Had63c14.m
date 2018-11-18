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
recdir = 'R:\rec\';
calroot =  cd;
% calroot =  'R:';
hadtraces = hadamard_bincode_nopermutation(63)'*2-1;
if ~exist('scorr_561_rcamp_63c14','var')
    corrpath = dir(fullfile(calroot,'*scorr_561_rcamp_63c14.mat'));
    if ~isempty(corrpath)
        disp(['loading cal from ' fullfile(calroot,corrpath(1).name)])
        load(fullfile(calroot,corrpath(1).name))
    else
        allcals = dir(fullfile(calroot,'*RCaMP_Had63c14'));
        allcals = {allcals.name}';
%         allcals = {
%             '112351_cal_RCaMP_Had63c14'
%             '112417_cal_RCaMP_Had63c14'
%             '112451_cal_RCaMP_Had63c14'
%             '112547_cal_RCaMP_Had63c14'
%             };
        for it = 1:numel(allcals)
            disp(fullfile(calroot,allcals{it}))
            mfull = vm(fullfile(calroot,allcals{it}),2:65);
            mfull = vm(mean(reshape(mfull.data,mfull.rows,mfull.cols,64,[]),4)) - 100;
            switch it
                case 1
                    m_561_63c14 =     mfull; %%% !!! $$$ ~_~
                otherwise
                    m_561_63c14 = m_561_63c14 + mfull;
            end
        end

        clear mfull
        ccorr = m_561_63c14*hadtraces;
        clear m_561_63c14;
        ccorr = (ccorr)./(imgaussfilt(max(abs(ccorr)),2));    
        m = whos('ccorr');
        [userview, systemview] = memory;
        if systemview.PhysicalMemory.Available < m.bytes*16
            error 'not enough memory for Had63c14 calibration'
        end
        ccorr = ccorr.blur(2).imresize(2,'bilinear');
        ccorr = cat(3,ccorr,-1.*ccorr);
        [~,ind] = max(ccorr.data,[],3);
        clear ccorr
        rpattern = ones(size(ind));
        rpattern(ind>size(hadtraces,2)) = -1;
        ind(ind>size(hadtraces,2)) = ind(ind>size(hadtraces,2)) - size(hadtraces,2);
        sind = sparse(1:numel(ind),ind,rpattern);
        vmind = vm(full(sind),size(ind));
        clear ind sind mvals
        scorr_561_rcamp_63c14 = vmind.imresize(.5,'bilinear').blur(.5);
        clear vmind
        scorr_561_rcamp_63c14 = scorr_561_rcamp_63c14*hadtraces';

        prefix = [datestr(now,'HHMMSS') '_'];
        save(fullfile(calroot,[prefix 'scorr_561_rcamp_63c14.mat']),'scorr_561_rcamp_63c14','allcals','rpattern','-v7.3')
    end
    figure windowstyle docked        
    imshow(scorr_561_rcamp_63c14.std,[])
end

if ~exist('mov','var')
%     p = cd;
    p = 'R:\';
%     p = 'X:\Lab\Labmembers\Vicente Parot\Data\2017-04-05 CaP55 clipped rbp4\';
%     p = 'D:\Data\Vicente\2017-01-09 zfish embryos\200000 embryo zstack 561 RCaMP';
    pd = dir([p '\*RCaMP_had-str-rcamp*Had63c14']);
    pd = pd(cell2mat({pd.isdir}));
    pd = pd(arrayfun(@(x)~isequal(x.name,'.'),pd));
    pd = pd(arrayfun(@(x)~isequal(x.name,'..'),pd));
    [d,ix] = sort(arrayfun(@(x)x.datenum,pd));
    for sel = 1:numel(ix) % ix(end); % 
        pname = fullfile(p,pd(ix(sel)).name,'Sq_camera.bin');
        dcname = fullfile(p,pd(ix(sel)).name,'Sq_camera.dcimg');
        recname = fullfile(p,pd(ix(sel)).name,'had.tif');
        if ~exist(pname,'file')
            continue
        end
        if exist(dcname,'file')
            continue
        end
%         if exist(recname,'file')
%             continue
%         end
        disp(pd(ix(sel)).name)
        mov = vm(fullfile(p,pd(ix(sel)).name));
        mov = mov(2:end-1).correct_blank_marker-100;
        ref = mean(mov);
        saveastiff(single(ref),fullfile(p,pd(ix(sel)).name,'ref.tif'));
%         had = mean(mov.*scorr_561_rcamp_63c14.blur(1))*2;
        had = mean(mov.*scorr_561_rcamp_63c14.ffzpad(mov.imsz).blur(1))*2;
%         had = imnotchfilt(had,.354,.03,2);
        saveastiff(single(had),fullfile(p,pd(ix(sel)).name,'had.tif'));

        if ~exist(recdir,'dir'), mkdir(recdir); end
%         system(sprintf('move "%s" "%s"',fullfile(p,pd(ix(sel)).name),fullfile(recdir,pd(ix(sel)).name)));
        movefile(fullfile(p,pd(ix(sel)).name),fullfile(recdir,pd(ix(sel)).name));
        mkdir(fullfile(recdir,pd(ix(sel)).name,'canmove'))
    end
end
clear mov ref had