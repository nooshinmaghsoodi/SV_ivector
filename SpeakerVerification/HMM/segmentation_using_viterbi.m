function [index, llk] = segmentation_using_viterbi(hmm, state_log_likelihood)
number_of_frames = size(state_log_likelihood, 2);
[delta, psi] = viterbi(hmm, state_log_likelihood);
llk = delta(end, end) / number_of_frames;
nstates = hmm.nstates;
% termination
index = zeros(nstates, 1);
j = nstates;
index(j) = number_of_frames;
j = j - 1;
bt = zeros(1, number_of_frames);
bt(number_of_frames) = nstates;
for i = number_of_frames - 1 : -1 : 1
    bt(i) = psi(bt(i + 1), i);
    if (j > 0 && bt(i + 1) == j)
        index(j) = i;
        j = j - 1;
    end
end
for i = nstates : -1 : 2
    index(i) = index(i) - index(i - 1);
end