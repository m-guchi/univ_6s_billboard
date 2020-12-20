require "erb"

class HttpStatusCode

    def initialize(code)
        @status_code = code
        @status_list = {
            200 => "OK",
            204 => "No Content",
            301 => "Moved Permanently",
            302 => "Found",
            400 => "Bad Request",
            401 => "Unauthorized",
            403 => "Forbidden",
            404 => "Not Found",
            405 => "Method Not Allowed",
            500 => "Internal Server Error",
            501 => "Not Implemented",
        }
        include_status_code
    end

    def include_status_code()
        unless @status_list.include?(@status_code)
            @status_code = 500
        end
    end
    private:include_status_code

    def is_success()
        success_status_list = [200,204]
        return success_status_list.include?(@status_code)
    end

    def status_code()
        return @status_code.to_s
    end

    def status_text()
        return @status_list[@status_code]
    end

    def format_status_code()
        return status_code + " " + status_text
    end

    def change_header()
        header = "Content-Type: text/html; charset=utf-8"
        if @status_code == 405
            header += "\nAllow: GET, HEAD, POST"
        end
        return header
    end

    def change_body()
        body = ""
        error_page_list = {
            400 => "リクエストされた内容をサーバーは理解できませんでした。<br>ブラウザのキャッシュやCookieを削除すると解消される可能性があります。",
            401 => "認証に失敗しました。<br>正しいユーザー情報でログインする必要があります。",
            403 => "指定されたURLにアクセスする権限がありません。",
            404 => "指定されたページが見つかりません。<br>URLに誤りがあるか、指定されたページは移動もしくは削除された可能性があります。",
            405 => "リクエストされたメソッドをサーバーは処理することができません。",
            500 => "サーバーエラーが発生しました。<br>サーバーの問題でページを表示することができません。<br>再度時間をおいてアクセスしてください。",
            501 => "リクエストされたメソッドをサーバーは認識することができません。",
        }
        if error_page_list.has_key?(@status_code)
            error_html = ERB.new(File.read(__dir__ + "/../templetes/error.html.erb"))
            @status_text = status_text
            @error_text = error_page_list[@status_code]
            body = error_html.result(binding)
        end
        unless body
            body = "サーバーエラーが発生しました。<br>サーバーの問題でお探しのページを表示できません。<br>再度時間をおいてアクセスしてください。"
        end
        return body
    end
end