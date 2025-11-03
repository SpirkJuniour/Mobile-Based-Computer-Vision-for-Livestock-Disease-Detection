# Supabase Email Configuration for MifugoCare

## Overview
This guide shows you how to configure custom email settings in Supabase so all authentication emails (verification, password reset, etc.) come from your app's email address with official branding.

## Prerequisites
- Supabase project: `https://slkihxgkafkzasnpjmbl.supabase.co`
- Custom email domain (e.g., `noreply@mifugocare.com`)
- Access to your domain's DNS settings

---

## Step 1: Configure Custom SMTP (Recommended)

### Option A: Using Gmail/Google Workspace

1. **Go to Supabase Dashboard**
   - Navigate to: https://supabase.com/dashboard/project/slkihxgkafkzasnpjmbl
   - Click on "Authentication" → "Email Templates"
   - Scroll down to "SMTP Settings"

2. **Configure Gmail SMTP**
   ```
   SMTP Host: smtp.gmail.com
   SMTP Port: 587
   SMTP User: your-app-email@gmail.com (or your@mifugocare.com)
   SMTP Password: [App Password - see below]
   Sender Email: noreply@mifugocare.com
   Sender Name: MifugoCare
   ```

3. **Generate Gmail App Password**
   - Go to: https://myaccount.google.com/security
   - Enable 2-Factor Authentication (required)
   - Go to: https://myaccount.google.com/apppasswords
   - Create new app password for "Mail"
   - Copy the 16-character password
   - Use this as SMTP Password in Supabase

### Option B: Using SendGrid (Professional)

1. **Sign up for SendGrid**
   - Go to: https://sendgrid.com
   - Create free account (100 emails/day)

2. **Create API Key**
   - Settings → API Keys → Create API Key
   - Choose "Full Access"
   - Save the API key securely

3. **Configure in Supabase**
   ```
   SMTP Host: smtp.sendgrid.net
   SMTP Port: 587
   SMTP User: apikey
   SMTP Password: [Your SendGrid API Key]
   Sender Email: noreply@mifugocare.com
   Sender Name: MifugoCare
   ```

4. **Verify Domain in SendGrid**
   - Sender Authentication → Domain Authentication
   - Add your domain (mifugocare.com)
   - Add DNS records to your domain provider

---

## Step 2: Customize Email Templates

### Access Email Templates
1. Supabase Dashboard → Authentication → Email Templates
2. You'll see templates for:
   - Confirm signup
   - Magic link
   - Change email address
   - Reset password

### Customize Each Template

