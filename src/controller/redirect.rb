require "./src/controller.base"

class Redirect < ControllerBase
    def initialize(method, param, message_body)
        super
        self.location = "/"
        @status_code = 301
    end
end