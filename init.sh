#!/bin/sh

# Set timezone
if [ ! -z "${SYSTEM_TIMEZONE}" ]; then
    echo "configuring system timezone"
    echo "${SYSTEM_TIMEZONE}" > /etc/timezone
    dpkg-reconfigure -f noninteractive tzdata
fi

# Set mynetworks for postfix relay
if [ ! -z "${MYNETWORKS}" ]; then
   echo "setting mynetworks = ${MYNETWORKS}"
   postconf -e mynetworks="${MYNETWORKS}"
fi

# General the email/password hash and remove evidence.
if [ ! -z "${EMAIL}" ] && [ ! -z "${EMAILPASS}" ]; then
    echo "[smtp.mailgun.org]:587    ${EMAIL}:${EMAILPASS}" > /etc/postfix/sasl_passwd
    postmap /etc/postfix/sasl_passwd
    rm /etc/postfix/sasl_passwd
    echo "postfix EMAIL/EMAILPASS combo is setup."
else
    echo "EMAIL or EMAILPASS not set!"
fi
unset EMAIL
unset EMAILPASS

if [ ! -z "${DOMAIN}" ]; then
    echo "set default domain"
    postconf -e smtpd_sasl_local_domain = example.com
fi

if [ ! -z "${SASL_LDAP_SERVER}" ]; then
    echo "setting sasl ldap settings"
    cat << EOF > /etc/saslauthd.conf
ldap_servers: ldap://${SASL_LDAP_SERVER}

ldap_bind_dn: ${SASL_LDAP_BIND_DN}
ldap_password: ${SASL_LDAP_BIND_DN_PASSWORD}

ldap_search_base: ${SASL_LDAP_USERS}
ldap_filter: ${SASL_LDAP_USERS_FILTER}
EOF
fi

unset \
 SASL_LDAP_SERVER \
 SASL_LDAP_BIND_DN \
 SASL_LDAP_BIND_DN_PASSWORD \
 SASL_LDAP_USERS \
 SASL_LDAP_USERS_FILTER \
 SASL_LDAP_GENERATE_HOMEDIR
