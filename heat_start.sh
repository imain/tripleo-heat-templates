#!/bin/bash

heat stack-create -e $TRIPLEO_ROOT/overcloud-env.json -e $TRIPLEO_ROOT/tripleo-heat-templates/overcloud-resource-registry-docker.yaml -t 360 -f $TRIPLEO_ROOT/tripleo-heat-templates/overcloud-without-mergepy.yaml -P "ExtraConfig=;KeyName=heat-key" $1
