local M = {}

M.is_mason_package_installed = function(package_name)
  local present, mason_registry = pcall(require, "mason-registry")
  if not present then
    return false
  end

  return mason_registry.is_installed(package_name)
end

return M
