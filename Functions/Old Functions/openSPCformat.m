%% 
filename = ['/Users/Kevin/Google Drive/Linkoping/Master Thesis/Data/Raman/x946_xx20/' ... 
    'x946_xx20Ra_c-1.spc'];
filename3 = ['/Users/Kevin/Documents/OneDrive/Linkoping/Master Thesis/Data/Raman/x946_xx20/' ...
    'x946_xx20Ra_c-1.prn'];
out = tgspcread(filename);
textout = importdata(filename3);
xtext = textout(:,1);
ytext = textout(:,2);
[ xtextraman ] = AngtoRamanShift( 5318,  xtext );
figure(10);clf;
plot(xtextraman',ytext,xtextraman',flipud(out.Y))
legend('text','spc')
%%
out = tgspcread(filename);
yIvan = out.Y;
xIvan = out.X;
figure(1);clf;
plot(xIvan,yIvan,'.',x,y(:,4),'.')
xlim([1205 inf])
legend('Ivan','me')
% 
%% Proof 
% 
% filename2 = ['/Users/Kevin/Google Drive/Linkoping/Master Thesis/Data/Raman/x946_xx20/Subtracted/' ... 
%     '-refx946_xx20Ra_c-_rs2.spc'];
% out2 = tgspcread(filename2);
% y2 = out2.Y;
% figure(2);clf;
% plot(out.X,y2,'.',out.X,flipud(y)-1057,'.')

%%
% fid = fopen(filename,'r','l');
% h = fread(fid);
% % h2 = dec2hex(h);
% fclose(fid)
