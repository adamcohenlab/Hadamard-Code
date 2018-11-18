function had = imnotchfilt(had,offrc,sigmarc,nhar)
%imnotchfilt	Spatial notch filter an image or movie.
% m = imnotchfilt(m, offrc, sigmarc, nhar) cancels the spatial frequency
% content of an image or movie at selected spatial frequencies. offrc is
% the offset or location for the 1st peak in units of cycles per pixel.
% sigmarc (optional if nhar is omitted) determines the width of the
% gaussian peak used for cancellation, and nhar (optional) is the number of
% harmonics at which this peak is repeated.
% 
%   2016 Vicente Parot
%   Cohen Lab - Harvard University
%
%     if ~exist('notch_mask','var')
        [nr, nc, ~] = size(had);
        tr = -2\nr:nr/2-1;
        tc = -2\nc:nc/2-1;
        ur = tr/nr;
        uc = tc/nc;
    %%
    %{
        im = log(abs(fftshift(fft2(had(:,:,1)))));
        imagesc(...
            uc,ur,...
            im)
        axis image
    %}
    %%
        if ~exist('offrc','var') || isempty(offrc)
            offr = .2615;
            offc = offr;
        else
            offr = offrc(1);
            if numel(offrc) > 1
                offc = offrc(2);
            else
                offc = offr;
            end
        end
        if ~exist('sigmarc','var') || isempty(sigmarc)
            sigmarc = .02;
        end
        if ~exist('nhar','var') || isempty(nhar)
            nhar = 3;
        end
    %%
        notch_mask = ones(nr,nc);
        for ir = -nhar:nhar
            for ic = -nhar:nhar
                if ~ir && ~ic
                    continue
                end
                notch_mask = notch_mask .* (1-exp(-bsxfun(@plus,...
                    (ur'-(offr*ir-round(offr*ir))).^2,...
                    (uc -(offc*ic-round(offc*ic))).^2)/sigmarc^2));
            end
        end
%     end
    had2 = abs(ifft2(bsxfun(@times,fft2(had),fftshift(notch_mask))));
    had = had2;
    %
%     imshow(fftshift(log(abs(fft2(had2()-0*mean(mean(had2)))))),[])
%     im = log(abs(fftshift(fft2(had2(:,:,1)))));
%     imagesc(...
%         uc,ur,...
%         im)
%     axis image
%     imshow(notch_mask)

