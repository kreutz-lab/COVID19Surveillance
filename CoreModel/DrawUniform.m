function uni = DrawUniform(range,n)

% uni = DrawUniform(range,n)
%
% Draw n values from a uniform distribution on the interval range.

if ~exist('n','var') == 1
    n = 1;
end

uni = random('unif',range(1),range(2),[1,n]);

end

