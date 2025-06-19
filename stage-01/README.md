# Stage 01: Connect a worker to an existing Kamaji cluster using a pre-built Kairos ISO

## 1. The Worker Image (Kairos)

Download the Kairos ISO from this repository's releases: https://github.com/jimmykarily/kamaji-demo/releases

## 2. Create a Tenant (Kamaji)

Visit https://cnd-italy-2025.kairos.io/ui/dashboard

> [!IMPORTANT]
> The host will provide you the credentials

Find the tenant assigned to you (see number on your cheat sheet) and click on it.

> [!IMPORTANT]
> Please respect other participants and do not access the tenant of other people.

Press on View Kubeconfig button to download the kubeconfig file for that tenant cluster and make a copy of it, e.g. `default-mycluster.kubeconfig`.

## 3. Generate Worker Credentials

Then you will need kubeadmin in order to get the connection details to that cluster.
You can install it following the [documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/). E.g. with something like:

> [!IMPORTANT]
> Make sure you have `curl` installed on your system. And select the right architecture for your system (e.g. `amd64` or `arm64`).

```bash
RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
ARCH="amd64"
curl -L --remote-name-all https://dl.k8s.io/release/${RELEASE}/bin/linux/${ARCH}/kubeadm
chmod +x kubeadm
```

Generate the credentials:

```bash
./kubeadm --kubeconfig=default-mycluster.kubeconfig token create --print-join-command
```

where `default-mycluster.kubeconfig` is the kubeconfig of your tenant cluster, which we recovered above.

This command, will print something like:

```
kubeadm join <JOIN_URL> --token <JOIN_TOKEN> --discovery-token-ca-cert-hash <JOIN_TOKEN_CACERT_HASH>
```

Note down those values because you are going to need them in the next step.

## 4. Create the Kairos config for the workers

Now copy the [config.yaml.tmpl](../config.yaml.tmpl) from this repository to `config.yaml` and update the `cluster:` section with those values.

Also make sure you update the user configuration to get the user you want created. See the [Kairos documentation](https://kairos.io/v3.4.2/docs/reference/) for more options.

## 5. Deploy a Kairos worker

1. Create a VM and boot the ISO file you created in the first step.
2. When it boots, scp the `config.yaml` in it.
3. Ssh to the machine and start the installation
4. Start installation with `sudo kairos-agent manual-install config.yaml`.
5. Reboot when the installation is done using `sudo reboot` 

> [!IMPORTANT]
> Make sure you are booting from the disk after you reboot the system

## 6. Deploy cilium CNI

Your worker won't become "Ready" until you got a [Container Network Interface (CNI)](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/) configured.

1. Download the Cilium CLI following the instructions here: https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-the-cilium-cli
2. Install Cilium on the worker using the kubeconfig you downloaded in step 2.

```
export KUBECONFIG=./default-mycluster.kubeconfig
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

