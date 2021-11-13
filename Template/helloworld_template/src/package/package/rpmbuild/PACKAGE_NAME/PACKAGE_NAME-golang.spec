#
# spec file for package <PACKAGE_NAME>
#
# Copyright (c) 2019 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#
# nodebuginfo


%define import_path github.com/<REPO_NAME>/<PACKAGE_NAME>

Name:           <PACKAGE_NAME>
Version:        0.0.1
Release:        0
Summary:        Backup program with deduplication and encryption
License:        Apache-2.0
Group:          Productivity/Archiving/Backup
URL:            https://<PACKAGE_NAME>.io
Source0:        https://github.com/<REPO_NAME>/<PACKAGE_NAME>/releases/download/v%{version}/%{name}-%{version}.tar.gz
# BuildRequires:  go-go-md2man
# BuildRequires:  golang-packaging
# BuildRequires:  golang(API) >= 1.12

%description
<PACKAGE_NAME> is a backup program. It supports verification, encryption,
snapshots and deduplication.

%prep
%setup -q

%build
# Set up GOPATH.
export GOPATH="$GOPATH:${HOME}/go"
mkdir -p ${HOME}/go/src/%{import_path}
cp -rT ${PWD} ${HOME}/go/src/%{import_path}

# Build <PACKAGE_NAME>. We don't use build.go because it builds statically, uses go
# modules, and also restricts the Go version in cases where it's not actually
# necessary. We disable go modules because <PACKAGE_NAME> still provides a vendor/.
GO111MODULE=off go build -o %{name} -buildmode=pie \
	-ldflags "-s -w -X main.version=%{version}" \
	%{import_path}/cmd/<PACKAGE_NAME>

# GO111MODULE=on GOFLAGS=-mod=vendor go build -o %%{name} \
# 	-ldflags "-s -w -X main.version=%%{version}" \
# 	%%{import_path}/cmd/<PACKAGE_NAME>

%install
install -D -m0755 %{name} %{buildroot}%{_bindir}/%{name}

%files
%defattr(-,root,root)
%doc *.md
%license LICENSE
%{_bindir}/<PACKAGE_NAME>

%changelog
