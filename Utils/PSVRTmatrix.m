function [RTmatrix] = PSVRTmatrix(p,mi,mt)
%
%    p = ray parameter (a scalar or row vector)
%
%    mi = model of incident    wave [Vp Vs Rho]
%    mt = model of transmitted wave [Vp Vs Rho]
%
%    RTmatrix = [ Rpp' Rps' Rss' Rsp' Tpp' Tps' Tss' Tsp'];
 
% vertical slownesses
etaai = sqrt(1/(mi(1)*mi(1)) - p.*p);
etaat = sqrt(1/(mt(1)*mt(1)) - p.*p);
etabi = sqrt(1/(mi(2)*mi(2)) - p.*p);
etabt = sqrt(1/(mt(2)*mt(2)) - p.*p);
%
a = mt(3)*(1-2*mt(2)*mt(2)*p.*p)-mi(3)*(1-2*mi(2)*mi(2)*p.*p);
b = mt(3)*(1-2*mt(2)*mt(2)*p.*p)+2*mi(3)*mi(2)*mi(2)*p.*p;
c = mi(3)*(1-2*mi(2)*mi(2)*p.*p)+2*mt(3)*mt(2)*mt(2)*p.*p;
d = 2*(mt(3)*mt(2)*mt(2)-mi(3)*mi(2)*mi(2));
%
E = b .* etaai + c .* etaat;
F = b .* etabi + c .* etabt;
G = a - d * etaai .* etabt;
H = a - d * etaat .* etabi;
D = E.*F + G.*H.*p.*p;
%
Rpp = ( (b.*etaai-c.*etaat).*F - (a + d*etaai.*etabt).*H.*p.*p)./D;
Rps = -(2 * etaai .* (a .* b + d * c .* etaat .* etabt) .* p * mi(1)/mi(2) )./D;
Rss = -((b.*etabi-c.*etabt).*E-(a+d.*etaat.*etabi).*G.*p.*p)./D;
Rsp = -(2*etabi.*(a.*b+d*c.*etaat.*etabt).*p*(mi(2)/mi(1)))./D;
Tpp =  (2*mi(3)*etaai.*F*(mi(1)/mt(1)))./D;
Tps =  (2*mi(3)*etaai.*H.*p*(mi(1)/mt(2)))./D;
Tss =   2*mi(3)*etabi.*E*(mi(2)/mt(2))./D;
Tsp =  -2*(mi(3)*etabi.*G.*p*(mi(2)/mt(1)))./D;
%
RTmatrix = [ Rpp' Rps' Rss' Rsp' Tpp' Tps' Tss' Tsp'];
%
