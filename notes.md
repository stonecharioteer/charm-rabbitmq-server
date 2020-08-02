# My notes on this charm

## Building fails

Why isn't it building. Seems to need some layer.yaml file. I suspect this has something to do with how the charm uses the classic method and not the new reactive programming approach.
```
build: Please add a `repo` key to your layer.yaml, with a url from which your layer can be cloned.
build: Destination charm directory: /home/stonecharioteer/code/learning/juju/charms/builds/rabbitmq-server
build: The top level layer expects a valid layer.yaml file
build: Processing layer: rabbitmq-server (from .)
build: At least one layer must provide hooks/hook.template
```

## Code

So [the documentation for the classic approach](https://discourse.juju.is/t/writing-your-first-juju-charm/1046) seems to indicate that ./hooks is where I begin.

``` ls -l hooks/
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 amqp-relation-changed -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 ceph-relation-changed -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 ceph-relation-joined -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 certificates-relation-changed -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 certificates-relation-joined -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 cluster-relation-broken -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 cluster-relation-changed -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 cluster-relation-joined -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 config-changed -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 ha-relation-changed -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 ha-relation-joined -> rabbitmq_server_relations.py
-rwxrwxr-x 1 stonecharioteer stonecharioteer   436 Aug  2 19:48 install
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 install.real -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 leader-deposed -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 leader-elected -> rabbitmq_server_relations.py>
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 leader-settings-changed -> rabbitmq_server_relations.py
drwxrwxr-x 2 stonecharioteer stonecharioteer  4096 Aug  2 19:48 lib
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 nrpe-external-master-relation-changed -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 post-series-upgrade -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 pre-series-upgrade -> rabbitmq_server_relations.py
-rw-rw-r-- 1 stonecharioteer stonecharioteer  9049 Aug  2 19:48 rabbitmq_context.py
-rwxrwxr-x 1 stonecharioteer stonecharioteer 35402 Aug  2 19:48 rabbitmq_server_relations.py
-rw-rw-r-- 1 stonecharioteer stonecharioteer   713 Aug  2 19:48 rabbit_net_utils.py
-rw-rw-r-- 1 stonecharioteer stonecharioteer 39711 Aug  2 19:48 rabbit_utils.py
-rw-rw-r-- 1 stonecharioteer stonecharioteer  3968 Aug  2 19:48 ssl_utils.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 start -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 stop -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 update-status -> rabbitmq_server_relations.py
lrwxrwxrwx 1 stonecharioteer stonecharioteer    28 Aug  2 19:48 upgrade-charm -> rabbitmq_server_relations.py
```


So a lot of these hooks are symlinks. That works I suppose.

We begin with `start`. This is just `rabbitmq_server_relations.py`. In fact, all of the commands are just this.

Let's back up. Look at `install`. This is assumed to be triggered first. It installs, not rabbitmq, but the following:

1. apt
2. netaddr
3. netifaces
4. pip
5. yaml
6. dnspython
7. requests

Each of these dependencies are installed through `apt-get`. Weird. How does it install `apt` through `apt-get` if `apt` was never around?

Moving on, once it does this, it executes `hooks/install.real`, which, unsurprisingly, is a link to `rabbitmq_server_relations.py`.

After a bunch of import hacks (adding to path if not found, and
installing python3-yaml, python3-requests), the script imports the
local libraries:

1. `rabbit_net_utils`
2. `rabbit_utils`
3. `ssl_utils`
4. `rabbitmq_context`
5. `lib.utils`:
   1. `chown`
   2. `chmod`
   3. `is_newer`

It also imports a library that can be pip installed: [`charmhelpers`.](https://charm-helpers.readthedocs.io)

I am assuming that `juju` performs the installation of `charmhelpers`.
There is a `charm-helpers-hooks.yaml` file that defines how to get these
modules. That makes sense. I suppose charm build can fetch these.

The core of this "charm" is the `hook`.
