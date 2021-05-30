ARG OPF_CI_BASE=quay.io/fedora/fedora:34-x86_64

FROM ${OPF_CI_BASE} as stage1

    # We're installing from sources, which results in a lot of cached code
    # we don't need in the final image. We use a multistage build so that
    # we can copy over the binaries in a subsequent stage and discard the
    # sources.

    ARG GOLANGCI_LINT_VERSION=1.40.1
    ARG REVIVE_VERSION=v1.0.6
    ARG STATICCHECK_VERSION=2020.2.4
    ARG INEFFASSIGN_VERSION=2e10b26
    ARG ERRCHECK_VERSION=v1.6.0
    ARG GHCLI_VERSION=1.10.3

    ENV GOPATH=/build \
        PATH=/build/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

    WORKDIR /build/src

    RUN dnf -y install \
        golang \
        git

    RUN go install github.com/mgechev/revive@${REVIVE_VERSION}
    RUN go install honnef.co/go/tools/cmd/staticcheck@${STATICCHECK_VERSION}
    RUN go install github.com/gordonklaus/ineffassign@${INEFFASSIGN_VERSION}
    RUN go install github.com/kisielk/errcheck@${ERRCHECK_VERSION}

    RUN curl -L -o /tmp/golangci-lint.tar.gz \
        https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64.tar.gz
    RUN tar -C /tmp -xv --strip-components=1 -f /tmp/golangci-lint.tar.gz && \
        cp /tmp/golangci-lint /build/bin/

    RUN curl -L -o /tmp/ghcli.tar.gz https://github.com/cli/cli/releases/download/v${GHCLI_VERSION}/gh_${GHCLI_VERSION}_linux_amd64.tar.gz
    RUN tar -C /tmp -xv --strip-components=1 -f /tmp/ghcli.tar.gz && \
    	cp /tmp/bin/gh /build/bin/

FROM quay.io/fedora/fedora:34-x86_64

    # In this stage, we copy over the binaries produced in stage1 and
    # then install pre-commit.

    ENV SUMMARY="Operate First toolchain for running pre-commit hooks." \
        DESCRIPTION="Operate First toolchain for running pre-commit hooks." \
        PATH=/build/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

    LABEL summary="$SUMMARY" \
        description="$DESCRIPTION" \
        io.k8s.description="$DESCRIPTION" \
        io.k8s.display-name="Operate First Pre-Commit Toolchain" \
        io.openshift.tags="operate-first,pre-commit" \
        name="operate-first/opf-pre-commit:fedora34"

    COPY --from=stage1 /build/bin /build/bin

    RUN dnf -y install \
        python3 \
        python3-pip \
        golang \
        git \
        && \
        dnf clean all

    WORKDIR /build/src

    COPY requirements.txt /tmp/requirements.txt
    RUN python3 -m venv /build

    RUN . /build/bin/activate && \
        pip3 install -U pip && \
        pip3 install -r /tmp/requirements.txt
