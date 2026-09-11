{{/*
Persistent storage helpers. Each component template keeps its own PersistentVolume and
PersistentVolumeClaim objects (name, labels) and uses these helpers for the spec.

  cloudProvider aws
    AWS_ElasticBlockStore_volumeID set  -> static PV on that EBS volume, PVC bound to it
    volumeID empty                      -> dynamic PVC (storageClassName, size)
  cloudProvider k3s
    staticHostPath true                 -> static hostPath PV (localVolumeHostPath), PVC bound to it
    staticHostPath false                -> dynamic PVC on local-path (localVolumeSize)

All helpers take (dict "root" . "values" .Values.<component> "name" "<pv/pvc name>").
*/}}

{{/* "true" when the component needs a static PersistentVolume, empty otherwise. */}}
{{- define "osm-seed.pv.static" -}}
{{- $p := .values.persistenceDisk -}}
{{- $cp := .root.Values.cloudProvider -}}
{{- if or (and (eq $cp "k3s") $p.staticHostPath) (and (eq $cp "aws") $p.AWS_ElasticBlockStore_volumeID) }}true{{- end -}}
{{- end -}}

{{/* spec of the static PersistentVolume. */}}
{{- define "osm-seed.pv.spec" -}}
{{- $p := .values.persistenceDisk -}}
storageClassName: ""
accessModes:
  - ReadWriteOnce
{{- if eq .root.Values.cloudProvider "aws" }}
capacity:
  storage: {{ $p.AWS_ElasticBlockStore_size }}
awsElasticBlockStore:
  volumeID: {{ $p.AWS_ElasticBlockStore_volumeID }}
  fsType: ext4
{{- else }}
persistentVolumeReclaimPolicy: Retain
capacity:
  storage: {{ $p.localVolumeSize }}
hostPath:
  path: {{ $p.localVolumeHostPath | quote }}
  type: DirectoryOrCreate
{{- end }}
{{- end -}}

{{/* spec of the PersistentVolumeClaim, bound to the static PV when there is one. */}}
{{- define "osm-seed.pvc.spec" -}}
{{- $p := .values.persistenceDisk -}}
{{- $k3s := eq .root.Values.cloudProvider "k3s" -}}
{{- $static := include "osm-seed.pv.static" . -}}
{{- if $static }}
storageClassName: ""
volumeName: {{ .name }}
{{- else if $k3s }}
storageClassName: local-path
{{- else if $p.storageClassName }}
storageClassName: {{ $p.storageClassName | quote }}
{{- end }}
accessModes:
  - ReadWriteOnce
resources:
  requests:
    {{- if $k3s }}
    storage: {{ $p.localVolumeSize }}
    {{- else if $static }}
    storage: {{ $p.AWS_ElasticBlockStore_size }}
    {{- else }}
    storage: {{ $p.size }}
    {{- end }}
{{- end -}}
