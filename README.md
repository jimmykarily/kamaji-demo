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
