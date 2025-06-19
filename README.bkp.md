This repository is an example on how to create Kairos not and attach them to a Kamaji instance (self hosted of not)


Inspired by:
- https://www.youtube.com/watch?v=LERzvNzQimc
- https://github.com/kairos-io/provider-kubeadm/


Presented in Cloud Native Days workshop (Italy 2025): https://cloudnativedaysitaly.org/agenda/workshop-morning-1

## Build a Kairos image

### Build the container image

```bash
docker build -t kairos-kubeadm .
```

or use one of the images publishe by the pipelines of this repo. E.g.

```
quay.io/jimmykarily/kairos-kubeadm:v0.0.2
```

Choose a tag here: https://quay.io/repository/jimmykarily/kairos-kubeadm

### Build a Kairos install medium

```bash
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD/build:/build \
  quay.io/kairos/auroraboot:latest \
    --debug build-iso --output /build  docker://quay.io/jimmykarily/kairos-kubeadm:v0.0.2
```

(use the image you've selected or built in the previous step)

If you'd like to embed the Kairos config in the image (see the step below), you can build with:

```
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD/config.yaml:/config.yaml \
  -v $PWD/build:/build \
  quay.io/kairos/auroraboot:latest \
    --debug build-iso --cloud-config /config.yaml --output /build  docker://quay.io/jimmykarily/kairos-kubeadm:v0.0.2
```

> [!IMPORTANT]
> This will embed the connection details too, which means the image will only be useful for one specific cluster.

You can also use the released ISO from this repository's releases: https://github.com/jimmykarily/kamaji-demo/releases

## Create a Kamaji cluster

There are 2 ways to get access to a kamaji instance. See the next 2 sections for each one.

### Option 1: Using console.clastix.cloud

There is a free instance of kamaji running at: https://console.clastix.cloud
Create an account, then create a cluster and make sure you've added the cilium add-on,
otherwise your workers won't get a proper network configuration to connect to the cluster.

### Option 2: Deploying your own instance

You can follow the documentation: [kamaji on your own infrastructure](https://kamaji.clastix.io/getting-started/) or you can spin up a kamaji server using Kairos.
You can use the released Kairos artifacts to create a cluster. You don't need a kubeadm cluster, k3s and k0s will do. Use a config like the `kamaji-config.yaml` from this repository,
making sure you adapt the users section, to include your own SSH keys.

When you create a new tenant control plane, kamaji will use the IP address of the kamaji ingress unless you explicitly specify `spec.kubernetes.networkProfile.address` on the
Tenant resource manifest. If you are deploying on some public cloud (e.g. AWS), it's likely that the VMs IP address is not the one automatically assigned to the ingress resource (it would
be an internal IP address instead). You can annotate the k3s node to make sure klipper-lb assigns the external IP address like so:

```
kubectl annotate node kamaji-9236 k3s.io/external-ip=<your VMs IP address here>
```

After the cluster is up and running, create a "tenant control plane" as per the docs: https://kamaji.clastix.io/getting-started/kamaji-generic/#tenant-control-plane

Here is an example manifest:

```yaml
apiVersion: kamaji.clastix.io/v1alpha1
kind: TenantControlPlane
metadata:
  name: mycluster
  namespace: default
  labels:
    tenant.clastix.io: mycluster
spec:
  dataStore: default
  controlPlane:
    deployment:
      replicas: 3
    service:
      serviceType: LoadBalancer
  kubernetes:
    version: v1.30.2
    kubelet:
      cgroupfs: systemd
  networkProfile:
    port: 8000
    # certSANs:
    # - mycluster.192.168.122.145.sslip.io
    # serviceCidr: 10.96.0.0/24
    # podCidr: 10.244.0.0/16
    # dnsServiceIPs:
    # - 10.96.0.10
  addons:
    konnectivity:
      server:
        port: 8132
```

For the purpose of the workshop, the `create_clusters.sh` script can be used to create "N" clusters at once.

When your tenant cluster is created, you will need to [download the kubeconfig](https://kamaji.clastix.io/getting-started/kamaji-aws/#working-with-tenant-control-plane) to talk to it:

```bash
kubectl get secrets -n ${TENANT_NAMESPACE} ${TENANT_NAME}-admin-kubeconfig -o json \
  | jq -r '.data["admin.conf"]' \
  | base64 --decode \
  > ${TENANT_NAMESPACE}-${TENANT_NAME}.kubeconfig
```

(replace with the values matching your kamaji cluster).

The kubeconfig can also be downloaded from the kamaji console UI.

Then you will need kubeadmin in order to get the connection details to that cluster.
You can install it following the [documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/). E.g. with something like:

```bash
RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
ARCH="amd64"
sudo curl -L --remote-name-all https://dl.k8s.io/release/${RELEASE}/bin/linux/${ARCH}/kubeadm
sudo chmod +x kubeadm
```

Finally get the needed values with:

```bash
./kubeadm --kubeconfig=default-mycluster.kubeconfig token create --print-join-command
```

where `default-mycluster.kubeconfig` is the kubeconfig of your tenant cluster, which we recovered above.

This command, will print something like:

```
kubeadm join <JOIN_URL> --token <JOIN_TOKEN> --discovery-token-ca-cert-hash <JOIN_TOKEN_CACERT_HASH>
```

Note down those values because you are going to need them in the next step.

## Create the Kairos config for the workers

If you are using the clastix hosted kamaji server, go to the cluster you created and click on "Add" button in the "List of Nodes" section.
This will open a modal showing you:

- the JOIN_URL
- the JOIN_TOKEN
- the JOIN_TOKEN_CACERT_HASH

If instead, you deployed your own kamaji, you should have noted down those values already.

Copy the [config.yaml.tmpl](/config.yaml.tmpl) from this repository to `config.yaml` and update the `cluster:` section with those values.

Also make sure you update the user configuration to get the user you want created. See the [Kairos documentation](https://kairos.io/v3.4.2/docs/reference/) for more options.

## Deploy a Kairos worker

Create a VM and boot the ISO file you created in the first step. When it boots, scp the `config.yaml` in it. Then ssh to the machine and start the installation with `kairos-agent manual-install config.yaml`. Reboot when the installation is done and make sure you are booting from the disk this time.

Check the kamaji interface to see the worker connecting and becoming ready. You can get your kubeconfig  from the kamaji interface and start talking to your new cluster.

## Deploy cilium CNI

Your worker won't become "Ready" until you got a [Container Network Interface (CNI)](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/) configured.

If you used clastix kamaji instance, you just had to enable the cilium add-on from the web interface.
If you deployed your own kamaji instance, you need to deploy cilium manually on the worker.
Follow the instructions here: https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-the-cilium-cli

Something like this should work (provided your KUBECONFIG points to the tenant cluster):

```
cilium install --version 1.17.4
```

## Debugging

If something doesn't work (e.g. the worker not connecting to the cluster or not becoming "Ready"), there are a number places in the worker where you should look for helpful logs:

- `journalctl -f`
- `tail -f /var/log/kube-*`
- `cat /var/log/provider-kubeadm.log`

## Repository Contents

- scripts directory: Copied from here: https://github.com/kairos-io/provider-kubeadm/tree/main/scripts
- config.toml: Copied from here: https://github.com/kairos-io/provider-kubeadm/blob/main/containerd/config.toml
- Dockerfile: Replaces the build process defined [in earthly](https://github.com/kairos-io/provider-kubeadm/blob/0b6ed2290bc759276650214f3497dde201013487/Earthfile#L137) with a `kairos-init` based one.
