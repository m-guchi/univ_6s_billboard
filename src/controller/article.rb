require "./src/controller.base"
require "./data/model/article"

class Article < ControllerBase
    def initialize(method, param, message_body)
        super
        set_location("/")
        @@status_code = 301
    end
end