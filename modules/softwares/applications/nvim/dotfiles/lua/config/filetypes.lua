if vim.filetype then
	vim.filetype.add({
		filename = {
			["docker-compose.yml"] = "yaml.docker-compose",
			["docker-compose.yaml"] = "yaml.docker-compose",
			["compose.yml"] = "yaml.docker-compose",
			["compose.yaml"] = "yaml.docker-compose",
			["gitlab.yml"] = "yaml.gitlab",
			["gitlab.yaml"] = "yaml.gitlab",
			["helm-values.yaml"] = "yaml.helm-values",
			["helm-values.yml"] = "yaml.helm-values",
		},
		extension = {
			gotmpl = "gotmpl",
		},
	})
end
