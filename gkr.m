function ys = gkr(xs, x, y, h)

% Gaussian kernel regression function
kerf=@(z)exp(-z.*z/2)/sqrt(2*pi);


z=kerf((xs-x)/h);
ys=sum(z.*y)/sum(z);

end
