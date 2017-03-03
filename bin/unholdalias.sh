#!/bin/sh
# 17.01.2015 added quota_users logic
set -e
maint_aliases='/etc/postfix/recipient_access'
quota_users='/etc/postfix/quota_users'
quota_users_new='/etc/postfix/quota_users.new'
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

msg_formatted 'Cleaning up aliases.'
sed -i'' -e "/account=$1/d" $maint_aliases
msg_formatted "Updating \"$maint_aliases\""
postmap $db_type:$maint_aliases

# Enable quota_users again for Postfix check_policy_service checks
# sort quota_users matching column after @ sign
printf "$1\t\tquota_users\n" >> $quota_users
sort -t@ -k2 $quota_users > $quota_users_new
mv $quota_users_new $quota_users
msg_formatted "Enabling mail quota for \"$1\""
postmap $db_type:$quota_users

echo "Don't forget to run <postsuper -r ALL>"
echo '[ Complete ]'
