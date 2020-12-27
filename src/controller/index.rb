require "./src/post_article"
require "./src/controller.base"
require "./data/model/article"

class Index < ControllerBase
    def initialize(method, message_body)
        super
        @@valid_method_list.append("POST")
        if valid_method?
            if method == "POST"
                _article = ModelArticle.new()
                _article.post(message_body["name"], message_body["article"])
            end
        end
    end

    def header_hash
        set_mime_type(".html")
        set_method_allow()
        return @@header_hash
    end

    def body
        file_path = "./templetes/index.html.erb"
        file_contents = ERB.new(File.read(file_path))
        @csv = CSV.read("./data/csv/article.csv")
        return file_contents.result(binding)
    end

    def post
        PostArticle.new(@@message_body["name"], @@message_body["article"])
    end
end