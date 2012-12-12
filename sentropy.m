function [ H ] = sentropy(vec)
% Computes the Shannon entropy of a vector

v = full(vec);

hist = histc(v, unique(v));
hist = hist ./ sum(hist);

H = -sum(hist .* log(hist));

end

