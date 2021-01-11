require "erb"

class HttpStatusCode

    def initialize(code)
        @status_code = code
        @status_list = {
            200 => "OK",
            204 => "No Content",
            301 => "Moved Permanently",
            302 => "Found",
            303 => "See Other",
            400 => "Bad Request",
            401 => "Unauthorized",
            403 => "Forbidden",
            404 => "Not Found",
            405 => "Method Not Allowed",
            411 => "Length Required",
            500 => "Internal Server Error",
            501 => "Not Implemented",
            505 => "HTTP Version Not Supported",
        }
        set_status_code_expect_list()
    end

    def set_status_code_expect_list()
        unless @status_list.include?(@status_code)
            @status_code = 500
        end
    end
    private:set_status_code_expect_list

    def success?()
        return 200 <= @status_code && @status_code < 300
    end

    def error?()
        return 400 <= @status_code
    end

    def status_code()
        return @status_code
    end

    def status_text()
        return @status_list[@status_code]
    end

    def format_status_code()
        return status_code().to_s + " " + status_text()
    end

    def error_page_header_hash()
        header_list = Hash.new()
        header_list.store("Content-Type","text/html; charset=UTF-8")
        return header_list
    end

    def error_page_body()
        body = nil
        error_page_list = {
            400 => "サーバーはリクエストされた内容を理解できませんでした。<br>ブラウザのキャッシュやCookieを削除すると解消される可能性があります。",
            401 => "認証に失敗しました。<br>正しいユーザー情報でログインする必要があります。",
            403 => "指定されたURLにアクセスする権限がありません。",
            404 => "指定されたページが見つかりません。<br>URLに誤りがあるか、指定されたページは移動もしくは削除された可能性があります。",
            405 => "サーバーはリクエストされたメソッドを処理することができません。",
            411 => "サーバーはヘッダーにContent-Lengthがないためリクエストを拒否しました。",
            500 => "サーバーエラーが発生しました。<br>サーバーの問題でページを表示することができません。<br>再度時間をおいてアクセスしてください。",
            501 => "サーバーはリクエストされたメソッドをサーバーは認識することができません。",
            505 => "サーバーはリクエストされたHTTPプロトコルのバージョンに対応していません。",
        }
        if error_page_list.has_key?(@status_code)
            error_html = ERB.new(File.read(__dir__ + "/../../templetes/error.html.erb"))
            @status_text = status_text()
            @error_text = error_page_list[@status_code]
            body = error_html.result(binding)
        end
        unless body
            body = "サーバーエラーが発生しました。<br>サーバーの問題でお探しのページを表示できません。<br>再度時間をおいてアクセスしてください。"
        end
        return body
    end
end