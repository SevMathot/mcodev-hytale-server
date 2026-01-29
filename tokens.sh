#!/usr/bin/env bash
set -euo pipefail

# ====   Copyright 2026, mCoDev Systems, All rights reserved.   ====
# =  Purpose:    Fetch Hytale OAuth sessions tokens for running a dedicated server
# =  Reference:  https://support.hytale.com/hc/en-us/articles/45328341414043
# =  Author:     Steve (Sev) Mathot, mCoDev Systems. (www.mcodev.net
# =  License:    mCoDev Systems General Public License (MIT)
# =  Usage:      source ./tokens.sh     or     . ./tokens.sh
# =  Output:     Exported system environment variables: 
#                     - HYTALE_SERVER_SESSION_TOKEN
#                     - HYTALE_SERVER_IDENTITY_TOKEN
#                     - HYTALE_SERVER_REFRESH_TOKEN
# ==================================================================



CLIENT_ID="hytale-server"
SCOPE="openid offline auth:server"

DEVICE_AUTH_URL="https://oauth.accounts.hytale.com/oauth2/device/auth"
TOKEN_URL="https://oauth.accounts.hytale.com/oauth2/token"
PROFILES_URL="https://account-data.hytale.com/my-account/get-profiles"
SESSION_URL="https://sessions.hytale.com/game-session/new"

echo "Requesting device code..."

DEVICE_RESPONSE=$(curl -s -X POST "$DEVICE_AUTH_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=$CLIENT_ID" \
  -d "scope=$SCOPE")

DEVICE_CODE=$(echo "$DEVICE_RESPONSE" | jq -r '.device_code')
USER_CODE=$(echo "$DEVICE_RESPONSE" | jq -r '.user_code')
VERIFICATION_URI=$(echo "$DEVICE_RESPONSE" | jq -r '.verification_uri')
INTERVAL=$(echo "$DEVICE_RESPONSE" | jq -r '.interval')

echo ""
echo "=============================================="
echo "   HYTALE SERVER AUTHENTICATION REQUIRED"
echo "=============================================="
echo "Visit this URL in a browser:"
echo "  $VERIFICATION_URI?user_code=$USER_CODE"
echo ""
echo "Enter this code:"
echo "  $USER_CODE"
echo "=============================================="
echo ""

echo "Waiting for authorization..."

# ============================================
# Poll for OAuth tokens
# ============================================
while true; do
  TOKEN_RESPONSE=$(curl -s -X POST "$TOKEN_URL" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=$CLIENT_ID" \
    -d "grant_type=urn:ietf:params:oauth:grant-type:device_code" \
    -d "device_code=$DEVICE_CODE")

  ERROR=$(echo "$TOKEN_RESPONSE" | jq -r '.error // empty')

  if [[ "$ERROR" == "authorization_pending" ]]; then
    sleep "$INTERVAL"
    continue
  elif [[ -n "$ERROR" ]]; then
    echo "Error during token polling: $ERROR"
    exit 1
  else
    break
  fi
done

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token')
REFRESH_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.refresh_token')

echo "Authorization successful."

# ============================================
# Fetch available profiles
# ============================================
echo "Fetching available profiles..."

PROFILE_RESPONSE=$(curl -s -X GET "$PROFILES_URL" -H "Authorization: Bearer $ACCESS_TOKEN")

PROFILE_UUID=$(echo "$PROFILE_RESPONSE" | jq -r '.profiles[0].uuid')

if [[ "$PROFILE_UUID" == "null" ]]; then
  echo "No profiles found for this account."
  exit 1
fi

echo "Using profile UUID: $PROFILE_UUID"

# ============================================
# Create game session
# ============================================
echo "Creating game session..."

SESSION_RESPONSE=$(curl -s -X POST "$SESSION_URL" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"uuid\":\"$PROFILE_UUID\"}")

SESSION_TOKEN=$(echo "$SESSION_RESPONSE" | jq -r '.sessionToken')
IDENTITY_TOKEN=$(echo "$SESSION_RESPONSE" | jq -r '.identityToken')
REFRESH_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.refresh_token')

if [[ -z "$SESSION_TOKEN" || -z "$IDENTITY_TOKEN" || -z "$REFRESH_TOKEN" ]]; then
  echo "Failed to create game session:"
  echo "$SESSION_RESPONSE"
  exit 1
fi
if [[ "$REFRESH_TOKEN" == "null" ]]; then
  echo "No refresh token received!"
  exit 1
fi


export HYTALE_SERVER_SESSION_TOKEN="$SESSION_TOKEN"
export HYTALE_SERVER_IDENTITY_TOKEN="$IDENTITY_TOKEN"
export HYTALE_SERVER_REFRESH_TOKEN="$REFRESH_TOKEN"

echo ""
echo "=============================================="
echo "   TOKENS EXPORTED SUCCESSFULLY"
echo "=============================================="
echo "HYTALE_SERVER_SESSION_TOKEN"
echo "HYTALE_SERVER_IDENTITY_TOKEN"
echo "HYTALE_SERVER_REFRESH_TOKEN"
echo "=============================================="
echo ""
