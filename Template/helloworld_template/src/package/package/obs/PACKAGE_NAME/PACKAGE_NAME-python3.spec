#
# spec file for package <PACKAGE_NAME>
#
# Copyright (c) 2020 SUSE LLC
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


%{?!python_module:%define python_module() python-%{**} python3-%{**}}
Name:           
Version:        
Release:        0
Summary:        
License:        
Group:          Development/Languages/Python
Url:            
Source0:        

%define use_python python3
%define skip_python2 1
%{?!python_module:%define python_module() python-%{**} python3-%{**}}

BuildRequires:  %{python_module devel}
BuildRequires:  %{python_module setuptools}
BuildRequires:  python-rpm-macros
Requires:       %{use_python}-argcomplete
Requires:       %{use_python}-argparse-manpage
Requires:       %{use_python}-six

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
#BuildArch:      noarch
%python_subpackages

%description


%prep
%setup -q

%build
# Remove export CFLAGS=... for noarch packages (unneeded)
export CFLAGS="%{optflags}"
%python_build

%install
%python_install

%check
%python_expand $python setup.py test

%files %{python_files}
%defattr(-,root,root)
%doc
# For noarch packages: sitelib
%{python_sitelib}/*
# For arch-specific packages: sitearch
%{python_sitearch}/*

%changelog
