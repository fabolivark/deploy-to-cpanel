#!/bin/sh -l

set -e

: ${CPANEL_ENVIRONMENT_SSH_URL?Required environment name variable not set.}
: ${CPANEL_HOST?Required environment name variable not set.}
: ${CPANEL_SSH_KEY_PRIVATE?Required secret not set.}
: ${CPANEL_SSH_KEY_PUBLIC?Required secret not set.}
: ${GLOBAL_USER_EMAIL?Required secret not set.}
: ${GLOBAL_USER_NAME?Required secret not set.}
: ${KEY_PUB?Required secret not set.}

SSH_PATH="$HOME/.ssh"
CPANEL_HOST="[wccolombia.org]:1891"
KNOWN_HOSTS_PATH="$SSH_PATH/known_hosts"
CPANEL_SSH_KEY_PRIVATE_PATH="$SSH_PATH/cpanel_key"
CPANEL_SSH_KEY_PUBLIC_PATH="$SSH_PATH/cpanel_key.pub"

mkdir "$SSH_PATH"

echo $KEY_PUB >> "$KNOWN_HOSTS_PATH"

ssh-keyscan -t rsa "$CPANEL_HOST" >> "$KNOWN_HOSTS_PATH"

echo "$CPANEL_SSH_KEY_PRIVATE" > "$CPANEL_SSH_KEY_PRIVATE_PATH"
echo "$CPANEL_SSH_KEY_PUBLIC" > "$CPANEL_SSH_KEY_PUBLIC_PATH"

echo "SETTING UP SSH"
chmod 700 "$SSH_PATH"
chmod 644 "$KNOWN_HOSTS_PATH"
chmod 600 "$CPANEL_SSH_KEY_PRIVATE_PATH"
chmod 644 "$CPANEL_SSH_KEY_PUBLIC_PATH"
ls -la $SSH_PATH

git init

git config --global user.email $GLOBAL_USER_EMAIL
git config --global user.name $GLOBAL_USER_NAME

echo "CONFIGURING GIT SSH"
git config core.sshCommand "ssh -i $CPANEL_SSH_KEY_PRIVATE_PATH -o UserKnownHostsFile=$KNOWN_HOSTS_PATH"

echo "ADDING GIT REMOTE"
git remote add origin "$CPANEL_ENVIRONMENT_SSH_URL"
git remote -v
git branch -a
ls -la
pwd
git add --all

echo "Committing build changes..."
git commit -m "Committing build changes"

echo "PUSHING TO CPANEL"
git push origin master:master --force

echo "ALL DONE"