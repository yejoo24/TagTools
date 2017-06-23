function [block_acf] = block_acf(resids, blocks, max_lag, make_plot)
% Compute autocorrelation function, respecting grouping by a categorical variable
%   
% This function allows calculation of an ACF for a dataset with multiple 
%    independent units (for example, data from several individuals, data 
%    from multiple dives by an individual animal, etc.). The groups 
%    (individual, dive, etc.) should be coded in a categorical variable. 
%    The function calculates correlation coefficients over all levels of 
%    the categorical variable, but respecting divisions between levels 
%    (for example, individual animals are kept separate).
%
% Inputs:
%    resids: The variable for which the ACF is to be computed (often a 
%            vector of residuals from a fitted model)
%    blocks: A categorical variable indicating the groupings (must be the 
%            same length as resids. ACF will be computed only for data 
%            points within the same block.)
%    max_lag: ACF will be computed at 0-max_lag lags, ignoring all 
%             observations that span blocks. Defaults to the minimum number 
%             of observations in any block. The function will allow you to 
%             specify a max_lag longer than the shortest block if you so choose.
%   make_plot: Logical. Should a plot be produced? Defaults to TRUE.

blocks = as.factor(blocks);

if length(blocks) ~= length(resids)
    warning("blocks and resids must be the same length.")
end

if ismissing(max_lag)
    y = zeros(size(unique(blocks)));
    uniqueX = unique(blocks);
    for i = 1:length(uniqueX)
        y(i) = sum(blocks==uniqueX(i));
    end
    max_lag = min(y);
end
    
%get indices of last element of each block (excluding the last block)
i1 = cumsum(sort(y));
r = resids;
block_acf = ones(max_lag + 1, 1);

for k = 1:max_lag
    for b = 1:length(i1)
        r = append(r, NA, i1(b));
    end
    %adjust for the growing r
    %%%%%%%%%%%%%%%%%%%%%%%%i1 = i1 + utils::head(c(0:(-1 + nlevels(blocks))), -1)
    %%%%%%%%%%%%%%%%%%%%%%%%rmmissing(r)
    this_acf = autocorr(r, max_lag);
    block_acf(k + 1) = this_acf(k + 1, 1, 1);
end

if ismissing(make_plot) || make_plot == TRUE
    %get an acf object in which the block_acf results will be inserted. Facilitates plotting.
    A = autocorr(resids, max_lag);
    %insert coefficients from block_acf into A
    A(:, 1, 1] = block_acf;
    %plot block_acf
    plot(A)
end