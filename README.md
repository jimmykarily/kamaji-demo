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
quay.io/jimmykarily/kairos-kubeadm:v0.0.1
```

Choose a tag here: https://quay.io/repository/jimmykarily/kairos-kubeadm

### Build a Kairos install medium

```bash
docker run --rm -it \
  -v $PWD/config.yaml:/config.yaml \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD/build:/build \
  quay.io/kairos/auroraboot:latest \
    --debug build-iso --cloud-config /config.yaml --output /build  docker://quay.io/jimmykarily/kairos-kubeadm:v0.0.1
```

(use the image you've selected or built in the previous step)

## Create a Kamaji cluster

Either deploy [kamaji on your own infrastructure](https://kamaji.clastix.io/getting-started/) or create an account on the hosted service: https://console.clastix.cloud

From there create a cluster and make sure you've added the cilim addon, otherwise your workers won't get a proper network configuration to connect to the cluster.

## Create the Kairos config

First, find the values needed to populate the kairos configuration by clicking on "Add" button in the "List of Nodes" section in the Kamaji interface. This will open a modal showing you:

- the JOIN_URL
- the JOIN_TOKEN
- the JOIN_TOKEN_CACERT_HASH

Copy the `config.yaml.tmpl` from this repository to `config.yaml` and update the `cluster:` section with the values you got from Kamaji.

Also make sure you update the user configuration to get the user you want created. See the [Kairos documentation](https://kairos.io/v3.4.2/docs/reference/) for more options.

## Deploy a Kairos worker

Create a VM and boot the ISO file you created in the first step. When it boots, scp the `config.yaml` in it. Then ssh to the machine and start the installation with `kairos-agent manual-install config.yaml`. Reboot when the installation is done and make sure you are booting from the disk this time.

Check the kamaji interface to see the worker connecting and becoming ready. You can get your kubeconfig  from the kamaji interface and start talking to your new cluster.

## Debugging

If something doesn't work (e.g. the worker not connecting to the cluster or not becoming "Ready"), there are a number places in the worker where you should look for helpful logs:

- `journalctl -f`
- `tail -f /var/log/kube-*`
- `cat /var/log/provider-kubeadm.log`

## Repository Contents

- scripts directory: Copied from here: https://github.com/kairos-io/provider-kubeadm/tree/main/scripts
- config.toml: Copied from here: https://github.com/kairos-io/provider-kubeadm/blob/main/containerd/config.toml
- Dockerfile: Replaces the build process defined [in earthly](https://github.com/kairos-io/provider-kubeadm/blob/0b6ed2290bc759276650214f3497dde201013487/Earthfile#L137) with a `kairos-init` based one.

## Tasks (TODOs)

- Implement a dockerfile for a kube-admin enabled Kairos based on: https://github.com/clastix/kamaji-kairos (with kairos-init instead of Earthly)
- Use the above Kairos to create both ISO and raw image artifacts.
- Try the idea in this video with the above artifacts: https://www.youtube.com/watch?v=LERzvNzQimc
- Create an easy way to deploy a Kamaji control plane on Kairos
- Try everything e2e, the Kairos kamaji control plane with the Kairos workers created above. Create at least 2 different clusters talking to the same kamaji.