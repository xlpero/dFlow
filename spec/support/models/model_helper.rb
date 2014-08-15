module ModelHelper

	def json
		@json ||= JSON.parse(response.body)
	end

	def config_init
		Rails.application.config.api_key = "test_key"

		Rails.application.config.process_list = [
		{
			id: 1,
			code: "scan_job",
			manual: true
		},
		{
			id: 2,
			code: "rename_files",
			allowed_processes: 1
		},
		{
			id: 3,
			code: "move_files",
			allowed_processes: 1
		},
		{
			id: 4,
			code: "copy_files",
			allowed_processes: 1
		}
	]
	end
end