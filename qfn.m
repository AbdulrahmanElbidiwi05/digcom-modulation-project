function y = qfn(x)
% QFN  Gaussian Q-function (no toolbox needed).
y = 0.5 * erfc(x ./ sqrt(2));
end
