#!/bin/bash
# ensure-grafana-smtp-secret.sh

SECRET_NAME="grafana/smtp"
REGION="us-east-1"

# --- UPDATED JSON: Added the missing SMTP_NAME line ---
# SMTP_HOST: "smtp.gmail.com:587" is for gmail account"
# SMTP_PASSWORD":The SMTP password is the password for your email account, 
# but if your email provider uses two-factor authentication, 
# you will need to generate an app password. 
# This is a unique password that you use specifically for applications like email clients, 
# and it replaces your regular login password for those services. 
# To get one, go to your email account's security settings and look for "app passwords
SECRET_STRING='{
  "SMTP_USER":"<group email id>",
  "SMTP_PASSWORD":"<smtp password>",
  "SMTP_HOST":"smtp.gmail.com:587",
  "SMTP_FROM":"<group email id>",
  "SMTP_NAME":"IoT Factory Simulator"
}'

# Check if secret exists
aws secretsmanager describe-secret \
  --secret-id "$SECRET_NAME" \
  --region "$REGION" >/dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "Secret $SECRET_NAME exists. Updating value..."
  aws secretsmanager put-secret-value \
    --secret-id "$SECRET_NAME" \
    --secret-string "$SECRET_STRING" \
    --region "$REGION"
else
  echo "Secret $SECRET_NAME not found. Creating..."
  aws secretsmanager create-secret \
    --name "$SECRET_NAME" \
    --secret-string "$SECRET_STRING" \
    --region "$REGION"
fi