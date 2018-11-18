function img = imsat(img,p,same_values)
%imsat   Adjust image contrast. 
%
%   img = imsat(img) scales the values of img to the interval (0,1)
%
%   img = imsat(img,p) scales the saturated values of img to the interval
%   (0,1). p indicates the percentile at which values are clipped, p with
%   two elements indicate lower and upper percentiles, while 1 element sets
%   the upper percentile and lower percentile is set to 0.
%
%   img = imsat(img,p,true) saturates the values at the indicated
%   percentiles but with no scaling to the interval (0,1), keeping the
%   original values instead.
%
% 
%   2016-2017 Vicente Parot
%   Cohen Lab - Harvard University

if ~exist('same_values','var')
    same_values = false;
end
if ~exist('p','var')
    p = 100;
end
switch numel(p)
    case 1 % low saturation is at value 0
        losat = 0;
        hisat = prctile(img(:),p);
    case 2 % low saturation is at percentile p(1)
        losat = prctile(img(:),p(1));
        hisat = prctile(img(:),p(2));
    otherwise
        error 'p must have 1 or 2 elements'
end
if same_values
    img = min(max(img,losat),hisat);
else
    img = img - losat;
    if hisat - losat
        img = img./(hisat - losat);
        img = max(0,img);
        img = min(1,img);
    end
end
