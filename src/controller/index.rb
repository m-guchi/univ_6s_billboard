require "./src/controller.base"

class Index < ControllerBase
    def initialize(method)
        super
        @@valid_method_list.append("POST")
    end

    def header_hash
        set_mime_type(".html")
        set_method_allow()
        return @@header_hash
    end

    def body
        file_path = "./templetes/index.html.erb"
        file_contents = ERB.new(File.read(file_path))
        @csv = CSV.read("./data/text.csv")
        return file_contents.result(binding)
    end
end