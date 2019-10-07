#!/bin/sh

CONF_FILE=/etc/ncs/ncs.conf

# switch to local auth per default, allow to override through environment variable PAM
if [ "$PAM" != "true" ]; then
    xmlstarlet edit --inplace -N x=http://tail-f.com/yang/tailf-ncs-config \
               --update '/x:ncs-config/x:aaa/x:pam/x:enabled' --value 'false' \
               --update '/x:ncs-config/x:aaa/x:local-authentication/x:enabled' --value 'true' \
               $CONF_FILE
fi

# change SSH key dir
xmlstarlet edit --inplace -N x=http://tail-f.com/yang/tailf-ncs-config \
           --update '/x:ncs-config/x:aaa/x:ssh-server-key-dir' --value '/nso/ssh' \
           $CONF_FILE

# update ports for various protocols for which the default value in ncs.conf is
# different from the protocols default port (to allow starting ncs without root)
# NETCONF call-home is already on its default 4334 since that's above 1024
xmlstarlet edit --inplace -N x=http://tail-f.com/yang/tailf-ncs-config \
           --update '/x:ncs-config/x:cli/x:ssh/x:port' --value '22' \
           --update '/x:ncs-config/x:webui/x:transport/x:tcp/x:port' --value '80' \
           --update '/x:ncs-config/x:webui/x:transport/x:ssl/x:port' --value '443' \
           --update '/x:ncs-config/x:netconf-north-bound/x:transport/x:ssh/x:port' --value '830' \
           $CONF_FILE

# enable SSH CLI, NETCONF over SSH northbound and NETCONF call-home
xmlstarlet edit --inplace -N x=http://tail-f.com/yang/tailf-ncs-config \
           --update '/x:ncs-config/x:cli/x:ssh/x:enabled' --value 'true' \
           --update '/x:ncs-config/x:netconf-north-bound/x:transport/x:ssh/x:enabled' --value 'true' \
           --update '/x:ncs-config/x:netconf-call-home/x:enabled' --value 'true' \
           $CONF_FILE

# conditionally enable webUI with no TLS on port 80
if [ "$HTTP_ENABLE" == "true" ]; then
    xmlstarlet edit --inplace -N x=http://tail-f.com/yang/tailf-ncs-config \
               --update '/x:ncs-config/x:webui/x:transport/x:tcp/x:enabled' --value 'true' \
               $CONF_FILE
fi

# conditionally enable webUI with TLS on port 443
if [ "$HTTPS_ENABLE" == "true" ]; then
    xmlstarlet edit --inplace -N x=http://tail-f.com/yang/tailf-ncs-config \
               --update '/x:ncs-config/x:webui/x:transport/x:ssl/x:enabled' --value 'true' \
               --update '/x:ncs-config/x:webui/x:transport/x:ssl/x:key-file' --value '/nso/ssl/cert/host.key' \
               --update '/x:ncs-config/x:webui/x:transport/x:ssl/x:cert-file' --value '/nso/ssl/cert/host.cert' \
               $CONF_FILE
fi
