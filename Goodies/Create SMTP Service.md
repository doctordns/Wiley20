# Create an SMTP Service using SendGrid

## Introduction

In testing, it is often useful to be able to send SMTP email.
For example, if you are testing File Server Resource Manager, it is useful to have an email server you can use to test things. 
If you are reading my book, you may want to do this at home.

This article shows how to create an SMTP Forwarder in IIS on Windows that forwards email to Sendgrid.com.

## Why Sendgrid?

Sendgrid.com offers a free SMTP email forwarding service. 
With Sendgrid, you can setup an email forwarder in IIS that forwards to Sendgrid's smart host. 
This way, you can send mail to your local server (eg SRV1), and it forwards to Sendgrid who forwards to your test email inbox.
I have used this to test out FSRM and other things in my internal testing VM farm.

The Sendgrid service is free, although paid accounts are possible if you ARE sending a lot of mail.
Initially you can send a LOT of emails, 40000 for the first 30 days.
Thereafter, you are limited to 100/day.
That limit has proven perfectly usable for me - and I'm using this a third time for a third book.

## How to set it up

Let's assume you have an internal VM farm - mine is Reskit.Org.
You want to setup an SMTP relay server on the WIndows server Host SRV2.
These directions assume you have a DC, with a domain joined member server SRV2.
Also, assume you have nothing else yet loaded on SRV2.

Here is what you do.

### 1. Install the SMTP Service on SRV2

You can use the Install-WIndowsfeature command to install the SMTP Server service, like this:

```powershell
Install-WindowsFeature -Name SMTP-Server -IncludeManagementTools
```

### 2. Ensure that key features were installed

It is always useful to ensure you have the two necessary features loaded, like this:

```powershell
Get-WindowsFeature -Name *SMTP*
```

### 3. Setup A SendGrid Account

With the SMTP Service installed, you next need to get a SendGrid account.
Go to <https://signup.sendgrid.com/> and sign up for a free account.
Note: This does not require a credit card, which is a nice touch.

### 4. Login to Sendgrid

After setting up an account, login to Sendgrid.
Ensure you can login before continuing.

### 5. Setup a Sendkey API

Next, you need to create an API key.
The APIkey serces as a password to your Sendgrid account
After logging on, go to <https://app.sendgrid.com/guide/integrate/langs/smtp>.
From the 'Integrate using our Web API or SMTP relay' page, enter an API Key name then click create key.
The API Name is just an identification so it can contain anythign useful.
For example "SendGrid API key for SRV2.Reskit.Org".
Then Click **Create Key**.

### 6. Copy your APIKey and save it securely

Once you click on **Create Key**, Sendgrid creates your API key and displays it for you.
Copy it to Notepad for safekeeping. 
Don't forget to save the file.

### 7. Open IIS 6 Manager
On SRV2, login as an Admin.
Open the IIS 6 Manager: C:\Windows\system32\inetsrv\iis6.msc.
You installed this tool when you installed the SMTP Service.
You should see your server.

### 8. Configure SMTP Relay
In the left pane of the MSC, click your server to show the SMTP Server.
Right click on your SMTP Virtual Server then select Properties for the service.
You then see the properties dialog that you use to configure the SMTP Relay.

### 9. Specify Relay Restrictions
From the SMTP Server Properties page, click on the Access Tab.
From that tab, click on Relay (at the bottom) to bring up relay restrictions.
Click on 'All except the list below (or configure a list of systems you allow to use this relay).
Click on OK.

### 10. Configure Relay API key
From the SMTP Server Properties page, click on the Delivery Tab.
Then click on Outbound Security.
From the OUtbound Connections Security dialog box, click on Basic Authentication, the enter the Username of 'apikey' and enter the apikey you just generated to be the password. 
Click on OK.

### 11. Configure Advanced Delivery
From the SMTP Properties page, click on the Delivery tab, then click on Advanced.
Enter a FQDN for your server (eg SRV2.Reskit.Org). and a smarthost name (smtp.sendgrid.net).
Then Click OK.

### 12. Test the service
From SRV2 (or another system with access), run this script:
```powershell
$From  = 'srv2@reskit.org'
$To    = 'doctordns@Gmail.Com'
$subj  = 'Test from SRV2'
$Body  = 'This is a test message'
$SMTP  = 'SRV2'
Send-MailMessage -From $from -To $To -Subject $subj -Body $Body -SmtpServer $SMTP
```


You should soon see the email in your inbox.
If you are using Outlook, or certain other email clients, look in the junk mail folder.