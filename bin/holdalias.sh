#!/bin/sh
# 17.01.2015 added code to disable quota_users
set -e
aliases='/etc/postfix/virtual'
maint_aliases='/etc/postfix/recipient_access'
quota_users='/etc/postfix/quota_users'
db_type='lmdb'

if [ $# -eq 0 ]; then
    echo "usage: $0 user@domain" >&2
    exit 1
fi

msg_formatted() {
  echo "[>] $*"
}

# Do we have that user on Backend?
doveadm user $1 || { printf '\nUser query failed.\n' >&2; exit 1; }

# Set HOLD flag for aliases
sed -e "/$1/s/\(.*\)$1/\1/;s/[ \t]$/\tHOLD Planned maintenance: account=$1/" $aliases | grep $1 >>$maint_aliases
msg_formatted 'Queueing mail for these aliases:'
grep $1 $maint_aliases
msg_formatted "Updating \"$maint_aliases\""
postmap $db_type:$maint_aliases

# Disable quota_users in case Dovecot needs to be stopped where check_policy_service would fail then
sed -i'' -e "/$1[ \t]*quota_users$/d" $quota_users
msg_formatted "Disabling mail quota for \"$1\""
postmap $db_type:$quota_users

echo '[ Complete ]'