#### Example: Confirmation Email
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; }
    .container { background: white; padding: 40px; border-radius: 12px; max-width: 600px; margin: 0 auto; }
    .header { text-align: center; margin-bottom: 30px; }
    .logo { width: 80px; height: 80px; background: #4CAF50; border-radius: 20px; margin: 0 auto 20px; }
    .button { display: inline-block; padding: 16px 32px; background: #4CAF50; color: white; text-decoration: none; border-radius: 8px; font-weight: bold; }
    .footer { text-align: center; margin-top: 30px; color: #666; font-size: 12px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <div class="logo">🐄</div>
      <h1>Welcome to MifugoCare!</h1>
    </div>
    
    <p>Hi there,</p>
    <p>Thank you for signing up! Please confirm your email address to start detecting livestock diseases and keeping your animals healthy.</p>
    
    <div style="text-align: center; margin: 30px 0;">
      <a href="{{ .ConfirmationURL }}" class="button">Confirm Email Address</a>
    </div>
    
    <p>Or copy and paste this URL into your browser:</p>
    <p style="word-break: break-all; color: #666;">{{ .ConfirmationURL }}</p>
    
    <div class="footer">
      <p><strong>MifugoCare</strong> - AI-Powered Livestock Disease Detection</p>
      <p>This email was sent to {{ .Email }}</p>
      <p>If you didn't create an account, you can safely ignore this email.</p>
    </div>
  </div>
</body>
</html>
```

#### Password Reset Email
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; }
    .container { background: white; padding: 40px; border-radius: 12px; max-width: 600px; margin: 0 auto; }
    .header { text-align: center; margin-bottom: 30px; }
    .logo { width: 80px; height: 80px; background: #4CAF50; border-radius: 20px; margin: 0 auto 20px; }
    .button { display: inline-block; padding: 16px 32px; background: #4CAF50; color: white; text-decoration: none; border-radius: 8px; font-weight: bold; }
    .warning { background: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 20px 0; }
    .footer { text-align: center; margin-top: 30px; color: #666; font-size: 12px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <div class="logo">🐄</div>
      <h1>Reset Your Password</h1>
    </div>
    
    <p>Hi there,</p>
    <p>We received a request to reset your MifugoCare password. Click the button below to create a new password:</p>
    
    <div style="text-align: center; margin: 30px 0;">
      <a href="{{ .ConfirmationURL }}" class="button">Reset Password</a>
    </div>
    
    <div class="warning">
      <strong>⚠️ Security Notice:</strong> This link will expire in 1 hour for your security.
    </div>
    
    <p>Or copy and paste this URL into your browser:</p>
    <p style="word-break: break-all; color: #666;">{{ .ConfirmationURL }}</p>
    
    <div class="footer">
      <p><strong>MifugoCare</strong> - AI-Powered Livestock Disease Detection</p>
      <p>This email was sent to {{ .Email }}</p>
      <p>If you didn't request a password reset, you can safely ignore this email. Your password will remain unchanged.</p>
    </div>
  </div>
</body>
</html>
```

---

## Step 3: Configure Email Settings in Supabase

### Authentication Settings
1. Go to: Authentication → Settings
2. Configure:
   ```
   Site URL: https://your-app-domain.com (or localhost for development)
   Redirect URLs: 
     - https://your-app-domain.com/**
     - http://localhost:*/**
   
   Enable Email Confirmations: ✓ ON
   Enable Email Change Confirmations: ✓ ON
   Double Confirm Email Changes: ✓ ON (recommended)
   Secure Email Change: ✓ ON
   ```

### Email Rate Limiting
- Protect against spam/abuse:
  ```
  Max emails per hour: 10
  ```

---

## Step 4: Test Email Configuration

### From Supabase Dashboard
1. Go to Authentication → Users
2. Click "Invite user"
3. Enter a test email
4. Check if email arrives with correct sender and branding

### From Your App
```dart
// Test password reset email
await AuthService.instance.sendPasswordResetEmail('test@example.com');

// Test signup email
await AuthService.instance.signUpWithEmail(
  email: 'test@example.com',
  password: 'Test123!',
  fullName: 'Test User',
  role: UserRole.farmer,
);
```

---

## Step 5: Domain Verification (Production)

### For Custom Domain (e.g., @mifugocare.com)

1. **Add SPF Record** (Prevents spam marking)
   ```
   Type: TXT
   Name: @
   Value: v=spf1 include:_spf.google.com ~all
   (Or for SendGrid: v=spf1 include:sendgrid.net ~all)
   ```

2. **Add DKIM Record** (Email authentication)
   - Get DKIM values from SendGrid/Google
   - Add TXT records to your DNS

3. **Add DMARC Record** (Email security)
   ```
   Type: TXT
   Name: _dmarc
   Value: v=DMARC1; p=none; rua=mailto:admin@mifugocare.com
   ```

---

## Admin Account Configuration

### Hardcoded Admin Access
The app now has a built-in admin account:

```
Email: admin@mifugocare.com
Password: Admin2024!
```

**To access:**
1. Open app → Role Selection screen
2. Click "Admin Access" at the bottom
3. Enter admin credentials
4. You'll be logged in with full administrative powers

**Security Note:** Change the password in `lib/features/auth/role_selection_screen.dart` line 264 before deploying to production!

---

## Troubleshooting

### Emails not sending?
1. Check SMTP credentials are correct
2. Verify sender email is verified in your email provider
3. Check Supabase logs: Project Settings → API → Logs
4. Test SMTP connection: https://www.smtper.net/

### Emails going to spam?
1. Verify domain with SPF/DKIM records
2. Use a professional email service (SendGrid, AWS SES)
3. Don't use free email providers for sender (Gmail, Yahoo)
4. Add unsubscribe link to emails

### Wrong sender name/email?
1. Update in: Authentication → Email Templates → SMTP Settings
2. Clear browser cache
3. Test with new signup

---

## Recommended Setup for Production

**Best Practice:**
1. Use SendGrid or AWS SES (professional, reliable)
2. Verify your custom domain (@mifugocare.com)
3. Add all DNS records (SPF, DKIM, DMARC)
4. Customize all email templates with branding
5. Enable rate limiting (10 emails/hour)
6. Test thoroughly before launch

**Email Address Recommendations:**
- Sender: `noreply@mifugocare.com`
- Support: `support@mifugocare.com`
- Admin: `admin@mifugocare.com`

---

## Quick Setup Checklist

- [ ] Choose email provider (Gmail/SendGrid)
- [ ] Configure SMTP in Supabase dashboard
- [ ] Customize all 4 email templates
- [ ] Set Site URL and Redirect URLs
- [ ] Enable email confirmations
- [ ] Test with your email address
- [ ] Add DNS records (SPF, DKIM, DMARC)
- [ ] Verify domain in email provider
- [ ] Change admin password before production
- [ ] Test emails don't go to spam

---

## Support

If you need help:
1. Supabase Docs: https://supabase.com/docs/guides/auth/auth-smtp
2. SendGrid Guide: https://docs.sendgrid.com/for-developers/sending-email
3. Gmail SMTP: https://support.google.com/mail/answer/7126229

