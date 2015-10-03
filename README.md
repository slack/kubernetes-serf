# serf in Kubernetes

This started out as an experiement to see if I could deploy serf into
Kubernetes.

Instead of using the k8s apis to facilitate discovery, this repo instead
creates a serf service. Pods booted by the replication controller use the
`SERF_SERVICE_HOST` to find any active member. Gossip after that fact continues
as pod to pod communication is established.

This repo uses a serf replication controller to add/remove additional serf
replicas. My initial though experiement was to deploy this as a
cluster-membership sidecar container to other workloads. This is probably a bad
idea, and instead should use k8s native APIs for discovery.

But who says bad ideas aren't fun?

## Usage

Step 1. Create serf and verify service:

```console
$ kubectl create -f kubernetes/serf-service.yml
service/serf
$ kubectl get svc
NAME             LABELS                                    SELECTOR              IP(S)        PORT(S)
serf             name=serf,role=service                    name=serf             10.3.0.48    7946/TCP
```

Step 2. Create and verify serf controller:

```console
$ kubectl create -f kubernetes/serf-controller.yaml
replicationcontrollers/serf
$ ks get rc
CONTROLLER       CONTAINER(S)   IMAGE(S)                      SELECTOR              REPLICAS
serf             serf           quay.io/jhansen/serf:v0.0.9   name=serf             1
```

Step 3. Scale via serf controller:

```console
$ kubectl scale rc serf --replicas=5
scaled
$ ks describe rc serf
Name:		serf
Namespace:	default
Image(s):	quay.io/jhansen/serf:v0.0.9
Selector:	name=serf
Labels:		name=serf
Replicas:	5 current / 5 desired
Pods Status:	5 Running / 0 Waiting / 0 Succeeded / 0 Failed
Events:
  FirstSeen				LastSeen			Count	From				SubobjectPath	Reason			Message
  Sat, 03 Oct 2015 09:35:33 -0700	Sat, 03 Oct 2015 09:35:33 -0700	1	{replication-controller }			successfulCreate	Created pod: serf-4pglm
  Sat, 03 Oct 2015 09:38:53 -0700	Sat, 03 Oct 2015 09:38:53 -0700	1	{replication-controller }			successfulCreate	Created pod: serf-cryxj
  Sat, 03 Oct 2015 09:38:53 -0700	Sat, 03 Oct 2015 09:38:53 -0700	1	{replication-controller }			successfulCreate	Created pod: serf-ll1kt
  Sat, 03 Oct 2015 09:38:53 -0700	Sat, 03 Oct 2015 09:38:53 -0700	1	{replication-controller }			successfulCreate	Created pod: serf-9xqxo
  Sat, 03 Oct 2015 09:38:53 -0700	Sat, 03 Oct 2015 09:38:53 -0700	1	{replication-controller }			successfulCreate	Created pod: serf-r97xl
```

Step 4. Verify serf cluster:

```console
$ kubectl logs serf-4pglm
======================================================================
SERF_PORT_7946_TCP=tcp://10.3.0.48:7946
KUBERNETES_PORT=tcp://10.3.0.1:443
KUBERNETES_SERVICE_PORT=443
SERF_PORT_7946_UDP=udp://10.3.0.48:7946
HOSTNAME=serf-4pglm
SHLVL=2
HOME=/home/serf
SERF_SERVICE_PORT_SERF_TCP=7946
SERF_SERVICE_PORT_SERF_UDP=7946
SERF_SERVICE_HOST=10.3.0.48
KUBERNETES_PORT_443_TCP_ADDR=10.3.0.1
SERF_CONFDIR=/etc/serf
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_PROTO=tcp
SERF_PORT=tcp://10.3.0.48:7946
SERF_SERVICE_PORT=7946
SERF_PORT_7946_TCP_ADDR=10.3.0.48
SERF_PORT_7946_UDP_ADDR=10.3.0.48
SERF_PORT_7946_TCP_PORT=7946
SERF_APPDIR=/app
KUBERNETES_PORT_443_TCP=tcp://10.3.0.1:443
SERF_PORT_7946_TCP_PROTO=tcp
SERF_PORT_7946_UDP_PORT=7946
SERF_PORT_7946_UDP_PROTO=udp
KUBERNETES_SERVICE_HOST=10.3.0.1
PWD=/
======================================================================
serf: starting args(agent -config-dir /etc/serf -retry-join 10.3.0.48)
==> Starting Serf agent...
==> Starting Serf agent RPC...
==> Serf agent running!
         Node name: 'serf-4pglm'
         Bind addr: '0.0.0.0:7946'
          RPC addr: '127.0.0.1:7373'
         Encrypted: false
          Snapshot: false
           Profile: lan

==> Log data will now stream in as it occurs:

    2015/10/03 16:35:48 [INFO] agent: Serf agent starting
    2015/10/03 16:35:48 [INFO] serf: EventMemberJoin: serf-4pglm 10.2.6.17
    2015/10/03 16:35:48 [INFO] agent: Joining cluster...(replay: false)
    2015/10/03 16:35:48 [INFO] agent: joining: [10.3.0.48] replay: false
    2015/10/03 16:35:48 [WARN] agent: error joining: Reading remote state failed: EOF
    2015/10/03 16:35:48 [WARN] agent: Join failed: Reading remote state failed: EOF, retrying in 30s
    2015/10/03 16:35:49 [INFO] agent: Received event: member-join
    2015/10/03 16:36:18 [INFO] agent: Joining cluster...(replay: false)
    2015/10/03 16:36:18 [INFO] agent: joining: [10.3.0.48] replay: false
    2015/10/03 16:36:18 [INFO] agent: joined: 1 nodes
    2015/10/03 16:36:18 [INFO] agent: Join completed. Synced with 1 initial agents
    2015/10/03 16:39:06 [INFO] serf: EventMemberJoin: serf-9xqxo 10.2.30.8
    2015/10/03 16:39:06 [INFO] serf: EventMemberJoin: serf-ll1kt 10.2.60.19
    2015/10/03 16:39:06 [INFO] serf: EventMemberJoin: serf-r97xl 10.2.60.20
    2015/10/03 16:39:07 [INFO] serf: EventMemberJoin: serf-cryxj 10.2.35.14
    2015/10/03 16:39:08 [INFO] agent: Received event: member-join
```
