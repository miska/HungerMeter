#
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.27
#

Name:       harbour-hungermeter

# >> macros
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    Hunger Meter
Version:    4.1.0
Release:    0
Group:      Qt/Qt
License:    GPL-3.0
URL:        http://example.org/
Source0:    HungerMeter-big.png
Source1:    %{name}-%{version}.tar.bz2
Source100:  harbour-hungermeter.yaml
Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires:  pkgconfig(sailfishapp) >= 0.0.10
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

%description
Simple monitor showing current battery consumption. Visible in cover action as
well, so you can peek to see how battery hungry is your phone at it’s current
state even from running applications.

It displays three values - current consumption which is by default last 1s,
average which is by default average for last 10s and long average which is 24
hours. You can configure these time intervals via Settings menu as well as
sampling intervals. Short values are kept only during application runtime, long
average value is kept even between application runs. There is an option to
store these statistics even to permanent storage to keep them available after
reboot.

Hunger meter can help you decide whether changes you did to your device setup
are going to help you get better battery life or not (for example which
applications doesn’t hurt keep running on background and which does). It also
gives you estimate how long will your battery last given your customs and
average consumption.

NOTE: Running this application can also increase a consumption a little. It
periodically takes measurements to average them and displaying graph can take
some more effort as well.

%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

install -D -m 0644 %{S:0} %{buildroot}%{_datadir}/%{name}/icons/about-icon.png
find %{buildroot}%{_datadir} -type f -exec chmod a-x \{\} \;

%files
%defattr(-,root,root,-)
%{_datadir}/harbour-hungermeter/icons/about-icon.png
%{_datadir}/icons/hicolor/86x86/apps/%{name}.png
%{_datadir}/applications/%{name}.desktop
%{_datadir}/%{name}/qml
%{_bindir}
# >> files
# << files
