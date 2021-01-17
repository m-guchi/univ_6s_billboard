require "./src/controller.base"
require "./data/model/article"

class Teapot < ControllerBase
    def initialize(method, param, message_body)
        super
        @status_code = 418
        # @body = 
    end
end