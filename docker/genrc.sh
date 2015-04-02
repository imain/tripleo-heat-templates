#!/bin/bash

OS_AUTH_URL=`heat output-show $1 KeystoneURL`
OS_PASSWORD=`grep '"AdminPassword"' ../overcloud-env.json | cut -f 6 -d ' ' | sed 's/,//'`

cat > overcloudrc <<EOF
export OS_AUTH_URL=$OS_AUTH_URL
export OS_USERNAME=admin
export OS_PASSWORD=$OS_PASSWORD
export OS_TENANT_NAME=admin
EOF
