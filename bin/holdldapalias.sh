#!/bin/sh
set -e
# Queue mails for user in Postfix (HOLD).
# https://github.com/tleuxner/ldap-virtualMail
# Thomas Leuxner <tlx@leuxner.net> 20-12-2018
maint_aliases='/etc/postfix/recipient_access'
db_type='lmdb'

. ldap_binds.inc
. msg_formatted.inc

if [ $# -eq 0 ]; then
    echo "usage: $0 user@domain" >&2
    exit 1
fi

confirm_yn() {
  while :; do
        read -p "$1" yn
        case $yn in
                [Yy]* ) return 0;;
                [Nn]* ) return 1;;
                * ) echo 'Please answer [y/n].';;
        esac
  done
}

# Do we have that mail user?
doveadm user -u $1 || { msg_formatted "$i_warn No valid mail user found." >&2; exit 1; }
printf '\n'              

# Queue all mail for these aliases?
confirm_yn "Hold all mails for <$1> ? "

# Set HOLD flag for aliases
timestamp=$(date +%Y%m%d%H%M%S.%3N)
ldapsearch -LLL -ZZ -D $ldap_bind_dn -w $ldap_bind_dn_pw -H $ldap_server -b $ldap_search_base "(&(objectClass=mailUser)(mailDrop=$1))" mailAlias\
| awk -v ts="$timestamp" '/mailAlias/{ print $2 "\tHOLD Planned maintenance " ts }' >>$maint_aliases

msg_formatted "$i_step Queueing mail for these aliases:"
grep $timestamp $maint_aliases

msg_formatted "$i_step Updating \"$maint_aliases\""
postmap $db_type:$maint_aliases

msg_formatted "$i_done Hold mail action comitted $date <<<"
