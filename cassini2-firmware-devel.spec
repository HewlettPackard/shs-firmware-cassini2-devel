Summary: Cassini firmware headers
Name: cassini2-firmware-devel
Version:        0.1
Release:        1%{?dist}
License: MIT
Source: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
Vendor: Hewlett Packard Enterprise
Packager: Hewlett Packard Enterprise
%description
This package contains header files for Cassini firmware

%build

%prep
%setup -q -n %{name}-%{version}

%install
mkdir -p %{buildroot}%{_includedir}
install -D -m 644 lib/casuc/cuc_cxi.h %{buildroot}%{_includedir}/cuc_cxi.h
install -D -m 644 lib/craypldm/pldm_cxi.h %{buildroot}%{_includedir}/pldm_cxi.h

%files
%defattr(-, root, root)
%{_includedir}/*

%clean
rm -rf %{buildroot}

%changelog
