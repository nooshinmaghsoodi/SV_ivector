function [delta, psi] = viterbi(hmm, state_log_likelihood)
LZERO = -1.0e10;
number_of_frames = size(state_log_likelihood, 2);
nstates = hmm.nstates;
delta = LZERO * ones(nstates, number_of_frames);
psi = ones(nstates, number_of_frames);
transProb = hmm.transmat;
transProb(isinf(transProb)) = LZERO;
% initialization
delta(1, 1) = state_log_likelihood(1, 1);
% recursion
for i = 2 : number_of_frames
    for j = 1 : nstates
        maxProb = delta(1, i - 1) + transProb(1, j);
        maxProbIndex = 1;
        for k = 2 : nstates
            prob = delta(k, i - 1) + transProb(k, j);
            if (prob > maxProb)
                maxProb = prob;
                maxProbIndex = k;
            end
        end
        delta(j, i) = maxProb + state_log_likelihood(j, i);
        psi(j, i) = maxProbIndex;
    end
end