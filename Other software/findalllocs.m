function [locmask] = findalllocs(img,mindistance,minamp)
%	Finds 2D peaks at least mindistance apart, and taller than minamp.
%	Works well with low noise images of peaks with no background. 
% 
%   2016 Vicente Parot
%   Cohen Lab - Harvard University
%
%% FindPeaks
% find all the peaks
th0 = 0;
d1 = -conv2(img,[1 0 0; 0 -1 0; 0 0 0],'same');
d2 = -conv2(img,[0 1 0; 0 -1 0; 0 0 0],'same');
d3 = -conv2(img,[0 0 1; 0 -1 0; 0 0 0],'same');
d4 = -conv2(img,[0 0 0; 1 -1 0; 0 0 0],'same');
d6 = -conv2(img,[0 0 0; 0 -1 1; 0 0 0],'same');
d7 = -conv2(img,[0 0 0; 0 -1 0; 1 0 0],'same');
d8 = -conv2(img,[0 0 0; 0 -1 0; 0 1 0],'same');
d9 = -conv2(img,[0 0 0; 0 -1 0; 0 0 1],'same');
locmask = d1>=th0 & d2>=th0 & d3>=th0 & d4>=th0 & d6>=th0 & d7>=th0 & d8>=th0 & d9>=th0;
% remove all peaks lower than threshold
locmask(img < minamp) = false;
%% MinPeakDist
% remove peaks that are too close to a nearby higher peak
tp8 = locmask;
it = 0;
tfp8 = find(tp8);
[tfp8r, tfp8c] = find(tp8);
[~, tix] = sort(img(tp8),'descend');
while true
    it = it + 1;
    if numel(tix) < it
        break
    end
    tooclose = find(sqrt((tfp8r(tix(it)) - tfp8r).^2 + (tfp8c(tix(it)) - tfp8c).^2) < mindistance);
    if numel(tooclose) > 1
        sd1 = setdiff(tooclose,tix(it));
        tp8(tfp8(sd1)) = false;
        sd2 = setdiff(1:numel(tfp8),sd1);
        tfp8 = tfp8(sd2);
        tfp8r = tfp8r(sd2); 
        tfp8c = tfp8c(sd2); 
        [~, tix] = sort(img(tp8),'descend');
    end
end
locmask = tp8;
end
