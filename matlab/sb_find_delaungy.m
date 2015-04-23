function []=sb_find_delaungy(rho_min,ddiff_max,bdiff_max)
%SB_FIND find small baselines
%   SB_FIND(RHO_MIN,DDIFF_MAX,BDIFF_MAX)
%
%   RHO_MIN:   minumum coherence (default=0.50)
%   DDIFF_MAX: time in days for total decorrelation (default=1500)
%   BDIFF_MAX: critical baseline in m (default=1070)
%
%   Andy Hooper, September 2006
%
%   ======================================================================
%   04/2008 AH: Criteria for selection changed to coherence basis 
%   09/2015 DB: Do a delaungy triangulation of the network to generate SB list
%   ======================================================================


if nargin<1
    rho_min=0.5
end

if nargin<2
    ddiff_max=1500
end

if nargin<3
    bdiff_max=1070
end

load psver
psname=['ps',num2str(psver)];
ps=load(psname);




DT = delaunayTriangulation([ps.day ps.bperp]);
temp = [DT.ConnectivityList DT.ConnectivityList(:,1) DT.ConnectivityList(:,2:3)];
dates_ix = unique(reshape(temp',2,[])','rows');
dates_ix(find(dates_ix(:,2)<dates_ix(:,1)),[2 1])=dates_ix(find(dates_ix(:,2)<dates_ix(:,1)),:);
dates_ix = unique(dates_ix,'rows');

ps.day = DT.Points(:,1);
ps.bperp = DT.Points(:,2);

sbname='small_baselines.list';



x=dates_ix(:,1);
y=dates_ix(:,2);

clf

for i=1:length(x)
    l=line([ps.day(x(i)),ps.day(y(i))],[ps.bperp(x(i)),ps.bperp(y(i))]);
    text((ps.day(x(i))+ps.day(y(i)))/2,(ps.bperp(x(i))+ps.bperp(y(i)))/2,num2str(i));
    set(l,'color',[0 1 0],'linewidth',2)
end
hold on
p=plot(ps.day,ps.bperp,'ro');
set(p,'markersize',12,'linewidth',2)
hold off
datetick('x',12)
ylabel('B_{perp}')


h=gcf;
print(h,'-dpng','SB_plot.png')


fid=fopen(sbname,'w');
for i=1:length(x)
    fprintf(fid,'%s %s\n',datestr(ps.day(x(i)),'yyyymmdd'),datestr(ps.day(y(i)),'yyyymmdd'));
end
fclose(fid);

