% This program constructs a contour plot for the two-bar truss
% constants
pi = 3.14159;
%design variables
d = .0005;  %average limestone particle size after grinding, ft
%other analysis variables
L = 15*5280; %pipeline length, feet
W = 12.67; %flowrate of limestone, lbm/sec
g = 32.17; %gravity, ft/sec^2
rho_w = 62.4; %water density, lbm/ft^3
rho_l = 168.5; %limestone density, lbm/ft^3
mu = 7.392*10^-4; %viscosity of water, lbm/ft-sec
pi = 3.14159;
a = .01; %average lump size, ft 

% design variables at mesh points
[D,V] = meshgrid(10:2:30,1:.3:3);
 
% equations
Q = pi.*D.^2./4.*V; %volumetric slurry flow rate, ft^3/sec 
Ql = W./rho_l; %volumetric limestone flow rate, ft^3/sec
Qw = Q-Ql; %volumetric water flow rate, ft^3/sec
conc = Ql./Q; %concentration
S = rho_l./rho_w; %density of limestone divided by density of water
rho = rho_w + conc.*(rho_l-rho_w); %density of slurry
Rw = rho_w.*V.*D./mu; %Reynolds number of water
if Rw <= 10^5
    fric_w = .3164./Rw.^.25;
end
if Rw >= 10^5
    fric_w = .0032+.221.*Rw.^(-.237);
end %friction factor of water
CdRp2 = 4.*g.*rho_w.*d.^3.*(rho_l-rho_w)./(3.*mu.^2); 
Cd = 549.2.*CdRp2.^(-.9546); %coefficient of drag - R^2 of .9954 using Matlab
fric = fric_w.*(rho_w./rho+150.*conc.*rho_w./rho.*(g.*D.*(S-1)./V.^2./(Cd.^(.5))).^1.5); %slurry friction factor
delta_p = fric.*rho.*L.*V.^2./D./2./g; %change in pressure
Pf = delta_p.*(Qw+Ql)./550; %pump power, Hp
Pg = 218.*Ql.*(1./(d.^(.5))-1/(a.^(.5)))./550; %grinding power, Hp
Vc = (40.*g.*conc.*(S-1).*D./(Cd.^.5)).^.5; %Critical velocity, ft/sec
hrs = 8*300;
power = Pg+Pf
Cost = 300.*Pg+200.*Pf+(.07+.05)*hrs*((1.07^7-1)/.07/(1.07^7));
 
figure(1)
[C,h] = contour(D,V,Cost,12:3:33,'k');
clabel(C,h,'Labelspacing',250);
title('Limestone Pipe Contour Plot');
xlabel('Diameter');
ylabel('Velocity');
hold on;
% solid lines to show constraint boundaries
contour(D,V,(1.1*Vc-V),[0,0],'g-','LineWidth',2);
contour(D,V,(conc-.4),[0,0],'r-','LineWidth',2);

% show a legend
legend('Cost','V<1.1Vc','conc<.4')

