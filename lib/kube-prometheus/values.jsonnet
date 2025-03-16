local kp =
  (import 'kube-prometheus/main.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: 'mon',
      },
      grafana+: {
        dashboards: {},
        config: {
          sections: {
            date_formats: { default_timezone: 'UTC' },
          },  // sections
        },  // config
      },  // grafana
    },  // values

    prometheus+: {
      prometheus+: {
        spec+: {
          replicas: 1,
          resources: {
            requests: { cpu: '250m', memory: '400Mi' },
            limits: { cpu: '500m', memory: '1Gi' },
          },  // resources
        },  // spec
      },  // prometheus
    },  // prometheus

    grafana+:: {
      service+: {
        spec+: {
          type: 'ClusterIP',  // Default, explicit.
        },  // spec
      },  // service
    },  // grafana
  };

{ 'setup/0-namespace-namespace': kp.kubePrometheus.namespace } +
{
  ['setup/1-prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor' && name != 'prometheusRule'), std.objectFields(kp.prometheusOperator))
} +
{ 'setup/1-prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
{ 'setup/1-prometheus-operator-prometheusRule': kp.prometheusOperator.prometheusRule } +
// { ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['0-prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['1-kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ '2-kubernetes-serviceMonitorKubelet': kp.kubernetesControlPlane.serviceMonitorKubelet } +
{ ['3-grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) }
