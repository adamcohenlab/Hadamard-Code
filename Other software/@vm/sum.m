% Sum along frame dimension
%
% vm: Vectorized movie class
%
% 2016-2017 Vicente Parot
% Cohen Lab - Harvard University
%
        function img = sum(obj)
            img = sum(obj.data,3);
        end
