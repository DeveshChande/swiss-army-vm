set -eou pipefail

apt -y purge libgfortran5
apt -y autoremove --purge
