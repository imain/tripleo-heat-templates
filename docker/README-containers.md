# Using Docker Containers With TripleO

## Baremetal Setup

In order to integrate with TripleO, we need to have a baremetal machine
successfully spawning.  There are a series of steps highlighted below on how to
setup to boot your baremetal machine using the rhel-atomic-cloud image.

```
http://download.devel.redhat.com/rel-eng/Atomic-7.1-images/rhel-atomic-cloud-7.1-9.x86_64.qcow2
```

Make a new baremetal flavor that includes no swap or ephemeral disk:
```
nova flavor-create baremetal_fulldisk auto 3072 10 1
```

Set the right ramdisk and kernel images for setting up the image:
```
nova flavor-key baremetal_fulldisk set baremetal:deploy_kernel_id=<baremetal kernel>
nova flavor-key baremetal_fulldisk set baremetal:deploy_ramdisk_id=<baremetal ramdisk>
nova flavor-key baremetal_fulldisk set cpu_arch=amd64
```

Add rhel atomic image:
```
glance image-create --name rhel-atomic --file rhel-atomic-cloud-7.1-9.x86_64.qcow2 --disk-format qcow2 --container-format bare
```

Ssh into the seed vm and add chain.c32 to tftpboot so that it can use it for
pxe booting:

```
cp /boot/extlinux/chain.c32 /tftpboot
cp /boot/extlinux/libcom32.c32 /tftpboot
cp /boot/extlinux/libutil.c32 /tftpboot
```

## Configuring TripleO

Edit overcloud-env.json:

- Change all flavors to baremetal_fulldisk.
- Change controllerImage to the ID of the rhel-atomic image.
- Change NovaImage to the rhel atomic image.

I like to create a keypair to access the nodes:
```
$ nova keypair-add heat-key > heat-key.pem
$ chmod 600 heat-key.pem
```

## Start heat overcloud template for docker

```
$ heat stack-create -e $TRIPLEO_ROOT/overcloud-env.json -e $TRIPLEO_ROOT/tripleo-heat-templates/overcloud-resource-registry-docker.yaml -t 360 -f $TRIPLEO_ROOT/tripleo-heat-templates/overcloud-without-mergepy.yaml -P "ExtraConfig=;KeyName=heat-key" containerized-overcloud
```

This will start the process of bringing up nodes.  The controller node will come up first and then the compute nodes.

Once this is up you can generate an overcloudrc using:
```
./genrc.sh <heat stack name>
```

Source the overcloudrc and then you can use the overcloud.

## Debugging

You can ssh into the controller/compute nodes by using the heat key, eg:
```
ssh -i heat-key.pem heat-admin@192.0.2.5
```

You can check to see what docker containers are running:
```
sudo docker ps -a
```

To enter a container that doesn't seem to be working right:
```
sudo docker exec -ti <container name> /bin/bash
```

Then you can check logs etc.

You can also just do a 'docker logs' on a given container.
