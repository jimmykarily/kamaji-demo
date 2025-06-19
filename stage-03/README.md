# Stage 03: Build a Kamaji Management Cluster using Kairos

## 1. Create a Kamaji cluster

Our Kamaji cluster will be running on a Kairos k3s single node cluster based on Ubuntu.

1. Download the ISO here: https://github.com/kairos-io/kairos/releases/download/v3.4.2/kairos-ubuntu-24.04-standard-amd64-generic-v3.4.2-k3sv1.33.1+k3s1.iso
2. Create a VM and boot the ISO file you just downloaded.
3. Replace all values in [config.yaml](./config.yaml) file and scp it into your VM.
4. SSH into the VM using the default credentials (username: `kairos`, password: `kairos`).
5. Start the installation process by running the following command:
    ```bash
    sudo kairos-agent manual-install ./config.yaml
    ```
6. Reboot the VM when the installation is done using:
    ```bash
    sudo reboot
    ```

## 2. Annotate the node

When you create a new tenant control plane, kamaji will use the IP address of the kamaji ingress unless you explicitly specify `spec.kubernetes.networkProfile.address` on the

Tenant resource manifest. In some cases (e.g. when having multiple network
interfaces) the VMs IP address is not the one automatically assigned to the
ingress resource (it would be an internal IP address instead). You can annotate
the k3s node to make sure klipper-lb assigns the external IP address like so:

```
kubectl annotate node <YOUR_NODE_NAME> k3s.io/external-ip=<YOUR_VM_IP_ADDRESS>
```

## 3. Create a Tenant Control Plane

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
  addons:
    konnectivity:
      server:
        port: 8132
```

## 4. Connect to the Tenant Control Plane

When your tenant cluster is created, you will need to [download the kubeconfig](https://kamaji.clastix.io/getting-started/kamaji-aws/#working-with-tenant-control-plane) to talk to it:

```bash
kubectl get secrets -n ${TENANT_NAMESPACE} ${TENANT_NAME}-admin-kubeconfig -o json \
  | jq -r '.data["admin.conf"]' \
  | base64 --decode \
  > ${TENANT_NAMESPACE}-${TENANT_NAME}.kubeconfig
```

(replace with the values matching your kamaji cluster).

The kubeconfig can also be downloaded from the kamaji console UI.

## 5. Deploy a worker

You can now deploy a worker using the ISO you built in [Stage 02](/stage-02/README.md) or the pre-built image we used on [Stage 01](/stage-01/README.md).
