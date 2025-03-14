local kp =
  (import 'kube-prometheus/main.libsonnet') +
  // (import 'cadvisor.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: 'mon',
      },
      grafana+: {
        dashboards: {},
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
// { 'setup/pyrra-slo-CustomResourceDefinition': kp.pyrra.crd } +
// serviceMonitor and prometheusRule are separated so that they can be created after the CRDs are ready
{ 'setup/1-prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
{ 'setup/1-prometheus-operator-prometheusRule': kp.prometheusOperator.prometheusRule } +
// { 'kube-prometheus-prometheusRule': kp.kubePrometheus.prometheusRule } +
// { ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
// { ['blackbox-exporter-' + name]: kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter) } +
{ ['3-grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
// { ['pyrra-' + name]: kp.pyrra[name] for name in std.objectFields(kp.pyrra) if name != 'crd' } +
// { ['2-cadvisor-' + name]: kp.cadvisor[name] for name in std.objectFields(kp.cadvisor) } +
{ ['1-kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['2-kubernetes-serviceMonitorKubelet']: kp.kubernetesControlPlane.serviceMonitorKubelet } +
// { ['kubernetes-' + name]: kp.kubernetesControlPlane[name] for name in std.objectFields(kp.kubernetesControlPlane) }
// { ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['0-prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) }
// { ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) }
