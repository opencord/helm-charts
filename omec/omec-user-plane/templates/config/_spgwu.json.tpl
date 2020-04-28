{
  "ue_cidr": {{ .Values.networks.ue.subnet | quote }},
  "enb_cidr": {{ .Values.networks.enb.subnet | quote }},
  "s1u": {
    "ifname": {{ .Values.config.spgwu.s1u.device | quote }}
  },
  "sgi": {
    "ifname": {{ .Values.config.spgwu.sgi.device | quote }}
  },
  "workers": {{ .Values.config.spgwu.workers }},
  "max_sessions": {{ .Values.config.spgwu.maxSessions }}
}
