{
  values+:: {
    cadvisor+: {
      namespace: $.values.common.namespace,
    },
  },

  local defaults = {
    local defaults = self,

    name:: 'cadvisor',
    namespace:: error 'must provide namespace',
    replicas:: 1,

    commonLabels:: {
      'app.kubernetes.io/name': 'cadvisor',
      'app.kubernetes.io/component': 'exporter',
      'app.kubernetes.io/part-of': 'kube-prometheus',
    },

    resources:: {
      requests: { memory: '400Mi', cpu: '250m' },
      limits: { memory: '2000Mi', cpu: '500m' },
    },
  },

  local cadvisor = function(params) {
    local cadvisor = self,
    _config:: defaults + params,
    // Safety check
    assert std.isObject(cadvisor._config.resources),

    name:: cadvisor._config.name,
    namespace:: cadvisor._config.namespace,
    commonLabels:: cadvisor._config.commonLabels,

    _metadata:: {
      name: cadvisor.name,
      namespace: cadvisor.namespace,
      labels: cadvisor.commonLabels,
    },

    serviceAccount: {
      apiVersion: 'v1',
      kind: 'ServiceAccount',
      metadata: cadvisor._metadata,
      automountServiceAccountToken: true,
    },

    daemonSet: {
      apiVersion: 'apps/v1',
      kind: 'DaemonSet',
      metadata: cadvisor._metadata,
      spec: {
        selector: {
          matchLabels: {
            name: cadvisor.name,
          },
        },
        template: {
          metadata: {
            annotations: {
              'prometheus.io/scrape': 'true',
            },
            labels: {
              name: cadvisor.name,
            },
          },
          spec: {
            serviceAccountName: cadvisor.name,
            containers: [
              {
                name: cadvisor.name,
                image: 'gcr.io/cadvisor/cadvisor:v0.52.1',
                resources: cadvisor._config.resources,
                ports: [
                  {
                    name: 'https-main',
                    containerPort: 8080,
                    protocol: 'TCP',
                  },
                ],
                // cAdvisor runs as root, but only has a single capability
                // "CAP_DAC_READ_SEARCH", which gives it permission to read any
                // file or list any directory.
                securityContext: {
                  capabilities: {
                    add: [
                      'DAC_READ_SEARCH',
                    ],
                    drop: [
                      'all',
                    ],
                  },
                },
                volumeMounts: [
                  {
                    mountPath: '/rootfs',
                    name: 'rootfs',
                    readOnly: true,
                  },
                  {
                    mountPath: '/var/run',
                    name: 'var-run',
                    readOnly: true,
                  },
                  {
                    mountPath: '/sys',
                    name: 'sys',
                    readOnly: true,
                  },
                  {
                    mountPath: '/var/lib/docker',
                    name: 'var-lib-docker',
                    readOnly: true,
                  },
                  {
                    mountPath: '/dev/disk',
                    name: 'dev-disk',
                    readOnly: true,
                  },
                ],
              },
            ],
            tolerations: [
              {
                effect: 'NoSchedule',
                key: 'lame-duck',
                operator: 'Exists',
              },
            ],
            volumes: [
              {
                hostPath: {
                  path: '/',
                },
                name: 'rootfs',
              },
              {
                hostPath: {
                  path: '/var/run',
                },
                name: 'var-run',
              },
              {
                hostPath: {
                  path: '/sys',
                },
                name: 'sys',
              },
              {
                hostPath: {
                  path: '/var/lib/docker',
                },
                name: 'var-lib-docker',
              },
              {
                hostPath: {
                  path: '/dev/disk',
                },
                name: 'dev-disk',
              },
            ],
          },
        },
        updateStrategy: {
          type: 'RollingUpdate',
        },
      },
    },

    service: {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: cadvisor._metadata,
      spec: {
        type: 'ClusterIP',
      },
    },
  },

  cadvisor: cadvisor($.values.cadvisor),
}
