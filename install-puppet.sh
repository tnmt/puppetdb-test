#!/bin/bash

set -eu
[[ $UID -ne 0 ]] && exec sudo "$BASH_SOURCE"

ensure_version=6.0.0

if ! rpm -q puppet-release; then
    os_release=$(awk '{print gensub(/.+ ([0-9])\.[0-9].+/, "\\1", "")}' /etc/redhat-release)
    rpm --import https://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs
    rpm -ivh "https://yum.puppet.com/puppet/puppet-release-el-${os_release}.noarch.rpm "
fi

if [[ $ensure_version != $(rpm -q --queryformat '%{VERSION}' puppet-agent || true) ]]; then
    yum install -q -y puppet-agent-"$ensure_version"
fi

if ! /opt/puppetlabs/puppet/bin/gem list | grep hiera-eyaml ; then
  /opt/puppetlabs/puppet/bin/gem install hiera-eyaml
fi

rm -f /etc/puppetlabs/puppet/hiera.yaml
