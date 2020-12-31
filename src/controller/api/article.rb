require 'json'
require "./src/controller.base"
require "./data/model/article"

class Article < ControllerBase
    def initialize(method, message_body)
        super
        @@valid_method_list.append("POST")
        @@model = ModelArticle.new()
        if valid_method?
            if method == "POST"
                post()
            elsif method =="GET" || method =="HEAD"
                get()
            end
        end
    end

    def header_hash
        set_mime_type(".json")
        set_method_allow()
        return @@header_hash
    end

    def body
        return JSON.generate(@body)
    end

    def get
        @body = {
            "ok"=>true,
            "data"=>@@model.fetch_all
        }
    end

    def post
        unless @@message_body.include?("name")
            @body = {
                "ok"=>false,
                "error"=>'Invalid parameter :name'
            }
            return 0
        end
        unless @@message_body.include?("article")
            @body = {
                "ok"=>false,
                "error"=>'Invalid parameter :article'
            }
            return 0
        end
        @@model.post(@@message_body["name"], @@message_body["article"])
        @body = {
            "ok"=>true,
            "data"=>@@model.fetch_last
        }
    end
end