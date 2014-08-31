Cloudify Puppet Standalone Nodecellar example
==============================================

Description
-----------

This is a blueprint for simple Nodecellar installation on two VMs:

1. Nodecellar NodeJS application
2. Mongo database

Tested on `OpenStack` (HP cloud) and `Ubuntu 12.04`

After successful blueprint run, Nodecellar installation will be at: http://YOUR_APP_SERVER_FLOATING_IP:8080/

You can use `nova list` and look for `nodejs_vm_XXXXX` named server to discover the floating IP for the URL above.


Running
-------

This example needs an additional step after the blueprint is downloaded and before running it. This step creates the `puppet.tar.gz` file needed by Puppet standalone:

```bash
tar --exclude='*.swp' -czf puppet.tar.gz -C puppet manifests
```

After executing the command above, you proceed as with any other Cloudify blueprint. See http://getcloudify.org/guide/3.0/quickstart.html for instructions regarding blueprints usage.
