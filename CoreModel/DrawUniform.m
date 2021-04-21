function uni = DrawUniform(range,n)

if ~exist('n','var') == 1
    n = 1;
end

uni = random('unif',range(1),range(2),[1,n]);

end

