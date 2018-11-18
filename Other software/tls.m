function t = tls
%TLS    Timed Loop Start.
%   WHICH_LOOP_TIC = TLS returns the start time returned by TIC, to be
%   further used as a timing index by TLP and TLE.
% 
%   Usage:
%     WHICH_LOOP_TIC = TLS;
%     for k = 1:N
%         % k-th iteration computation
%         TLP(k/N,WHICH_LOOP_TIC);
%     end
%     TLE(WHICH_LOOP_TIC);
% 
%   See also TLP, TLE, TIC, TOC.

%   Vicente Parot 2008-2011

global LOOP_TIC
global LOOP_BKSP
global LOOP_LAST_COUNT

LOOP_TIC = [LOOP_TIC;tic];
LOOP_LAST_COUNT = [LOOP_LAST_COUNT;toc(LOOP_TIC(end))];
LOOP_BKSP = [LOOP_BKSP;0];

if nargout>0
    t = LOOP_TIC(end);
end