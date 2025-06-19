# Hosted Control Plane (HCP) and Immutable Workers Workshop

This repository is an example on how to create Kairos not and attach them to a Kamaji instance (self hosted of not)

Inspired by:
- https://www.youtube.com/watch?v=LERzvNzQimc
- https://github.com/kairos-io/provider-kubeadm/

Presented in Cloud Native Days workshop (Italy 2025): https://cloudnativedaysitaly.org/agenda/workshop-morning-1

This repository will show you through different stages how to create a Hosted Control Plane (HCP) with Kamaji and immutable workers with Kairos. Each stage is presented in a different directory and contains a README.md file with instructions on how to proceed. They go from very simple to more complex setups.

- [Stage 1](/stage-01): Connect a worker to an existing Kamaji cluster using a pre-built Kairos ISO
- [Stage 2](/stage-02): Build a Kairos ISO suitable for Kamaji workers
- [Stage 3](/stage-03): Build a Kamaji Management Cluster using Kairos
