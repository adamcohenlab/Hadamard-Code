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

function gather_zstack
    datadir = 'X:\Lab\Labmembers\Vicente Parot\Data\2017-05-11 CaP63 uncut antiepileptics\Structural';
    
    sfix = 'S5B';
    
    pd = dir(fullfile(datadir,sfix,['\*rcamp_' sfix '*_Had63c14']));
    dirlist = sort({pd.name})';
    prefix561 = [dirlist{1}(1:6) '_' sfix '_561'];
    makezstack(fullfile(datadir,sfix),dirlist,prefix561)
    
    pd = dir(fullfile(datadir,sfix,['\*gfp_' sfix '*_Had63c14']));
    dirlist = sort({pd.name})';
    prefix460 = [dirlist{1}(1:6) '_' sfix '_460'];
    makezstack(fullfile(datadir,sfix),dirlist,prefix460)
    
    img_561 = imread(fullfile(fullfile(datadir,sfix),[prefix561 '_had_mip.tif']));
    img_460 = imread(fullfile(fullfile(datadir,sfix),[prefix460 '_had_mip.tif']));
    cimg = imblend(imsat(img_561,99.9),imsat(img_460,99.9));
    imshow(cimg)
    imwrite(double(cimg),fullfile(datadir,[sfix '_had_mip_blend_orange_rcamp_blue_gfp.tif']))
end

function makezstack(rootdir,dirlist,prefix)
    tsize = [imsz(vm(fullfile(rootdir,dirlist{1}),1)) numel(dirlist)];
    ref = zeros(tsize,'single');
    had = zeros(tsize,'single');
    for it = 1:numel(dirlist) % (end);
        itdir = fullfile(rootdir,dirlist{it});
        disp(itdir)
        rname = fullfile(itdir,'ref.tif');
        ref(:,:,it) = imread(rname);
        hname = fullfile(itdir,'had.tif');
        had(:,:,it) = imread(hname);
    end
    % ref = rot90(ref);
    % had = rot90(had);
    ref = vm(ref);
    ref_mip = max(ref);
%     had_mip = imnotchfilt(max(had.blur(.25)),.354,.02,1); % rcamp
    had = vm(imnotchfilt(had,.354,.02,1));
    had_mip = imnotchfilt(max(had),.354,.02,1);
    savetiffstack(vm(ref_mip),  fullfile(rootdir,sprintf('%s_ref_mip.tif',prefix)));
    savetiffstack(ref,          fullfile(rootdir,sprintf('%s_ref_stack.tif',prefix)));
    savetiffstack(vm(had_mip),  fullfile(rootdir,sprintf('%s_had_mip.tif',prefix)));
    savetiffstack(had,          fullfile(rootdir,sprintf('%s_had_stack.tif',prefix)));
end
