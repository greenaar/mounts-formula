# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mounts with context %}

{%- for name, opts in mounts.mounted.items() %}

  {%- if opts.get('format') %}
# Uses a small wrapper script instead of the `blockdev.formatted` state:
# older Salt releases would hang waiting for interactive input from mkfs
# if the device turned out to already have a filesystem on it
# (https://github.com/saltstack/salt/issues/31033). If you're on a recent
# enough Salt version this may no longer be necessary -- see the README.
mounts-format-{{ name }}:
  cmd.script:
    - name: salt://mounts/files/safe-format
    - args: {{ opts.get('device') }}
    - stateful: True
    - require_in:
      - mount: mounts-mount-{{ name }}
  {%- endif %}

mounts-mount-{{ name }}:
  mount.mounted:
    - name: {{ opts.get('name') }}
    - device: {{ opts.get('device') }}
    - fstype: {{ opts.get('fstype', 'ext4') }}
    - mkmnt: {{ opts.get('mkmnt', False) }}
    - opts: {{ opts.get('opts', 'defaults') | json }}
    - hidden_opts: {{ opts.get('hidden_opts', None) | json }}
    - dump: {{ opts.get('dump', '0') }}
    - pass_num: {{ opts.get('pass_num', '0') }}
    - config: {{ opts.get('config', '/etc/fstab') }}
    - persist: {{ opts.get('persist', True) }}
    - mount: {{ opts.get('mount', True) }}
    - user: {{ opts.get('user', 'root') }}
    - match_on: {{ opts.get('match_on', 'auto') }}
    - order: 1
{%- endfor %}

{%- for name, opts in mounts.unmounted.items() %}
mounts-unmounted-{{ name }}:
  mount.unmounted:
    - name: {{ opts.get('name') }}
    - device: {{ opts.get('device') }}
    - config: {{ opts.get('config', '/etc/fstab') }}
    - persist: {{ opts.get('persist', False) }}
    - user: {{ opts.get('user', 'root') }}
{%- endfor %}
