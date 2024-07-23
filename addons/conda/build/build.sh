#!/bin/bash
set -e -x

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

pushd gstreamer
mkdir -pm755 build
pushd build

export XDG_DATA_DIRS="${XDG_DATA_DIRS:+${XDG_DATA_DIRS}:}:${PREFIX}/share:${BUILD_PREFIX}/share"
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH:+${PKG_CONFIG_PATH}:}${PREFIX}/lib/pkgconfig:${BUILD_PREFIX}/lib/pkgconfig"

# Build and install GStreamer
export EXTRA_FLAGS="${EXTRA_FLAGS}"

export PKG_CONFIG="$(which pkg-config)"

meson setup ${MESON_ARGS} --wrap-mode=nofallback --force-fallback-for="gl-headers,graphene,json-glib,libgudev,libnice,libsrtp2,orc,webrtc-audio-processing" -Dauto_features=disabled -Dpython=enabled -Dgst-python:libpython-dir="lib" -Dgstreamer:ptp-helper-permissions=none -Dintrospection=enabled -Dorc=enabled -Dwebrtc=enabled -Dgst-plugins-bad:webrtcdsp=enabled -Dtls=enabled -Dgst-plugins-bad:dtls=enabled -Dgst-plugins-good:rtp=enabled -Dgst-plugins-bad:rtp=enabled -Dgst-plugins-good:rtpmanager=enabled -Dgst-plugins-bad:srtp=enabled -Dgst-plugins-bad:sctp=enabled -Dgst-plugins-bad:sdp=enabled -Dlibnice=enabled -Dtools=enabled -Dgpl=enabled -Dbase=enabled -Dlibav=disabled -Dgst-plugins-base:gl=enabled -Dgst-plugins-bad:gl=enabled -Dgst-plugins-base:videoconvertscale=enabled -Dgst-plugins-base:opus=enabled -Dgst-plugins-bad:opus=enabled -Dgst-plugins-good:pulse=enabled -Dgst-plugins-base:alsa=enabled -Dgst-plugins-good:jack=enabled -Dgst-plugins-base:x11=enabled -Dgst-plugins-bad:x11=enabled -Dgst-plugins-base:xshm=enabled -Dgst-plugins-good:ximagesrc=enabled -Dgst-plugins-good:ximagesrc-xshm=enabled -Dgst-plugins-good:ximagesrc-xfixes=enabled -Dgst-plugins-good:ximagesrc-xdamage=enabled -Dgst-plugins-good:ximagesrc-navigation=enabled -Dgst-plugins-bad:qsv=enabled -Dgst-plugins-bad:va=enabled -Dgst-plugins-bad:drm=enabled -Dgst-plugins-bad:udev=enabled -Dgst-plugins-bad:wayland=enabled -Dgst-plugins-bad:nvcodec=enabled -Dgst-plugins-good:v4l2=enabled -Dgst-plugins-bad:v4l2codecs=enabled -Dgst-plugins-bad:openh264=enabled -Dgst-plugins-good:vpx=enabled -Dgst-plugins-ugly:x264=enabled -Dgst-plugins-bad:x265=enabled -Dgst-plugins-bad:aom=enabled -Dgst-plugins-bad:svtav1=enabled -Dgst-plugins-rs:webrtc=enabled -Dgst-plugins-rs:webrtchttp=enabled -Dgst-plugins-rs:rtp=enabled -Dgst-plugins-rs:rav1e=enabled -Dgst-plugins-rs:sodium=disabled -Dqt5=disabled -Dqt6=disabled -Ddoc=disabled -Ddevtools=disabled -Dexamples=disabled -Dgst-examples=disabled -Dnls=disabled -Dtests=disabled ${EXTRA_FLAGS} ..

ninja
ninja install

rm -rf "${PREFIX}/share/gdb"
rm -rf "${PREFIX}/share/gstreamer-1.0/gdb"

popd

rm -rf build

popd

# Install Selkies Python components with dependencies because of python-xlib patch
export PIP_NO_DEPENDENCIES="False"
export PIP_NO_BUILD_ISOLATION="True"
export PIP_NO_INDEX="False"
# C_INCLUDE_PATH is for building evdev
C_INCLUDE_PATH="${CONDA_BUILD_SYSROOT}/usr/include" ${PYTHON} -m pip install -v "${SELKIES_SOURCE}/${PYPI_PACKAGE}-${PACKAGE_VERSION}-py3-none-any.whl"
# Install web interface components
cp -rf "${SELKIES_SOURCE}/gst-web" "${PREFIX}/share/selkies-web"
# Install startup scripts
cp -rf "${SELKIES_BUILD}/selkies-gstreamer-run" "${PREFIX}/bin/selkies-gstreamer-run"
chmod -f +x "${PREFIX}/bin/selkies-gstreamer-run"
ln -snf "${PREFIX}/bin/selkies-gstreamer-run" "${PREFIX}"
cp -rf "${SELKIES_BUILD}/selkies-gstreamer-resize-run" "${PREFIX}/bin/selkies-gstreamer-resize-run"
chmod -f +x "${PREFIX}/bin/selkies-gstreamer-resize-run"
ln -snf "${PREFIX}/bin/selkies-gstreamer-resize-run" "${PREFIX}"
