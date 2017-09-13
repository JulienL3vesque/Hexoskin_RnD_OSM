function [  ] = SendEmail( UserEmail,Password,EmailTo,Subject,Content )
% This function sends an email

setpref('Internet','E_mail',UserEmail);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',UserEmail);
setpref('Internet','SMTP_Password',Password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', ...
                  'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');
sendmail(EmailTo, Subject, Content);

end

