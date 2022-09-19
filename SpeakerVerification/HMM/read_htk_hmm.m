function hmms = read_htk_hmm(filename)
% hmm = read_htk_hmm(filename)
%
% Reads in an HTK HMM definition file.  Only works on text files.
% At the moment this only works for Gaussian emissions with
% diagonal covariance.
%
% 2006-06-09 ronw@ee.columbia.edu

% Copyright (C) 2006-2007 Ron J. Weiss
% Modified by Hossein Zeinali.
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Read the M-file into a cell array of strings: 
[fid, message] = fopen(filename, 'rt');
warning(message)
file = textscan(fid, '%s', 'delimiter', '\n', 'whitespace', '', 'bufSize', 16000);
fclose(fid);

file = file{1};
% Remove any empty lines
file = file(cellfun('length', file) > 0);

nhmms = 1;
x = 1;
while (x < length(file))
    % header stuff:
    %tok = regexpi(file{x}, '<VECSIZE> %d', 'tokens');
    %if ~isempty(tok)
    %  vecsize = tok{1}
    %end

    % is this a new HMM?
    if length(file{x}) >= 2 && (strncmp(file{x}, '~h', 2) || strncmpi(file{x}, '<BEGINHMM>', 10))
        [hmms{nhmms, 1}, x] = readNextHMM(file, x); %#ok<AGROW>
        nhmms = nhmms + 1;
    else
        x = x + 1;
    end
end

function [hmm, linenum] = readNextHMM(file, linenum)

x = linenum;
if ~isempty(strfind(file{x}, '~h'))
    c = textscan(file{linenum}, '~h %q');
    hmm.name = c{1}{1};
    x = x + 1;
else
    hmm.name = 'matlabhmm';
end

x = x + 1;
% first and last state in 
hmm.nstates = textscan(upper(file{x}), '<NUMSTATES> %d');
hmm.nstates = hmm.nstates{1} - 2;

x = x + 1;
while isempty(strfind(upper(file{x}),'<TRANSP>'))
    state = textscan(upper(file{x}), '<STATE> %d'); state = state{1} - 1;
    x = x + 1;

    if ~isempty(strfind(upper(file{x}), '<NUMMIXES>'))
        nmix = textscan(upper(file{x}), '<NUMMIXES> %d'); nmix = nmix{1};
        x = x + 1;

        hmm.gmms(state).nmix = nmix;
        hmm.gmms(state).priors(1:nmix) = -Inf;
    else
        nmix = 1;
    end 

    for n = 1 : nmix
        if ~isempty(strfind(file{x}, '~s "'))
            x = x + 1;
            break;
        end

        if nmix > 1
            if isempty(strfind(upper(file{x}), '<MIXTURE>'))
                % sometimes HTK skips mixture components.  If we make sure
                % that is a prior of -Inf, then it won't be a problem.
                % Luckilly this is take care of in the initialization above.
                continue;
            end

            temp = textscan(upper(file{x}), '<MIXTURE> %d %f');
            currmix = temp{1}; prior = temp{2};
            x = x + 1;
        end

        ndim = textscan(upper(file{x}), '<MEAN> %d'); ndim = ndim{1};
        x = x + 1;

        if n == 1 && nmix > 1
            hmm.gmms(state).means(1:ndim, 1:nmix) = 0;
            hmm.gmms(state).covars(1:ndim, 1:nmix) = 1;
        end

        mu = textscan(file{x}, '%f', ndim); mu = mu{1};
        x = x + 1;

        ndim = textscan(upper(file{x}), '<VARIANCE> %d'); ndim = ndim{1};
        x = x + 1;
        covar = textscan(file{x}, '%f', ndim); covar = covar{1};
        x = x + 1;

        if ~isempty(strfind(upper(file{x}), '<GCONST>'))
            gconst = textscan(upper(file{x}), '<GCONST> %f'); gconst = gconst{1};
            x = x + 1;
        end

        if nmix == 1
            % Gaussian emissions
            hmm.emission_type = 'gaussian';
            hmm.means(:, state) = mu;
            hmm.covars(:, state) = covar;
            hmm.gconst(state) = gconst;
        else 
            % GMM emissions
            hmm.emission_type = 'GMM';
            hmm.gmms(state).priors(currmix) = log(prior);
            hmm.gmms(state).nmix = nmix;
            hmm.gmms(state).means(:, currmix) = mu;
            hmm.gmms(state).covars(:, currmix) = covar;
            hmm.gmms(state).gconst(currmix) = gconst;
        end
    end
end  

nstates = textscan(upper(file{x}), '<TRANSP> %d'); nstates = nstates{1};
x = x + 1;

transmat = zeros(nstates);
for n = 1 : nstates
    temp = textscan(file{x}, '%f', nstates);
    transmat(n, :) = temp{1};
    x = x + 1;
end
linenum = x;
w = warning('query', 'MATLAB:log:logOfZero');
if strcmp(w.state, 'on')
    warning('off', 'MATLAB:log:logOfZero');
end
hmm.start_prob = log(transmat(1, 2 : end - 1));
hmm.transmat = log(transmat(2 : end - 1, 2 : end - 1));
hmm.end_prob = log(transmat(2 : end - 1, end));
warning(w.state, w.identifier);
