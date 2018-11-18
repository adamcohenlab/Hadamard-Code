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

% datadir = tdir;
datadir = 'X:\Lab\Labmembers\Vicente Parot\Data\2017-05-11 CaP63 uncut antiepileptics\Functional';
slicefilterlist = {
    '*_S5B*'
    };
movingfnamelist = {
      'rec_had.tif'
%     'pre_post_had.tif'
%     'ref_mean.tif'
%     'had_mean.tif'
    };
registration_reference = 'ref_mean.tif';
clear opts
opts.overwrite = true;
for sliceit = 1:numel(slicefilterlist)
    dirlist = dir(fullfile(datadir,slicefilterlist{sliceit}));
    dirlist = sort({dirlist.name})';
%     dirlist = dirlist([5 1:4 6:end]); % register to 5th folder
%     dirlist = dirlist([1 2 end-1:end]); % uncomment to transform last run only
    fixedrefpath = fullfile(datadir,dirlist{1},registration_reference);
    fixedref = imread(fixedrefpath);
    for dirit = 2:numel(dirlist)
        currdir = dirlist{dirit};
            jt = 1;
            movingfname = movingfnamelist{jt};
            targetfname = [movingfname(1:end-4) '_reg' movingfname(end-3:end)];
            targetpath = fullfile(datadir,currdir,targetfname);
            if exist(targetpath,'file')
                continue
            end
        movingrefpath = fullfile(datadir,currdir,registration_reference);
        movingref = imread(movingrefpath);
        clear elastix_params;
        elastix_params(1).Transform='AffineTransform';
        elastix_params(2).Transform='BSplineTransform';
        disp(['registering ' currdir ' ...'])
        tic
        evalc('[~,elastix_out] = elastix(movingref,fixedref,[],''elastix_hadamard.yml'',''paramstruct'',elastix_params);');
        disp(['registering took ' num2str(toc) ' s']);
        save(fullfile(datadir,currdir,'reg_params.mat'),'fixedrefpath','movingrefpath','elastix_out')
        for jt = 1:numel(movingfnamelist)
            movingfname = movingfnamelist{jt};
            targetfname = [movingfname(1:end-4) '_reg' movingfname(end-3:end)];
            movingpath = fullfile(datadir,currdir,movingfname);
            targetpath = fullfile(datadir,currdir,targetfname);
            disp(['transforming ' currdir filesep movingfname ' ...'])
            movingmov = vm(movingpath);
            thistic = tls;
            for it = 1:movingmov.frames
                evalc('movingmov(it) = transformix(movingmov(it).data,elastix_out);');
                tlp(it/movingmov.frames,thistic)
            end
            tle(thistic);
            fprintf('saving %s ...\n',targetpath)
            tic
            saveastiff(single(movingmov.data),targetpath,opts);
            disp(['saving took ' num2str(toc) ' s']);
        end
    end
end