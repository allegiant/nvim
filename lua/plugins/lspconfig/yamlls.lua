return {
  settings = {
    yaml = {
      schemas = {
        ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.26.5-standalone-strict/all.json"] = "/*.k8s.yaml",
        ["kubernetes"] = "/*.k8s.yaml"
      },
    },
  }
}
