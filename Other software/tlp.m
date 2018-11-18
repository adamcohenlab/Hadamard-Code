function tlp(compl,WHICH_LOOP_TIC)
%TLP    Timed Loop Progress.
%   PROGRESS is a scalar in the (0,1) interval with the loop progress at
%   the end of one iteration when TLP is called.
%   WHICH_LOOP_TIC is a timing table index returned by TLS just before
%   starting the loop.
%   TLP(PROGRESS,WHICH_LOOP_TIC) prints in one line the caller name and
%   line and in a second line the percentual progress of the loop and the
%   remaining time, estimated by the elapsed time and current progress.
% 
%   Usage:
%     WHICH_LOOP_TIC = TLS;
%     for k = 1:N
%         % k-th iteration computation
%         TLP(k/N,WHICH_LOOP_TIC);
%     end
%     TLE(WHICH_LOOP_TIC);
% 
%   See also TLS, TLE, TIC, TOC.

%   Vicente Parot 2008-2011

global LOOP_TIC
global LOOP_BKSP
global LOOP_LAST_COUNT
if nargin>2
    pos = find(LOOP_TIC==WHICH_LOOP_TIC);
else
    pos = numel(LOOP_TIC);
end
    
if (toc(LOOP_TIC(pos))-LOOP_LAST_COUNT(pos)) > .25 % [s]
    [a,dum] = dbstack();
    if length(a)<2 
        caller_name_line = '?';
    else
        caller_name_line = [a(2).name ', ' num2str(a(2).line)];
    end
    str = [caller_name_line ': ' num2str(floor(compl*100)/1) '% complete' 13 ...
        'remaining time: ' datestr(datenum([0 0 0 0 0 floor(toc(LOOP_TIC(pos))*(1-compl) ...
        /compl)+1]),'dd, HH:MM:SS\n')];
    fprintf('%s',['' 8*ones(1,LOOP_BKSP(pos)) str]);
    drawnow;
    LOOP_BKSP(pos) = numel(str);
    LOOP_LAST_COUNT(pos) = toc(LOOP_TIC(pos));
end
