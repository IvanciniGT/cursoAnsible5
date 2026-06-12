# Execution Environment del proyecto.
#
# Construido sobre awx-ee (EE público con ansible-core + ansible-runner) porque
# las bases quay.io/ansible/community-ee-* fueron retiradas (401).
#
# Fijamos ansible-core 2.16: RHEL/Rocky 8 solo tiene los bindings de 'dnf' para
# Python 3.6, y ansible-core >=2.17 dejó de soportar Python 3.6 en el nodo. Con
# 2.16, rocky8 se gestiona con su python del sistema (3.6, con dnf) y ubuntu22
# con su 3.10.
#
# Build (--provenance=false evita un manifest-list con atestación que ansible-navigator
# no resuelve con 'docker image inspect' y daría "image was not found locally"):
#   docker build --provenance=false --sbom=false -t apache-ee:latest -f apache-ee.Dockerfile .
FROM quay.io/ansible/awx-ee:latest

USER root
ENV HOME=/root

# Downgrade de ansible-core al python real donde vive ansible (vía shebang de ansible-playbook).
RUN PYBIN="$(head -1 "$(command -v ansible-playbook)" | sed 's/^#!//; s/ .*//')" && \
    "$PYBIN" -m pip install --no-cache-dir 'ansible-core>=2.16,<2.17'

# Colecciones compatibles con ansible-core 2.16:
#   community.general 11+ requiere >=2.17  -> 10.x
#   ansible.posix 2.x puede requerir core nuevo -> 1.5.x (incluye firewalld)
RUN ansible-galaxy collection install --upgrade --force \
        -p /usr/share/ansible/collections \
        'community.general:>=10.0.0,<11.0.0' \
        'ansible.posix:>=1.5.0,<2.0.0'

USER 1000
