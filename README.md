# postfix
Helper scripts for Postfix.

`holdalias.sh` - Hold incomming messages so changes/maintenance on the physical mailboxes are not at risk of losing messages or getting desynced.

`holdldapalias.sh` - LDAP based version for use with [ldap-virtualMail Schema](https://github.com/tleuxner/ldap-virtualMail).

 #### /etc/postfix/main.cf:
    
    mua_recipient_restrictions = check_recipient_access
        lmdb:$config_directory/recipient_access
        [...]
        
    smtpd_recipient_restrictions = check_recipient_access
        lmdb:$config_directory/recipient_access
        [...]
    
 #### /etc/postfix/recipient_access:
    
    postmaster@example.com          HOLD Planned maintenance: account=postmaster@example.com
      
`unholdalias.sh` - Stop queueing incomming messages.
