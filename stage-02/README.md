# Stage 02: Build a Kairos ISO suitable for Kamaji workers

## 1. Build a Kairos container image

> [!IMPORTANT]
> Run the following commands in the root of this repository.

```bash
docker build -t kairos-kamaji-worker .
```

## 2. Build a Kairos install medium using the Kairos Factory

You have two options to build a Kairos install medium: using the Web UI or using the CLI.

### 2a. Using the Web UI

```bash
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --privileged \
  -v $PWD/build/:/output \
  -p 8080:8080 \
  quay.io/kairos/auroraboot:latest web --create-worker
```

Visit http://localhost:8080 and follow the instructions presented by the host.

### 2b. Using the CLI

```bash
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD/build:/build \
  quay.io/kairos/auroraboot:latest \
    --debug build-iso --output /build  docker://kairos-kamaji-worker
```

## 3. Deploy the Kairos worker

Follow the steps from [Stage 01](/stage-01/README.md) to deploy the Kairos worker using the ISO you just built.
