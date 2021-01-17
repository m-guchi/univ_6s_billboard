require 'json'
require "./src/controller.base"
require "./data/model/thread"

class ApiThread < ControllerBase
    def initialize(method, param, message_body)
        super
        @valid_method_list.append("POST")
        @model = ModelThread.new()
        if valid_method?
            if method == "POST"
                post()
            elsif method =="GET" || method =="HEAD"
                get()
            end
        end
    end

    def header_hash
        self.mime_type = ".json"
        set_method_allow()
        return @header_hash
    end

    def body
        return JSON.generate(@body)
    end

    def get
        unless @param
            @body = {
                "ok"=>true,
                "data"=>@model.fetch_all
            }
            return 0
        end
        if @param.include?("id")
            thread_data = @model.fetch_filter_thread?(@param["id"])
            if thread_data
                @body = {
                    "ok"=>true,
                    "data"=>thread_data
                }
            else
                @body = {
                    "ok"=>false,
                    "error"=>"No match thread data"
                }
            end
            return 0
        end
        @body = {
            "ok"=>true,
            "data"=>@model.fetch_all
        }
    end

    def post
        unless @message_body.include?("name")
            @body = {
                "ok"=>false,
                "error"=>'Invalid parameter :name'
            }
            return 0
        end
        if @model.post(@message_body["name"])
            @body = {
                "ok"=>true,
                "data"=>@model.fetch_last
            }
        else
            @body = {
                "ok"=>false,
                "error"=>'Error insert data'
            }
        end
    end
end