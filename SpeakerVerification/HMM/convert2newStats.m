function [out_N, out_F] = convert2newStats(N, F, ubmModels, statesAlignment, params)
nmix = params.hmmMixtureNum;
nstate = params.hmmStateNum;
stateCounts = 0;
for i = 1 : length(ubmModels)
    stateCounts = stateCounts + ubmModels{i}.nstates;
end
ndim = floor(length(F) / length(N));
out_N = zeros(nmix * stateCounts, 1);
out_F = zeros(ndim * nmix * stateCounts, 1);
for i = 1 : length(statesAlignment)
    ii = statesAlignment(i);
    out_N((ii - 1) * nmix + 1 : ii * nmix) = out_N((ii - 1) * nmix + 1 : ii * nmix)...
        + N((i - 1) * nmix + 1 : i * nmix);
    out_F((ii - 1) * nmix * ndim + 1 : ii * nmix * ndim) = out_F((ii - 1) * nmix * ndim + 1 : ii * nmix * ndim)...
        + F((i - 1) * nmix * ndim + 1 : i * nmix * ndim);
end
sil_idx = (params.silIndex - 1) * nstate * nmix + 1 : params.silIndex * nstate * nmix;
out_N(sil_idx) = [];
sil_idx = (params.silIndex - 1) * nstate * nmix * ndim + 1 : params.silIndex * nstate * nmix * ndim;
out_F(sil_idx) = [];