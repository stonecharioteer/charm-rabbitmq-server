# My notes on this charm

## Resources

1. [Charm hooks](https://discourse.juju.is/t/charm-hooks/1040)
2. [Charm Helpers](https://charm-helpers.readthedocs.io)
3. [Implementing Leadership](https://discourse.juju.is/t/implementing-leadership/1124)
4. [RabbitMQ charm](https://jaas.ai/rabbitmq-server) (and this repo, of course)
5. [RabbitMQ Clustering](https://www.rabbitmq.com/clustering.html)
6. [Developing a Charm](https://discourse.juju.is/t/tutorial-charm-development-beginner-part-1/377)


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

## About hooks

In this exercise, I am going to look at a few hooks:

1. `install`
2. `config-changed`
3. `cluster-relation-joined`
4. `cluster-relation-changed`

The install hook is pretty straightforward. It is run at the very beginning of a new charm.

We begin with `install`. This is just `rabbitmq_server_relations.py`. In fact, all of the commands are just this.

## The `install` hook

This is triggered first. It installs, not *just* rabbitmq, but the following:

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

The action is translated to `sys.argv`.

And the code triggers `hooks.execute(sys.argv)`. The hooks are registered through the `@hook.hook` decorator.

This decorator adds the name of the hook to a private variable called `self._hooks`.

This tells `hooks.execute` what hooks are available.

`hook.hook` *registers* the decorated function to be executed when the particular hook is *executed*.

For example: `install.real` does the following:

```python
@hooks.hook('install.real')
@harden()
def install():
    pre_install_hooks()
    add_source(config('source'), config('key'))
    rabbit.install_or_upgrade_packages()
```

`pre_install_hooks` executes all hooks matching `exec.d/*/charm-preinstall`.

`add_source` is an *aliased* function pointing to `charmhelpers.fetch.<platform>.add_source`.

Consider `charmhelpers.fetch.ubuntu.add_source`. This function adds a PPA to the system.

Finally, it runs `rabbit_utils.install_or_upgrade_packages()`.

```python

def install_or_upgrade_packages():
    """Run apt-get update/upgrade mantra.
    This is called from either install hook, or from config-changed,
    if upgrade is warranted
    """
    status_set('maintenance', 'Installing/upgrading RabbitMQ packages')
    apt_update(fatal=True)
    apt_install(PACKAGES, fatal=True)

```

This function sets the status of the cluster to maintainence, with the message. It updates `apt` sources.

Again, these functions are aliased to `charmhelpers.fetch.<platform>.<module>`.

Now, these functions internally run `_run_apt_command`. See `charmhelpers.fetch.ubuntu.apt_update` for an example:

```python
def apt_update(fatal=False):
    """Update local apt cache."""
    cmd = ['apt-get', 'update']
    _run_apt_command(cmd, fatal)
```

And `_run_apt_command` just uses `subprocess`.


```python

def _run_apt_command(cmd, fatal=False):
    """Run an apt command with optional retries.

    :param cmd: The apt command to run.
    :type cmd: str
    :param fatal: Whether the command's output should be checked and
                  retried.
    :type fatal: bool
    """
    if fatal:
        _run_with_retries(
            cmd, retry_exitcodes=(1, APT_NO_LOCK,),
            retry_message="Couldn't acquire DPKG lock")
    else:
        subprocess.call(cmd, env=get_apt_dpkg_env())

```

Finally, `install_or_upgrade_packages` installs the requirements, which include:

1. `rabbitmq-server`
2. `python3-amqplib`
3. `lockfile-progs`


So once this is done, `rabbitmq` is finally installed.


## `config-changed` hook

This runs immediately after `install`.

This hook applies the configuration changes across the cluster, allows enabling or disabling config
features.

## `cluster-relation-joined` hook

This hook seems to run when a new node joins the cluster. At this point, for a manual deployment, the `.erlang.cookie` file needs to be copied to `/var/lib/rabbitmq/.erlang.cookie` from the leader to this new node.

The way this is coded is that the leader alone has the responsibility of doing this. Check the following:

```python
@hooks.hook('cluster-relation-joined')
def cluster_joined(relation_id=None):
    relation_settings = {
        'hostname': rabbit.get_unit_hostname(),
        'private-address':
            ch_ip.get_relation_ip(
                rabbit_net_utils.CLUSTER_INTERFACE,
                cidr_network=config(rabbit_net_utils.CLUSTER_OVERRIDE_CONFIG)),
    }

    relation_set(relation_id=relation_id,
                 relation_settings=relation_settings)

    if is_relation_made('ha') and \
            config('ha-vip-only') is False:
        log('hacluster relation is present, skipping native '
            'rabbitmq cluster config.')
        return

    try:
        if not is_leader():
            log('Not the leader, deferring cookie propagation to leader')
            return
    except NotImplementedError:
        if is_newer():
            log('cluster_joined: Relation greater.')
            return

    if not os.path.isfile(rabbit.COOKIE_PATH):
        log('erlang cookie missing from %s' % rabbit.COOKIE_PATH,
            level=ERROR)
        return

    if is_leader():
        log('Leader peer_storing cookie', level=INFO)
        cookie = open(rabbit.COOKIE_PATH, 'r').read().strip()
        peer_store('cookie', cookie)
        peer_store('leader_node_ip', unit_private_ip())
        peer_store('leader_node_hostname', rabbit.get_unit_hostname())

```

Here, the last section only functions if the node running this hook is a leader.

`peer_store` comes from `charmhelpers.contrib.peerstorage`.

```python
def peer_store(key, value, relation_name='cluster'):
    """Store the key/value pair on the named peer relation `relation_name`."""
    cluster_rels = relation_ids(relation_name)
    if len(cluster_rels) > 0:
        cluster_rid = cluster_rels[0]
        relation_set(relation_id=cluster_rid,
                     relation_settings={key: value})
    else:
        raise ValueError('Unable to detect '
```

In the original call for the `cookie` key, the leader has read the file stored at `rabbit.COOKIE_PATH`
and now it seeks to set that value across the new node.

Take a look at `relation_set`, as `peer_store` calls it after some initial cleanup.

```python


def relation_set(relation_id=None, relation_settings=None, **kwargs):
    """Attempt to use leader-set if supported in the current version of Juju,
    otherwise falls back on relation-set.

    Note that we only attempt to use leader-set if the provided relation_id is
    a peer relation id or no relation id is provided (in which case we assume
    we are within the peer relation context).
    """
    try:
        if relation_id in relation_ids('cluster'):
            return leader_set(settings=relation_settings, **kwargs)
        else:
            raise NotImplementedError
    except NotImplementedError:
        return _relation_set(relation_id=relation_id,
                             relation_settings=relation_settings, **kwargs)

```

Depending on the Juju version, this either runs `leader_set` or `_relation_set`. Let's look at `leader_set` which is in `charmhelpers.core.hookenv`.

```python
@translate_exc(from_exc=OSError, to_exc=NotImplementedError)
def leader_set(settings=None, **kwargs):
    """Juju leader set value(s)"""
    # Don't log secrets.
    # log("Juju leader-set '%s'" % (settings), level=DEBUG)
    cmd = ['leader-set']
    settings = settings or {}
    settings.update(kwargs)
    for k, v in settings.items():
        if v is None:
            cmd.append('{}='.format(k))
        else:
            cmd.append('{}={}'.format(k, v))
    subprocess.check_call(cmd)
```

Note: this `translate_exc` decorator is **very** clever. I like it.

```python

def translate_exc(from_exc, to_exc):
    def inner_translate_exc1(f):
        @wraps(f)
        def inner_translate_exc2(*args, **kwargs):
            try:
                return f(*args, **kwargs)
            except from_exc:
                raise to_exc

        return inner_translate_exc2

    return inner_translate_exc1
```
The `raise to_exc` can be changed to `raise to_exc from from_exc` for better traceability of errors.

Back to `leader_set`.

This ultimately just runs `leader-set`. Wait, the original `relation_set` function says this:

>   Note that we only attempt to use leader-set if the provided relation_id is
>   a peer relation id or no relation id is provided (in which case we assume
>   we are within the peer relation context).

I need to look at `_relation_set` instead. This is in `charmhelpers.core.hookenv`.


Hmm. `leader-set` and `relation-set` are in `juju` tools. In one ubuntu machine I found them at `/var/lib/juju/tools/2.8.1-bionic-amd64/`. They are compiled binaries.

[Juju's leadership settings are discussed here.](https://discourse.juju.is/t/implementing-leadership/1124)

I am assuming `leader-set` writes the value to the file? Ultimately `.erlang.cookie` needs to be written to.

## `cluster-relation-changed` hook

Now this is the interesting hook. It is what actually does the copying of the cookie and the `join_cluster` command.


```python

@hooks.hook('cluster-relation-changed')
def cluster_changed(relation_id=None, remote_unit=None):
    # Future travelers beware ordering is significant
    rdata = relation_get(rid=relation_id, unit=remote_unit)

    # sync passwords
    blacklist = ['hostname', 'private-address', 'public-address']
    whitelist = [a for a in rdata.keys() if a not in blacklist]
    peer_echo(includes=whitelist)

    cookie = peer_retrieve('cookie')
    if not cookie:
        log('cluster_changed: cookie not yet set.', level=INFO)
        return

    if rdata:
        hostname = rdata.get('hostname', None)
        private_address = rdata.get('private-address', None)

        if hostname and private_address:
            rabbit.update_hosts_file({private_address: hostname})

    # sync the cookie with peers if necessary
    update_cookie()

    if is_relation_made('ha') and \
            config('ha-vip-only') is False:
        log('hacluster relation is present, skipping native '
            'rabbitmq cluster config.', level=INFO)
        return

    if rabbit.is_sufficient_peers():
        # NOTE(freyes): all the nodes need to marked as 'clustered'
        # (LP: #1691510)
        rabbit.cluster_with()
        # Local rabbit maybe clustered now so check and inform clients if
        # needed.
        update_clients()

    if not is_leader() and is_relation_made('nrpe-external-master'):
        update_nrpe_checks()
```

The lines to look at are `update_cookie` and `rabbit.cluster_with`

`update_cookie` reads the value of `cookie` from the `peer_retrieve` function and then writes to the path.

```python
def update_cookie(leaders_cookie=None):
    # sync cookie
    if leaders_cookie:
        cookie = leaders_cookie
    else:
        cookie = peer_retrieve('cookie')
    cookie_local = None
    with open(rabbit.COOKIE_PATH, 'r') as f:
        cookie_local = f.read().strip()

    if cookie_local == cookie:
        log('Cookie already synchronized with peer.')
        return

    service_stop('rabbitmq-server')
    with open(rabbit.COOKIE_PATH, 'wb') as out:
        out.write(cookie.encode('ascii'))
    if not is_unit_paused_set():
        service_restart('rabbitmq-server')
        rabbit.wait_app()
```

And if there are sufficient peers, the script runs `cluster_with`.

```python

def cluster_with():
    if is_unit_paused_set():
        log("Do not run cluster_with while unit is paused", "WARNING")
        return

    log('Clustering with new node')

    # check the leader and try to cluster with it
    node = leader_node()
    if node:
        if node in running_nodes():
            log('Host already clustered with %s.' % node)

            cluster_rid = relation_id('cluster', local_unit())
            is_clustered = relation_get(attribute='clustered',
                                        rid=cluster_rid,
                                        unit=local_unit())

            log('am I clustered?: %s' % bool(is_clustered), level=DEBUG)
            if not is_clustered:
                # NOTE(freyes): this node needs to be marked as clustered, it's
                # part of the cluster according to 'rabbitmqctl cluster_status'
                # (LP: #1691510)
                relation_set(relation_id=cluster_rid,
                             clustered=get_unit_hostname(),
                             timestamp=time.time())

            return False
        # NOTE: The primary problem rabbitmq has clustering is when
        # more than one node attempts to cluster at the same time.
        # The asynchronous nature of hook firing nearly guarantees
        # this. Using cluster_wait based on modulo_distribution
        cluster_wait()
        try:
            join_cluster(node)
            # NOTE: toggle the cluster relation to ensure that any peers
            #       already clustered re-assess status correctly
            relation_set(clustered=get_unit_hostname(), timestamp=time.time())
            return True
        except subprocess.CalledProcessError as e:
            status_set('blocked', 'Failed to cluster with %s. Exception: %s'
                       % (node, e))
            start_app()
    else:
        status_set('waiting', 'Leader not available for clustering')
        return False

    return False
```


`cluster_with` runs `join_cluster`.

```python

def join_cluster(node):
    ''' Join cluster with node '''
    if cmp_pkgrevno('rabbitmq-server', '3.0.1') >= 0:
        cluster_cmd = 'join_cluster'
    else:
        cluster_cmd = 'cluster'
    status_set('maintenance',
               'Clustering with remote rabbit host (%s).' % node)
    rabbitmqctl('stop_app')
    # Intentionally using check_output so we can see rabbitmqctl error
    # message if it fails
    cmd = [RABBITMQ_CTL, cluster_cmd, node]
    subprocess.check_output(cmd, stderr=subprocess.STDOUT)
    start_app()
    log('Host clustered with %s.' % node, 'INFO')
```

This is the function that does the stopping, joining and the starting.


## Building fails

Why isn't it building. Seems to need some layer.yaml file. I suspect this has something to do with how the charm uses the classic method and not the new reactive programming approach.

```
build: Please add a `repo` key to your layer.yaml, with a url from which your layer can be cloned.
build: Destination charm directory: /home/stonecharioteer/code/learning/juju/charms/builds/rabbitmq-server
build: The top level layer expects a valid layer.yaml file
build: Processing layer: rabbitmq-server (from .)
build: At least one layer must provide hooks/hook.template
```

I suspect that this charm has been built in a different way. I was unable to figure that out in the time I had, but I suspect it uses a builder, such as the resource I have linked below.

## End Notes

To summarize, I've gone through only 3 hooks in this short timeframe. I am still unable to build this charm, but I am not yet sure why. Since I didn't have the time to delve into this, I decided to make notes on the source code and its lifecycle instead.

## Additional Resources

1. [How to build Charms using modern tools (charmcraft)](https://discourse.juju.is/t/tutorial-how-to-build-a-charm-using-modern-tools/3246)
