This is a repository that will be used for the workshop in CND Italy 2025

## Tasks

- Implement a dockerfile for a kube-admin enabled Kairos based on: https://github.com/clastix/kamaji-kairos (with kairos-init instead of Earthly)
- Use the above Kairos to create both ISO and raw image artifacts.
- Try the idea in this video with the above artifacts: https://www.youtube.com/watch?v=LERzvNzQimc
- Create an easy way to deploy a Kamaji control plane on Kairos
- Try everything e2e, the Kairos kamaji control plane with the Kairos workers created above. Create at least 2 different clusters talking to the same kamaji.

## Repository Contents

- scripts directory: Copied from here: https://github.com/kairos-io/provider-kubeadm/tree/main/scripts
- config.toml: Copied from here: https://github.com/kairos-io/provider-kubeadm/blob/main/containerd/config.toml
- Dockerfile: Replaces the build process defined [in earthly](https://github.com/kairos-io/provider-kubeadm/blob/0b6ed2290bc759276650214f3497dde201013487/Earthfile#L137) with a `kairos-init` based one.




Currently failing with:


```
root@localhost:~# kubeadm join --config "$root_path"/opt/kubeadm/kubeadm.yaml --ignore-preflight-errors=DirAvailable--etc-kubernetes-manifests -v=5
I0611 14:21:11.465208    5373 join.go:421] [preflight] found NodeName empty; using OS hostname as NodeName
I0611 14:21:11.465264    5373 joinconfiguration.go:83] loading configuration from "/opt/kubeadm/kubeadm.yaml"
I0611 14:21:11.465995    5373 initconfiguration.go:123] detected and using CRI socket: unix:///var/run/containerd/containerd.sock
[preflight] Running pre-flight checks
I0611 14:21:11.466059    5373 preflight.go:93] [preflight] Running general checks
I0611 14:21:11.468521    5373 checks.go:278] validating the existence of file /etc/kubernetes/kubelet.conf
I0611 14:21:11.468545    5373 checks.go:278] validating the existence of file /etc/kubernetes/bootstrap-kubelet.conf
I0611 14:21:11.468552    5373 checks.go:102] validating the container runtime
I0611 14:21:11.468856    5373 checks.go:637] validating whether swap is enabled or not
I0611 14:21:11.468986    5373 checks.go:368] validating the presence of executable losetup
I0611 14:21:11.469014    5373 checks.go:368] validating the presence of executable mount
I0611 14:21:11.469028    5373 checks.go:368] validating the presence of executable cp
I0611 14:21:11.469044    5373 checks.go:514] running all checks
I0611 14:21:11.478040    5373 checks.go:399] checking whether the given node name is valid and reachable using net.LookupHost
I0611 14:21:11.478172    5373 checks.go:603] validating kubelet version
I0611 14:21:11.501205    5373 checks.go:128] validating if the "kubelet" service is enabled and active
I0611 14:21:11.510510    5373 checks.go:201] validating availability of port 10250
I0611 14:21:11.510710    5373 checks.go:278] validating the existence of file /etc/kubernetes/pki/ca.crt
I0611 14:21:11.510729    5373 checks.go:428] validating if the connectivity type is via proxy or direct
I0611 14:21:11.510753    5373 join.go:551] [preflight] Discovering cluster-info
I0611 14:21:11.510771    5373 token.go:72] [discovery] Created cluster-info discovery client, requesting info from "dkarakasilis-1069-default-kairos-test.k8s.clastix.cloud:443"
I0611 14:21:11.510919    5373 envvar.go:172] "Feature gate default state" feature="ClientsAllowCBOR" enabled=false
I0611 14:21:11.510938    5373 envvar.go:172] "Feature gate default state" feature="ClientsPreferCBOR" enabled=false
I0611 14:21:11.510944    5373 envvar.go:172] "Feature gate default state" feature="InformerResourceVersion" enabled=false
I0611 14:21:11.510952    5373 envvar.go:172] "Feature gate default state" feature="InOrderInformers" enabled=true
I0611 14:21:11.510957    5373 envvar.go:172] "Feature gate default state" feature="WatchListClient" enabled=false
I0611 14:21:11.511185    5373 token.go:230] [discovery] Waiting for the cluster-info ConfigMap to receive a JWS signature for token ID "i973xz"
I0611 14:21:11.717521    5373 token.go:127] [discovery] Requesting info from "dkarakasilis-1069-default-kairos-test.k8s.clastix.cloud:443" again to validate TLS against the pinned public key
I0611 14:21:11.718107    5373 token.go:230] [discovery] Waiting for the cluster-info ConfigMap to receive a JWS signature for token ID "i973xz"
I0611 14:21:11.933456    5373 token.go:150] [discovery] Cluster info signature and contents are valid and TLS certificate validates against pinned roots, will use API Server "dkarakasilis-1069-default-kairos-test.k8s.clastix.cloud:443"
I0611 14:21:11.933509    5373 discovery.go:53] [discovery] Using provided TLSBootstrapToken as authentication credentials for the join process
I0611 14:21:11.933539    5373 join.go:565] [preflight] Fetching init configuration
I0611 14:21:11.933550    5373 join.go:654] [preflight] Retrieving KubeConfig objects
[preflight] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[preflight] Use 'kubeadm init phase upload-config --config your-config-file' to re-upload it.
I0611 14:21:12.187152    5373 kubeproxy.go:55] attempting to download the KubeProxyConfiguration from ConfigMap "kube-proxy"
I0611 14:21:12.257344    5373 kubelet.go:74] attempting to download the KubeletConfiguration from ConfigMap "kubelet-config"
I0611 14:21:12.327645    5373 initconfiguration.go:115] skip CRI socket detection, fill with the default CRI socket unix:///var/run/containerd/containerd.sock
I0611 14:21:12.327768    5373 interface.go:432] Looking for default routes with IPv4 addresses
I0611 14:21:12.327784    5373 interface.go:437] Default route transits interface "enp1s0"
I0611 14:21:12.327832    5373 interface.go:209] Interface enp1s0 is up
I0611 14:21:12.327855    5373 interface.go:257] Interface "enp1s0" has 2 addresses :[192.168.122.189/24 fe80::5054:ff:fe71:7147/64].
I0611 14:21:12.327865    5373 interface.go:224] Checking addr  192.168.122.189/24.
I0611 14:21:12.327871    5373 interface.go:231] IP found 192.168.122.189
I0611 14:21:12.327878    5373 interface.go:263] Found valid IPv4 address 192.168.122.189 for interface "enp1s0".
I0611 14:21:12.327884    5373 interface.go:443] Found active IP 192.168.122.189
I0611 14:21:12.327895    5373 kubelet.go:196] the value of KubeletConfiguration.cgroupDriver is empty; setting it to "systemd"
this version of kubeadm only supports deploying clusters with the control plane version >= 1.32.0. Current version: v1.31.1
k8s.io/kubernetes/cmd/kubeadm/app/util/config.NormalizeKubernetesVersion
	k8s.io/kubernetes/cmd/kubeadm/app/util/config/common.go:155
k8s.io/kubernetes/cmd/kubeadm/app/util/config.SetClusterDynamicDefaults
	k8s.io/kubernetes/cmd/kubeadm/app/util/config/initconfiguration.go:176
k8s.io/kubernetes/cmd/kubeadm/app/util/config.SetInitDynamicDefaults
	k8s.io/kubernetes/cmd/kubeadm/app/util/config/initconfiguration.go:71
k8s.io/kubernetes/cmd/kubeadm/app/util/config.FetchInitConfigurationFromCluster
	k8s.io/kubernetes/cmd/kubeadm/app/util/config/cluster.go:73
k8s.io/kubernetes/cmd/kubeadm/app/cmd.fetchInitConfiguration
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/join.go:685
k8s.io/kubernetes/cmd/kubeadm/app/cmd.fetchInitConfigurationFromJoinConfiguration
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/join.go:662
k8s.io/kubernetes/cmd/kubeadm/app/cmd.(*joinData).InitCfg
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/join.go:574
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/join.runPreflight
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/join/preflight.go:102
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).Run.func1
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow/runner.go:261
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).visitAll
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow/runner.go:450
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).Run
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow/runner.go:234
k8s.io/kubernetes/cmd/kubeadm/app/cmd.newCmdJoin.func1
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/join.go:185
github.com/spf13/cobra.(*Command).execute
	github.com/spf13/cobra@v1.8.1/command.go:985
github.com/spf13/cobra.(*Command).ExecuteC
	github.com/spf13/cobra@v1.8.1/command.go:1117
github.com/spf13/cobra.(*Command).Execute
	github.com/spf13/cobra@v1.8.1/command.go:1041
k8s.io/kubernetes/cmd/kubeadm/app.Run
	k8s.io/kubernetes/cmd/kubeadm/app/kubeadm.go:47
main.main
	k8s.io/kubernetes/cmd/kubeadm/kubeadm.go:25
runtime.main
	runtime/proc.go:283
runtime.goexit
	runtime/asm_amd64.s:1700
unable to fetch the kubeadm-config ConfigMap
k8s.io/kubernetes/cmd/kubeadm/app/cmd.fetchInitConfiguration
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/join.go:687
k8s.io/kubernetes/cmd/kubeadm/app/cmd.fetchInitConfigurationFromJoinConfiguration
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/join.go:662
k8s.io/kubernetes/cmd/kubeadm/app/cmd.(*joinData).InitCfg
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/join.go:574
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/join.runPreflight
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/join/preflight.go:102
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).Run.func1
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow/runner.go:261
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).visitAll
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow/runner.go:450
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).Run
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow/runner.go:234
k8s.io/kubernetes/cmd/kubeadm/app/cmd.newCmdJoin.func1
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/join.go:185
github.com/spf13/cobra.(*Command).execute
	github.com/spf13/cobra@v1.8.1/command.go:985
github.com/spf13/cobra.(*Command).ExecuteC
	github.com/spf13/cobra@v1.8.1/command.go:1117
github.com/spf13/cobra.(*Command).Execute
	github.com/spf13/cobra@v1.8.1/command.go:1041
k8s.io/kubernetes/cmd/kubeadm/app.Run
	k8s.io/kubernetes/cmd/kubeadm/app/kubeadm.go:47
main.main
	k8s.io/kubernetes/cmd/kubeadm/kubeadm.go:25
runtime.main
	runtime/proc.go:283
runtime.goexit
	runtime/asm_amd64.s:1700
error execution phase preflight
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).Run.func1
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow/runner.go:262
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).visitAll
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow/runner.go:450
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).Run
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow/runner.go:234
k8s.io/kubernetes/cmd/kubeadm/app/cmd.newCmdJoin.func1
	k8s.io/kubernetes/cmd/kubeadm/app/cmd/join.go:185
github.com/spf13/cobra.(*Command).execute
	github.com/spf13/cobra@v1.8.1/command.go:985
github.com/spf13/cobra.(*Command).ExecuteC
	github.com/spf13/cobra@v1.8.1/command.go:1117
github.com/spf13/cobra.(*Command).Execute
	github.com/spf13/cobra@v1.8.1/command.go:1041
k8s.io/kubernetes/cmd/kubeadm/app.Run
	k8s.io/kubernetes/cmd/kubeadm/app/kubeadm.go:47
main.main
	k8s.io/kubernetes/cmd/kubeadm/kubeadm.go:25
runtime.main
	runtime/proc.go:283
runtime.goexit
	runtime/asm_amd64.s:1700
debug2: channel 0: window 996014 sent adjust 52562
```